require 'puppet_x/cisconexus5k/transport'
require 'puppet/provider/network_device'

# This is the base class of all prefetched cisco device providers
class Puppet::Provider::Cisconexus5k < Puppet::Provider::NetworkDevice
  def self.device(url)
     Puppet::Util::NetworkDevice::Cisconexus5k::Device.new(url)
  end
end

