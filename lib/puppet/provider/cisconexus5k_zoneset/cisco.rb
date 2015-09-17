require 'puppet/provider/cisconexus5k'

Puppet::Type.type(:cisconexus5k_zoneset).provide :cisconexus5k , :parent => Puppet::Provider::Cisconexus5k do

  desc "Cisco switch/router provider for ZoneSet."

  mk_resource_methods

  def self.get_current(name)
    zonesets = {}
    transport.command do |dev|
      zonesets = dev.parse_zonesets || {}
    end
    zonesets[name]
  end

  # Clear out the cached values.
  def flush
    transport.command do |dev|
      dev.update_zoneset(resource[:name], former_properties, properties, resource[:member], resource[:active], resource[:force], resource[:vsanid], resource[:ensure])
    end
    super
  end
end
