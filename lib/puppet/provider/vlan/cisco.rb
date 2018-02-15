require 'puppet/provider/cisconexus5k'

Puppet::Type.type(:vlan).provide :cisconexus5k, :parent => Puppet::Provider::Cisconexus5k do

  desc "Cisco switch/router provider for vlans."

  mk_resource_methods

  def self.get_current(name)
    vlans = {}
    transport.command do |dev|
      vlans = dev.parse_vlans || {}
    end
    vlans[name]
  end

  # Clear out the cached values.
  def flush
    transport.command do |dev|
      interface = ""
      portchannel = ""
      interface = resource[:interface]
      portchannel = resource[:portchannel]
      ensureabsent = resource[:ensure]
      interfaceoperation = resource[:interfaceoperation]
      if ( interface != nil && ensureabsent == :absent)
        dev.update_interface(resource[:name], former_properties, properties,resource[:interface],resource[:nativevlanid],resource[:istrunkforinterface],resource[:interfaceencapsulationtype],resource[:isnative],resource[:deletenativevlaninformation],resource[:unconfiguretrunkmode],resource[:shutdownswitchinterface],resource[:interfaceoperation],resource[:removeallassociatedvlans],ensureabsent)
      end
      if ( portchannel != nil && ensureabsent == :absent)
        dev.update_portchannel(resource[:name],former_properties, properties,resource[:portchannel],resource[:istrunkforportchannel],resource[:portchanneloperation],ensureabsent)
      end
      dev.update_vlan(resource[:name], former_properties, properties, resource[:ensure])
      if ( interface != nil && ensureabsent == :present)
        dev.update_interface(resource[:name], former_properties, properties,resource[:interface],resource[:nativevlanid],resource[:istrunkforinterface],resource[:interfaceencapsulationtype],resource[:isnative],resource[:deletenativevlaninformation],resource[:unconfiguretrunkmode],resource[:shutdownswitchinterface],resource[:interfaceoperation],resource[:removeallassociatedvlans],ensureabsent)
      end
    end
    super
  end
end
