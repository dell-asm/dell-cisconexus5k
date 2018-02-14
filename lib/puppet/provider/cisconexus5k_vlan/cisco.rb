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
      dev.update_vlan(resource[:name], former_properties, properties, resource[:ensure])
    end
    super
  end
end


