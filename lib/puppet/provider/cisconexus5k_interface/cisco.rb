require "puppet/provider/cisconexus5k"
require "pry"

Puppet::Type.type(:cisconexus5k_interface).provide :cisconexus5k, :parent => Puppet::Provider::Cisconexus5k do

  desc "Cisco switch/router Interface provider for device configuration."

  mk_resource_methods

  def initialize(device, *args)
    super
  end

  def self.get_current(name)
    interface = {}
    transport.command do |dev|
      interface = dev.parse_interfaces(name) || {}
    end

    interface[name]
  end

  def flush
    transport.command do |dev|
      interface = resource[:name]
      # native vlans can be used only on truck mode.
      is_native = resource[:istrunkforinterface]

      dev.update_interface(resource, former_properties, properties, interface, is_native)
    end
    super
  end

  def self.post_resource_eval()
    Puppet.info "Saving running-config to start-up config"
    @transport.execute("copy running-config startup-config")
    super()
  end
end
