#!/usr/bin/ruby
#encoding: utf-8
#version: ruby 2.3.1

require 'yaml'
require 'fileutils'
require 'pp'

module DeepSort
  # inject this method into the Array class to add deep sort functionality to Arrays
  module DeepSortArray
    def deep_sort
      deep_sort_by { |obj| obj }
    end

    def deep_sort!
      deep_sort_by! { |obj| obj }
    end

    def deep_sort_by(&block)
      self.map do |value|
        if value.respond_to? :deep_sort_by
          value.deep_sort_by(&block)
        else
          value
        end
      end.sort_by(&block)
    end

    def deep_sort_by!(&block)
      self.map! do |value|
        if value.respond_to? :deep_sort_by!
          value.deep_sort_by!(&block)
        else
          value
        end
      end.sort_by!(&block)
    end
  end

  # inject this method into the Hash class to add deep sort functionality to Hashes
  module DeepSortHash
    def deep_sort
      deep_sort_by { |obj| obj }
    end

    def deep_sort!
      deep_sort_by! { |obj| obj }
    end

    def deep_sort_by(&block)
      Hash[self.map do |key, value|
        [if key.respond_to? :deep_sort_by
           key.deep_sort_by(&block)
         else
           key
         end,

         if value.respond_to? :deep_sort_by
           value.deep_sort_by(&block)
         else
           value
         end]

      end.sort_by(&block)]
    end

    def deep_sort_by!(&block)
      replace(Hash[self.map do |key, value|
        [if key.respond_to? :deep_sort_by!
           key.deep_sort_by!(&block)
         else
           key
         end,

         if value.respond_to? :deep_sort_by!
           value.deep_sort_by!(&block)
         else
           value
         end]

      end.sort_by(&block)])
    end

    # comparison for hashes is ill-defined. this performs array or string comparison if the normal comparison fails.
    def <=>(other)
      super(other) || to_a <=> other.to_a || to_s <=> other.to_s
    end
  end
end
Array.send(:include, DeepSort::DeepSortArray)
Hash.send(:include, DeepSort::DeepSortHash)


# and if you don't like calling member methods on objects, these two functions do it for you.
# if the object cannot be deep sorted, it will simply return the sorted object or the object itself if sorting isn't available.
def deep_sort(obj)
  if obj.respond_to? :deep_sort
    obj.deep_sort
  elsif obj.respond_to? :sort
    obj.sort
  else
    obj
  end
end

# similar to the deep_sort method, but performs the deep sort in place
def deep_sort!(obj)
  if obj.respond_to? :deep_sort!
    obj.deep_sort!
  elsif obj.respond_to? :sort!
    obj.sort!
  else
    obj
  end
end

def sort_yaml(yaml_file_path)
   obj_yaml = get_yaml_file_content(yaml_file_path)
   if !obj_yaml
     $stderr.puts("cannot get yaml obj from the file [#{yaml_file_path}].")
     exit(false)
   end
   output_filepath = output_yaml_file(yaml_file_path, obj_yaml)
   if !output_filepath
     $stderr.puts("cannot get yaml obj from the file #{yaml_file_path}.")
     exit(false)
   end
   $stdout.puts("the sorted file[#{output_filepath}] is created from the yaml file [#{yaml_file_path}].")
   exit(true)
end

def get_yaml_file_content(yaml_file_path, sort = true)
  obj_yaml_return = nil
  begin
    raise("File not exist [#{yaml_file_path}]") unless yaml_file_path && File.exists?(yaml_file_path)
    File.open(yaml_file_path,'r') do |file|
      content = file.readlines.join("\n")
      obj_yaml_return = YAML.load(content)
      obj_yaml_return.deep_sort! if sort
      pp obj_yaml_return
    end
  rescue Exception => ex
    $stderr.puts("Error in get_yaml_file_content(#{yaml_file_path}): #{ex.message}")
    $stderr.puts("#{ex.backtrace.inspect}")
    obj_yaml_return = nil
  end
  obj_yaml_return
end

def output_yaml_file(yaml_file_path, obj_yaml)
  output_filepath = nil
  begin
    output_filepath = yaml_file_path + '.sorted'
    raise("File not exist [#{yaml_file_path}]") unless yaml_file_path && File.exists?(yaml_file_path)
    File.open(output_filepath,'w') do |file|
      file.write(YAML.dump(obj_yaml))
    end
  rescue Exception => ex
    $stderr.puts("Error in output_yaml_file(#{yaml_file_path},obj_yaml): \n  #{ex.message}")
    $stderr.puts("#{ex.backtrace}")
    output_filepath = nil
  end
  output_filepath
end

if ARGV.length != 1
  $stderr.puts("The script requires one input parm [valid yaml file path] only.")
  exit(false)
end

sort_yaml(ARGV[0])
