#!/usr/bin/ruby
#encoding: utf-8
#version: ruby 2.3.1
#
#Perform backup task functions on Linux OS:
#1) copy to destination and backup the overwrited files
#2) clear the backup files on specific day(and also housekeep the backups until)
#3) recover the backup files to original

require 'fileutils'
require 'date'

module BackupAdmin
  DateFormat="%Y%m%d"

  protected
  def is_valid_dir_path?(dir_path)
    bool_return = false
    if Dir.exists?(dir_path)
      bool_return = true
    else
      if File.file?(dir_path)
        bool_return = false
      else
        Dir.mkdir(dir_path, 0755)
        bool_return = true
      end
    end
    return bool_return
  end

  def get_date_time(str_date, str_format = BackupAdmin::DateFormat)
    obj_return = nil
    begin
      t_now = Time.now
      obj_return = DateTime.strptime(str_date, str_format)
      raise 'not match' if obj_return.strftime(str_format).length != t_now.strftime(str_format).length
    rescue
      obj_return = nil
    end
    return obj_return
  end
end

class << $stdout
end

class CPBKP
  include BackupAdmin
  def cpbkp()
    if !is_valid_dir_path?($copy_src_folder)
      puts("the src folder [#{$copy_src_folder}] is not a valid folder path")
      exit(false)
    elsif !is_valid_dir_path?($copy_dest_path)
      puts("the dest folder [#{$copy_dest_path}] is not a valid folder path")
      exit(false)
    end

    puts("copy the files from the folder [#{$copy_src_folder}] to the directory [#{$copy_dest_path}]...")

    if backup_plus_copy_files?()
      puts("all files related are backup and copied successfully!!")
      exit(true)
    else
      puts("the processes are failed with errors?! Please verify and try again.")
      exit(false)
    end
  end

  private
  def backup_plus_copy_files?()
    bool_return = true
    begin
      #initialization
      $copy_src_folder = File.absolute_path("#{$copy_src_folder}")
      $copy_dest_path = File.absolute_path("#{$copy_dest_path}")
      $copy_src_files_pattern = File.join("#{$copy_src_folder}","**","*")
      $copy_src_files = Dir.glob($copy_src_files_pattern).select{|filename| File.file?(filename)}
      $copy_src_files.each do |src_file|
        int_result, obj_result = backup_plus_copy_one_file(src_file)
        case int_result
          when 1
            $stdout.puts("the file [#{src_file}] have already existed and instincted, won't copy.") if $is_verbose
          when 0
            $stdout.puts("[#{src_file}] are made to:") if $is_verbose && !src_file.nil?
            $stdout.puts("the backup file: [#{obj_result[0]}]") if $is_verbose && !obj_result[0].nil?
            $stdout.puts("the desc file: [#{obj_result[1]}]") if $is_verbose && !obj_result[1].nil?
          when -1
            $stdout.puts("the file [#{src_file}] cannot successfully backuped and copied.") if $is_verbose
          else
            raise("Unknown output from [#{src_file}]")
        end
      end
    rescue
      $stderr.puts "An error occurred during the copying process : #{$!}"
      bool_return = false
    ensure
    end
    return bool_return
  end

  private
  def backup_plus_copy_one_file(src_file)
    int_return = nil
    obj_return = nil
    filepath_backuped = nil
    filepath_copied = nil
    begin
      str_date = $t_current.strftime(DateFormat)
      str_date = !$backup_date.empty? && $backup_date =~ /^\d{8}$/ ? $backup_date : str_date
      src_filename = File.basename(src_file)
      src_relative_path = src_file.sub(/#{$copy_src_folder}/,'')
      dest_file_absolute_path = File.join($copy_dest_path, src_relative_path)
      dest_backup_absolute_path = File.join(File.dirname(dest_file_absolute_path),"#{src_filename}.#{str_date}")
      backup_num = 0

      #check the diff., skipped when there are no diff.
      cmd_diff = %x(diff -s #{src_file} #{dest_file_absolute_path})
      if ($?.success?)
        int_return = 1
        raise("the src and dest are the same")
      end
      #backup before copying
      st_file = nil
      default_uid = nil
      default_gid = nil
      default_mode = nil
      if File.file?(dest_file_absolute_path)
        st_file = File.stat(dest_file_absolute_path)
        default_uid = st_file.uid
        default_gid = st_file.gid
        default_mode = st_file.mode
        while filepath_backuped.nil?
          dest_backup_path = dest_backup_absolute_path + ( backup_num > 0 ? ".#{backup_num.to_s}" : "" )
          backup_num = backup_num + 1
          next if File.exist?(dest_backup_path)
          FileUtils.move(dest_file_absolute_path, dest_backup_path, :force => false)
          filepath_backuped = dest_backup_path
        end
        $stdout.puts("the original is moved and the backup file [#{filepath_backuped}] is created.") if $is_verbose
      end
      #then copy
      if File.file?(src_file)
        if !is_valid_dir_path?(File.dirname(dest_file_absolute_path))
          int_return = -1
          raise("dest folder cannot be made, the copying action cancelled.")
        end
        #FileUtils.cp(src_file, dest_file_absolute_path, :preserve => true)
        FileUtils.cp(src_file, dest_file_absolute_path, preserve: true)
        if !st_file.nil?
          File.chown(default_uid, default_gid, dest_file_absolute_path)
          File.chmod(default_mode, dest_file_absolute_path)
        end
        filepath_copied = dest_file_absolute_path
        $stdout.puts("the dest file [#{filepath_copied}] is copied from the src file[#{src_file}].") if $is_verbose
      else
        int_return = -1
        raise("the src file #{src_file} is not existed.")
      end
    rescue
      $stderr.puts "An error occurred when copying [#{src_file}]: #{$!}"
      filepath_backuped = nil
      filepath_copied = nil
      obj_return = nil
    ensure
      if filepath_backuped != nil || filepath_copied != nil
        int_return = 0
        obj_return = [filepath_backuped, filepath_copied]
      end
    end
    return int_return, obj_return
  end
end

class CLR
  include BackupAdmin
end

class HK
  include BackupAdmin

  def initialize(backup_date)
    @date_backup_date = get_date_time(backup_date)
    @str_backup_date = backup_date
  end

  public
  def hk()
    $stdout.puts("clear the files from the folder [#{$copy_src_folder}] to date [#{$backup_date}]...")
    if clear_backup_files?()
      $stdout.puts("all files related are cleared successfully!!")
      exit(true)
    else
      $stderr.puts("the hk processes are failed with errors?! Please verify and try again.")
      exit(false)
    end
  end

  private
  def clear_backup_files?()
    bool_return = true
    begin
      raise("no correct datetime input") unless @date_backup_date

      find_result_src = %x(find #{$copy_dest_path} -type f).split("\n")
      find_result_dest = %x(find #{$copy_dest_path} -type f).split("\n")
      find_result = find_result_src + find_result_dest
      find_result.each do |item|
        findfile_filename = File.basename(item)
        str_date_findfile = findfile_filename.split('.').reverse.inject(nil) do |memo, obj; var|
          var = /^[0-9]{8}/.match(obj)
          if var && !memo
            break var.to_s
          else
            next memo
          end
        end

        t_date_findfile = get_date_time(str_date_findfile, DateFormat)
        next unless t_date_findfile && (@date_backup_date - t_date_findfile >= 0)
        FileUtils.rm_f([item])
        $stdout.puts("the backup file [#{item}] is removed successfully") if $is_verbose
      end
    rescue
      $stderr.puts "An error occurred when copying backup files to [#{@str_backup_date}]: #{$!}"
      bool_return = false
    ensure
    end
    return bool_return
  end
end

$t_current=Time.now
$str_t_current=$t_current.strftime(BackupAdmin::DateFormat)
$is_verbose=true
$action=ARGV[0].to_s.strip.downcase
$copy_src_folder=ARGV[1].to_s.strip
$copy_dest_path=ARGV[2].to_s.strip
$backup_date=ARGV[3].to_s.strip
$action.freeze
$copy_src_folder.freeze
$copy_dest_path.freeze
$backup_date.freeze

if ARGV.length < 3
  $stderr.puts("the script requires at least three input parm.")
  $stderr.puts("./backup_admin.rb {{ action }} {{ copy_src_folder }} {{ copy_dest_path }} {{ backup_date }}")
  exit(false)
end

case $action
  when 'cpbkp'
    CPBKP.new.cpbkp()
  when 'clr'
    CLR.new($backup_date).clr()
  when 'hk'
    HK.new($backup_date).hk()
  when 'rc'
  else
    $stderr.puts("unavailable action type [#{$action}]! please input the arguments values again.")
    exit(false)
end
