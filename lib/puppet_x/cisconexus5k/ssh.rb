#This class is responsible for SSH specific transport to the switch

require 'puppet/util/network_device/transport/ssh'

module PuppetX
  module Cisconexus5k
    class Ssh < Puppet::Util::NetworkDevice::Transport::Ssh
      #These switches require a carriage return as well, instead of just new line.  So we override Puppet's method to add \r
      def send(line, noop=false)
        Puppet.debug "SSH send: #{line}" if Puppet[:Debug]
        @channel.send_data(line + "\r") unless noop
      end

      def sendwithoutnewline(line, noop = false)
        Puppet.debug "SSH send: #{line}" if Puppet[:debug]
        @channel.send_data(line) unless noop
      end
    end
  end
end