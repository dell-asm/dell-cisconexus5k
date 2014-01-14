#! /usr/bin/env ruby
provider_path = Pathname.new(__FILE__).parent.parent
require 'puppet/util/network_device/cisconexus5k/device'
require 'puppet/provider/cisconexus5k'
require 'spec_helper'
require 'yaml'
require 'fixtures/unit/puppet/provider/vlan/vlan_fixture'

#require 'rspec/expectations'

describe Puppet::Type.type(:vlan).provider(:cisconexus5k) do

  before(:each) do
    my_url = 'ssh://admin:p!ssw0rd@172.17.7.15:22/'
    @device = Puppet::Util::NetworkDevice::Cisconexus5k::Device.new(my_url)
    @transport = double('transport')
    @device.transport = @transport
  end
  let :vlanforupdate do
    Vlan_fixture.new.get_dataforupdatevlan
  end

  let :vlanfordelete do
    Vlan_fixture.new.get_datafordeletevlan
  end

  let :providerforupdate do
    described_class.new(@device,vlanforupdate)
  end

  let :providerfordelete do
    described_class.new(@device,vlanfordelete)
  end

  describe "when updating vlan." do
    it "should create/update vlan" do
      @transport.should_receive(:connect)
      @transport.should_receive(:handles_login?).and_return(true)
      @transport.should_receive(:command).once.with("terminal length 0")
      @device.should_receive(:execute).with("conf t").and_return("")
      @device.should_receive(:execute).with("vlan #{vlanforupdate[:name]}").and_return("")
      @device.should_receive(:execute).twice.with("exit")

      @device.should_receive(:execute).with("show interface #{vlanforupdate[:interface]}")
      @device.should_receive(:execute).with("conf t").and_return("")
      @device.should_receive(:execute).with("interface #{vlanforupdate[:interface]}").and_return("")
      @device.should_receive(:execute).with("show interface #{vlanforupdate[:interface]} trunk").and_return("")
      @device.should_receive(:execute).with("show interface #{vlanforupdate[:interface]} Capabilities").and_return("Trunk encap. type: dot1q")
      @device.should_receive(:execute).twice.with("switchport").and_return("")
      @device.should_receive(:execute).with("switchport trunk encapsulation #{vlanforupdate[:interfaceencapsulationtype]}").and_return("")
      @device.should_receive(:execute).with("switchport mode trunk").and_return("")
      @device.should_receive(:execute).with("switchport trunk allowed vlan none").and_return("")
      @device.should_receive(:execute).with("switchport trunk native vlan #{vlanforupdate[:nativevlanid]}").and_return("")
      @device.should_receive(:execute).with("switchport trunk allowed vlan add #{vlanforupdate[:name]}").and_return("")
      @device.should_receive(:execute).with("no shutdown").and_return("")
      @device.should_receive(:execute).twice.with("exit")

      @device.should_receive(:execute).with("show interface po#{vlanforupdate[:portchannel]}").and_return("")
      @device.should_receive(:execute).with("conf t").and_return("")
      @device.should_receive(:execute).with("interface port-channel #{vlanforupdate[:portchannel]}").and_return("")
      @device.should_receive(:execute).with("show interface po#{vlanforupdate[:portchannel]} Capabilities").and_return("Trunk encap. type: dot1q")
      @device.should_receive(:execute).with("switchport").and_return("")
      @device.should_receive(:execute).with("show interface po#{vlanforupdate[:portchannel]} trunk").and_return("")
      @device.should_receive(:execute).with("switchport trunk encapsulation ").and_return("")
      @device.should_receive(:execute).with("switchport mode trunk").and_return("")
      @device.should_receive(:execute).with("show interface po#{vlanforupdate[:portchannel]} switchport").and_return("Trunking VLANs Allowed: NONE ")
      @device.should_receive(:execute).with("switchport trunk allowed vlan #{vlanforupdate[:name]}").and_return("")
      @device.should_receive(:execute).with("no shutdown").and_return("")
      @device.should_receive(:execute).twice.with("exit")
      @device.should_receive(:disconnect)

      providerforupdate.flush
    end

    it "should delete vlan" do
      @transport.should_receive(:connect)
      @transport.should_receive(:handles_login?).and_return(true)
      @transport.should_receive(:command).once.with("terminal length 0")
      #update interface
      @device.should_receive(:execute).with("show interface #{vlanfordelete[:interface]}")
      @device.should_receive(:execute).with("conf t").and_return("")
      @device.should_receive(:execute).with("interface #{vlanfordelete[:interface]}").and_return("")
      @device.should_receive(:execute).with("show interface #{vlanfordelete[:interface]} trunk").and_return("")
      @device.should_receive(:gettrunkinterfacestatus).with("").and_return("trunking")      
      @device.should_receive(:execute).with("no switchport trunk native vlan #{vlanfordelete[:nativevlanid]}").and_return("")
      @device.should_receive(:execute).with("switchport trunk allowed vlan remove #{vlanfordelete[:name]}").and_return("")
      @device.should_receive(:execute).with("no switchport mode trunk").and_return("")
      #@device.should_receive(:execute).with("shutdown").and_return("")
      @device.should_receive(:execute).twice.with("exit")
      #update portchannel
      @device.should_receive(:execute).with("show interface po#{vlanfordelete[:portchannel]}").and_return("")
      @device.should_receive(:execute).with("conf t").and_return("")
      @device.should_receive(:execute).with("interface port-channel #{vlanfordelete[:portchannel]}").and_return("")
      @device.should_receive(:execute).with("switchport trunk allowed vlan remove #{vlanfordelete[:name]}").and_return("")
      @device.should_receive(:execute).with("no switchport access vlan #{vlanfordelete[:name]}").and_return("")
      @device.should_receive(:execute).with("exit")
      #update vlan
      @device.should_receive(:execute).with("conf t").and_return("")
      @device.should_receive(:execute).with("no vlan #{vlanfordelete[:name]}").and_return("")
      @device.should_receive(:execute).with("exit")
      @device.should_receive(:disconnect)

      providerfordelete.flush
    end

  end

end
