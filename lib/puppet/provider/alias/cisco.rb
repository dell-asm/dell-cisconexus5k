require 'puppet/provider/cisconexus5k'

Puppet::Type.type(:alias).provide :cisconexus5k, :parent => Puppet::Provider::Cisconexus5k do

  desc "Cisco switch/router provider for vlans."

  mk_resource_methods

  def self.get_current(name)
    malias = {}
    transport.command do |dev|
      malias = dev.parse_alias || {}
    end
    malias[name]
  end

  # Clear out the cached values.
  def flush
    Puppet.debug "Former_properties #{former_properties}"
    Puppet.debug "properties #{properties}"
    transport.command do |dev|
      dev.update_alias(resource[:name], former_properties, properties, resource[:member], resource[:ensure])
    end
    super
    former_properties.clear
    properties.clear
  end
end

