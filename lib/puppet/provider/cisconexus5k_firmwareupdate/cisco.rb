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

  def run(url, force, copy_to_tftp=nil, path=nil)
    Puppet.debug("cisconexus5k Puppet::Cisco_Nexus_firmwareUpdate*********************")
    if copy_to_tftp
      move_to_tftp(copy_to_tftp,path)
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

    Puppet.debug("Flash file path ::" + flashfilepath)
    copysuccessful = copy_binary_to_switch(url,filename)
    unless copysuccessful
      err = "Unable to copy the file to the switch. Copy failed"
      Puppet.debug(err)
      raise err
    end

    if(!copy_startup_config())
      err = "Unable to update firmware version as copy startup config failed"
      Puppet.debug("*********"+err+"*********")
      raise err
    end
    if is_upgradable(flashfilepath)
      Puppet.debug("**************************************")
      Puppet.debug("Upgrading Cisco Switch firmware")
      Puppet.debug("**************************************")
      confirminstall=false
      out = send_command("install all nxos "+ flashfilepath +"  non-interruptive")
      responsetxt ="firmware update is successfull"
    else
      err = "Unable to update firmware as the version matches the current installed version"
      Puppet.debug("*********"+err+"*********")
      raise err
    end

    return responsetxt
  end

  def is_upgradable(filepath)
    successresponse=''
    send_command("show install all impact nxos "+ filepath) do |out|
      failresponse = out.scan('Pre-upgrade check failed')
      unless failresponse.empty?
        return false
      end
      successresponse << out
    end
    versionimpact = successresponse.match(/^nxos:\s+(\S+)$|nxos \s+(.*?)$/m)
    Puppet.debug("************Version Comparision************")
    Puppet.debug(versionimpact)
    Puppet.debug("*************************")
    unless versionimpact[0].scan("yes").empty?
      return true
    end
    return false
  end

  def copy_binary_to_switch(url,filename)
    copysuccess=false
    Puppet.debug("Check if file already exists")
    readdir=''
    send_command("dir bootflash:") do |out|
      readdir<<out
    end
    filenamefound = readdir.scan(filename)
    Puppet.debug("**********filenamefound**********")

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

  def copy_startup_config()
    updateout = ''
	copystartupconfigresponse = ''
    send_command("copy running-config startup-config") do |out|
      updateout<<out
    end
	Puppet.debug("updateout copy startup config")
	Puppet.debug(updateout)
    return true
  end

  def move_to_tftp(copy_to_tftp, path)
    Puppet.debug("Path::"+path)
    Puppet.debug("Copying files to TFTP share")
    tftp_share = copy_to_tftp[0]
    tftp_path = copy_to_tftp[1]

    full_tftp_path = tftp_share + "/" + tftp_path
    Puppet.debug("full_tftp_path  --> "+full_tftp_path)
    tftp_dir = full_tftp_path.split('/')[0..-2].join('/')
    Puppet.debug("tftp_dir --> "+tftp_dir)
    if !File.exist? tftp_dir
      FileUtils.mkdir_p tftp_dir
    end
    FileUtils.cp path, full_tftp_path
    FileUtils.chmod_R 0755, tftp_dir
  end


  def flush
    transport.command do |dev|
    interface = resource[:name]
    # native vlans can be used only on truck mode.
    is_native = resource[:istrunkforinterface]

    dev.update_interface(resource, former_properties, properties, interface, is_native)
    end
    super
  end
end
