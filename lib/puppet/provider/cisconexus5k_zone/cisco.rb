require 'puppet/provider/cisconexus5k'

Puppet::Type.type(:cisconexus5k_zone).provide :cisconexus5k , :parent => Puppet::Provider::Cisconexus5k do

  desc "Cisco switch/router provider for zone."

  mk_resource_methods

  def self.get_current(name)
    zones = {}
    transport.command do |dev|
      zones = dev.parse_zones || {}
    end
    zones[name]
  end

  # Clear out the cached values.
  def flush
    transport.command do |dev|
      dev.update_zone(resource[:name], former_properties, properties, resource[:vsanid], resource[:membertype], resource[:member], resource[:ensure])
    end
    super
  end
end
