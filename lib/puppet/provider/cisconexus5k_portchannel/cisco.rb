require "puppet/provider/cisconexus5k"

Puppet::Type.type(:cisconexus5k_portchannel).provide :cisconexus5k, :parent => Puppet::Provider::Cisconexus5k do

  desc "Cisco switch/router provider for port channel."

  mk_resource_methods

  def self.get_current(name)
    port_channels = {}
    transport.command do |dev|
      port_channels = dev.parse_port_channels || []
    end
    port_channels[name]
  end

  def flush
    transport.command do |dev|
      dev.update_port_channel(resource[:tagged_vlan], resource[:untagged_vlan], resource[:access_vlan], former_properties, properties,
                             resource[:name], resource[:istrunkforportchannel],
                             resource[:portchanneloperation], resource[:ensure])

    end
    super
  end
end
