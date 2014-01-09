require 'pp'
require 'json'
require 'puppet/util/network_device/cisconexus5k'
require 'puppet/util/network_device/ipcalc'

#
# This retrieves facts from a cisco device
#

class Puppet::Util::NetworkDevice::Cisconexus5k::Facts

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
        lines = out.split("\n")
        lines.shift; lines.shift; lines.shift; lines.shift; lines.shift; lines.pop
        line = lines[0].split(" ")
        mac_address = line[2]
        fact = { :interface_name => res[0], :type => res[2], :mode => res[3], :status => res[4], :speed => res[length - 2], :portchannel => res[length - 1], :reason => res[5..length - 3], :tagged_vlan => taggedvlan, :untagged_vlan => untaggedvlan, :macaddress => mac_address }
        facts[fact[:interface_name]] = fact
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
    # since we can communicate with the switch, set status to online
    facts[:status] = "online"
    #pp facts
    return facts
  end
end

