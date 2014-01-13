#! /usr/bin/env ruby
provider_path = Pathname.new(__FILE__).parent.parent
require 'puppet/provider/cisconexus5k'
require 'puppet/util/network_device/cisconexus5k/device'

require 'spec_helper'
require 'yaml'
require 'rspec/expectations'

describe Puppet::Type.type(:zoneset).provider(:cisconexus5k) do
    zoneset_conf=YAML.load_file(get_configpath('cisconexus5k','zoneset_config.yml'))
    zoneset_attrib = zoneset_conf['zoneset_configuration_provider']

    let :zoneset do
        Puppet::Type.type(:zoneset).new(
           :ensure                         => zoneset_attrib['ensure'],
           :name                           => zoneset_attrib['name'],
           :member                         => zoneset_attrib['member'],
           :vsanid                         => zoneset_attrib['vsanid'],
           :active                         => zoneset_attrib['active'],
           :force                          => zoneset_attrib['force']         
        )
    end

    device_conf =  YAML.load_file(my_deviceurl('cisconexus5k','device_conf.yml'))
    my_device = Puppet::Util::NetworkDevice::Cisconexus5k::Device.new(device_conf['url'])

    let :provider do
        described_class.new(my_device,zoneset)
    end

    describe "when asking exists?" do
        it "Create/Delete zoneset" do
           provider.flush
           
        end
    end
    

end

