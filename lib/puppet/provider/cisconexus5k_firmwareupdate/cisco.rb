require 'puppet/util/network_device'
require "puppet/provider/cisconexus"
require "pry"
require 'fileutils'

Puppet::Type.type(:cisconexus5k_firmwareupdate).provide :cisconexus5k, :parent => Puppet::Provider::Cisconexus do

  desc "Cisco switch/router Interface provider for device configuration."

  mk_resource_methods

  def initialize(device, *args)
    super
  end

  def self.get_current(name)

  end

  def send_command(cmd, options = {})
    transport.session.command(cmd, options) do |dev|
      yield dev if block_given?
    end
  end

  def run(url, force, copy_to_http=nil, path=nil)
    Puppet.debug("cisconexus5k Puppet::Cisco_Nexus_firmwareUpdate*********************")
    if copy_to_http
      move_to_http(copy_to_http,path)
    end

    responsetxt ="firmware update failed"
    filename = url.split("\/").last
    flashfilepath= "bootflash:"+filename
    versionout=''
    send_command("show version") do |out|
      versionout << out
    end
    versionmatch = versionout.match(/^NXOS\s+Version:\s+(\S+)$|NXOS: version\s+(.*?)$/m)
    installedversion = versionmatch[2]
    Puppet.debug("*** Cisco Version*********")
    Puppet.debug(installedversion)

    Puppet.debug("*** Deleting unused Binaries, if any. *********")
    delete_unused_binaries

    compact_supported = supports_compact(installedversion)

    if(!space_available_to_copy(path) && compact_supported)
      Puppet.debug("*************************************************")
      Puppet.debug("Compacting Installed Cisco Switch firmware binary")
      Puppet.debug("*************************************************")
      installed_image_file_details = ""
      out =  send_command("show version | grep image")
      installed_image_file_details << out.scan(/NXOS.+bin/i)[0]
      Puppet.debug("Installed Image File Details = "+installed_image_file_details)
      installed_image_file_name = installed_image_file_details.split("\/").last
      compact_out = ''
      send_command("install all nxos "+ installed_image_file_name +" compact") do |out|
        compact_out << out
      end
      Puppet.debug("*** Installed Image File Compacted ***")
    end

    Puppet.debug("Flash file path ::" + flashfilepath)
    copysuccessful = copy_binary_to_switch(url,filename)
    unless copysuccessful
      err = "Unable to copy the file to the switch. Copy failed"
      Puppet.debug(err)
      raise err
    end

    Puppet.debug("Copy startup config")
    send_command("copy running-config startup-config" , :prompt => /Copy complete|fail/)

    Puppet.debug("**************************************")
    Puppet.debug("Upgrading Cisco Switch firmware")
    Puppet.debug("**************************************")

    installout = ''
    command = "install all nxos "+ flashfilepath + " non-interruptive"
    send_command(command) do |out|
      installout << out
    end

    unless installout.scan("Use compact image").empty?
      Puppet.debug("System will compact the image before installing")
      compact_binary flashfilepath
      installout = ''
      command = "install all nxos "+ flashfilepath + " non-interruptive"
      send_command(command) do |out|
        installout << out
      end
    end

    unless installout.scan("Finishing the upgrade").empty?
      responsetxt ="firmware update is successfull"
      Puppet.debug("Waiting for switch to reboot")
      sleep 180
    end
    return responsetxt
  end

  def compact_binary(filepath)
    compactresponse = ''
    send_command("install all nxos "+ filepath +" compact") do |out|
      compactresponse << out
    end
  end

  def copy_binary_to_switch(url,filename)
    copysuccess=false
    Puppet.debug("Check if file already exists")
    Puppet.debug(url)
    readdir=''
    send_command("dir bootflash:") do |out|
      readdir<<out
    end
    filenamefound = readdir.scan(filename)
    if filenamefound[0]==filename
      Puppet.debug("File already exists, checking image version")
      deleteout = ''
      send_command("delete bootflash:"+filename+" no-prompt") do |out|
        deleteout << out
      end
      unless deleteout.scan("not allowed").empty?
        err = "Unable to update firmware as image file provided already exists and is the current bootable image"
        Puppet.debug("*********"+err+"*********")
        raise err
      end
    end
    Puppet.debug("Starting to copy the file to bootflash drive of switch")
    copysuccess=false
    send_command("copy #{url} bootflash: vrf management", :prompt => /Copy complete|File not found/)
    existreaddir=''
    send_command("dir bootflash:", :prompt => /#{filename}/) do |out|
      existreaddir<<out
    end
    filefound = existreaddir.scan(filename)
    Puppet.debug("******  File found ******")
    Puppet.debug(filefound)

    if filefound[0]==filename
      copysuccess=true
      Puppet.debug("Successfully copied the file")
    end
    return copysuccess
  end

  def move_to_http(copy_to_http, path)
    Puppet.debug("Path::"+path)
    Puppet.debug("Copying files to HTTP share")
    http_share = copy_to_http[0]
    http_path = copy_to_http[1]

    full_http_path = http_share + "/" + http_path
    Puppet.debug("full_http_path  --> "+full_http_path)
    http_dir = full_http_path.split('/')[0..-2].join('/')
    Puppet.debug("http_dir --> "+http_dir)
    if !File.exist? http_dir
      FileUtils.mkdir_p http_dir
    end
    if !File.exist? full_http_path
      FileUtils.cp path, full_http_path
    end
    FileUtils.chmod_R 0755, http_dir
  end

  def delete_unused_binaries
    out =  send_command("dir bootflash: | grep nxos")
    bin_file_arr =  out.scan(/nxos\S+bin/)
    bin_file_arr.each do |bin_file|
      send_command("delete bootflash:"+bin_file+" no-prompt")
    end
  end

  # File compact is attempted only when the free space is less than the size of the
  # image file to be copied. Compact is supported only on version nxos.7.0.3.I3.1.bin
  # or greater than nxos.7.0.3.I3.1.bin and on 31xx series switches.
  def supports_compact(installedversion)
    Puppet.debug("*** In supports_compact?(). installedversion - %s " %[installedversion])
    compact_supported = false
    out = send_command("show version | grep Chassis")
    cisco_switch_details = ""
    return false unless !out.scan(/cisco.+Chassis/i).empty?
    cisco_switch_details << out.scan(/cisco.+Chassis/i).first
    Puppet.debug(cisco_switch_details)
    cisco_switch_series = cisco_switch_details.split(" ")[2]
    Puppet.debug(cisco_switch_series)
    if (cisco_switch_series =~ /31\d+./i)
      min_version_supporting_compact = "7.0(3)I3(1)"
      installed_version_num = installedversion.gsub(/[^\d]/, '')
      Puppet.debug("Installed version number= %s " % [installed_version_num])
      min_version_supporting_compact_num = min_version_supporting_compact.gsub(/[^\d]/, '')
      if(installed_version_num.to_i >= min_version_supporting_compact_num.to_i)
        Puppet.debug("Installed version supports Compacting...")
        compact_supported = true
      end
    end
    compact_supported
  end

  def space_available_to_copy(path)
    space_available = false
    Puppet.debug("*** In space_available_to_copy?(). File - %s " %[path])
    file_size = File.size(path)
    Puppet.debug(file_size)
    free_space_details = ""
    out = send_command("dir bootflash: | grep free")
    free_space_details << out.scan(/\d+\s+bytes free/i).first
    free_space = free_space_details.split(" ").first
    Puppet.debug("Space available on the switch= %s " %[free_space])
    if(free_space.to_i > file_size)
      space_available = true
    end
    space_available
  end

  def flush
    Puppet.debug("in firmwareupdate flush method")
    super
  end
end
