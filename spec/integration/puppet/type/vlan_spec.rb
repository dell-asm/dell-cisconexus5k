#! /usr/bin/env ruby

require 'spec_helper'
describe Puppet::Type.type(:vlan) do
    let(:title) { 'vlan' }
    #++++++++++++++++++++++++++++++++++++++++++++++++++++
   context "should compile with given test params"  do 

    let(:params) {{
           :name                           => '111',
           :vlanname                       => 'demovlan',
           :istrunkforinterface            => 'true',
           :interface                      => 'Eth1/12',
           :interfaceoperation             => 'add',
           :interfaceencapsulationtype     => 'dot1q',
           :isnative                       => 'true',
           :nativevlanid                   => '1',
           :removeallassociatedvlans       => 'true',
           :deletenativevlaninformation    => 'true',
           :unconfiguretrunkmode           => 'true',
           :shutdownswitchinterface        => 'true',
           :portchannel                    => '11',
           :portchanneloperation           => 'add',
           :istrunkforportchannel          => 'true',
           :portchannelencapsulationtype   => 'dot1q'
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
            described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q')[:name].should == '111'
            end
                
            it "should not allow blank value in the name" do
            expect { described_class.new(:name => '',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q') }.to raise_error Puppet::Error
            end
        end
        describe "validating ensure property" do
            it "should support present value" do
                described_class.new(:name => '111',
            :ensure                         => 'present',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q')[:ensure].should == :present
            end
            
            it "should not allow values other than present or absent" do
                expect { described_class.new(:name => '111',
            :ensure                         => 'asdas',    
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q') }.to raise_error Puppet::Error
            end
        end
        describe "validating vlanname property" do
            it "should support vlanname value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q')[:vlanname].should == 'demovlan'
            end
            it "should not support vlanname empty value" do
                expect { described_class.new(:name => '111',
            :vlanname                       => '',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q') }.to raise_error Puppet::Error
            end
       end
        describe "validating istrunkforinterface property" do
            it "should support istrunkforinterface value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q')[:istrunkforinterface].should == 'true'
            end
            it "should not support istrunkforinterface empty value" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => '',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q') }.to raise_error Puppet::Error
            end
            
            it "should not allow values other than true or false" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'aaa',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q') }.to raise_error Puppet::Error
            end
        end
        describe "validating interface property" do
            it "should support interface value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q')[:interface].should == 'Eth1/12'
            end
            it "should not support interface empty value" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => '',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q') }.to raise_error Puppet::Error
            end
        end
        describe "validating interfaceoperation property" do
            it "should support interfaceoperation value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q')[:interfaceoperation].should == 'add'
            end
            it "should not support interfaceoperation empty value" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => '',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q') }.to raise_error Puppet::Error
            end
            it "should not allow values other than add or remove" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'aaa',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'aaa',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q') }.to raise_error Puppet::Error
            end
        end
        describe "validating interfaceencapsulationtype property" do
            it "should support interfaceencapsulationtype value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q')[:interfaceencapsulationtype].should == 'dot1q'
            end
        end
        describe "validating isnative property" do
            it "should support isnative value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q')[:isnative].should == 'true'
            end
            it "should not allow values other than true or false" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'aaa',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q') }.to raise_error Puppet::Error
            end
            it "should not support isnative empty value" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => '',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' ) }.to raise_error Puppet::Error
            end
        end
        describe "validating nativevlanid property" do
            it "should support nativevlanid value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' )[:nativevlanid].should == 1
            end
            it "should not support nativevlanid empty value" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' ) }.to raise_error Puppet::Error
            end
        end
        describe "validating removeallassociatedvlans property" do
            it "should support removeallassociatedvlans value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' )[:removeallassociatedvlans].should == 'true'
            end
            
            it "should not support removeallassociatedvlans empty value" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => '',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' ) }.to raise_error Puppet::Error
            end
            it "should not allow values other than true or false" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'aaa',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'aaa',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q') }.to raise_error Puppet::Error
            end
        end
        describe "validating deletenativevlaninformation property" do
            it "should support deletenativevlaninformation value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' )[:deletenativevlaninformation].should == 'true'
            end
            it "should not support deletenativevlaninformation empty value" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => '',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' ) }.to raise_error Puppet::Error
            end
            it "should not allow values other than true or false" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'aaa',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'aaa',
            :deletenativevlaninformation    => 'aaa',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q') }.to raise_error Puppet::Error
            end
        end
        describe "validating unconfiguretrunkmode property" do
            it "should support unconfiguretrunkmode value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' )[:unconfiguretrunkmode].should == 'true'
            end
            it "should not allow values other than true or false" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'aaa',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' ) }.to raise_error Puppet::Error
            end
            it "should not support unconfiguretrunkmode empty value" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => '',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' ) }.to raise_error Puppet::Error
            end
        end
        describe "validating shutdownswitchinterface property" do
            it "should support shutdownswitchinterface value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' )[:shutdownswitchinterface].should == 'true'
            end
            it "should not allow values other than true or false" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'aaa',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' ) }.to raise_error Puppet::Error
            end
            it "should not support shutdownswitchinterface empty value" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => '',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' ) }.to raise_error Puppet::Error
            end
        end
        describe "validating portchannel property" do
            it "should support portchannel value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' )[:portchannel].should == '11'
            end
            
            it "should not support portchannel empty value" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' ) }.to raise_error Puppet::Error
            end
        end
        describe "validating portchanneloperation property" do
            it "should support portchanneloperation value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' )[:portchanneloperation].should == 'add'
            end
            it "should not allow values other than add or remove" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'aaa',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' ) }.to raise_error Puppet::Error
            end
            it "should not support portchanneloperation empty value" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => '',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' ) }.to raise_error Puppet::Error
            end
        end
        describe "validating istrunkforportchannel property" do
            it "should support istrunkforportchannel value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' )[:istrunkforportchannel].should == 'true'
            end
            it "should not allow values other than true or false" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'aaa',
            :portchannelencapsulationtype   => 'dot1q' ) }.to raise_error Puppet::Error
            end
            it "should not support istrunkforportchannel empty value" do
                expect { described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => '',
            :portchannelencapsulationtype   => 'dot1q' ) }.to raise_error Puppet::Error
            end
        end
        describe "validating portchannelencapsulationtype property" do
            it "should support portchannelencapsulationtype value" do
                described_class.new(:name => '111',
            :vlanname                       => 'demovlan',
            :istrunkforinterface            => 'true',
            :interface                      => 'Eth1/12',
            :interfaceoperation             => 'add',
            :interfaceencapsulationtype     => 'dot1q',
            :isnative                       => 'true',
            :nativevlanid                   => '1',
            :removeallassociatedvlans       => 'true',
            :deletenativevlaninformation    => 'true',
            :unconfiguretrunkmode           => 'true',
            :shutdownswitchinterface        => 'true',
            :portchannel                    => '11',
            :portchanneloperation           => 'add',
            :istrunkforportchannel          => 'true',
            :portchannelencapsulationtype   => 'dot1q' )[:portchannelencapsulationtype].should == 'dot1q'
            end
        end
    end
    
end


