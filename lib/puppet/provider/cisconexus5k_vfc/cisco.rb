require 'puppet/provider/cisconexus5k'

Puppet::Type.type(:cisconexus5k_vfc).provide :cisconexus5k, :parent => Puppet::Provider::Cisconexus5k do

  desc "Cisco Nexus provider for vfc interface."

  mk_resource_methods
  def self.lookup(device, id)
    vfc_interfaces = {}
    device.command do |dev|
      vfc_interfaces = dev.parse_vfc_interfaces || {}
    end
    vfc_interfaces[id]
  end

  def initialize(device, *args)
    super
  end

  # Clear out the cached values.
  def flush
    device.command do |dev|
      bind_interface = ( resource[:bind_interface] || '' )
      bind_macaddress = ( resource[:bind_macaddress] || '')
      shutdown = ( resource[:shutdown] || 'false')
      ensureabsent = resource[:ensure]
      dev.update_vfc_interface(resource[:name], former_properties, 
        properties, bind_interface, bind_macaddress, shutdown, ensureabsent)
    end
    super
  end
end
