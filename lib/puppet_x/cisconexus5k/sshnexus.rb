#This class is responsible for SSH specific transport to the switch

require 'puppet/util/network_device/transport/ssh'

module PuppetX
  module Cisconexus5k
    class Ssh < Puppet::Util::NetworkDevice::Transport::Ssh

      def initialize
        @timeout = 1800
        @cache = {}
        super(true)
      end

      def connect(&block)
        @output = []
        @channel_data = ""

        begin
          Puppet.debug("connecting to #{host} as #{user}")
          @ssh = Net::SSH.start(host, user, :port => port, :password => password, :timeout => timeout)
        rescue TimeoutError
          raise TimeoutError, _("timed out while opening an ssh connection to the host"), $!.backtrace
        rescue Net::SSH::AuthenticationFailed
          raise Puppet::Error, _("SSH authentication failure connecting to %{host} as %{user}") % { host: host, user: user }, $!.backtrace
        rescue Net::SSH::Exception
          raise Puppet::Error, _("SSH connection failure to %{host}") % { host: host }, $!.backtrace
        end

        @buf = ""
        @eof = false
        @channel = nil
        @ssh.open_channel do |channel|
          Puppet.debug ("**************Opening Channel*******************")
          channel.request_pty { |ch,success| raise _("failed to open pty") unless success }

          channel.send_channel_request("shell") do |ch, success|
            raise _("failed to open ssh shell channel") unless success
            #Puppet.debug ("**************send_channel_request*******************")

            ch.on_data { |_,data| @buf << data }
            ch.on_extended_data { |_,type,data|  @buf << data if type == 1 }
            ch.on_close { @eof = true }

            @channel = ch
            expect(default_prompt, &block)
            # this is a little bit unorthodox, we're trying to escape
            # the ssh loop there while still having the ssh connection up
            # otherwise we wouldn't be able to return ssh stdout/stderr
            # for a given call of command.
            return
          end

        end
        @ssh.loop

      end

      #These switches require a carriage return as well, instead of just new line.  So we override Puppet's method to add \r
      def send(line, noop=false)
        Puppet.debug "SSH send only: #{line}"
        #Puppet.debug("Session info: #{@channel.inspect}")
        @channel.send_data(line + "\r") unless noop
      end

      def sendwithoutnewline(line, noop = false)
        #Puppet.debug "SSH send: #{line}"
        @channel.send_data(line) unless noop
      end

      def process_ssh
        while @buf == "" and not eof?
          begin
            @channel.connection.process(0.1)
          rescue IOError
            #Puppet.debug ("**************IOError eof true*******************")
            @eof = true
          end
        end

          def expect(prompt)
			time_out = 1800 #20 min timeout to allow for the firmware update command to finish
			result = Timeout::timeout(time_out) do
			  super
			end
		  end

        def command(cmd, options = {})
          Puppet.debug("inside command executing command in ssh")
          noop = options[:noop].nil? ? Puppet[:noop] : options[:noop]
          Puppet.debug("Default prompt: #{default_prompt}")
          Puppet.debug("Passed  prompt: #{options[:prompt]}")
          if options[:cache]
            return @cache[cmd] if @cache[cmd]
            send(cmd, noop)
            unless noop
              @cache[cmd] = expect(options[:prompt] || default_prompt)
            end
          else
            send(cmd, noop)
            unless noop
              expect(options[:prompt] || default_prompt) do |output|
                yield output if block_given?
              end
            end
          end
        end

      end
    end
  end
end
