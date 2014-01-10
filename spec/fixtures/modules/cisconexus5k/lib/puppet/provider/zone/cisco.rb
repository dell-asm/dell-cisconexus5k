require 'puppet/provider/cisconexus5k'

Puppet::Type.type(:zone).provide :cisconexus5k , :parent => Puppet::Provider::Cisconexus5k do

  desc "Cisco switch/router provider for zone."

  mk_resource_methods

  def self.lookup(device, id)
    zones = {}
    device.command do |dev|
      zones = dev.parse_zones || {}
    end
     zones[id]
  end

  def initialize(device, *args)
    super
  end

  # Clear out the cached values.
  def flush
    device.command do |dev|
      dev.update_zone(resource[:name], former_properties, properties, resource[:vsanid], resource[:membertype], resource[:member])
    end
    super
  end
end
