#!/usr/bin/ruby

#To get grouped inv list from a puppet master

CA_PATH = "/etc/puppetlabs/puppet/ssl/ca/signed/"
PEM_FILE_EXT = ".pem"
CMD_LIST_CA_FILE = "ls -1 *#{PEM_FILE_EXT}"
OUTPUT_FILE = "./puppet_inv_list"
@OUTPUT_FILE = ""

def output_puppet_inv_list?(output_file)
  bln_return = true
  arr_content = nil
  arr_prd, arr_nonprd, arr_others = [], [], []
  begin
    Dir.chdir(CA_PATH)
    str_list_ca_files = `#{CMD_LIST_CA_FILE}`
    raise("cannot find any ca files") if $? != 0
    str_list_ca_files.each_line do |line; str_host|
      next unless line and line.strip.end_with?(PEM_FILE_EXT)
      str_host = line.strip.chomp(PEM_FILE_EXT)
      case str_host
        when /[\w\d]+lp[\w\d\.]+/, /[\w\d]+pd[\w\d\.]+/
          arr_prd.concat([str_host])
        when /[\w\d]+ln[\w\d\.]+/, /[\w\d]+dv[\w\d\.]+/
          arr_nonprd.concat([str_host])
        else
          arr_others.concat([str_host])
      end
    end
    if arr_prd.length > 0 || arr_nonprd.length > 0 || arr_others.length > 0
      arr_content = []
      arr_content.concat(["#Puppet inv. list (Ansible inventory file)"])
      arr_content.concat(["","[prd]"]).concat(arr_prd) if arr_prd.length > 0
      arr_content.concat(["","[nonprd]"]).concat(arr_nonprd) if arr_nonprd.length > 0
      arr_content.concat(["","[others]"]).concat(arr_others) if arr_prd.length > 0
    end
  rescue Exception => ex
    bln_return = false
    $stderr.write("Error in output_puppet_inv_list?(#{output_file}):\n  #{ex.message}\n  #{ex.backtrace}")
  ensure
    if arr_content and output_file and bln_return
      File.write(output_file, arr_content.join("\n"))
      $stdout.write("The output puppet inv list[#{output_file}] is created.\n")
    end
  end
  bln_return
end

@OUTPUT_FILE = ARGV.length >= 1 ? File.absolute_path(ARGV[0]) : File.absolute_path(OUTPUT_FILE)
output_puppet_inv_list?(@OUTPUT_FILE) ? exit(true) : exit(false)
