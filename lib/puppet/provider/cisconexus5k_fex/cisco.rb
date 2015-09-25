require 'puppet/provider/cisconexus5k'

Puppet::Type.type(:cisconexus5k_fex).provide :cisconexus5k, :parent => Puppet::Provider::Cisconexus5k do

  desc "Cisco switch/router provider for vsan."

  mk_resource_methods
  def self.lookup(device, id)
    fexs = {}
    device.command do |dev|
      fexs = dev.parse_fexs || {}
    end
    fexs[id]
  end

  def initialize(device, *args)
    super
  end

  # Clear out the cached values.
  def flush
    device.command do |dev|
      fcoe = (resource[:fcoe] || '')
      ensure_absent = resource[:ensure]
      dev.update_fex(resource[:name], former_properties, properties, fcoe, ensure_absent)
    end
    super
  end
end
