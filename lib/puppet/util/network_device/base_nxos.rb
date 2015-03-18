require 'puppet/util/autoload'
require 'uri'
require 'puppet/util/network_device/transport'
require 'puppet/util/network_device/transport/base'
require '/etc/puppetlabs/puppet/modules/asm_lib/lib/security/encode'


class Puppet::Util::NetworkDevice::Base_nxos

  attr_accessor :url, :transport
  def initialize(url, options = {})
    @url = URI.parse(url)
    @query = Hash.new([])
    @query = CGI.parse(@url.query) if @url.query

    @autoloader = Puppet::Util::Autoload.new(
    self,
    "puppet/util/network_device/transport",
    :wrap => false
    )

    if @autoloader.load(@url.scheme)
      @transport = Puppet::Util::NetworkDevice::Transport.const_get(@url.scheme.capitalize).new(options[:debug])
      @transport.host = @url.host
      @transport.port = @url.port || case @url.scheme ; when "ssh" ; 22 ; when "telnet" ; 23 ; end
      @transport.user = URI.decode(@url.user)
      @transport.password = URI.decode(asm_decrypt(@url.password))

      override_using_credential_id
    end
  end

  def credential
    if id = @query['credential_id'].first
      require 'asm/cipher'
      @asm_credential ||= ASM::Cipher.decrypt_credential(id)
    end
  end

  def override_using_credential_id
    if cred = credential
      @transport.user = cred.username
      @transport.password = cred.password
    end
  end
end
