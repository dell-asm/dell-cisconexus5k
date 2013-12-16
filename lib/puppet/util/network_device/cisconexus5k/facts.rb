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
    @facts = {}

    interface_res = @transport.command("show interface brief")

    ethernet_interface_count = 0
    fiberchannel_interface_count = 0
    for line in interface_res.split("\n")
      if ( line =~ /^Eth(\d+)/ )
        ethernet_interface_count = ethernet_interface_count + 1
        res = line.split(" ")
        interface_name = res[0]
        status = res[4]
        type = res[2]
        mode = res[3]
        length = res.length
        speed = res[length - 2]
        portchannel = res[length - 1]
        reason = res[5..length - 3]
        @facts["#{ interface_name }" 'status'] = status
        @facts["#{ interface_name }" 'type'] = type
        @facts["#{ interface_name }" 'mode'] = mode
        @facts["#{ interface_name }" 'speed'] = speed
        @facts["#{ interface_name }" 'portchannel'] = portchannel
        @facts["#{ interface_name }" 'reason'] = reason
      end
      if ( line =~ /^fc(\d+)/ )
        fiberchannel_interface_count = fiberchannel_interface_count + 1
        res = line.split(" ")
        interface_name = res[0]
        length = res.length
        speed = res[length - 2]
        portchannel = res[length - 1]
        status = res[4]
        @facts["#{ interface_name }" 'status'] = status
        @facts["#{ interface_name }" 'speed'] = speed
        @facts["#{ interface_name }" 'portchannel'] = portchannel
      end
    end
    @facts['EthernetInterfaceCount'] = ethernet_interface_count
    @facts['FiberChannelInterfaceCount'] = fiberchannel_interface_count
    
    @facts
  end

end
