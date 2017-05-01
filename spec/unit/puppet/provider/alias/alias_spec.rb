#! /usr/bin/env ruby
require 'pathname'
provider_path = Pathname.new(__FILE__).parent.parent
require 'puppet_x/cisconexus5k/transport'
require 'puppet/provider/cisconexus5k'
require 'spec_helper'
require 'yaml'
require 'fixtures/unit/puppet/provider/alias/alias_fixture'

#require 'rspec/expectations'

describe Puppet::Type.type(:alias).provider(:cisconexus5k) do
  let(:certname) { "cisconexus5k-172.17.7.15" }
  let(:options) { {:device_config=>{:scheme=>"ssh", :host=>"172.17.11.13", :port=>22, :password=>"P@ssw0rd", :user=>"admin"}} }
  let(:transport) { PuppetX::Cisconexus5k::Transport.new(certname, options) }

  before(:each) do
    my_url = 'ssh://admin:p!ssw0rd@172.17.7.15:22/'
    @device = PuppetX::Cisconexus5k::Transport.new(my_url)
    @transport = double('transport')
    @device.transport = @transport
  end
  let :aliasforcreate do
    Alias_fixture.new.get_dataforcreatealias
  end

  let :aliasfordelete do
    Alias_fixture.new.get_datafordeletealias
  end

  let :providerforcreate do
    described_class.new(@device,aliasforcreate)
  end

  let :providerfordelete do
    described_class.new(@device,aliasfordelete)
  end

  describe "when updating aliass." do
    skip "should create alias" do
      @transport.should_receive(:connect)
      @transport.should_receive(:handles_login?).and_return(true)
      @transport.should_receive(:command).once.with("terminal length 0")
      #@device.should_receive(:get_all_aliass).and_return({})
      @device.should_receive(:execute).with("conf t").and_return("")
      @device.should_receive(:execute).with("device-alias database").and_return("")
      @device.should_receive(:execute).once.with("device-alias name  #{aliasforcreate[:name]} pwwn #{aliasforcreate[:member]}")
      @device.should_receive(:execute).once.with("device-alias commit")
      @device.should_receive(:execute).twice.with("exit")
      @device.should_receive(:disconnect)

      Puppet::Type.type(:alias).provider(:cisconexus5k).new({:ensure => :present},transport).flush
    end

    skip "should delete alias" do
      @transport.should_receive(:connect)
      @transport.should_receive(:handles_login?).and_return(true)
      @transport.should_receive(:command).once.with("terminal length 0")
      @device.should_receive(:execute).with("conf t").and_return("")
      @device.should_receive(:execute).with("device-alias database").and_return("")
      @device.should_receive(:execute).once.with("no device-alias name #{aliasfordelete[:name]} ")
      @device.should_receive(:execute).once.with("device-alias commit")
      @device.should_receive(:execute).twice.with("exit")
      @device.should_receive(:disconnect)

      providerfordelete.flush
    end

  end

end
