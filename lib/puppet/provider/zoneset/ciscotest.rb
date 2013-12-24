require 'puppet/provider/cisconexus5k'

Puppet::Type.type(:zoneset).provide :cisconexus5k , :parent => Puppet::Provider::Cisconexus5k do

  desc "Cisco switch/router provider for ZoneSet."

  mk_resource_methods

  def self.lookup(device, id)
    zonesets = {}
    device.command do |dev|
      zonesets = dev.parse_zonesets || {}
    end
    zonesets[id]
  end

  def initialize(device, *args)
    super
  end

  # Clear out the cached values.
  def flush
    device.command do |dev|
      dev.update_zoneset(resource[:name], former_properties, properties, resource[:member], resource[:active], resource[:force], resource[:vsanid])
    end
    super
  end
end
