require 'puppet/provider/cisconexus5k'
require 'pry'

Puppet::Type.type(:cisconexus5k_interface).provide :cisconexus5k, :parent => Puppet::Provider::Cisconexus5k do

  desc "Cisco switch/router Interface provider for device configuration."

  mk_resource_methods

  def initialize(device, *args)
    super
  end

  def self.get_current(name)
    vlans = {}
    transport.command do |dev|
      vlans = dev.parse_vlans || {}
    end
    vlans[name]
  end

  def flush
    transport.command do |dev|
      interface = ""
      portchannel = ""
      interface = resource[:name]
      resource_reference = resource[:ensure]
      interfaceoperation = resource[:interfaceoperation]
      if interface && resource_reference == :present
        dev.update_interface(resource[:tagged_general_vlans], former_properties, properties, resource[:name], resource[:tagged_general_vlans].to_i, resource[:istrunkforinterface], resource[:interfaceencapsulationtype], "false", resource[:deletenativevlaninformation], resource[:unconfiguretrunkmode], resource[:shutdownswitchinterface], resource[:interfaceoperation], resource[:removeallassociatedvlans], resource_reference)

        dev.update_interface(resource[:untagged_general_vlans], former_properties, properties, resource[:name], resource[:untagged_general_vlans].to_i, resource[:istrunkforinterface], resource[:interfaceencapsulationtype], "true", resource[:deletenativevlaninformation], resource[:unconfiguretrunkmode], resource[:shutdownswitchinterface], resource[:interfaceoperation], resource[:removeallassociatedvlans], resource_reference)
      end
    end
    super
  end
end
