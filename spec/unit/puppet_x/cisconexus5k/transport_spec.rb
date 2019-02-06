require 'spec_helper'
require 'puppet_x/cisconexus5k/transport'
require 'puppet_x/cisconexus5k/ssh'
require 'pry'

describe PuppetX::Cisconexus5k::Transport do
  let(:certname) { "cisconexus5k-172.17.7.15" }
  let(:options) { {:device_config=>{:scheme=>"ssh", :host=>"172.17.11.13", :port=>22, :password=>"P@ssw0rd", :user=>"admin"}} }
  let(:transport) { PuppetX::Cisconexus5k::Transport.new(certname, options) }
  let(:interfaceid) { "Eth1/19" }

  describe "#show_vlans" do
    it "should return a list of tagged vlans" do
      vlan_info = PuppetSpec.load_fixture("show_switchport_vlan/vlan_info.out")
      expect(transport).to receive(:execute).with("show running-config interface #{interfaceid}").and_return(vlan_info)
      expect(transport.show_vlans(interfaceid)).to eq([18, 20, 23, 24, 29, 1003])
    end

    it "should return a empty list when there were no tagged" do
      vlan_info = PuppetSpec.load_fixture("show_switchport_vlan/vlan_notagged_info.out")
      expect(transport).to receive(:execute).with("show running-config interface #{interfaceid}").and_return(vlan_info)
      expect(transport.show_vlans(interfaceid)).to eq([])
    end

    it "should return range of tagged vlans" do
      vlan_info = PuppetSpec.load_fixture("show_switchport_vlan/vlan_range_info.out")
      expect(transport).to receive(:execute).with("show running-config interface #{interfaceid}").and_return(vlan_info)
      expect(transport.show_vlans(interfaceid)).to eq([20, 24, 25, 26, 27, 28, 29, 1003])
    end
  end

  describe "#update_port_channel" do
    should = {:name => "200", :protocol => "NONE", :interfaces => "Eth1/5(D)    ",
              :untagged_vlan => "1", :tagged_vlan => "99,17",
              :mtu => "9216",:interface_port =>"Eth1/5", :speed => "10000", :istrunkforportchannel => "true", :removeallassociatedvlans => "true"}
    is = {:name => "200", :protocol => "NONE", :interfaces => "Eth1/5(D)    ", :speed => nil}
    interface_config = {"Eth1/5" => {:name => "200", :protocol => "NONE", :interfaces => "Eth1/5(D)    ", :speed => nil}}

    before(:each) do
      expect(transport).to receive(:execute).with("conf t")
      expect(transport).to receive(:execute).with("show interface po200")
    end

    it "should create a port channel for trunk port" do
      expect(transport).to receive(:addmembertotrunkvlan).with("17,19", "20", "200", "dot1q", "true")
      expect(transport).to receive(:execute).with("interface port-channel 200")
      expect(transport).to receive(:execute).with("speed 10000")
      expect(transport).to receive(:execute).with("mtu 9216")
      expect(transport).to receive(:execute).with("no shutdown")
      expect(transport).not_to receive(:execute).with("switchport mode access")

      transport.update_port_channel("17,19", "20", {}, is, should, "200", "true", {}, "present")
    end

    it "should create access port port-channel" do
      expect(transport).not_to receive(:addmembertotrunkvlan).with("17,19", "20", "200", "dot1q", "true")
      expect(transport).to receive(:execute).with("interface port-channel 200")
      expect(transport).to receive(:execute).with("switchport")
      expect(transport).to receive(:execute).with("show interface po200 switchport")
      expect(transport).to receive(:execute).with("switchport mode access")
      expect(transport).to receive(:execute).with("switcport access vlan 20")
      expect(transport).to receive(:execute).with("speed 10000")
      expect(transport).to receive(:execute).with("mtu 9216")
      expect(transport).to receive(:execute).with("no shutdown")
      expect(transport).to receive(:execute).exactly(2).times.with("exit")

      transport.update_port_channel(nil, nil, "20", is, should, "200", "false", {}, :present)
    end

    it "should remove existing port channel" do
      expect(transport).to receive(:execute).with("no interface port-channel 200")
      expect(transport).to receive(:execute).exactly(1).times.with("exit")

      transport.update_port_channel(nil, nil, "20", is, should, "200", "false", {}, :absent)
    end

    it "should raise error if port-channel is in access mode and resource is set to trunk-mode when server is already provisioned" do
      config = {:name => "200", :protocol => "NONE", :interfaces => "Eth1/5(D)    ",
                :untagged_vlan => "1", :tagged_vlan => "99,17",
                :mtu => "9216", :speed => "10000", :istrunkforportchannel => "true", :removeallassociatedvlans => "false", :enforce_portchannel => "false"}
      is = {:name => "200", :protocol => "NONE", :interfaces => "Eth1/5(D)    "}

      expect(transport).to receive(:execute).with("interface port-channel 200")
      expect(transport).to receive(:execute).with("switchport")
      expect(transport).to receive(:execute).with("show interface po200 switchport").and_return("Operational Mode: access")
      expect(Puppet).to receive(:warning).with("port-channel is in access mode cannot change at this stage skipping further config")

      transport.update_port_channel(25, 20, nil, is, config, "200", "true", {}, :present)
    end

    it "should raise error if port-channel is in trunk mode and resource config is set to access mode after initial switch config" do
      config = {:name => "200", :protocol => "NONE", :interfaces => "Eth1/5(D)    ", :access_vlan => 20,
                :mtu => "9216", :speed => "10000", :istrunkforportchannel => "true", :removeallassociatedvlans => "false"}
      is = {:name => "200", :protocol => "NONE", :interfaces => "Eth1/5(D)    "}

      expect(transport).to receive(:execute).with("interface port-channel 200")
      expect(transport).to receive(:execute).with("switchport")
      expect(transport).to receive(:execute).with("show interface po200 switchport").and_return("Operational Mode: trunk")
      expect(Puppet).to receive(:warning).with("port-channel is in trunk mode cannot change at this stage skipping further config")

      transport.update_port_channel(nil, nil, 20, is, config, "200", "false", {}, :present)
    end
  end

  describe "#update_interface" do
    is = {:switchport_mode => "trunk", :port_channel => nil, :untagged_general_vlans => nil, :tagged_general_vlans => "17,99", :access_vlan => nil}
    should = {:switchport_mode => "trunk",
              :port_channel => "200",
              :untagged_general_vlans => "1",
              :tagged_general_vlans => "99,17",
              :access_vlan => nil,
              :mtu => "9216",
              :speed => "10000",
              :shutdown => :false,
              :interfaceencapsulationtype => "dot1q",
              :is_lacp => :false,
              :istrunkforinterface => "true"}

    it "should create an interface port" do
      resource = {:name => "Eth1/5", :untagged_general_vlans => "20", :tagged_general_vlans => "17", :ensure => :present,
                  :istrunkforinterface => "true", :mtu => "9216", :speed => "10000", :removeallassociatedvlans => "true"
      }

      expect(transport).to receive(:gettrunkinterfacestatus).and_return("access")
      expect(transport).to receive(:getencapsulationtype).and_return("")
      expect(transport).to receive(:execute).with("switchport mode trunk")
      expect(transport).to receive(:execute).with("switchport trunk native vlan 20")
      expect(transport).to receive(:execute).with("switchport trunk allowed vlan 17")
      expect(transport).to receive(:execute).at_least(3).times

      transport.update_interface(resource, is, should, "Eth1/5", "true")
    end

    it "should not change interface if port-channel is already configured" do
      resource = {:name => "Eth1/5", :port_channel => "200", :untagged_general_vlans => "20", :tagged_general_vlans => "17", :ensure => :present,
                  :istrunkforinterface => "true", :mtu => "9216", :speed => "10000", :removeallassociatedvlans => "false"
      }

      is_resource = {:switchport_mode => "trunk", :port_channel => 200, :untagged_general_vlans => nil, :tagged_general_vlans => "17,99", :access_vlan => nil}

      expect(transport).not_to receive(:gettrunkinterfacestatus)
      expect(transport).not_to receive(:getencapsulationtype)
      expect(transport).not_to receive(:execute).with("switchport mode trunk")
      expect(transport).not_to receive(:execute).with("switchport trunk native vlan 20")
      expect(transport).not_to receive(:execute).with("switchport trunk allowed vlan 17")
      expect(transport).to receive(:execute).at_least(1).times

      transport.update_interface(resource, is_resource, should, "Eth1/5", "true")
    end

    it "should not override is port speed is already set" do
      resource = {:name => "Eth1/5" , :untagged_general_vlans => "20", :tagged_general_vlans => "17", :ensure => :present,
                  :istrunkforinterface => "true", :mtu => "9216", :speed => "10000", :removeallassociatedvlans => "true"
      }

      is_resource = {:switchport_mode => "trunk",:port_channel => 200, :untagged_general_vlans => nil, :tagged_general_vlans => "17,99", :access_vlan => nil, :speed => "10000"}

      expect(transport).to receive(:gettrunkinterfacestatus).and_return("access")
      expect(transport).to receive(:getencapsulationtype).and_return("")
      expect(transport).to receive(:execute).with("speed 10000")
      expect(transport).to receive(:execute).with("no channel-group")
      expect(transport).to receive(:execute).at_least(3).times


      transport.update_interface(resource, is_resource, should, "Eth1/5", "true")
    end

    it "should remove already existing port-channel when removeallassociatedvlans is true" do
      resource = {:name => "Eth1/5" , :untagged_general_vlans => "20", :tagged_general_vlans => "17", :ensure => :present,
                  :istrunkforinterface => "true", :mtu => "9216", :speed => "10000", :removeallassociatedvlans => "true"
      }

      is_resource = {:switchport_mode => "trunk",:port_channel => 200, :untagged_general_vlans => nil, :tagged_general_vlans => "17,99", :access_vlan => nil}

      expect(transport).to receive(:gettrunkinterfacestatus).and_return("access")
      expect(transport).to receive(:getencapsulationtype).and_return("")
      expect(transport).to receive(:execute).with("no channel-group")
      expect(transport).to receive(:execute).at_least(3).times

      transport.update_interface(resource, is_resource, should, "Eth1/5", "true")
    end

    it "should not configure port-channel if there no port-channel and enforce_portchannel is false" do
      resource = {:name => "Eth1/5", :enforce_portchannel => "false", :port_channel => "200", :untagged_general_vlans => "20", :tagged_general_vlans => "17", :ensure => :present,
                  :istrunkforinterface => "true", :mtu => "9216", :speed => "10000", :removeallassociatedvlans => "true"}
      is_resource = {:switchport_mode => "trunk", :port_channel => nil, :untagged_general_vlans => nil, :tagged_general_vlans => "17,99", :access_vlan => nil}

      expect(transport).to receive(:gettrunkinterfacestatus).and_return("access")
      expect(transport).to receive(:getencapsulationtype).and_return("")
      expect(transport).to receive(:execute).with("switchport mode trunk")
      expect(transport).to receive(:execute).with("switchport trunk native vlan 20")
      expect(transport).to receive(:execute).with("switchport trunk allowed vlan 17")
      expect(transport).not_to receive(:execute).with("channel-group 200")
      expect(transport).to receive(:execute).at_least(3).times

      transport.update_interface(resource, is_resource, should, "Eth1/5", "true")
    end

    it "should raise error if interface port is in access mode and expected port-mode is trunk and removeallassociatedvlans value is false" do
      resource = {:name => "Eth1/5", :enforce_portchannel => "false", :port_channel => "200", :untagged_general_vlans => "20", :tagged_general_vlans => "17", :ensure => :present,
                  :istrunkforinterface => "true", :mtu => "9216", :speed => "10000", :removeallassociatedvlans => "false"}
      is_resource = {:switchport_mode => "access", :port_channel => nil, :untagged_general_vlans => nil, :tagged_general_vlans => "17,99", :access_vlan => nil}
      expect(transport).to receive(:gettrunkinterfacestatus).and_return("access")
      expect(transport).to receive(:getencapsulationtype).and_return("")
      expect(transport).not_to receive(:execute).with("switchport mode trunk")
      expect(transport).to receive(:execute).at_least(3).times
      expect(Puppet).to receive(:warning).with("Interface mode has been modified after initial switch configuration proceeding will disrupt the network skipping further config")

      transport.update_interface(resource, is_resource, should, "Eth1/5", "true")
    end

    it "should raise error if interface is in trunk mode, resource config is set to access mode and removeallassociatedvlans is set to false" do
      resource = {:name => "Eth1/5", :enforce_portchannel => "false", :port_channel => "200", :untagged_general_vlans => "20", :tagged_general_vlans => "17", :ensure => :present,
                  :istrunkforinterface => "false", :mtu => "9216", :speed => "10000", :removeallassociatedvlans => "false"}
      is_resource = {:switchport_mode => "trunk", :port_channel => nil, :untagged_general_vlans => nil, :tagged_general_vlans => "17,99", :access_vlan => nil}
      expect(transport).to receive(:execute).with("show interface Eth1/5")
      expect(transport).to receive(:execute).with("conf t")
      expect(transport).to receive(:execute).with("interface Eth1/5")
      expect(transport).to receive(:execute).with("show interface Eth1/5 switchport").and_return("Operational Mode: trunk")
      expect(Puppet).to receive(:warning).with("Interface-port is in trunk mode cannot be changed at this stage skipping further switch config")

      transport.update_interface(resource, is_resource, should, "Eth1/5", "true")
    end

    it "should not add untagged vlans to the trunk ports" do
      resource = {:name => "Eth1/5", :enforce_portchannel => "false", :port_channel => "200", :untagged_general_vlans => "NONE", :tagged_general_vlans => "17", :ensure => :present,
                  :istrunkforinterface => "true", :mtu => "9216", :speed => "10000", :removeallassociatedvlans => "true"}
      is_resource = {:switchport_mode => "trunk", :port_channel => nil, :untagged_general_vlans => "22", :tagged_general_vlans => "17,99", :access_vlan => nil}

      expect(transport).to receive(:execute).with("show interface Eth1/5")
      expect(transport).to receive(:execute).with("conf t")
      expect(transport).to receive(:execute).with("interface Eth1/5")
      expect(transport).to receive(:execute).with("show interface Eth1/5 trunk").and_return("Operational Mode: trunk")
      expect(transport).to receive(:execute).with("no switchport trunk native vlan")
      expect(transport).not_to receive(:execute).with("switchport trunk allowed vlan add 1")

      transport.update_interface(resource, is_resource, should, "Eth1/5", "true")
    end

    it "should copy running config when save_start_up_config is true" do
      resource = {:name => "Eth1/5", :enforce_portchannel => "false", :port_channel => "200", :tagged_general_vlans => "17", :ensure => :absent,
                  :istrunkforinterface => "false", :save_start_up_config => "true", :removeallassociatedvlans => "true"}
      is_resource = {}
      expect(transport).to receive(:execute).with("show interface Eth1/5")
      expect(transport).to receive(:execute).with("conf t")
      expect(transport).to receive(:execute).with("interface Eth1/5")
      expect(transport).to receive(:un_configure_access_port)
      expect(transport).to receive(:execute).with("exit").twice

      expect(transport).to receive(:execute).with("copy running-config startup-config")
      transport.update_interface(resource, is_resource, should, "Eth1/5", "true")
    end
  end

  describe "#update_tagged_vlans" do
    it "should remove extra tagged vlans" do
      expect(transport).to receive(:execute).with("config").ordered
      expect(transport).to receive(:execute).with("interface Eth1/19").ordered
      expect(transport).to receive(:execute).with("switchport trunk allowed vlan remove 18").ordered
      expect(transport).to receive(:execute).with("config").ordered
      expect(transport).to receive(:execute).with("interface Eth1/19").ordered
      expect(transport).to receive(:execute).with("switchport trunk allowed vlan remove 1003")
      transport.update_tagged_vlans("20", "Eth1/19", [18, 20, 1003])
    end

    it "should add tagged vlan" do
      expect(transport).to receive(:execute).with("config").ordered
      expect(transport).to receive(:execute).with("interface Eth1/19").ordered
      expect(transport).to receive(:execute).with("switchport trunk allowed vlan add 20").ordered
      transport.update_tagged_vlans("20", "Eth1/19", [])
    end

    it "should unset tagged vlan" do
      expect(transport).to receive(:execute).with("config").ordered
      expect(transport).to receive(:execute).with("interface Eth1/19").ordered
      expect(transport).to receive(:execute).with("switchport trunk allowed vlan remove 18").ordered
      expect(transport).to receive(:execute).with("config").ordered
      expect(transport).to receive(:execute).with("interface Eth1/19").ordered
      expect(transport).to receive(:execute).with("switchport trunk allowed vlan add 20").ordered
      transport.update_tagged_vlans("20", "Eth1/19", [18])
    end
  end
end
