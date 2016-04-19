require 'spec_helper'
require 'puppet_x/cisconexus5k/transport'

describe PuppetX::Cisconexus5k::Transport do
  let(:fact_fixtures) { File.join(PuppetSpec::FIXTURE_DIR, "unit", "puppet_x", "cisconexus5k") }
  let(:transport) { PuppetX::Cisconexus5k::Transport.new("rspec-certname", :device_config => {:host => "rspec-host", :user => "rspec-user", :password => "rspec-password"}) }
  let(:sh_vlan_ouput) { File.read(File.join(fact_fixtures, "sh_vlan.out")) }
  let(:sh_int_trunk_output) { File.read(File.join(fact_fixtures, "sh_int_trunk.out")) }

  describe "#show_vlans" do

    it "should return a list of tagged vlans" do
      vlan_info = PuppetSpec.load_fixture("show_switchport_vlan/vlan_info.out")
      transport.stub(:execute).with("show running-config interface Eth1/19").and_return(vlan_info)
      expect(transport.show_vlans("Eth1/19")).to eq([18, 20, 23, 24, 29, 1003])
    end

    it "should return a empty list when there were no tagged vlans" do
      vlan_info = PuppetSpec.load_fixture("show_switchport_vlan/vlan_notagged_info.out")
      transport.stub(:execute).with("show running-config interface Eth1/19").and_return(vlan_info)
      expect(transport.show_vlans("Eth1/19")).to eq([])
    end

    it "should return range of tagged vlans" do
      vlan_info = PuppetSpec.load_fixture("show_switchport_vlan/vlan_range_info.out")
      transport.stub(:execute).with("show running-config interface Eth1/19").and_return(vlan_info)
      expect(transport.show_vlans("Eth1/19")).to eq([20, 24, 25, 26, 27, 28, 29, 1003])
    end
  end

  describe "#remove_tagged_vlans" do

    it "should remove extra tagged vlans" do
      expect(transport).to receive(:execute).with("config").ordered
      expect(transport).to receive(:execute).with("interface Eth1/19").ordered
      expect(transport).to receive(:execute).with("switchport trunk allowed vlan remove 18").ordered
      expect(transport).to receive(:execute).with("config").ordered
      expect(transport).to receive(:execute).with("interface Eth1/19").ordered
      expect(transport).to receive(:execute).with("switchport trunk allowed vlan remove 1003")
      transport.remove_tagged_vlans("20", "Eth1/19", [18, 20, 1003])
    end

    it "should add tagged vlan" do
      expect(transport).to receive(:execute).with("config").ordered
      expect(transport).to receive(:execute).with("interface Eth1/19").ordered
      expect(transport).to receive(:execute).with("switchport trunk allowed vlan add 20").ordered
      transport.remove_tagged_vlans("20", "Eth1/19", [])
    end

    it "should unset tagged valn" do
      expect(transport).to receive(:execute).with("config").ordered
      expect(transport).to receive(:execute).with("interface Eth1/19").ordered
      expect(transport).to receive(:execute).with("switchport trunk allowed vlan remove 18").ordered
      expect(transport).to receive(:execute).with("config").ordered
      expect(transport).to receive(:execute).with("interface Eth1/19").ordered
      expect(transport).to receive(:execute).with("switchport trunk allowed vlan add 20").ordered
      transport.remove_tagged_vlans("20", "Eth1/19", [18])
    end
  end
end
