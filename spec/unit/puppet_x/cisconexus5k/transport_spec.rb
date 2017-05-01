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
