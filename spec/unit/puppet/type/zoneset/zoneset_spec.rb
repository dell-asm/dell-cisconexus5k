require 'spec_helper'

#require '/etc/puppet/modules/cisconexus5k/lib/puppet/type/zoneset'
describe Puppet::Type.type(:zoneset)  do
  let(:title) {'zoneset'}

  it "Should Compile." do
    expect {should compile}
  end

  it "Should have name property as its key for zoneset." do
    described_class.key_attributes.should == [:name]
  end

  context "When validating valid properties:" do
    [:member, :vsanid, :ensure, :active, :force].each do |param|
      it "should have a #{param} property." do
        described_class.attrtype(param).should == :property
      end
    end
  end

  context "When validating invalid properties:" do
    [:radioactive].each do |param|
      it "should not have a #{param} property." do
        described_class.attrtype(param).should == nil
      end
    end
  end

  context "when validating property values." do
    describe "validating name property:" do

      it "should support an alphanumerical name." do
        described_class.new(:name => 'zoneset1', :member => 'zone1', :ensure => 'present', :vsanid => '999', :active => 'false', :force => 'false')[:name].should == 'zoneset1'
      end

      it "should support underscores." do
        described_class.new(:name => 'zoneset_1', :member => 'zone1', :ensure => 'present', :vsanid => '999', :active => 'false', :force => 'false')[:name].should == 'zoneset_1'
      end

      it "should not support blank value." do
        expect { described_class.new(:name => '', :member => 'zone1', :ensure => 'present', :vsanid => '999', :active => 'false', :force => 'false')}.to raise_error(Puppet::Error, /not a valid zoneset name/)
      end

      it "should not support special characters." do
        expect { described_class.new(:name => 'zoneset#$%11', :member => 'zone1', :ensure => 'present', :vsanid => '999', :active => 'false', :force => 'false')}.to raise_error(Puppet::Error, /not a valid zoneset name/)
      end
    end

    describe "validating vsanid property:" do
      it "should support digits." do
        described_class.new(:name => 'zoneset1', :member => 'zone1', :ensure => 'present', :vsanid => '999', :active => 'false', :force => 'false')[:vsanid].should == '999'
      end

      it "should not support an alphanumerical value." do
        expect { described_class.new(:name => 'zoneset1', :member => 'zone1', :ensure => 'present', :vsanid => 'vsan999', :active => 'false', :force => 'false')}.to raise_error(Puppet::Error, /not a valid vsan id/)
      end

      it "should not support underscores." do
        expect { described_class.new(:name => 'zoneset1', :member => 'zone1', :ensure => 'present', :vsanid => '9_99', :active => 'false', :force => 'false')}.to raise_error(Puppet::Error, /not a valid vsan id/)
      end

      it "should not support blank value." do
        expect { described_class.new(:name => 'zoneset1', :member => 'zone1', :ensure => 'present', :vsanid => '', :active => 'false', :force => 'false')}.to raise_error(Puppet::Error, /not a valid vsan id/)
      end

      it "should not support special characters." do
        expect { described_class.new(:name => 'zoneset1', :member => 'zone1', :ensure => 'present', :vsanid => '999#$%', :active => 'false', :force => 'false')}.to raise_error(Puppet::Error, /not a valid vsan id/)
      end
    end

    describe "validating active property:" do
      it "should support true." do
        described_class.new(:member => 'zone1', :name => 'zoneset1', :ensure => 'present', :vsanid => '999', :active => 'true', :force => 'false')[:active].should == 'true'
      end

      it "should support false." do
        described_class.new(:member => 'zone1', :name => 'zoneset1', :ensure => 'present', :vsanid => '999', :active => 'false', :force => 'false')[:active].should == 'false'
      end

      it "should not support other values." do
        expect { described_class.new(:member => 'zone1', :name => 'zoneset1', :ensure => 'present', :vsanid => '999', :active => 'invalidvalue', :force => 'false') }.to raise_error(Puppet::Error, /not a valid value/)
      end
    end

    describe "validating force property:" do
      it "should support true." do
        described_class.new(:member => 'zone1', :name => 'zoneset1', :ensure => 'present', :vsanid => '999', :active => 'false', :force => 'true')[:force].should == 'true'
      end

      it "should support false." do
        described_class.new(:member => 'zone1', :name => 'zoneset1', :ensure => 'present', :vsanid => '999', :active => 'false', :force => 'false')[:force].should == 'false'
      end

      it "should not support other values." do
        expect { described_class.new(:member => 'zone1', :name => 'zoneset1', :ensure => 'present', :vsanid => '999', :active => 'false', :force => 'invalidfalse') }.to raise_error(Puppet::Error, /not a valid value/)
      end
    end

    describe "validating member property:" do
      it "should support semicolon separated list of member zones." do
        described_class.new(:member => 'zone1,zone2', :name => 'zoneset1', :ensure => 'present', :vsanid => '999', :active => 'false', :force => 'false')[:member].should == 'zone1,zone2'
      end
    end

    describe "validating ensure property:" do
      it "should support present." do
        described_class.new(:member => 'zone1', :name => 'zoneset1', :ensure => 'present', :vsanid => '999', :active => 'false', :force => 'false')[:ensure].should == :present
      end

      it "should support absent." do
        described_class.new(:member => 'zone1', :name => 'zoneset1', :ensure => 'absent', :vsanid => '999', :active => 'false', :force => 'false')[:ensure].should == :absent
      end

      it "should not support other values." do
        expect { described_class.new(:member => 'zone1', :name => 'zoneset1', :ensure => 'negativetest', :vsanid => '999', :active => 'false', :force => 'false') }.to raise_error(Puppet::Error, /Invalid value "negativetest"/)
      end
    end

  end
end

