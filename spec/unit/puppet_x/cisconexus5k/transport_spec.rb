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
              :mtu => "9216", :speed => "10000", :istrunkforportchannel => "true"}
    is = {:name => "200", :protocol => "NONE", :interfaces => "Eth1/5(D)    "}

    before(:each) do
      expect(transport).to receive(:execute).with("conf t")
      expect(transport).to receive(:execute).with("show interface po200")
    end

    it "should create a port channel for trunk port" do
      expect(transport).to receive(:addmembertotrunkvlan).with("17,19", "20", "200", "dot1q")
      expect(transport).to receive(:execute).with("interface port-channel 200")
      expect(transport).to receive(:execute).with("speed 10000")
      expect(transport).to receive(:execute).with("mtu 9216")
      expect(transport).to receive(:execute).with("no shutdown")
      expect(transport).not_to receive(:execute).with("switchport mode access")

      transport.update_port_channel("17,19", "20", {}, is, should, "200", "true", {}, "present")
    end

    it "should create access port port-channel" do
      expect(transport).not_to receive(:addmembertotrunkvlan).with("17,19", "20", "200", "dot1q")
      expect(transport).to receive(:execute).with("interface port-channel 200")
      expect(transport).to receive(:execute).with("switchport")
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
  end

  describe "#update_interface" do
    is = {:switchport_mode => "trunk", :port_channel => "200", :untagged_general_vlans => nil, :tagged_general_vlans => "17,99", :access_vlan => nil}
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
      resource = {:name => "Eth1/5", :untagged_general_vlans => "20",:tagged_general_vlans  => "17", :ensure => :present,
                  :istrunkforinterface => "true", :mtu => "9216", :speed => "10000", :removeallassociatedvlans => "false"
      }

      expect(transport).to receive(:gettrunkinterfacestatus).and_return("access")
      expect(transport).to receive(:getencapsulationtype).and_return("")
      expect(transport).to receive(:execute).with("switchport mode trunk")
      expect(transport).to receive(:execute).with("switchport trunk native vlan 20")
      expect(transport).to receive(:execute).with("switchport trunk allowed vlan add 17")
      expect(transport).to receive(:execute).at_least(3).times

      transport.update_interface(resource,is,should,"Eth1/5","true")
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
