require 'spec_helper'
require 'puppet_x/cisconexus5k/facts'
require 'puppet_x/cisconexus5k/transport'
require 'puppet/util/network_device/transport/ssh'

describe PuppetX::Cisconexus5k::Facts do
  let(:fact_fixtures) {File.join(PuppetSpec::FIXTURE_DIR,"unit","puppet_x","cisconexus5k")}
  let(:facts) {PuppetX::Cisconexus5k::Facts.new(nil)}
  let(:sh_vlan_ouput) { File.read(File.join(fact_fixtures,"sh_vlan.out"))}
  let(:sh_interface_mac) {File.read(File.join(fact_fixtures,"sh_interface_mac.out"))}
  let(:sh_int_trunk_output) { File.read(File.join(fact_fixtures,"sh_int_trunk.out"))}
  let(:lldp_info) {File.read(File.join(fact_fixtures,"lldp_info.out"))}
  let(:interface_capabilities) {File.read(File.join(fact_fixtures, "capabilities.out"))}
  let(:transceiver_details) {File.read(File.join(fact_fixtures, "transceiver_details.out"))}
  let(:interface_mac_info) {File.read(File.join(fact_fixtures, "mac_address.out"))}
  let(:certname) { "cisconexus5k-172.17.7.15" }
  let(:options) { {:device_config=>{:scheme=>"ssh", :host=>"172.17.11.13", :port=>22, :password=>"P@ssw0rd", :user=>"admin"}} }
  let(:transport) { PuppetX::Cisconexus5k::Transport.new(certname, options) }

  describe "#get_vlan_information" do
    it "should return the correct fact data" do
      facts.stub(:sh_vlan_brief).and_return(sh_vlan_ouput)
      facts.stub(:sh_int_trunk).and_return(sh_int_trunk_output)
      vlan_information = facts.get_vlan_information
      expect(vlan_information).to include("18")
      expect(vlan_information["18"]).to eq({
                                             "tagged_tengigabit"=>"Te1/17,Te1/20,Te1/21,Te1/29,Te1/30,Te1/31,Te102/1/2,Te102/1/3",
                                             "untagged_tengigabit"=>"Te1/19",
                                             "tagged_fortygigabit"=>"",
                                             "untagged_fortygigabit"=>"",
                                             "tagged_portchannel"=>"Po125,Po128",
                                             "untagged_portchannel"=>""})
      expect(vlan_information).to include("1")
      expect(vlan_information["1"]).to include("untagged_portchannel")
      expect(vlan_information["1"]["untagged_portchannel"]).to eq("Po125,Po128")
    end
  end

  describe "#retrieve" do
    let(:facts) {PuppetX::Cisconexus5k::Facts.new(transport)}

    before do
      # device_config = mock("device_config")
      require 'asm/device_management'
      ASM::DeviceManagement.stub(:parse_device_config).and_return(options[:device_config])
      transport.stub(:command).and_return("rspec rsult mocking")
      transport.stub(:host).and_return("100.68.100.100")
      facts.stub(:get_vlan_information)
    end

    it "should get cisco 5k model name" do
      cisco_5k_model = "cisco Nexus5548 Chassis"
      transport.stub(:command).with("sh ver").and_return(cisco_5k_model)
      expect(facts.retrieve["model"]).to eq("Nexus5548")
    end

    it "should get cisco 3k model name" do
      cisco_3k_model = "cisco Nexus 3172T Chassis"
      transport.stub(:command).with("sh ver").and_return(cisco_3k_model)
      expect(facts.retrieve["model"]).to eq("Nexus3172T")
    end

    it "should get cisco 9k model name" do
      cisco_9k_model = "cisco Nexus9000 C9372PX chassis"
      transport.stub(:command).with("sh ver").and_return(cisco_9k_model)
      expect(facts.retrieve["model"]).to eq("Nexus9000")
    end

    it "should get correct lldp neighbors with intercace and mac address" do
      transport.stub(:command).with("show lldp neighbors detail").and_return(lldp_info)
      expect(JSON.parse(facts.retrieve[:remote_device_info])).to include({"interface" => "Eth1/52", "location" => "Ethernet1/52", "remote_mac" => "00:d7:8f:2a:b1:4d"})
    end

    it "should get correct mac-address of the switch" do
      transport.stub(:command).with("show interface mac-address").and_return(sh_interface_mac)
      expect(facts.retrieve["macaddress"]).to eq("b4:de:31:f2:e3:90")
    end

    describe "#Interface_link_speed" do
      before do
        transport.stub(:command).with("show interface brief").and_return("Eth1/35       1       eth  trunk  up      none                        10G(D) 2 \n")
        transport.stub(:command).with("show interface Eth1/35 mac-address").and_return(interface_mac_info)
      end

      it "should get correct interface-port link speed" do
        transport.stub(:command).with("show interface Eth1/35 transceiver").and_return(transceiver_details)
        transport.stub(:command).with("show interface Eth1/35 capabilities").and_return(interface_capabilities)
        expect(JSON.parse(facts.retrieve["Eth1/35"])["max_speed"]).to eq("10000")
      end

      it "should set 25000 speed for max_speed" do
        transceriver_info = transceiver_details.gsub(/SFP-H10GB-CU3M/, 'QSFP-100G-CR4')
        transport.stub(:command).with("show interface Eth1/35 capabilities").and_return(interface_capabilities)
        transport.stub(:command).with("show interface Eth1/35 transceiver").and_return(transceriver_info)

        expect(JSON.parse(facts.retrieve["Eth1/35"])["max_speed"]).to eq("25000")
      end

      it "should set 100000 speed for max_speed" do
        capabilities = interface_capabilities.gsub(/1000,10000,25000/, '10000,25000,100000')
        transceriver_info = transceiver_details.gsub(/SFP-H10GB-CU3M/, 'QSFP-40/100-SRBD')

        transport.stub(:command).with("show interface Eth1/35 capabilities").and_return(capabilities)
        transport.stub(:command).with("show interface Eth1/35 transceiver").and_return(transceriver_info)

        expect(JSON.parse(facts.retrieve["Eth1/35"])["max_speed"]).to eq("100000")
      end

      it "should set 100000 speed for max_speed for cable type QSFP-4X10G-AOC" do
        capabilities = interface_capabilities.gsub(/1000,10000,25000/, '10000,25000,100000')
        transceriver_info = transceiver_details.gsub(/SFP-H10GB-CU3M/, 'QSFP-4X10G-AOC')

        transport.stub(:command).with("show interface Eth1/35 capabilities").and_return(capabilities)
        transport.stub(:command).with("show interface Eth1/35 transceiver").and_return(transceriver_info)

        expect(JSON.parse(facts.retrieve["Eth1/35"])["max_speed"]).to eq("10000")
      end

      it "should set max speed 40000 for cable type QSFP-40G-CR4" do
        capabilities = interface_capabilities.gsub(/1000,10000,25000/, '10000,40000,100000')
        transceriver_info = transceiver_details.gsub(/SFP-H10GB-CU3M/, 'QSFP-40G-CR4')

        transport.stub(:command).with("show interface Eth1/35 capabilities").and_return(capabilities)
        transport.stub(:command).with("show interface Eth1/35 transceiver").and_return(transceriver_info)

        expect(JSON.parse(facts.retrieve["Eth1/35"])["max_speed"]).to eq("40000")
      end

      it "should set max_speed 25000 for cable type SFP-10/25G-LR-S" do
        capabilities = interface_capabilities.gsub(/1000,10000,25000/, '10000,40000,100000')
        transceriver_info = transceiver_details.gsub(/SFP-H10GB-CU3M/, 'SFP-10/25G-LR-S')

        transport.stub(:command).with("show interface Eth1/35 capabilities").and_return(capabilities)
        transport.stub(:command).with("show interface Eth1/35 transceiver").and_return(transceriver_info)
        expect(JSON.parse(facts.retrieve["Eth1/35"])["max_speed"]).to eq("25000")
      end

      it "should set max_speed 25000 for cable type QSFP40G-4SFP10G-CU5M" do
        capabilities = interface_capabilities.gsub(/1000,10000,25000/, '10000,40000,100000')
        transceriver_info = transceiver_details.gsub(/SFP-H10GB-CU3M/, 'QSFP40G-4SFP10G-CU5M')

        transport.stub(:command).with("show interface Eth1/35 capabilities").and_return(capabilities)
        transport.stub(:command).with("show interface Eth1/35 transceiver").and_return(transceriver_info)
        expect(JSON.parse(facts.retrieve["Eth1/35"])["max_speed"]).to eq("10000")
      end
    end
  end
end
