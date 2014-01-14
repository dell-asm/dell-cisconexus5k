#! /usr/bin/env ruby

require 'spec_helper'
describe Puppet::Type.type(:alias) do
    alias_conf = YAML.load_file(get_configpath('cisconexus5k','alias_config.yml'))
    alias_attrib = alias_conf['alias_configuration_type']
    let(:title) { 'alias' }
        #++++++++++++++++++++++++++++++++++++++++++++++++++++
   context "should compile with given test params"  do

    let(:params) {{
            :ensure => alias_attrib['ensure'],
            :name => alias_attrib['name'],
            :member => alias_attrib['member']

    } }
    it do
        expect { should compile }
   end

   end
        #++++++++++++++++++++++++++++++++++++++++++++++++++++
        context "when validating attributes" do

       it "should have name as its keyattribute" do
        puts alias_attrib['name']
         described_class.key_attributes.should == [:name]
        end

        describe "when validating attribute" do
            [:member].each do |param|
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
                    described_class.new(:name => alias_attrib['name'],
                        :member             => alias_attrib['member'],
                        :ensure                         => alias_attrib['ensure'])[:name].should == alias_attrib['name']
                 end
                it "should not allow blank value in the name" do
                    expect { described_class.new(:name => '',
                        :member                         => alias_attrib['member'],
                        :ensure                         => alias_attrib['ensure']) }.to raise_error Puppet::Error
                 end
             end
             describe "validating ensure property" do
                    it "should support present value" do
                        described_class.new(:name => alias_attrib['name'],
                        :ensure                         => alias_attrib['ensure'],
                        :member                         => alias_attrib['member'])[:ensure].should == (alias_attrib['ensure'] == 'present' ? :present : (alias_attrib['ensure'] == 'absent' ? :absent : alias_attrib['ensure']))
                    end
                    it "should not allow values other than present or absent" do
                        expect { described_class.new(:name => alias_attrib['name'],
                        :ensure                          => 'asdas',
                        :member                         => alias_attrib['member']) }.to raise_error Puppet::Error
                    end
                    it "should not allow blank value in the ensure" do
                        expect { described_class.new(:name => alias_attrib['name'],
                        :ensure                          => '',
                        :member                         => alias_attrib['member']) }.to raise_error Puppet::Error
                    end
            end
            describe "validating member property" do
                    it "should support member value" do
                        described_class.new(:name => alias_attrib['name'],
                        :member                         => alias_attrib['member'])[:member].should == alias_attrib['member']
                    end
            end
        end
end

