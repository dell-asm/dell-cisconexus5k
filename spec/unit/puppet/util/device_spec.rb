#! /usr/bin/env ruby
#provider_path = Pathname.new(__FILE__).parent.parent
require 'puppet/provider/cisconexus5k'
require 'puppet_x/cisconexus5k/transport'
require 'spec_helper'
require 'yaml'
require 'fixtures/unit/puppet/util/device_fixture'

describe PuppetX::Cisconexus5k::Transport do

  skip "skipping as it is unused device spec" do

    before(:each) do
      @transport = double('transport')
      my_url = 'ssh://admin:p!ssw0rd@172.17.7.15:22/'
      @cisco = PuppetX::Cisconexus5k::Transport.new(my_url)
      @cisco.transport = @transport
    end

    describe 'when creating the device.' do
      it 'should find the enable password from the url.' do
        cisco = PuppetX::Cisconexus5k::Transport.new('ssh://admin:p!ssw0rd@172.17.7.15:22/?enable=enable_password')
        cisco.enable_password == 'enable_password'
      end
    end

    context "when device provider is created." do
      it "should have connect method defined." do
        described_class.instance_method(:connect).should_not == nil

      end

      it "should have disconnect method defined." do
        described_class.instance_method(:disconnect).should_not == nil
      end

      it "should have command method defined." do
        described_class.instance_method(:command).should_not == nil
      end

      it "should have execute method defined." do
        described_class.instance_method(:execute).should_not == nil
      end

      it "should have login method defined." do
        described_class.instance_method(:login).should_not == nil
      end

      it "should have parent 'Puppet::Util::NetworkDevice::Base_nxos'" do
        @cisco.should be_kind_of(PuppetX::Cisconexus5k::Transport)
      end
    end

    describe "when connecting to the physical device." do
      it "should connect to the transport." do
        @transport.should_receive(:connect)
        @transport.should_receive(:handles_login?).and_return(true)
        @transport.should_receive(:command).once.with("terminal length 0")
        @cisco.connect
      end

      it "should attempt to login." do
        @transport.should_receive(:connect)
        @cisco.should_receive(:login)
        @transport.should_receive(:command).once.with("terminal length 0")
        @cisco.connect
      end
    end
    describe "when login in." do
      it "should not login if transport handles login." do
        @transport.should_receive(:handles_login?).and_return(true)
        @transport.should_not_receive(:command)
        @transport.should_not_receive(:expect)
        @cisco.login
      end

      it "should send username and password if transport don't handle login." do
        @transport.should_receive(:handles_login?).and_return(false)
        @transport.should_receive(:command).with("admin", {:prompt => /^Password:/})
        @transport.should_receive(:command).with("p!ssw0rd")
        @cisco.login
      end

      it "should expect the Password: prompt if no user was sent." do
        @transport.should_receive(:handles_login?).and_return(false)
        @cisco.url.user = ''
        @transport.should_receive(:expect).once.with(/^Password:/)
        @transport.should_receive(:command).once.with("p!ssw0rd")
        @cisco.login
      end
    end

    describe "when disconnecting from the device." do
      it "should disconnect from the transport." do
        @transport.should_receive(:close)
        @cisco.disconnect
      end
    end

    describe "when parsing VLANs" do
      before do
        @vlan_output = Device_fixture.new.get_devicevlans
      end
      it "should parse VLANs." do
        @cisco.should_receive(:execute).once.with("show vlan brief").and_return(@vlan_output)
        vlans = @cisco.parse_vlans
        vlans.has_key?("1").should == true
      end
    end

    describe "when parsing Zones." do
      before do
        @zone_output = Device_fixture.new.get_devicezones
      end
      it "should parse Zones." do
        @cisco.should_receive(:execute).once.with("show zone").and_return(@zone_output)
        zones = @cisco.parse_zones
        zones.has_key?("Zone_Demo1").should == true
      end
    end

    describe "when parsing Alias." do
      before do
        @alias_output = Device_fixture.new.get_devicealias
        @temp_alias = "Alias_Demo1"
      end
      it "should parse Alias." do
        @cisco.should_receive(:execute).once.with("show device-alias database").and_return(@alias_output)
        aliashash = @cisco.parse_alias
        aliashash.has_key?(@temp_alias).should == true
      end
    end

    describe "when parsing Zonesets." do
      before do
        @activezoneset_output = Device_fixture.new.get_deviceactivezonesets
        @allzoneset_output = Device_fixture.new.get_devicezonesets
      end
      it "should parse Active Zonesets." do
        @cisco.should_receive(:execute).once.with("show zoneset active").and_return(@activezoneset_output)
        activezonesets = @cisco.get_active_zonesets
        activezonesets.has_key?("VSAN_999_Zoneset_Demo1").should == true
      end
      it "should parse All Zonesets." do
        @cisco.should_receive(:execute).once.with("show zoneset active").and_return(@activezoneset_output)
        activezonesets = @cisco.get_active_zonesets
        @cisco.should_receive(:get_active_zonesets).once.and_return(activezonesets)
        @cisco.should_receive(:execute).once.with("show zoneset brief").and_return(@allzoneset_output)
        allzonesets = @cisco.get_all_zonesets
        allzonesets.has_key?("VSAN_999_Zoneset_Demo1").should == true
      end
    end
  end
end

