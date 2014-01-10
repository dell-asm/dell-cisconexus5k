#! /usr/bin/env ruby
#provider_path = Pathname.new(__FILE__).parent.parent
require 'puppet/provider/cisconexus5k'
require 'puppet/util/network_device/cisconexus5k/device'

require 'spec_helper'
require 'yaml'

describe Puppet::Util::NetworkDevice::Cisconexus5k::Device do

  before(:each) do
    @transport = double('transport')
    my_url = 'ssh://admin:p!ssw0rd@172.17.7.15:22/'
    @cisco = Puppet::Util::NetworkDevice::Cisconexus5k::Device.new(my_url)
    @cisco.transport = @transport
  end

  describe 'when creating the device.' do
    it 'should find the enable password from the url.' do
      cisco = Puppet::Util::NetworkDevice::Cisconexus5k::Device.new('ssh://admin:p!ssw0rd@172.17.7.15:22/?enable=enable_password')
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
      @cisco.should be_kind_of(Puppet::Util::NetworkDevice::Base_nxos)
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
      @vlan_output = <<END
NEXUS-5548-Top# show vlan brief

VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    Po27, Po125, Eth1/18, Eth1/19
                                                Eth1/20, Eth1/21, Eth1/22
                                                Eth1/23, Eth1/24, Eth1/25
                                                Eth1/27, Eth1/28, Eth1/29
                                                Eth1/30
235   vMotion_Net                      active    Po1, Po3, Po5, Po10, Po20
                                                Po125, Po128, Eth1/1, Eth1/2
                                                Eth1/3, Eth1/4, Eth1/5, Eth1/6
                                                Eth1/7, Eth1/8, Eth1/9, Eth1/10
                                                Eth1/17, Eth1/29, Eth1/30
                                                Eth1/31, Eth1/32
288   Hypervisor_Mgmt                  active    Po1, Po3, Po5, Po10, Po20
                                                Po125, Po128, Eth1/1, Eth1/2
                                                Eth1/3, Eth1/4, Eth1/5, Eth1/6
                                                Eth1/7, Eth1/8, Eth1/9, Eth1/10
                                                Eth1/17, Eth1/29, Eth1/30
                                                Eth1/31, Eth1/32
50   VLAN_50                           active
255  VLAN_255                          active
256  VLAN_256                         active
1111 VLAN1111                         active    Po11, Po13, Po15, Po27, Eth1/11
                                                Eth1/12, Eth1/13, Eth1/14
                                                Eth1/15, Eth1/16, Eth1/27
                                                Eth1/28

NEXUS-5548-Top#
END
    end
    it "should parse VLANs." do
      @cisco.should_receive(:execute).once.with("show vlan brief").and_return(@vlan_output)
      vlans = @cisco.parse_vlans
      vlans.has_key?("1").should == true
    end
  end

  describe "when parsing Zones." do
    before do
      @zone_output = <<END
NEXUS-5548-Bottom# show zone
zone name temp vsan 999
  pwwn 50:0a:09:89:88:89:93:0a

zone name EMC_VNX vsan 999

zone name zone6 vsan 999
  pwwn 20:01:74:86:7a:d7:df:4d
  fcalias name EMC_VNX vsan 999
    pwwn 50:09:01:61:3e:e0:39:dc
    pwwn 50:06:09:60:3e:e0:39:dc

zone name Zone_Demo1 vsan 999
  pwwn 20:01:74:76:7a:d7:cb:59 [hostwwpn]
  pwwn 50:00:d3:17:00:5e:c4:24 [netappwwpn3]
  pwwn 50:00:d3:10:70:5e:c4:0a [netappwwpn4]
NEXUS-5548-Bottom#
END
    end
    it "should parse Zones." do
      @cisco.should_receive(:execute).once.with("show zone").and_return(@zone_output)
      zones = @cisco.parse_zones
      zones.has_key?("Zone_Demo1").should == true
    end
  end

  describe "when parsing Alias." do
    before do
      @alias_output = <<END
NEXUS-5548-Bottom# show device-alias database
device-alias name hostwwpn pwwn 20:01:74:86:7n:d7:cb:59
device-alias name Alias_Demo1 pwwn 20:01:00:0e:aa:34:00:07
device-alias name netappwwpn1 pwwn 50:00:d3:17:00:5e:c4:05
device-alias name netappwwpn2 pwwn 50:00:d3:10:70:5e:c4:23
device-alias name netappwwpn3 pwwn 50:00:d3:10:07:5e:c4:24
device-alias name netappwwpn4 pwwn 50:00:d3:10:00:7e:c4:0a
device-alias name abc_4K5JMY1_B2 pwwn 21:00:00:84:ff:4b:53:b3
device-alias name ABC_5K5JMY1_B2 pwwn 21:00:00:94:ff:4b:1b:57
device-alias name ABC_6K5JMY1_B2 pwwn 21:00:00:54:ff:4b:53:4d
device-alias name ABC_7K5JMY1_B2 pwwn 21:00:00:26:ff:4b:52:e9
device-alias name ABC_8K5JMY1_B2 pwwn 21:00:00:64:ff:4b:53:85
device-alias name ABC_CK5JMY1_B2 pwwn 21:00:00:25:ff:4b:18:e5

Total number of entries = 12
NEXUS-5548-Bottom#
END
    end
    it "should parse Alias." do
      @cisco.should_receive(:execute).once.with("show device-alias database").and_return(@alias_output)
      aliashash = @cisco.parse_alias
      aliashash.has_key?("Alias_Demo1").should == true
    end
  end


  describe "when parsing Zonesets." do
    before do
      @activezoneset_output = <<END
NEXUS-5548-Bottom# show zoneset active
zoneset name Zoneset_Demo1 vsan 999
  zone name Zone_Demo1 vsan 999
  * fcid 0x5f0000 [pwwn 57:0a:09:81:88:89:93:0a]

  zone name abcde6 vsan 999
    pwwn 20:01:74:46:7a:d7:hf:4d
    pwwn 50:06:02:61:3e:e0:34:dc
    pwwn 50:06:03:60:3e:e0:36:dc

  zone name abcde1 vsan 999
    pwwn 50:06:01:61:3e:e0:36:dc
    pwwn 50:06:01:60:3e:e0:39:dc
  * fcid 0x5f0526 [pwwn 20:01:74:86:7a:d7:cb:59] [hostwwpn]
  * fcid 0x5f00f0 [pwwn 50:00:d3:10:00:5e:c4:0a] [netappwwpn4]
  * fcid 0x5f00a5 [pwwn 50:00:d3:10:00:5e:c4:24] [netappwwpn3]

  zone name Zone_Demo1 vsan 999
  * fcid 0x5f0025 [pwwn 20:01:44:86:7a:d7:cb:59] [hostwwpn]
  * fcid 0x5f04a1 [pwwn 50:00:d3:10:00:5e:c4:24] [netappwwpn3]
  * fcid 0x5f30a0 [pwwn 50:00:d2:10:00:5e:c4:0a] [netappwwpn4]
NEXUS-5548-Bottom#
END
    @allzoneset_output = <<END
NEXUS-5548-Bottom# show zoneset brief
zoneset name Zoneset_Demo1 vsan 999
  zone Zone_Demo1
  zone abcde6
  zone abcde1
  zone Zone_Demo1
NEXUS-5548-Bottom#
END
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

#    my_url = 'ssh://admin:p!ssw0rd@172.17.7.15:22/'
#    my_device = Puppet::Util::NetworkDevice::Cisconexus5k::Device.new(my_url)
#    my_device.connect()
#    let :provider do
#        described_class.new(my_url)
#    end

#    describe "when parse zonesets" do
#        it "Parse Zonesets" do
#	   @cisco.connect()
#           syszonesets = @cisco.parse_zonesets
#           puts ("#{syszonesets}")
#        end
#    end
    

end

