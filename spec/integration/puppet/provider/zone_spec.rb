#! /usr/bin/env ruby
provider_path = Pathname.new(__FILE__).parent.parent
require 'puppet/util/network_device/cisconexus5k/device'

require 'puppet/provider/cisconexus5k'
require 'spec_helper'
require 'yaml'
require 'rspec/expectations'


describe Puppet::Type.type(:zone).provider(:cisconexus5k) do
    zone_conf=YAML.load_file(get_configpath('cisconexus5k','zone_config.yml'))
    zone_attrib = zone_conf['zone_configuration_provider']


    let :zone do
        Puppet::Type.type(:zone).new(
           :ensure                         => zone_attrib['ensure'],
           :name                           => zone_attrib['name'],
           :member                         => zone_attrib['member'],
           :membertype                     => zone_attrib['membertype'],
           :vsanid                         => zone_attrib['vsanid']
        )
    end
    device_conf =  YAML.load_file(my_deviceurl('cisconexus5k','device_conf.yml'))
    my_device = Puppet::Util::NetworkDevice::Cisconexus5k::Device.new(device_conf['url'])
    
    let :provider do
        described_class.new(my_device,zone)
    end

    describe "when asking exists?" do
        it "Create/Delete zone" do
           provider.flush
           
        end
    end
    

end

