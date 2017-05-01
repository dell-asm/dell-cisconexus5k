provider_path = Pathname.new(__FILE__).parent.parent
require 'puppet_x/cisconexus5k/transport'
require 'puppet/provider/cisconexus5k'
require 'spec_helper'
require 'yaml'
require 'fixtures/unit/puppet/provider/zone/zone_fixture'

#require 'rspec/expectations'

describe Puppet::Type.type(:zone).provider(:cisconexus5k) do

  before(:each) do
    my_url = 'ssh://admin:p!ssw0rd@172.17.7.15:22/'
    @device = PuppetX::Cisconexus5k::Transport.new(my_url)
    @transport = double('transport')
    @device.transport = @transport
  end
  let :zoneforupdate do
    Zone_fixture.new.get_dataforupdatezone
  end

  let :zonefordelete do
    Zone_fixture.new.get_datafordeletezone
  end

  let :providerforupdate do
    described_class.new(@device,zoneforupdate)
  end

  let :providerfordelete do
    described_class.new(@device,zonefordelete)
  end

  describe "when updating zones." do
    skip "should create/update zone" do
      @transport.should_receive(:connect)
      @transport.should_receive(:handles_login?).and_return(true)
      @transport.should_receive(:command).once.with("terminal length 0")
      @device.should_receive(:execute).with("conf t").and_return("")
      @device.should_receive(:execute).with("zone name #{zoneforupdate[:name]} vsan #{zoneforupdate[:vsanid]}").and_return("")
      @device.should_receive(:execute).twice
      @device.should_receive(:execute).twice.with("exit")
      @device.should_receive(:disconnect)

      providerforupdate.flush
    end

    skip "should delete zone" do
      @transport.should_receive(:connect)
      @transport.should_receive(:handles_login?).and_return(true)
      @transport.should_receive(:command).once.with("terminal length 0")
      @device.should_receive(:execute).with("conf t").and_return("")
      @device.should_receive(:execute).with("zone name #{zoneforupdate[:name]} vsan #{zoneforupdate[:vsanid]}").and_return("")
      @device.should_receive(:execute).twice
      @device.should_receive(:execute).with("show zone name #{zoneforupdate[:name]} vsan #{zoneforupdate[:vsanid]}").and_return(" \n \n \n")
      @device.should_receive(:execute).with("no zone name #{zoneforupdate[:name]} vsan #{zoneforupdate[:vsanid]}").and_return("")
      @device.should_receive(:execute).twice.with("exit")
      @device.should_receive(:disconnect)

      providerfordelete.flush
    end

  end

end
