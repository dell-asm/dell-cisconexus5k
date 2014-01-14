#! /usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:vlan) do
  vlan_conf = YAML.load_file(get_configpath('cisconexus5k','vlan_config.yml'))
  vlan_attrib = vlan_conf['vlan_configuration_type']
  let(:title) { 'vlan' }
  #++++++++++++++++++++++++++++++++++++++++++++++++++++
  context "should compile with given test params"  do

    let(:params) {{
        :name                           => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype']
      } }
    it do
      expect { should compile }
    end

  end
  #++++++++++++++++++++++++++++++++++++++++++++++++++++
  context "when validating attributes" do

    it "should have name as its keyattribute" do

      described_class.key_attributes.should == [:name]
    end

    describe "when validating attribute" do
      [:vlanname,:istrunkforinterface,:interface,:interfaceoperation,:interfaceencapsulationtype,:isnative,:nativevlanid,:removeallassociatedvlans,:deletenativevlaninformation,:unconfiguretrunkmode,:shutdownswitchinterface,:portchannel,:portchanneloperation,:istrunkforportchannel,:portchannelencapsulationtype].each do |param|
        it "should hava a #{param} parameter" do
          described_class.attrtype(param).should == :property
        end

      end

      [:ensure].each do |property|
        it "should have a #{property} property" do
          described_class.attrtype(property).should == :property
        end
      end

    end

  end
  #++++++++++++++++++++++++++++++++++++++++++++++++++++
  describe "when validating values" do
    describe "validating name property" do
      it "should allow a valid name" do
        described_class.new(:name       => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'])[:name].should == vlan_attrib['name']
      end

      it "should not allow blank value in the name" do
        expect { described_class.new(:name       => '',
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype']) }.to raise_error Puppet::Error
      end
    end
    describe "validating ensure property" do
      it "should support present value" do
        described_class.new(:name   => vlan_attrib['name'],
        :ensure                         => vlan_attrib['ensure'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'])[:ensure].should == (vlan_attrib['ensure'] == 'present' ? :present : (vlan_attrib['ensure'] == 'absent' ? :absent : vlan_attrib['ensure']))
      end

      it "should not allow values other than present or absent" do
        expect { described_class.new(:name   => vlan_attrib['name'],
          :ensure                         => 'xxx',
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype']) }.to raise_error Puppet::Error
      end
    end
    describe "validating vlanname property" do
      it "should support vlanname value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'])[:vlanname].should == vlan_attrib['vlanname']
      end
      it "should not support vlanname empty value" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => '',
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype']) }.to raise_error Puppet::Error
      end
    end
    describe "validating istrunkforinterface property" do
      it "should support istrunkforinterface value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'])[:istrunkforinterface].should == vlan_attrib['istrunkforinterface']
      end
      it "should not support istrunkforinterface empty value" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => '',
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype']) }.to raise_error Puppet::Error
      end

      it "should not allow values other than true or false" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => 'xxx',
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype']) }.to raise_error Puppet::Error
      end
    end
    describe "validating interface property" do
      it "should support interface value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'])[:interface].should == vlan_attrib['interface']
      end
      it "should not support interface empty value" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => '',
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype']) }.to raise_error Puppet::Error
      end
    end
    describe "validating interfaceoperation property" do
      it "should support interfaceoperation value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'])[:interfaceoperation].should == vlan_attrib['interfaceoperation']
      end
      it "should not support interfaceoperation empty value" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => '',
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype']) }.to raise_error Puppet::Error
      end
      it "should not allow values other than add or remove" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => 'xxx',
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype']) }.to raise_error Puppet::Error
      end
    end
    describe "validating interfaceencapsulationtype property" do
      it "should support interfaceencapsulationtype value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'])[:interfaceencapsulationtype].should == vlan_attrib['interfaceencapsulationtype']
      end
    end
    describe "validating isnative property" do
      it "should support isnative value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'])[:isnative].should == vlan_attrib['isnative']
      end
      it "should not allow values other than true or false" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => 'xxx',
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype']) }.to raise_error Puppet::Error
      end
      it "should not support isnative empty value" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => '',
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] ) }.to raise_error Puppet::Error
      end
    end
    describe "validating nativevlanid property" do
      it "should support nativevlanid value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] )[:nativevlanid].should == (vlan_attrib['nativevlanid'].to_i)
      end
      it "should not support nativevlanid empty value" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => '',
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] ) }.to raise_error Puppet::Error
      end
    end
    describe "validating removeallassociatedvlans property" do
      it "should support removeallassociatedvlans value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] )[:removeallassociatedvlans].should == vlan_attrib['removeallassociatedvlans']
      end

      it "should not support removeallassociatedvlans empty value" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => '',
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] ) }.to raise_error Puppet::Error
      end
      it "should not allow values other than true or false" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => 'xxx',
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype']) }.to raise_error Puppet::Error
      end
    end
    describe "validating deletenativevlaninformation property" do
      it "should support deletenativevlaninformation value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] )[:deletenativevlaninformation].should == vlan_attrib['deletenativevlaninformation']
      end
      it "should not support deletenativevlaninformation empty value" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => '',
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] ) }.to raise_error Puppet::Error
      end
      it "should not allow values other than true or false" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => 'xxx',
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype']) }.to raise_error Puppet::Error
      end
    end
    describe "validating unconfiguretrunkmode property" do
      it "should support unconfiguretrunkmode value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] )[:unconfiguretrunkmode].should == vlan_attrib['unconfiguretrunkmode']
      end
      it "should not allow values other than true or false" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => 'xxx',
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] ) }.to raise_error Puppet::Error
      end
      it "should not support unconfiguretrunkmode empty value" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => '',
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] ) }.to raise_error Puppet::Error
      end
    end
    describe "validating shutdownswitchinterface property" do
      it "should support shutdownswitchinterface value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] )[:shutdownswitchinterface].should == vlan_attrib['shutdownswitchinterface']
      end
      it "should not allow values other than true or false" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => 'xxx',
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] ) }.to raise_error Puppet::Error
      end
      it "should not support shutdownswitchinterface empty value" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => '',
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] ) }.to raise_error Puppet::Error
      end
    end
    describe "validating portchannel property" do
      it "should support portchannel value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] )[:portchannel].should == vlan_attrib['portchannel']
      end

      it "should not support portchannel empty value" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => '',
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] ) }.to raise_error Puppet::Error
      end
    end
    describe "validating portchanneloperation property" do
      it "should support portchanneloperation value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] )[:portchanneloperation].should == vlan_attrib['portchanneloperation']
      end
      it "should not allow values other than add or remove" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => 'xxx',
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] ) }.to raise_error Puppet::Error
      end
      it "should not support portchanneloperation empty value" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => '',
          :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] ) }.to raise_error Puppet::Error
      end
    end
    describe "validating istrunkforportchannel property" do
      it "should support istrunkforportchannel value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] )[:istrunkforportchannel].should == vlan_attrib['istrunkforportchannel']
      end
      it "should not allow values other than true or false" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => 'xxx',
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] ) }.to raise_error Puppet::Error
      end
      it "should not support istrunkforportchannel empty value" do
        expect { described_class.new(:name       => vlan_attrib['name'],
          :vlanname                       => vlan_attrib['vlanname'],
          :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
          :interface                      => vlan_attrib['interface'],
          :interfaceoperation             => vlan_attrib['interfaceoperation'],
          :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
          :isnative                       => vlan_attrib['isnative'],
          :nativevlanid                   => vlan_attrib['nativevlanid'],
          :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
          :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
          :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
          :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
          :portchannel                    => vlan_attrib['portchannel'],
          :portchanneloperation           => vlan_attrib['portchanneloperation'],
          :istrunkforportchannel          => '',
          :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] ) }.to raise_error Puppet::Error
      end
    end
    describe "validating portchannelencapsulationtype property" do
      it "should support portchannelencapsulationtype value" do
        described_class.new(:name   => vlan_attrib['name'],
        :vlanname                       => vlan_attrib['vlanname'],
        :istrunkforinterface            => vlan_attrib['istrunkforinterface'],
        :interface                      => vlan_attrib['interface'],
        :interfaceoperation             => vlan_attrib['interfaceoperation'],
        :interfaceencapsulationtype     => vlan_attrib['interfaceencapsulationtype'],
        :isnative                       => vlan_attrib['isnative'],
        :nativevlanid                   => vlan_attrib['nativevlanid'],
        :removeallassociatedvlans       => vlan_attrib['removeallassociatedvlans'],
        :deletenativevlaninformation    => vlan_attrib['deletenativevlaninformation'],
        :unconfiguretrunkmode           => vlan_attrib['unconfiguretrunkmode'],
        :shutdownswitchinterface        => vlan_attrib['shutdownswitchinterface'],
        :portchannel                    => vlan_attrib['portchannel'],
        :portchanneloperation           => vlan_attrib['portchanneloperation'],
        :istrunkforportchannel          => vlan_attrib['istrunkforportchannel'],
        :portchannelencapsulationtype   => vlan_attrib['portchannelencapsulationtype'] )[:portchannelencapsulationtype].should == vlan_attrib['portchannelencapsulationtype']
      end
    end
  end

end

