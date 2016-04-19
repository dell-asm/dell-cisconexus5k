require 'pp'
require 'puppet'
require 'puppet/util'
require 'puppet_x/cisconexus5k/facts'
#require '/etc/puppetlabs/puppet/modules/asm_lib/lib/security/encode'
require 'puppet/util/autoload'
require 'uri'
require 'puppet/util/network_device/transport'
require 'puppet/util/network_device/transport/base'

#
# Main device class for Cisco nexus5k module
# This class is called by the provider and contains methods
# for performing all operations
# * parse_vlans: get a list of VLANs on the device
#   as a hash of hash, used by the lookup function of the
#   provider
# * update_vlan: delete/create VLAN
#

class PuppetX::Cisconexus5k::Transport

  include Puppet::Util::NetworkDevice::IPCalc

  attr_accessor :enable_password, :url, :session

  def initialize(certname, options = {})
    if options[:device_config]
      device_conf = options[:device_config]
    else
      require 'asm/device_management'
      device_conf = ASM::DeviceManagement.parse_device_config(certname)
    end

    #@url = URI.parse(url)
    #@query = Hash.new([])
    #@query = CGI.parse(@url.query) if @url.query

    #if @autoloader.load(device_conf[:scheme])
      require "puppet_x/cisconexus5k/ssh"
      @session = PuppetX::Cisconexus5k::Ssh.new(true)
      #= PuppetX::Cisconexus5k::Ssh.new(true)
      #= Puppet::Util::NetworkDevice::session.const_get(device_conf[:scheme].capitalize).new(options[:debug])
      @session.host = device_conf[:host]
      @session.port = device_conf[:port] || 22

      @session.user = device_conf[:user]
      @session.password = device_conf[:password]

      #@cred_id = device_conf[:credential_id]

      #override_using_credential_id
    #end

    @enable_password = device_conf[:password]
    #options[:enable_password] || parse_enable(device_conf[:password])
    @session.default_prompt = /\r.*[#>]\s?\z/n

  end

  #def credential
  #   require 'asm/cipher'
  #    @asm_credential ||= ASM::Cipher.decrypt_credential(@cred_id)
  #end

  def override_using_credential_id
    if cred = credential
      @session.user = cred.username
      @session.password = cred.password
    end
  end

  def connect_session
    session.connect
    login
    check_ag
  end
  
  def check_ag
    if session.command('ag --modeshow')['Access Gateway mode is enabled.'].nil?
      abort("Access Gateway mode required to configure switch.")
    end
  end

  def login
    return if session.handles_login?
    if @session.user != ''
      session.command(@session.user, {:prompt => /^Password:/, :noop => false})
    else
      session.expect(/^Password:/)
    end
    session.command(@session.password, :noop => false)
  end

  def parse_enable(query)
    if query
      params = CGI.parse(query)
      params['enable'].first unless params['enable'].empty?
    end
  end

  def connect
    session.connect
    login
    session.command("terminal length 0") do |out|
      enable if out =~ />\s?\z/n
    end
    #find_capabilities
  end

  def disconnect
    session.close
  end

  def command(cmd = nil)
    connect
    out = execute(cmd) if cmd
    yield self if block_given?
    disconnect
    out
  end

  def execute(cmd)
    Puppet.debug("Inside command execute: #{cmd}")
    session.command(cmd)
  end

  def login
    return if session.handles_login?

    if cred = credential
      user = cred.username
      password = cred.password
    else
      user = @session.user
      password = URI.decode(asm_decrypt(@session.password))
    end

    if user != ''
      session.command(user, :prompt => /^Password:/)
    else
      session.expect(/^Password:/)
    end
    session.command(password)
  end

  def enable
    raise "Can't issue \"enable\" to enter privileged, no enable password set" unless enable_password
    session.command("enable", :prompt => /^Password:/)
    session.command(enable_password)
  end

  IF = {
    :FastEthernet => %w{FastEthernet FastEth Fast FE Fa F},
    :GigabitEthernet => %w{GigabitEthernet GigEthernet GigEth GE Gi G},
    :TenGigabitEthernet => %w{TenGigabitEthernet TE Te},
    :Ethernet => %w{Ethernet Eth E},
    :Serial => %w{Serial Se S},
    :PortChannel => %w{PortChannel Port-Channel Po},
    :POS => %w{POS P},
    :VLAN => %w{VLAN VL V},
    :Loopback => %w{Loopback Loop Lo},
    :ATM => %w{ATM AT A},
    :Dialer => %w{Dialer Dial Di D},
    :VirtualAccess => %w{Virtual-Access Virtual-A Virtual Virt}
  }

  def canonalize_ifname(interface)
    IF.each do |k,ifnames|
      if found = ifnames.find { |ifname| interface =~ /^#{ifname}\s*\d/i }
        found = /^#{found}(.+)\Z/i.match(interface)
        return "#{k.to_s}#{found[1]}".gsub(/\s+/,'')
      end
    end
    interface
  end

  def facts
    @facts ||= PuppetX::Cisconexus5k::Facts.new(session)
    facts = {}
    command do |ng|
      facts = @facts.retrieve
    end
    facts
  end

  def parse_vlans
    vlans = {}
    out = execute("show vlan brief")
    lines = out.split("\n")
    lines.shift; lines.shift; lines.shift; lines.pop
    vlan = nil
    lines.each do |line|
      case line
      # vlan    name    status
      when /^(\d+)\s+(\w+)\s+(\w+)\s+([a-zA-Z0-9,\/. ]+)\s*$/
        vlan = { :name => $1, :vlanname => $2, :status => $3, :interfaces => [] }
        if $4.strip.length > 0
          vlan[:interfaces] = $4.strip.split(/\s*,\s*/)
        end
        vlans[vlan[:name]] = vlan
      when /^\s+([a-zA-Z0-9,\/. ]+)\s*$/
        raise "Invalid show vlan summary output" unless vlan
        if $1.strip.length > 0
          vlan[:interfaces] += $1.strip.split(/\s*,\s*/)
        end
      else
        next
      end
    end
    vlans
  end
  
  def parse_vsans
    vsan_info = {}
    vsan_res = execute("show vsan")
    vsans = ( vsan_res.scan(/^vsan\s+(\d+)\s+/i) || [] ).flatten
    vsans.each do |vsan|
      vsan_membership = execute("show vsan #{vsan} membership")
      vsan_info[vsan] = vsan_membership.scan(/(fc\d+\/\d+|vfc\d+|san-port-channel\s+\d+)/).flatten
    end
    vsan_info
  end

  def parse_fexs
    fex_info = {}
    fex_res = execute("show fex")
    fexs = ( fex_res.scan(/^(\d+)\s+(.*?)?\s+(\w+)\s+(\S+)\s+(\S+)$/i) || [] )
    fexs.each do |fex|
      fex_id = fex[0]
      fex_info[fex_id] = {:name => fex_id, :description => fex[1], :status => fex[2], :model => fex[3], :serial_num => fex[4]}
    end
    fex_info
  end
  
  def parse_vfc_interfaces
    vfc_interfaces = {}
    out = execute("show interface brief")
    vfc_interfaces_info = out.scan(/^vfc\s+(\d+)\s+(\d+)\s+\S+\s+(\S+)\s+(\S+)/)
    if vfc_interfaces_info.empty?
      vfc_interfaces_info.each do vfc_interface_info
        vfc_interfaces = {:name =>  vfc_interface_info[0], 
          :vsan => vfc_interface_info[1], 
          :admin_mode => vfc_interface_info[2], 
          :admin_trunk_mode => vfc_interface_info[3], 
          :status => vfc_interface_info[4]}
      end
    end
    vfc_interfaces
  end

  def parse_install_features
    install_features = {}
    out = execute("show running-config | include 'install feature-set'")
    features = ( out.scan(/^install feature-set\s+(\S+)/).flatten  || [] )
    features.each do |f|
        install_features[f] = { :name => f , :feature => f}
    end
    install_features
  end

  def parse_zones
    zones = {}
    out = execute("show zone")
    lines = out.split("\n")
    lines.shift; lines.pop
    zone = nil
    lines.each do |l|
      zone = { :name => '' , :vsanid => '', :membertype => [], :member => [] }
      if l =~ /^zone name\s*(\S*)\s*vsan\s*(\d*)/
        zone = { :name => $1, :vsanid => $2, :membertype => [], :member => [] }
      end
      if l =~ /pwwn\s*(\S*)/
        zone[:member] += Array($1).map{ |ifn| canonalize_ifname(ifn) }
        zone[:membertype] += Array('pwwn').map{ |ifn| canonalize_ifname(ifn) }
      end
      if l =~/fcalias name\s*(\S*)\s*vsan\s*(\d*)/
        zone[:member] += Array($1).map{ |ifn| canonalize_ifname(ifn) }
        zone[:membertype] += Array('fcalias').map{ |ifn| canonalize_ifname(ifn) }
      end
      zones[zone[:name]] = zone if zone[:name].length > 0
    end
    zones
  end

  def parse_alias
    malias ={}
    out=execute("show device-alias database")
    Puppet.debug "show device-alias database \n  #{out} "
    lines = out.split("\n")
    lines.shift ; lines.pop
    lines.each do |l|
      if l =~ /device-alias\s*name\s*(\S*)\s*(\S*)\s*(\S*)/
        m_alias = { :name => $1, :member => $3 }
        malias[m_alias[:name]] = m_alias
      end
    end
    malias
  end

  def parse_zonesets
    zonesets = {}
    allzonesets = get_all_zonesets
    allzonesets.each do |key, value|
      zonesets[value[:name]] = value
    end
    zonesets
  end

  def get_active_zonesets
    activezonesets = {}
    out = execute("show zoneset active")
    #Puppet.debug("#{out}")
    lines = out.split("\n")
    lines.shift; lines.pop
    activezoneset = nil
    lines.each do |l|
      if l =~  /^zoneset name\s+(\S+)\s+vsan\s+(\d+)\s*$/
        activezoneset = { :name => $1, :vsanid => $2}
        varkey = "VSAN_"+$2+"_"+$1
        #puts("Active Zoneset Key: #{varkey}")
        activezonesets[varkey] = activezoneset
      end
    end
    keys = activezonesets.keys
    Puppet.debug("Active Zoneset keys: #{keys}")
    activezonesets
  end

  def get_all_zonesets
    activezonesets = get_active_zonesets
    zonesets = {}
    out = execute("show zoneset brief")
    #Puppet.debug("#{out}")
    lines = out.split("\n")
    lines.shift; lines.pop
    zoneset = nil
    lines.each do |l|
      zoneset = { :name => '' , :vsanid => '' }
      if l =~  /^zoneset name\s+(\S+)\s+vsan\s+(\d+)\s*$/
        varkey = "VSAN_"+$2+"_"+$1
        if activezonesets.key?(varkey)
          zoneset = { :name => $1, :vsanid => $2, :member => [], :active => "true" }
        else
          zoneset = { :name => $1, :vsanid => $2, :member => [], :active => "false" }
        end
      end
      if l =~ /zone\s+(\S*)/
        #Puppet.debug("Zoneset: #{zoneset[:name]} Member: #{$1}")
        zoneset[:member] += Array($1).map{ |ifn| canonalize_ifname(ifn) } if zoneset[:name].length > 0
      end
      zonesets["VSAN_"+zoneset[:vsanid]+"_"+zoneset[:name]] = zoneset if zoneset[:vsanid].length > 0
      #Puppet.debug("Found Zoneset-> zonesetName : #{zoneset[:name]} vsanid : #{zoneset[:vsanid]} member : #{zoneset[:member]} active : #{zoneset[:active]}")
    end
    keys = zonesets.keys
    Puppet.debug("All Zoneset keys: #{keys}")
    zonesets
  end

  def update_alias(id, is = {}, should = {},member = {}, tempensure = {} )
    #member=should[:member]
    if  tempensure.to_s == "absent" || should[:ensure] == :absent
      Puppet.debug "Removing #{id} from device alias"
      execute("conf t")
      execute("device-alias database")
      execute("no device-alias name #{id} ")
      execute("device-alias commit")
      execute("exit")
      execute("exit")
      return
    end

    Puppet.debug "Creating Alias id #{id} member #{member} "
    execute("conf t")
    execute("device-alias database")
    Puppet.debug "id #{id} member #{member}  "
    out = execute("device-alias name  #{id} pwwn #{member}")
    if ( out =~ /% Invalid/ )
      raise "The command input #{memberval} is invalid"
    end
    if (out =~ /already present/)
      raise "Another device-alias already present with the same pwwn"
    end
    execute("device-alias commit")
    execute("exit")
    execute("exit")
  end

  def update_vlan(id, is = {}, should = {}, tempensure = ':absent')
    if should[:ensure] == :absent || tempensure == :absent
      Puppet.info "A VLAN #{id} is being removed from the device."
      execute("conf t")
      out = execute("no vlan #{id}")
      if out =~ /Invalid/
        raise "The VLAN id value/range is invalid."
      end
      execute("exit")
      return
    end

    # We're creating or updating an entry
    execute("conf t")
    out = execute("vlan #{id}")
    if out =~ /Invalid/
      raise "The VLAN id value/range is invalid."
    end
    [is.keys, should.keys].flatten.uniq.each do |property|
      Puppet.debug("trying property: #{property}: #{should[property]}")
      next if property != :vlanname
      execute("name #{should[property]}")
      Puppet.info "Successfully created a VLAN #{id}."
    end
    out = execute("exit")
    if out =~/ERROR:\s*(.*)/
      Puppet.info "#{$1}"
    end

    execute("exit")
  end

  def update_interface(id, is = {}, should = {},interfaceid = {},nativevlanid={},istrunk = {},encapsulationtype={},isnative={},deletenativevlaninformation={},unconfiguretrunkmode={},
    shutdownswitchinterface={},interfaceoperation={}, removeallassociatedvlans={},ensureabsent=':absent')
    Puppet.debug("Performing the update interfaces for Cisco Nexus")
    responseinterface = execute("show interface #{interfaceid}")
    if ( responseinterface =~ /Invalid/ )
      raise "The interface #{interfaceid} does not exist on the switch."
    end
    if should[:ensure] == :absent || interfaceoperation == "remove" || ensureabsent == :absent
      Puppet.info "The interface #{interfaceid} is being removed from the VLAN #{id}."
      execute("conf t")
      execute("interface #{interfaceid}")
      if istrunk == "true"
        responsetrunk = execute("show interface #{interfaceid} trunk")
        if ( responsetrunk =~ /Invalid/ )
          Puppet.info("The trunking is not configured on the interface #{interfaceid}.")
          return
        end
        interfacestatus = gettrunkinterfacestatus(responsetrunk)
        if ( interfacestatus != "trunking" )
          Puppet.info "The interface #{interfaceid} is in access mode."
          return
        end
        Puppet.info "The interface #{interfaceid} is in trunk mode."
        if deletenativevlaninformation == "true"
          Puppet.info "The native VLAN information is being deleted."
          execute("no switchport trunk native vlan #{nativevlanid}")
        end
        execute("switchport trunk allowed vlan remove #{id}")
        if unconfiguretrunkmode == "true"
          Puppet.info "The trunk mode is being unconfigured."
          execute("no switchport mode trunk")
        end
        if shutdownswitchinterface == "true" && unconfiguretrunkmode == "false"
          Puppet.info "The interface #{interfaceid} is being shut down."
          execute("shutdown")
        end
      else
        Puppet.info "The interface #{interfaceid} is in access mode."
        execute("no switchport access vlan #{id}")
        execute("no switchport mode access")
        execute("shutdown")
      end
      execute("exit")
      execute("exit")
      return
    end

    # We're creating or updating an entry
    execute("conf t")
    execute("interface #{interfaceid}")
    if istrunk == "true"
      Puppet.debug("Verify whether or not the specified interface is already configured as a trunk interface.")
      responsetrunk = execute("show interface #{interfaceid} trunk")
      if ( responsetrunk =~ /Invalid/ )
        Puppet.info("The trunking feature is not already configured for  the interface #{interfaceid}. Configure trunking feature on this interface.")
        return
      end
      Puppet.info("The trunk interface status for #{interfaceid} is being retrieved.")
      interfacestatus = gettrunkinterfacestatus(responsetrunk)
      Puppet.info("The encapsulationtype for the interface #{interfaceid} is being retrieved.")
      updateencapsulationtype = getencapsulationtype(interfaceid,encapsulationtype)
      if ( interfacestatus != "trunking" )
        execute("switchport")
        if ( updateencapsulationtype != "" )
          execute("switchport trunk encapsulation #{updateencapsulationtype}")
        end
        execute("switchport mode trunk")
      end
      if removeallassociatedvlans == "true"
        Puppet.info("The associated VLANs are being deleted.")
        execute("switchport trunk allowed vlan none")
      end
      if isnative == "true"
        Puppet.info("A switch interface with a native VLAN is being configured.")
        Puppet.debug("Command: 'switchport trunk native vlan #{nativevlanid}'")
        execute("switchport trunk native vlan #{nativevlanid}")
        execute("no shutdown")
      elsif isnative == "false"
        Puppet.info("Need to remove the native vlan configuration.")
        Puppet.debug("Command: 'no switchport trunk native vlan #{nativevlanid}'")
        tagged_vlans = show_vlans(interfaceid)
        remove_tagged_vlans(id, interfaceid, tagged_vlans)
        execute("no switchport trunk native vlan #{nativevlanid}")
        execute("no shutdown")
      end
    else
      Puppet.info "The interface #{interfaceid} is being configured into access mode."
      execute("switchport")
      execute("switchport mode access")
      execute("switchport access vlan #{id}")
      execute("no shutdown")
    end
    execute("exit")
    execute("exit")
    return
  end

  def show_vlans(interfaceid)
    get_vlan_info = execute("show running-config interface #{interfaceid}")
    meta_data = get_vlan_info.match /switchport trunk allowed vlan (.+?)$/
    tagged = []
    str = meta_data.nil? ? "" : meta_data[1]
    str_arr = str.split(",")
    str_arr.each do |num_str|
      num = num_str.to_i
      if num_str == num.to_s
        tagged << num
      else
        nums = num_str.split("-").map(&:to_i)
        nums[0].upto(nums[1]).each do |range_num|
          tagged << range_num
        end
      end
    end
    return tagged
  end

  def remove_tagged_vlans(id, interfaceid, existing_vlans)
    id = id.split("/").map(&:to_i)
    current_vlans = existing_vlans

    vlans_to_remove = current_vlans - id
    vlans_to_remove.each do |vlan|
      Puppet.info("Removing unnecessary tagged vlans")
      execute("config")
      execute("interface #{interfaceid}")
      execute("switchport trunk allowed vlan remove #{vlan}")
    end

    vlans_to_add = id - existing_vlans
    vlans_to_add.each do |val|
      Puppet.info("adding vlans")
      execute("config")
      execute("interface #{interfaceid}")
      execute("switchport trunk allowed vlan add #{val}")
    end
  end

  def update_feature_set(id, is = {}, should = {}, feature_name = '', ensure_absent = ':absent')
    if should[:ensure] == :absent || ensure_absent == :absent
      Puppet.info "The feature set #{feature_name} is being removed from the switch."
      execute('conf t')
      execute("no install feature-set #{feature_name}")
      execute('exit')
      return
    end

    Puppet.debug("Configuring feature set #{feature_name}")
    execute('conf t')
    execute("install feature-set #{feature_name}")
    execute("feature-set #{feature_name}")
    execute('exit')
    return
  end

  def update_fex(id, is = {}, should = {}, fcoe = {} , ensure_absent = ":absent")
    Puppet.debug("Performing the vsan update for Cisco Nexus")

    if should[:ensure] == :absent || ensure_absent == :absent
      Puppet.info "Removing fex #{id}."
      execute('conf t')
      execute("no fex #{id}")
      execute('exit')
      return
    end

    # We're creating or updating an entry
    execute('conf t')
    execute("fex #{id}")

    if !fcoe.empty?
      execute("fcoe")
    end

    execute("end")
    return
  end

  def update_vfc_interface(id, is = {}, should = {}, bind_interface = {}, bind_macaddress={}, shutdown = {}, ensureabsent = ':absent')
    Puppet.debug("Performing the vfc interfaces update for Cisco Nexus")

    if should[:ensure] == :absent || ensureabsent == :absent
      Puppet.info "The interface #{interfaceid} is being removed from the vfc #{id}."
      execute("conf t")
      execute("no interface vfc #{interfaceid}")
      execute("exit")
      return
    end

    # We're creating or updating an entry
    execute("conf t")
    execute("interface vfc #{id}")
    if !bind_interface.empty?
      execute("bind interface #{bind_interface}")
    end

    if !bind_macaddress.empty?
      execute("bind macaddress vfc #{bind_interface}")
    end

    Puppet.debug("Value of shutdown: '#{shutdown}'")
    if shutdown == :false
      execute("no shutdown")
    else
      execute("shutdown")
    end
    
    execute("exit")
    return
  end

  def update_vsan(id, is = {}, should = {}, vsanname = {}, membership = {} , membershipoperation = {} , fcoemap = {} , ensureabsent = ":absent")
    Puppet.debug("Performing the vsan update for Cisco Nexus")

    if should[:ensure] == :absent || ensureabsent == :absent
      Puppet.info "Removing VSAN #{id}."
      execute("conf t")
      execute("vsan database")
      execute("no vsan #{interfaceid}")
      execute("y")
      execute("exit")
      return
    end

    # We're creating or updating an entry
    execute("conf t")
    execute("vsan database")
    execute("vsan #{id}")
    if !vsanname.empty?
      execute("vsan #{id} name #{vsanname}")
    end
    
    if !membership.empty?
      members = ( membership.split(';') || [] )
      members.each do |member|
        if membershipoperation == 'add'
          execute("vsan #{id} interface #{member}")
        else
          execute("vsan 1 member interface #{member}")
        end
      end
    end
    
    if !fcoemap.empty?
      execute("fcoe fcmap #{fcoemap}")
      execute("y")
    end
    
    execute("end")
    return
  end

  def update_zoneset(id, is = {}, should = {}, member = {}, active = {}, force = {}, vsanid = {}, ensureabsent=':absent')
    Puppet.debug("INPUTS: zonesetName : #{id} vsanid : #{vsanid} member : #{member} active : #{active} force : #{force}")
    #Fetch the existing config from switch
    existingzonesets = get_all_zonesets
    iskeymatched = false

    # Delete Zoneset - start
    if should[:ensure] == :absent || ensureabsent == :absent
      existingzonesets.each do |key, value|
        Puppet.debug("System Zoneset key: #{key} name: #{value[:name]} VSAN: #{value[:vsanid]}, Required Zoneset key: name: #{id} VSAN: #{vsanid}")
        if value[:name] == id && value[:vsanid] == vsanid
          iskeymatched = true
          #matching zoneset found so remove it.

          Puppet.info "Removing zoneset: #{id} VSAN #{vsanid} from device."
          execute("conf t")
          #Deactivate the zoneset if "active = false" property is explicitely mentioned in inputs.
          if (active != nil) && (active == "false")
            Puppet.debug("De-activating Zoneset #{id} for VSAN #{vsanid}")
            out = execute("no zoneset activate name #{id} vsan #{vsanid}")
            Puppet.debug("#{out}")
          end
          #Remove the member zones.
          existingmembers = value[:member]
          out = execute("zoneset name #{id} vsan #{vsanid}")
          Puppet.debug("#{out}")

          existingmembers.each do |memberval|
            out = execute("no member #{memberval}")
            Puppet.debug("#{out}")
          end

          out = execute("no zoneset name #{id} vsan #{vsanid}")
          Puppet.debug("#{out}")

          execute("exit")
          execute("exit")
          break
        end
      end
      if iskeymatched == false
        Puppet.info "Zoneset: #{id} VSAN #{vsanid} not found on device."
      end
      return
    end
    # Delete Zoneset - end

    # Create or update zoneset - start
    Puppet.info "Add/Updating a zoneset: #{id} VSAN #{vsanid} on device"
    execute("conf t")
    iskeymatched = false #reset the flag.

    #If zoneset already exists then update it.
    existingzonesets.each do |key, value|
      Puppet.debug("System Zoneset key: #{key} name: #{value[:name]} VSAN: #{value[:vsanid]} members: #{value[:member]}, Required zoneset key: name: #{id} VSAN: #{vsanid} member: #{member}")
      if value[:name] == id && value[:vsanid] == vsanid
        iskeymatched = true
        #matching zoneset found so update it.

        Puppet.info("Updating a zoneset: #{id} with VSAN #{vsanid} on device")
        mem = {}
        if (member !=nil)
          mem = member.split(",")
          existingmembers = value[:member]

          out = execute("zoneset name #{id} vsan #{vsanid}")
          Puppet.debug("#{out}")

          #Remove unwanted members.
          memberstoremove = existingmembers - mem
          Puppet.debug("Zoneset members to remove: #{memberstoremove}")
          memberstoremove.each do |memberval|
            out = execute("no member #{memberval}")
            Puppet.debug("#{out}")
          end

          #Add new members.
          memberstoadd = mem - existingmembers
          Puppet.debug("New members to add: #{memberstoadd}")
          memberstoadd.each do |memberval|
            out = execute("member #{memberval}")
            Puppet.debug("#{out}")
          end
          execute("exit")

        end
        break
      end
    end

    #If zoneset doesnot exists, then create a new one.
    if iskeymatched == false
      Puppet.info "Zoneset: #{id} VSAN #{vsanid} not found on device, creating a new zoneset."
      out = execute("zoneset name #{id} vsan #{vsanid}")
      Puppet.debug("#{out}")
      mem = {}
      if (member !=nil)
        mem = member.split(",")
        mem.each do |memberval|
          out =  execute("member #{memberval}")
          Puppet.debug("#{out}")
        end
      end
      execute("exit")
    end

    # Activate zoneset - start
    if (active != nil) && (active == "true")
      Puppet.info("Activating zoneset #{id} on VSAN #{vsanid}.")
      existingactive = ""
      iskeymatched = false
      activezonesets = get_active_zonesets

      activezonesets.each do |key, value|
        if value[:vsanid] == vsanid
          iskeymatched = true
          existingactive = value[:name]
          Puppet.info("Found an active zoneset #{existingactive} corresponding to VSAN #{vsanid}")
          if id != existingactive && force == "true"
            Puppet.info("De-activating Zoneset #{existingactive} for VSAN #{vsanid}")
            out = execute("no zoneset activate name #{existingactive} vsan #{vsanid}")
            Puppet.debug("#{out}")
            Puppet.info("Activating Zoneset #{id} for VSAN #{vsanid}")
            out = execute("zoneset activate name #{id} vsan #{vsanid}")
            Puppet.debug("#{out}")
          elsif id == existingactive
            Puppet.info("Re-activating Zoneset #{id} on  VSAN #{vsanid}")
            out = execute("no zoneset activate name #{id} vsan #{vsanid}")
            Puppet.debug("#{out}")
            out = execute("zoneset activate name #{id} vsan #{vsanid}")
            Puppet.debug("#{out}")
          elsif force != "true"
            Puppet.info("Another zoneset already active, Use property \"force => true\" to activate zoneset #{id} on VSAN #{vsanid}")
          end
        end
      end
      if iskeymatched == false
        Puppet.debug("No active zoneset found for VSAN #{vsanid}, Activating Zoneset #{id}")
        out = execute("zoneset activate name #{id} vsan #{vsanid}")
        Puppet.debug("#{out}")
      end
    elsif (active != nil) && (active == "false")
      Puppet.info("De-activating Zoneset #{id} for VSAN #{vsanid}")
      out = execute("no zoneset activate name #{id} vsan #{vsanid}")
      Puppet.debug("#{out}")
    end
    # Activate zoneset - end

    execute("exit")
    # Create or update zoneset - end
  end

  def getencapsulationtype(interfaceid,encapsulationtype)
    updateencapsulationtype = ""
    encapsulationtypelist = ""
    if encapsulationtype != ""
      responsecapability = execute("show interface #{interfaceid} Capabilities")
      if responsecapability =~ /Trunk encap. type:\s+(\S+)/
        encapsulationtypelist = $1
      end
      if ( encapsulationtypelist =~ /,/ )
        Puppet.info("The multiple encapsulation types exist.")
        updateencapsulationtype = encapsulationtype
      else
        updateencapsulationtype = encapsulationtype
        if encapsulationtype == "dot1q"
          updateencapsulationtype = "802.1Q"
        end
        if updateencapsulationtype == encapsulationtypelist
          updateencapsulationtype = ""
        else
          updateencapsulationtype = encapsulationtype
        end
      end
    end
    return updateencapsulationtype
  end

  def gettrunkinterfacestatus(response)
    response = response.gsub("\n",'')
    if response =~ /--.+\s+\s+(tr\S+)\s+/
      trunk = $1
    end
    if ( trunk =~ /trnk-bndl/ )
      trunk = "trunking"
    end
    return trunk
  end

  def update_portchannel(id, is = {}, should = {}, portchannel = {}, istrunkforportchannel = {},portchanneloperation = {},ensureabsent=':absent')
    if portchannel !~ /\d/
      Puppet.info("The port channel #{portchannel} should be numeric value.")
      return
    end
    pchannel = "po#{portchannel}"
    responsepchannel = execute("show interface #{pchannel}")
    if ( responsepchannel =~ /Invalid/ )
      raise "A port channel #{portchannel} does not exist on the switch."
      return
    end
    if should[:ensure] == :absent || portchanneloperation == "remove" || ensureabsent == :absent
      Puppet.info "A port channel #{portchannel} is being deleted from the device VLAN #{id}."
      execute("conf t")
      execute("interface port-channel #{portchannel}")
      if (istrunkforportchannel == "true")
        execute("switchport trunk allowed vlan remove #{id}")
      end
      execute("no switchport access vlan #{id}")
      execute("exit")
      return
    end

    # We're creating or updating an entry
    execute("conf t")
    execute("interface port-channel #{portchannel}")
    execute("switchport")
    if (istrunkforportchannel == "true")
      Puppet.info "A port channel #{portchannel} is being configured into trunk mode."
      portchannelencapsulationtype = should[:portchannelencapsulationtype]
      addmembertotrunkvlan(id,portchannel,portchannelencapsulationtype)
    else
      Puppet.info "A port channel #{portchannel} is being configured into access mode."
      execute("switchport mode access")
      execute("switcport access vlan #{id}")
    end
    execute("no shutdown")
    execute("exit")
    execute("exit")
    return
  end

  def addmembertotrunkvlan(vlanid,portchannelid,portchannelencapsulationtype)
    portchannel = "po#{portchannelid}"
    Puppet.info("The encapsulationtype for portchannel #{portchannelid} is being retrieved.")
    updateencapsulationtype = getencapsulationtype(portchannel,portchannelencapsulationtype)
    responseportchannel = execute("show interface #{portchannel} trunk")
    if ( responseportchannel =~ /Invalid/ )
      Puppet.info("The trunking feature is not already configured for  the port channel #{interfaceid}. Configure trunking feature on this interface.")
      return
    end
    Puppet.info("The trunk port channel status for portchannel #{portchannel} is being retrieved.")
    interfacestatus = gettrunkinterfacestatus(responseportchannel)
    if ( interfacestatus != "trunking" )
      execute("switchport")
      if ( updateencapsulationtype != "" )
        execute("switchport trunk encapsulation #{updateencapsulationtype}")
      end
      execute("switchport mode trunk")
    end
    notaddedtoanyvlan = "false"
    out = execute("show interface #{portchannel} switchport")
    if out =~ /Trunking VLANs Allowed:\s(\S+)\s/
      trunkportvlanid = $1
    end
    if (trunkportvlanid.length == 0 || trunkportvlanid == "NONE")
      notaddedtoanyvlan = "true"
    end
    if notaddedtoanyvlan == "true"
      execute("switchport trunk allowed vlan #{vlanid}")
    else
      execute("switchport trunk allowed vlan add #{vlanid}")
    end
    return
  end

  def update_zone(id, is = {}, should = {}, vsanid = {}, membertype = {}, member = {}, tempensure = {})
    mem = member.split(",")
    if tempensure.to_s == "absent" || should[:ensure] == :absent
      Puppet.info "Zone #{id} is being destroyed."
      execute("conf t")
      Puppet.debug "conf t"
      out = execute("zone name #{id} vsan #{vsanid}")
      Puppet.debug "zone name #{id} vsan #{vsanid}"
      if ( out =~/Illegal/ )
        raise "The zone name #{id} is not valid on the switch"
      end
      if ( out =~ /% Invalid/ )
        raise "The VSAN Id #{vsanid} is not valid on the switch"
      end
      if ( out =~ /not configured/ )
        raise "The VSAN Id #{vsanid} is not valid on the switch"
      end
      mem.each do |memberval|
        out = execute("no member #{membertype} #{memberval}")
        Puppet.debug "no member #{membertype} #{memberval}"
        #if ( out =~ /% Invalid/ )
        #  raise "invalid command input #{memberval}"
        #end
      end
      #check whether its was a last member of not
      out = execute("show zone name #{id} vsan #{vsanid}")
      Puppet.debug "show zone name #{id} vsan #{vsanid}"
      lines = out.split("\n")
      lines.shift; lines.pop
      outputlength = lines.length
      if ( outputlength == 1 )
        #No last member need to remove the zone"
        execute("no zone name #{id} vsan #{vsanid}")
        Puppet.debug "no zone name #{id} vsan #{vsanid}"
      end
      execute("exit")
      execute("exit")
      return
    end
    Puppet.info "Zone #{id} is being created."
    # We're creating or updating an entry
    execute("conf t")
    Puppet.debug "conf t"
    out = execute("zone name #{id} vsan #{vsanid}")
    Puppet.debug "zone name #{id} vsan #{vsanid}"
    if ( out =~/Illegal/ )
      raise "The zone name #{id} is not valid on the switch"
    end
    if ( out =~ /% Invalid/ )
      raise "The VSAN Id #{vsanid} is not valid on the switch"
    end
    if ( out =~ /not configured/ )
      raise "The VSAN Id #{vsanid} is not valid on the switch"
    end
    mem.each do |memberval|
      out =  execute("member #{membertype} #{memberval}")
      Puppet.debug "member #{membertype} #{memberval}"
      if ( out =~ /% Invalid/ )
        raise "The command input #{memberval} is invalid"
      end
    end
    execute("exit")
    execute("exit")
  end
end

