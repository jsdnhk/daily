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

module BACKUP_ADMIN
  protected
  def isValidDirPath(dir_path)
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

  def getDateTime(str_date, str_format = "%Y%m%d")
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

class CPBKP
  include BACKUP_ADMIN
  def cpbkp()
    if !isValidDirPath($copy_src_folder)
      puts("the src folder [#{$copy_src_folder}] is not a valid folder path")
      exit(false)
    elsif !isValidDirPath($copy_dest_path)
      puts("the dest folder [#{$copy_dest_path}] is not a valid folder path")
      exit(false)
    end

    puts("copy the files from the folder [#{$copy_src_folder}] to the directory [#{$copy_dest_path}]...")

    if backupPlusCopyFiles()
      puts("all files related are backup and copied successfully!!")
      exit(true)
    else
      puts("the processes are failed with errors?! Please verify and try again.")
      exit(false)
    end
  end

  private
  def backupPlusCopyFiles()
    bool_return = true
    begin
      #initialization
      $copy_src_folder = File.absolute_path("#{$copy_src_folder}")
      $copy_dest_path = File.absolute_path("#{$copy_dest_path}")
      $copy_src_files_pattern = File.join("#{$copy_src_folder}","**","*")
      $copy_src_files = Dir.glob($copy_src_files_pattern).select{|filename| File.file?(filename)}
      $copy_src_files.each do |src_file|
        obj_result = backupPlusCopyOneFile(src_file)
        if obj_result
          $stdout.puts("[#{src_file}] are made to:") if $is_verbose && !src_file.nil?
          $stdout.puts("the backup file: [#{obj_result[0]}]") if $is_verbose && !obj_result[0].nil?
          $stdout.puts("the desc file: [#{obj_result[1]}]") if $is_verbose && !obj_result[1].nil?
        else
          $stdout.puts("the file [#{src_file}] cannot successfully backuped and copied.") if $is_verbose
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
  def backupPlusCopyOneFile(src_file)
    obj_return = nil
    filepath_backuped = nil
    filepath_copied = nil
    begin
      str_date = $t_current.strftime("%Y%m%d")
      str_date = !$backup_date.empty? && $backup_date =~ /^\d{8}$/ ? $backup_date : str_date
      src_filename = File.basename(src_file)
      src_relative_path = src_file.sub(/#{$copy_src_folder}/,'')
      dest_file_absolute_path = File.join($copy_dest_path, src_relative_path)
      dest_backup_absolute_path = File.join(File.dirname(dest_file_absolute_path),"#{src_filename}.#{str_date}")
      backup_num = 0
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
          dest_backup_path = dest_backup_absolute_path + ( backup_num > 0 ? "-#{backup_num.to_s}" : "" )
          backup_num++
          next if File.exists?(dest_backup_path)
          FileUtils.move(dest_file_absolute_path, dest_backup_path, :force => false)
          filepath_backuped = dest_backup_path
        end
        $stdout.puts("the original is moved and the backup file [#{filepath_backuped}] is created.") if $is_verbose
      end
      #then copy
      if File.file?(src_file)
        raise("dest folder cannot be made, the copying action cancelled.") if !isValidDirPath(File.dirname(dest_file_absolute_path))
        #FileUtils.cp(src_file, dest_file_absolute_path, :preserve => true)
        FileUtils.cp(src_file, dest_file_absolute_path, preserve: true)
        if !st_file.nil?
          File.chown(default_uid, default_gid, dest_file_absolute_path)
          File.chmod(default_mode, dest_file_absolute_path)
        end
        filepath_copied = dest_file_absolute_path
        $stdout.puts("the dest file [#{filepath_copied}] is copied from the src file[#{src_file}].") if $is_verbose
      else
        raise("the src file #{src_file} is not existed.")
      end
    rescue
      $stderr.puts "An error occurred when copying [#{src_file}]: #{$!}"
      filepath_backuped = nil
      filepath_copied = nil
    ensure
      if filepath_backuped != nil || filepath_copied != nil
        obj_return = [filepath_backuped, filepath_copied]
      else
        obj_return = nil
      end
    end
    return obj_return
  end
end

class CLR
  include BACKUP_ADMIN

  def initialize(backup_date)
    @date_backup_date = getDateTime(backup_date)
    @str_backup_date = backup_date
  end

  def clr()
    $stdout.puts("clear the files from the folder [#{$copy_src_folder}] with the backup date [#{$backup_date}]...")
    if clearBackupFiles()
      $stdout.puts("all files related are backup and copied successfully!!")
      exit(true)
    else
      $stderr.puts("the clr processes are failed with errors?! Please verify and try again.")
      exit(false)
    end
  end

  private
  def clearBackupFiles()

  end
end

$t_current=Time.now
$is_verbose=true
$action=ARGV[0].to_s
$copy_src_folder=ARGV[1].to_s
$copy_dest_path=ARGV[2].to_s
$backup_date=ARGV[3].to_s

if ARGV.length < 3
  $stderr.puts("the script requires two input parm.")
  $stderr.puts("./backup_admin.rb {{ action }} {{ copy_src_folder }} {{ copy_dest_path }} {{ backup_date }}")
  exit(false)
end

case $action.to_s.downcase!
  when 'cpbkp'
    CPBKP.new.cpbkp()
  when 'clr'
    CLR.new($backup_date).clr()
  when 'hk'
  when 'rc'
  else
    fail("")
end