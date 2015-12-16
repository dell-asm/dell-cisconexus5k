require 'spec_helper'
require 'puppet_x/cisconexus5k/facts'

describe PuppetX::Cisconexus5k::Facts do
  let(:fact_fixtures) {File.join(PuppetSpec::FIXTURE_DIR,"unit","puppet_x","cisconexus5k")}
  let(:facts) {PuppetX::Cisconexus5k::Facts.new(nil)}
  let(:sh_vlan_ouput) { File.read(File.join(fact_fixtures,"sh_vlan.out"))}
  let(:sh_int_trunk_output) { File.read(File.join(fact_fixtures,"sh_int_trunk.out"))}

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
end