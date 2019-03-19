require 'puppet_x/cisconexus5k/transport'
require 'puppet/provider/network_device'

# This is the base class of all prefetched cisco device providers
class Puppet::Provider::Cisconexus5k < Puppet::Provider::NetworkDevice
  attr_accessor :transport
  def initialize(result, transport = nil)
    @transport = transport
    super(nil, result)
  end

  def self.transport
    @transport ||= PuppetX::Cisconexus5k::Transport.new(Puppet[:certname])
  end

  def self.prefetch(resources)
    transport.connect

    resources.each do |name, resource|
      current = get_current(name)
      #We want to pass the transport through so we don't keep initializing new ssh connections for every single resource
      if current
        resource.provider = new(current, transport)
      else
        resource.provider = new({:ensure => :absent}, transport)
      end
    end
  end

  def self.post_resource_eval()
    # closes existing session if exists
    if @transport.session.channel
      @transport.disconnect
    end
  end
end

