require 'pp'
require 'json'
require 'puppet_x/cisconexus5k/cisconexus5k'
require 'puppet/util/network_device/ipcalc'

#
# This retrieves facts from a cisco device
#

class PuppetX::Cisconexus5k::Facts

  attr_reader :transport
  def initialize(transport)
    @transport = transport
  end

  def retrieve
    facts = {}

    out = @transport.command("sh ver")

    for line in out.split("\n")
      if (line =~ /BIOS:\s+version\s+(\S+)/)
        facts["biosversion"] = $1
      end
      if (line =~ /kickstart:\s+version\s+(\S+)/)
        facts["kickstartversion"] = $1
      end
      if (line =~ /system:\s+version\s+(\S+)/)
        facts["systemversion"] = $1
      end
      if (line =~ /kickstart\ image\ file\ is:\s+(\S+)/)
        facts["kickstartimage"] = $1
      end
      if (line =~ /system\ image\ file\ is:\s+(\S+)/)
        facts["systemimage"] = $1
      end
      if (line =~ /cisco\s+(\S+)\s+Chassis/)
        facts["model"] = $1
      end
      if (line =~ /Device\s+name:\s+(\S+)/)
        facts["hostname"] = $1
      end
    end

    protocols = ""
    out = @transport.command("show feature")
    lines = out.split("\n")
    lines.shift; lines.shift; lines.shift; lines.pop
    count = 1
    for line in lines
      if (line =~ /^(\S+)\s+\d+\s+enabled/)
        if count == 1
          protocols = $1
          count = count + 1
        else
          protocols = protocols + "," + $1
        end
      end
    end
    facts["protocols_enabled"] = protocols

    out = @transport.command("show system resources")
    if (out =~ /Memory usage:\s+(\S+) total,\s+(\S+) used,\s+(\S+) free/)
      facts["mem_total"] = $1
      facts["mem_used"] = $2
      facts["mem_free"] = $3
    end

    if (out =~ /CPU states\s+:\s+(\S+) user,\s+(\S+) kernel,\s+(\S+) idle/)
      facts["cpu_user"] = $1
      facts["cpu_kernel"] = $2
      facts["cpu_idle"] = $3
    end
    
    interface_res = @transport.command("show interface brief")
    fact = nil
    ethernet_interface_count = 0
    fiberchannel_interface_count = 0
    for line in interface_res.split("\n")
      if ( line =~ /^Eth(\d+)/ )
        ethernet_interface_count = ethernet_interface_count + 1
        res = line.split(" ")
        interface_name = res[0]
        length = res.length
        vlan_info = @transport.command("show interface #{interface_name} switchport")
        for templine in vlan_info.split("\n")
          if (templine =~ /Access\s*Mode\s*VLAN:\s*(\S*)/)
            taggedvlan = $1
          end
          if (templine =~ /Trunking\s*Native\s*Mode\s*VLAN:\s*(\S*)/)
            untaggedvlan = $1
          end
        end

        out = @transport.command("show interface #{interface_name} mac-address")
        
        #puts "====>output: #{out}  ====?interface name: #{interface_name} ===="

        
        lines = out.split("\n")
        lines.shift; lines.shift; lines.shift; lines.shift; lines.shift; lines.pop

        #puts ("line =====> #{lines}")
        unless lines[0].nil?
          line = lines[0].split(" ")
          mac_address = normalize_mac(line[2])
          fact = { :interface_name => res[0], :type => res[2], :mode => res[3], :status => res[4], :speed => res[length - 2], :portchannel => res[length - 1], :reason => res[5..length - 3], :tagged_vlan => taggedvlan, :untagged_vlan => untaggedvlan, :macaddress => mac_address }
          facts[fact[:interface_name]] = fact
        end
      end
      if ( line =~ /^fc(\d+)/ )
        fiberchannel_interface_count = fiberchannel_interface_count + 1
        res = line.split(" ")
        length = res.length
        fact = { :interface_name => res[0], :status => res[4], :speed => res[length - 2], :portchannel => res[length - 1] }
        facts[fact[:interface_name]] = fact
      end
      if ( line =~ /^mgmt0/ )
        res = line.split(" ")
        management_ip = res[3]
        facts[:managementip] = management_ip
      end
    end
    out = @transport.command("show inventory")
    if ( out =~ /NAME:\s+"Chassis",\s+DESCR:.*\n.*SN:\s+(\S+)/ )
      facts[:chassisserialnumber] = $1
    end

    # Get FLOGI information
    out = @transport.command("show flogi database")
    flogi_info = []
    fc_interfaces = out.scan(/^(fc\d+\/\d+)\s*(\d+)\s+(\S+)\s+(\S+)\s+(\S+)/m)
    vfc_interfaces = out.scan(/^(vfc\d+)\s*(\d+)\s+(\S+)\s+(\S+)\s+(\S+)/)
    if fc_interfaces
      fc_interfaces.each do |fc_interface|
        flogi_info.push(fc_interface)
      end
    end
    if vfc_interfaces
      vfc_interfaces.each do |vfc_interface|
        flogi_info.push(vfc_interface)
      end
    end
    
    # Name Server Information
    nameserver_info = []
    out = @transport.command('show fcns database detail')
    ns_info = out.scan(/VSAN:(\d+)\s+FCID:(\S+).*?port-wwn\s+\(vendor\)\s+:(\S+).*?node-wwn\s+:(\S+).*?symbolic-port-name\s+:(.*?)port-type/m)
    if ns_info
      nameserver_info = ns_info
    end
    # Get VSAN information
    vsan_zoneset_info = []
    out = @transport.command('show zoneset active')
    vsan_zoneset_info = out.scan(/^zoneset\s+name\s*(\S+)\s+vsan\s+(\d+)/)

    # Adding show version command to clear the buffer prompts
    out = @transport.command("show version")
    
    # Remote LLDP information from the switch
    lldp_info = []
    out = @transport.command('show lldp  neighbors')
    lldp_info = out.scan(/^([a-f0-9\.]+)\s+(\S+)/m)
    remote_device_info = {}
    if !lldp_info.empty?
      lldp_info.each do |lldp_entry|
        remote_device = { :interface => lldp_entry[1].strip, :remote_mac => normalize_mac(lldp_entry[0].strip)}
        remote_device_info[remote_device[:interface]] = remote_device
      end
    end
    
    # Port channel information
    out = @transport.command('show port-channel summary')
    port_channel_out = out.scan(/^(\d+)\s+(Po\d+).*?LACP\s+(.*?)$/m)
    port_channels = {}
    if !port_channel_out.empty?
      port_channel_out.each do |port_channel|
        port_channel = { :port_channel => port_channel[0].strip, :name => port_channel[1].strip ,:ports => port_channel[2].strip }
        port_channels[port_channel[:port_channel]] = port_channel
      end
    end
    
    # Feature list enabled on the switch
    out = @transport.command('show running-config | inc feature')
    features = out.scan(/^feature\s+(\S+)$/m)
    configured_features= []
    if !features.empty?
      features.map {|x| configured_features.push(x[0])}
    end
    
    # VSAN Membership
    out = @transport.command("show vsan")
    vsans = ( out.scan(/^vsan\s+(\d+)\s+/) || [] ).flatten
    vsan_info = {}
    vsans.each do |vsan|
      out = @transport.command("show vsan #{vsan} membership")
      members = ( out.scan(/(fc\d+\/\d+|vfc\d+|san-port-channel\s+\d+)/) || [] ).flatten
      if !members.empty?
        vsan_info[vsan] = members
      end
    end

    # fex information
    out = @transport.command("show fex")
    fex = ( out.scan(/^(\d+)/).flatten || [] )

    fex_info = {}
    fex.each do |f|
      fex_info[f] = {}
      out = @transport.command("show fex #{f} detail")
      fex_info[f]['Extender Serial'] = out.scan(/^\s+Extender Serial:\s+(\S+)/).flatten.first
      fex_info[f]['Service Tag'] = out.scan(/^\s+Service Tag:\s*(\S*)$/).flatten.first
      fex_info[f]['Enclosure'] = out.scan(/^\s*Enclosure:\s*(.*)$/).flatten.first
      fex_info[f]['Interfaces'] = out.scan(/^\s+(Eth#{f}\S+)/).flatten
    end


    
    # Get VSAN Zoneset information
    # since we can communicate with the switch, set status to online
    # TODO: Find a method to get status programmatically
    facts[:ethernet_interface_count] = ethernet_interface_count
    facts[:fiberchannel_interface_count] = fiberchannel_interface_count
    facts[:status] = "online"
    facts[:manufacturer] = "Cisco"
    facts[:flogi_info] = flogi_info
    facts[:nameserver_info] = nameserver_info
    facts[:vsan_zoneset_info] = vsan_zoneset_info
    facts[:remote_device_info] = remote_device_info.to_json
    facts[:port_channels] = port_channels.to_json
    facts[:features] = configured_features
    facts[:vsan_member_info] = vsan_info
    facts[:fex] = fex
    facts[:fex_info] = fex_info
    #pp facts
    return facts
  end
  # d067.e572.13ce => d0:67:e5:72:13:ce
  def normalize_mac(mac)
    mac.gsub('.','').scan(/../).join(':') if mac
  end
end

