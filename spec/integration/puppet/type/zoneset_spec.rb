#! /usr/bin/env ruby

require 'spec_helper'
describe Puppet::Type.type(:zoneset) do
    zoneset_conf = YAML.load_file(get_configpath('cisconexus5k','zoneset_config.yml'))
    zoneset_attrib = zoneset_conf['zoneset_configuration_type'] 
    let(:title) { 'zoneset' }
    #++++++++++++++++++++++++++++++++++++++++++++++++++++
   context "should compile with given test params"  do 

    let(:params) {{
           :name                           => zoneset_attrib['name'],
           :member                         => zoneset_attrib['member'],
           :vsanid                         => zoneset_attrib['vsanid'],
           :active                         => zoneset_attrib['active'],
           :force                          => zoneset_attrib['force'] 
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
            [:member,:vsanid,:active,:force].each do |param| 
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
            described_class.new(:name       => zoneset_attrib['name'],
            :member                         => zoneset_attrib['member'],
            :vsanid                         => zoneset_attrib['vsanid'],
            :active                         => zoneset_attrib['active'],
            :force                          => zoneset_attrib['force'] )[:name].should == zoneset_attrib['name']
            end
                
            it "should not allow blank value in the name" do
            expect { described_class.new(:name       => '',
            :member                         => zoneset_attrib['member'],
            :vsanid                         => zoneset_attrib['vsanid'],
            :active                         => zoneset_attrib['active'],
            :force                          => zoneset_attrib['force']) }.to raise_error Puppet::Error
            end
        end
        describe "validating ensure property" do
            it "should support present value" do
            described_class.new(:ensure     => zoneset_attrib['ensure'],
            :name                           => zoneset_attrib['name'],
            :member                         => zoneset_attrib['member'],
            :vsanid                         => zoneset_attrib['vsanid'],
            :active                         => zoneset_attrib['active'],
            :force                          => zoneset_attrib['force'])[:ensure].should == (zoneset_attrib['ensure'] == 'present' ? :present : (zoneset_attrib['ensure'] == 'absent' ? :absent : zoneset_attrib['ensure']))
            end
            
            it "should not allow values other than present or absent" do
            expect { described_class.new(:ensure     => 'xxx',
            :name                           => zoneset_attrib['name'],
            :member                         => zoneset_attrib['member'],
            :vsanid                         => zoneset_attrib['vsanid'],
            :active                         => zoneset_attrib['active'],
            :force                          => zoneset_attrib['force']) }.to raise_error Puppet::Error
            end
        end
        describe "validating member property" do
            it "should support member value" do
                described_class.new(:name   => zoneset_attrib['name'],
            :member                         => zoneset_attrib['member'],
            :vsanid                         => zoneset_attrib['vsanid'],
            :active                         => zoneset_attrib['active'],
            :force                          => zoneset_attrib['force'])[:member].should == zoneset_attrib['member']
            end
       end
        describe "validating vsanid property" do
            it "should support vsanid value" do
                described_class.new(:name   => zoneset_attrib['name'],
            :member                         => zoneset_attrib['member'],
            :vsanid                         => zoneset_attrib['vsanid'],
            :active                         => zoneset_attrib['active'],
            :force                          => zoneset_attrib['force'])[:vsanid].should == zoneset_attrib['vsanid']
            end
            it "should not support vsanid empty value" do
                expect { described_class.new(:name   => zoneset_attrib['name'],
            :member                         => zoneset_attrib['member'],
            :vsanid                         => '',
            :active                         => zoneset_attrib['active'],
            :force                          => zoneset_attrib['force']) }.to raise_error Puppet::Error
            end
        end
        describe "validating active property" do
            it "should support active value" do
                described_class.new(:name   => zoneset_attrib['name'],
            :member                         => zoneset_attrib['member'],
            :vsanid                         => zoneset_attrib['vsanid'],
            :active                         => zoneset_attrib['active'],
            :force                          => zoneset_attrib['force'])[:active].should == zoneset_attrib['active']
            end
            it "should not allow values other than true or false" do
                expect { described_class.new(:name   => zoneset_attrib['name'],
            :member                         => zoneset_attrib['member'],
            :vsanid                         => zoneset_attrib['vsanid'],
            :active                         => 'xxx',
            :force                          => zoneset_attrib['force']) }.to raise_error Puppet::Error
            end
            it "should not support active empty value" do
                expect { described_class.new(:name   => zoneset_attrib['name'],
            :member                         => zoneset_attrib['member'],
            :vsanid                         => zoneset_attrib['vsanid'],
            :active                         => '',
            :force                          => zoneset_attrib['force'] ) }.to raise_error Puppet::Error
            end
        end
        describe "validating force property" do
            it "should support force value" do
                described_class.new(:name   => zoneset_attrib['name'],
            :member                         => zoneset_attrib['member'],
            :vsanid                         => zoneset_attrib['vsanid'],
            :active                         => zoneset_attrib['active'],
            :force                          => zoneset_attrib['force'])[:force].should == zoneset_attrib['force']
            end
            it "should not allow values other than true or false" do
                expect { described_class.new(:name   => zoneset_attrib['name'],
            :member                         => zoneset_attrib['member'],
            :vsanid                         => zoneset_attrib['vsanid'],
            :active                         => 'xxx',
            :force                          => zoneset_attrib['force']) }.to raise_error Puppet::Error
            end
            it "should not support force empty value" do
                expect { described_class.new(:name   => zoneset_attrib['name'],
            :member                         => zoneset_attrib['member'],
            :vsanid                         => zoneset_attrib['vsanid'],
            :active                         => '',
            :force                          => zoneset_attrib['force'] ) }.to raise_error Puppet::Error
            end
        end
    end
    
end


