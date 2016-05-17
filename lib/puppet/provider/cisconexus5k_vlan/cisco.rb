require 'puppet/provider/cisconexus5k'

Puppet::Type.type(:cisconexus5k_vlan).provide :cisconexus5k, :parent => Puppet::Provider::Cisconexus5k do

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
      resource_reference = resource[:ensure]
      interfaceoperation = resource[:interfaceoperation]
      if portchannel && resource_reference == :absent
        dev.update_portchannel(resource[:name], former_properties, properties, resource[:portchannel], resource[:istrunkforportchannel], resource[:portchanneloperation], resource_reference)
      end

      dev.update_vlan(resource[:name], former_properties, properties, resource_reference)

      if portchannel && resource_reference == :present
        dev.update_portchannel(resource[:name], former_properties, properties, resource[:portchannel], resource[:istrunkforportchannel], resource[:portchanneloperation], resource_reference)
      end
    end
    super
  end
end


