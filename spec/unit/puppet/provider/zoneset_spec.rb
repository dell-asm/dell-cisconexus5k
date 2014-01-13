#! /usr/bin/env ruby
provider_path = Pathname.new(__FILE__).parent.parent
require 'puppet/util/network_device/cisconexus5k/device'
require 'puppet/provider/cisconexus5k'
require 'spec_helper'
require 'yaml'
require 'fixtures/unit/puppet/provider/zoneset/zoneset_fixture'

#require 'rspec/expectations'

describe Puppet::Type.type(:zoneset).provider(:cisconexus5k) do

  before(:each) do
    my_url = 'ssh://admin:p!ssw0rd@172.17.7.15:22/'
    @device = Puppet::Util::NetworkDevice::Cisconexus5k::Device.new(my_url)
    @transport = double('transport')
    @device.transport = @transport
  end
  let :zonesetforupdate do
    Zoneset_fixture.new.get_dataforupdatezoneset
  end

  let :zonesetfordelete do
    Zoneset_fixture.new.get_datafordeletezoneset
  end

  let :providerforupdate do
    described_class.new(@device,zonesetforupdate)
  end

  let :providerfordelete do
    described_class.new(@device,zonesetfordelete)
  end

  describe "when updating zonesets." do
    it "should create zoneset" do
      @transport.should_receive(:connect)
      @transport.should_receive(:handles_login?).and_return(true)
      @transport.should_receive(:command).once.with("terminal length 0")
      @device.should_receive(:get_all_zonesets).and_return({})
      @device.should_receive(:execute).with("conf t").and_return("")
      @device.should_receive(:execute).with("zoneset name Demo_Zoneset1 vsan 999").and_return("")
      @device.should_receive(:execute).once.with("member Demo_Zone2")
      @device.should_receive(:execute).twice.with("exit")
      @device.should_receive(:disconnect)

      providerforupdate.flush
    end

    it "should update zoneset" do
      existingzoneset = { :name => "Demo_Zoneset1", :vsanid => "999", :member => ["Demo_Zone1"], :active => "false" }
      existingzonesets = {}
      existingzonesets["VSAN_999_Demo_Zoneset1"] = existingzoneset
      @transport.should_receive(:connect)
      @transport.should_receive(:handles_login?).and_return(true)
      @transport.should_receive(:command).once.with("terminal length 0")
      @device.should_receive(:get_all_zonesets).and_return(existingzonesets)
      @device.should_receive(:execute).with("conf t").and_return("")
      @device.should_receive(:execute).with("zoneset name Demo_Zoneset1 vsan 999").and_return("")
      @device.should_receive(:execute).with("no member Demo_Zone1")
      @device.should_receive(:execute).with("member Demo_Zone2")
      @device.should_receive(:execute).twice.with("exit")
      @device.should_receive(:disconnect)

      providerforupdate.flush
    end

    it "should delete zoneset" do
      existingzoneset = { :name => "Demo_Zoneset1", :vsanid => "999", :member => ["Demo_Zone1"], :active => "false" }
      existingzonesets = {}
      existingzonesets["VSAN_999_Demo_Zoneset1"] = existingzoneset
      @transport.should_receive(:connect)
      @transport.should_receive(:handles_login?).and_return(true)
      @transport.should_receive(:command).once.with("terminal length 0")
      @device.should_receive(:get_all_zonesets).and_return(existingzonesets)
      @device.should_receive(:execute).with("conf t").and_return("")
      @device.should_receive(:execute).with("no zoneset activate name Demo_Zoneset1 vsan 999").and_return("")
      @device.should_receive(:execute).with("zoneset name Demo_Zoneset1 vsan 999").and_return("")
      @device.should_receive(:execute).with("no member Demo_Zone1")
      @device.should_receive(:execute).with("no zoneset name Demo_Zoneset1 vsan 999").and_return("")
      @device.should_receive(:execute).twice.with("exit")
      @device.should_receive(:disconnect)

      providerfordelete.flush
    end

  end

end
