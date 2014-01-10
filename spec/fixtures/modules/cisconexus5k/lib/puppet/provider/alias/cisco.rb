require 'puppet/provider/cisconexus5k'

Puppet::Type.type(:alias).provide :cisconexus5k, :parent => Puppet::Provider::Cisconexus5k do

  desc "Cisco switch/router provider for vlans."

  mk_resource_methods

  def self.lookup(device, id) 
    malias = {}
        device.command do |dev|
               malias = dev.parse_alias || {}
        end
    malias[id]
  end

  def initialize(device, *args)
       super
  end

  # Clear out the cached values.
  def flush
      Puppet.debug "Former_properties #{former_properties}"
      Puppet.debug "properties #{properties}" 
        device.command do |dev|
             dev.update_alias(resource[:name], former_properties, properties)
         end
     super
    former_properties.clear
    properties.clear    
  end
end
