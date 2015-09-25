require 'puppet/provider/cisconexus5k'

Puppet::Type.type(:cisconexus5k_featureset).provide :cisconexus5k, :parent => Puppet::Provider::Cisconexus5k do

  desc "Manages the features that needs to be installed on the nexus switch."

  mk_resource_methods
  def self.lookup(device, id)
    install_features = {}
    device.command do |dev|
      install_features = dev.parse_install_features || {}
    end
    install_features[id]
  end

  def initialize(device, *args)
    super
  end

  # Clear out the cached values.
  def flush
    device.command do |dev|
      ensure_absent = resource[:ensure]
      feature_name = resource[:feature]
      dev.update_feature_set(resource[:name], former_properties, properties, feature_name, ensure_absent)
    end
    super
  end
end
