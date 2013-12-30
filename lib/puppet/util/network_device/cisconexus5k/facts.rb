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
      if (line =~ /(?:Cisco )?(IOS)\s*(?:\(tm\) |Software, )?(?:\w+)\s+Software\s+\(\w+-(\w+)-\w+\), Version ([0-9.()A-Za-z]+),/)
        facts["operatingsystem"] = $1
        facts["operatingsystemrelease"] = $3
        facts["operatingsystemfeature"] = $2
      end
      if (line =~ /kickstart\ image\ file\ is:\s+(\S+)/)
        facts["kickstartimage"] = $1
      end
      if (line =~ /system\ image\ file\ is:\s+(\S+)/)
        facts["systemimage"] = $1
      end
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
        fact = { :interface_name => res[0], :type => res[2], :mode => res[3], :status => res[4], :speed => res[length - 2], :portchannel => res[length - 1], :reason => res[5..length - 3], :tagged_vlan => taggedvlan, :untagged_vlan => untaggedvlan }
        facts[fact[:interface_name]] = fact
      end
      if ( line =~ /^fc(\d+)/ )
        fiberchannel_interface_count = fiberchannel_interface_count + 1
        res = line.split(" ")
        length = res.length
        fact = { :interface_name => res[0], :status => res[4], :speed => res[length - 2], :portchannel => res[length - 1] }
        facts[fact[:interface_name]] = fact
      end
    end
    #pp facts.to_json
    return facts
    end
end

