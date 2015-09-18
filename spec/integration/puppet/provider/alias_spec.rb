#! /usr/bin/env ruby
provider_path = Pathname.new(__FILE__).parent.parent
require 'puppet_x/cisconexus5k/transport'
require 'puppet/provider/cisconexus5k'
require 'spec_helper'
require 'yaml'
require 'rspec/expectations'

describe Puppet::Type.type(:alias).provider(:cisconexus5k) do
  alias_conf=YAML.load_file(get_configpath('cisconexus5k','alias_config.yml'))
  alias_attrib = alias_conf['alias_configuration_provider']

  let :nexusalias do
    Puppet::Type.type(:alias).new(
    :ensure                         => alias_attrib['ensure'],
    :name                           => alias_attrib['name'],
    :member                         => alias_attrib['member']
    )
  end
  device_conf =  YAML.load_file(my_deviceurl('cisconexus5k','device_conf.yml'))
  my_device = Puppet::Util::NetworkDevice::Cisconexus5k::Device.new(device_conf['url'])

  let :provider do
    described_class.new(my_device,nexusalias)
  end

  describe "when asking exists?" do
    it "Create/Delete alias" do
      provider.flush

    end
  end

end

