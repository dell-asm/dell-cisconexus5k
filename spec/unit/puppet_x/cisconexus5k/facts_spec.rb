require 'spec_helper'
require 'puppet_x/cisconexus5k/facts'
require 'puppet_x/cisconexus5k/transport'
require 'puppet/util/network_device/transport/ssh'

describe PuppetX::Cisconexus5k::Facts do
  let(:fact_fixtures) {File.join(PuppetSpec::FIXTURE_DIR,"unit","puppet_x","cisconexus5k")}
  let(:facts) {PuppetX::Cisconexus5k::Facts.new(nil)}
  let(:sh_vlan_ouput) { File.read(File.join(fact_fixtures,"sh_vlan.out"))}
  let(:sh_int_trunk_output) { File.read(File.join(fact_fixtures,"sh_int_trunk.out"))}
  let(:lldp_info) {File.read(File.join(fact_fixtures,"lldp_info.out"))}
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
  end
end
