require 'puppet/util/network_device/cisconexus5k'
require 'puppet/util/network_device/ipcalc'

# this retrieves facts from a cisco device
class Puppet::Util::NetworkDevice::Cisconexus5k::Facts

  attr_reader :transport

  def initialize(transport)
    @transport = transport
  end

  def retrieve
    @facts = {}

    interfaceRes = @transport.command("show interface brief")

    ethernetInterfaceCount = 0
    fiberChannelInterfaceCount = 0
    for line in interfaceRes.split("\n")
      if ( line =~ /^Eth(\d+)/ )
        ethernetInterfaceCount = ethernetInterfaceCount + 1
        res = line.split(" ")
        interfaceName = res[0]
        status = res[4]
        type = res[2]
        mode = res[3]
        length = res.length
        speed = res[length - 2]
        portChannel = res[length - 1]
        reason = res[5..length - 3]
        @facts["#{ interfaceName }" 'status'] = status
        @facts["#{ interfaceName }" 'type'] = type
        @facts["#{ interfaceName }" 'mode'] = mode
        @facts["#{ interfaceName }" 'speed'] = speed
        @facts["#{ interfaceName }" 'portChannel'] = portChannel
        @facts["#{ interfaceName }" 'reason'] = reason
      end
      if ( line =~ /^fc(\d+)/ )
        fiberChannelInterfaceCount = fiberChannelInterfaceCount + 1
        res = line.split(" ")
        interfaceName = res[0]
        length = res.length
        speed = res[length - 2]
        portChannel = res[length - 1]
        status = res[4]
        @facts["#{ interfaceName }" 'status'] = status
        @facts["#{ interfaceName }" 'speed'] = speed
        @facts["#{ interfaceName }" 'portChannel'] = portChannel
      end
    end
    @facts['EthernetInterfaceCount'] = ethernetInterfaceCount
    @facts['FiberChannelInterfaceCount'] = fiberChannelInterfaceCount
    
    @facts
  end

end
