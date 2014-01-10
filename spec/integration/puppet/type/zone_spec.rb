#! /usr/bin/env ruby

require 'spec_helper'
describe Puppet::Type.type(:zone) do
    zone_conf = YAML.load_file(get_configpath('cisconexus5k','zone_config.yml'))
    zone_attrib = zone_conf['zone_configuration_type'] 
    let(:title) { 'zone' }
        #++++++++++++++++++++++++++++++++++++++++++++++++++++
   context "should compile with given test params"  do

    let(:params) {{
            :ensure                         => zone_attrib['ensure'],
            :name                           => zone_attrib['name'],
            :member                         => zone_attrib['member'],
            :membertype                     => zone_attrib['membertype'],
            :vsanid                         => zone_attrib['vsanid']

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

        describe "when vslidating attribute" do
            [:member,:membertype,:vsanid,:ensure].each do |param|
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
                describe "validating name" do
                    it "should allow a valid name" do
                    described_class.new(:name => zone_attrib['name'],
            :member                         => zone_attrib['member'],
            :membertype                     => zone_attrib['membertype'],
            :vsanid                         => zone_attrib['vsanid'],
            :ensure                         => zone_attrib['ensure'])[:name].should == 'Zone_EB'
                        end
                  it "should not allow blank value in the name" do
                        expect { described_class.new(:name => '',
            :member                         => zone_attrib['member'],
            :membertype                     => zone_attrib['membertype'],
            :vsanid                         => zone_attrib['vsanid'],
            :ensure                         => zone_attrib['ensure']) }.to raise_error Puppet::Error
                  end
                end
                describe "validating ensure property" do
                        it "should support present value" do
                    described_class.new(:name => zone_attrib['name'],
            :ensure                         => zone_attrib['ensure'],
            :member                         => zone_attrib['member'],
            :membertype                     => zone_attrib['membertype'],
            :vsanid                         => zone_attrib['vsanid'])[:ensure].should == :present
                        end

                        it "should not allow values other than present or absent" do
                                expect { described_class.new(:name => zone_attrib['name'],
                        :ensure                          => 'asdas',
            :member                         => zone_attrib['member'],
            :membertype                     => zone_attrib['membertype'],
            :vsanid                         => zone_attrib['vsanid']) }.to raise_error Puppet::Error
                        end
            it "should not allow blank value in the ensure" do
                expect { described_class.new(:name => zone_attrib['name'],
            :ensure                          => '',
            :member                         => zone_attrib['member'],
            :membertype                     => zone_attrib['membertype'],
            :vsanid                         => zone_attrib['vsanid']) }.to raise_error Puppet::Error
            end
         end
         describe "validating member property" do
                        it "should support member value" do
                                described_class.new(:name => zone_attrib['name'],
                :member                         => zone_attrib['member'],
                :membertype                     => zone_attrib['membertype'],
                :vsanid   => zone_attrib['vsanid'])[:member].should == zone_attrib['member']
                        end
        end
        describe "validating membertype property" do
            it "should support membertype value" do
                described_class.new(:name => zone_attrib['name'],
                :member                         => zone_attrib['member'],
                :membertype                     => zone_attrib['membertype'],
                :vsanid   => zone_attrib['vsanid'])[:membertype].should.to_s == zone_attrib['membertype']
            end
            it "should not allow blank value in the membertype" do
                expect { described_class.new(:name => zone_attrib['name'],
            :ensure                          => zone_attrib['ensure'],
            :member                         => zone_attrib['member'],
            :membertype                     => '',
            :vsanid                         => zone_attrib['vsanid']) }.to raise_error Puppet::Error
            end
        end
        describe "validating vsanid property" do
            it "should support vsanid value" do
                described_class.new(:name => zone_attrib['name'],
                :member                         => zone_attrib['member'],
                :membertype                     => zone_attrib['membertype'],
                :vsanid   => zone_attrib['vsanid'])[:vsanid].should == zone_attrib['vsanid']
            end
            it "should not allow blank value in the vsanid" do
                expect { described_class.new(:name => zone_attrib['name'],
            :ensure                          => zone_attrib['ensure'],
            :member                         => zone_attrib['member'],
            :membertype                     => '',
            :vsanid                         => '') }.to raise_error Puppet::Error
            end
        end
        end

end

