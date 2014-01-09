#! /usr/bin/env ruby
provider_path = Pathname.new(__FILE__).parent.parent
require 'puppet/provider/cisconexus5k'
require 'puppet/util/network_device/cisconexus5k/device'

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:vlan).provider(:cisconexus5k) do

    let :vlan do
        Puppet::Type.type(:vlan).new(
           :ensure                         => 'present',
           :name                           => '111',
           :vlanname                       => 'demovlan',
           :istrunkforinterface            => 'true',
           :interface                      => 'Eth1/17',
           :interfaceoperation             => 'add',
           :interfaceencapsulationtype     => 'dot1q',
           :isnative                       => 'true',
           :nativevlanid                   => '1',
           :removeallassociatedvlans       => 'true',
           :deletenativevlaninformation    => 'true',
           :unconfiguretrunkmode           => 'true',
           :shutdownswitchinterface        => 'true',
           :portchannel                    => '11',
           :portchanneloperation           => 'add',
           :istrunkforportchannel          => 'true',
           :portchannelencapsulationtype   => 'dot1q'         
        )
    end

    my_url = 'ssh://admin:p!ssw0rd@172.17.7.15:22/'
    my_device = Puppet::Util::NetworkDevice::Cisconexus5k::Device.new(my_url)

    let :provider do
        described_class.new(my_device,vlan)
    end

    describe "when asking exists?" do
        it "Create/Delete vlan" do
           provider.flush
           
        end
    end
    

end

