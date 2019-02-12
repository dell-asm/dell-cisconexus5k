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

      # This method is (unfortunately) mostly copied from Puppet's SSH transport class.
      # added verify_host_key to fix known_host key issue
      def connect(&block)
        @output = []
        @channel_data = ''

        begin
          Puppet.debug("connecting to #{host} as #{user}")
          @ssh = Net::SSH.start(host, user, port: port, password: password, timeout: timeout, verify_host_key: false)
        rescue TimeoutError
          raise TimeoutError, _('timed out while opening an ssh connection to the host'), $ERROR_INFO.backtrace
        rescue Net::SSH::AuthenticationFailed
          raise Puppet::Error, _('SSH authentication failure connecting to %{host} as %{user}') % { host: host, user: user }, $ERROR_INFO.backtrace
        rescue Net::SSH::Exception
          raise Puppet::Error, _('SSH connection failure to %{host}') % { host: host }, $ERROR_INFO.backtrace
        end

        @buf = ''
        @eof = false
        @channel = nil
        @ssh.open_channel do |channel|
          channel.request_pty { |_ch, success| raise _('failed to open pty') unless success }

          channel.send_channel_request('shell') do |ch, success|
            raise _('failed to open ssh shell channel') unless success

            ch.on_data { |_, data| @buf << data }
            ch.on_extended_data { |_, type, data| @buf << data if type == 1 }
            ch.on_close { @eof = true }

            @channel = ch
            expect(default_prompt, &block)
            # this is a little bit unorthodox, we're trying to escape
            # the ssh loop there while still having the ssh connection up
            # otherwise we wouldn't be able to return ssh stdout/stderr
            # for a given call of command.
            # rubocop:disable Lint/NonLocalExitFromIterator
            return
            # rubocop:enable Lint/NonLocalExitFromIterator
          end
        end
        @ssh.loop
      end
    end
  end
end