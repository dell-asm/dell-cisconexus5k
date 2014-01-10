#! /usr/bin/env ruby
provider_path = Pathname.new(__FILE__).parent.parent
require 'puppet/provider/cisconexus5k'
require 'puppet/util/network_device/cisconexus5k/device'

require 'spec_helper'
require 'yaml'
require 'rspec/expectations'

describe Puppet::Type.type(:vlan).provider(:cisconexus5k) do
    vlan_conf=YAML.load_file(get_configpath('cisconexus5k','vlan_config.yml'))
    vlan_attrib = vlan_conf['vlan_configuration_provider']

    let :vlan do
        Puppet::Type.type(:vlan).new(
           :ensure                         => vlan_attrib['ensure'],
           :name                           => vlan_attrib['name'],
           :vlanname                       => vlan_attrib['vlanname'],
           :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
           :interface                      => vlan_attrib['interface'],
           :interfaceoperation             => vlan_attrib['interfaceoperation'],
           :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
           :isnative                       => vlan_attrib['isnative'],
           :nativevlanid                   => vlan_attrib['nativevlanid'],
           :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
           :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
           :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
           :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
           :portchannel                    => vlan_attrib['portchannel'],
           :portchanneloperation           => vlan_attrib['portchanneloperation'],
           :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
           :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype']         
        )
    end

    device_conf =  YAML.load_file(my_deviceurl('cisconexus5k','device_conf.yml'))
    my_device = Puppet::Util::NetworkDevice::Cisconexus5k::Device.new(device_conf['url'])

    let :provider do
        described_class.new(my_device,vlan)
    end

    describe "when asking exists?" do
        it "Create/Delete vlan" do
           provider.flush
           
        end
    end
    

end

