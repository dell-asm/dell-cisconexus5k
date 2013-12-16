require 'pp'
require 'puppet'
require 'puppet/util'
require 'puppet/util/network_device/base'
require 'puppet/util/network_device/cisconexus5k/facts'

#
# Main device class for Cisco nexus5k module
# This class is called by the provider and contains methods
# for performing all operations
# * parse_vlans: get a list of VLANs on the device
#   as a hash of hash
# * update_vlan: delete/create VLAN
#

class Puppet::Util::NetworkDevice::Cisconexus5k::Device < Puppet::Util::NetworkDevice::Base

  include Puppet::Util::NetworkDevice::IPCalc

  attr_accessor :enable_password

  def initialize(url, options = {})
    super(url, options)
    @enable_password = options[:enable_password] || parse_enable(@url.query)
    transport.default_prompt = /[#>]\s?\z/n
  end

  def parse_enable(query)
    if query
      params = CGI.parse(query)
      params['enable'].first unless params['enable'].empty?
    end
  end

  def connect
    transport.connect
    login
    transport.command("terminal length 0") do |out|
      enable if out =~ />\s?\z/n
    end
    #find_capabilities
  end

  def disconnect
    transport.close
  end

  def command(cmd = nil)
    connect
    out = execute(cmd) if cmd
    yield self if block_given?
    disconnect
    out
  end

  def execute(cmd)
    transport.command(cmd)
  end

  def login
    return if transport.handles_login?
    if @url.user != ''
      transport.command(@url.user, :prompt => /^Password:/)
    else
      transport.expect(/^Password:/)
    end
    transport.command(@url.password)
  end

  def enable
    raise "Can't issue \"enable\" to enter privileged, no enable password set" unless enable_password
    transport.command("enable", :prompt => /^Password:/)
    transport.command(enable_password)
  end

  #def support_vlan_brief?
  #  !! @support_vlan_brief
  #end

  #def find_capabilities
  #  out = execute("sh vlan brief")
  #  lines = out.split("\n")
  #  lines.shift; lines.pop

  #  @support_vlan_brief = ! (lines.first =~ /^%/)
  #end

  def facts
    @facts ||= Puppet::Util::NetworkDevice::Cisconexus5k::Facts.new(transport)
    facts = {}
    command do |ng|
      facts = @facts.retrieve
    end
    facts
  end

  def parse_vlans
    vlans = {}
    out = execute("show vlan brief")
    lines = out.split("\n")
    lines.shift; lines.shift; lines.shift; lines.pop
    vlan = nil
    lines.each do |line|
     case line
            # vlan    name    status
      when /^(\d+)\s+(\w+)\s+(\w+)\s+([a-zA-Z0-9,\/. ]+)\s*$/
        vlan = { :name => $1, :vlanname => $2, :status => $3, :interfaces => [] }
        if $4.strip.length > 0
          vlan[:interfaces] = $4.strip.split(/\s*,\s*/)
        end
        vlans[vlan[:name]] = vlan
      when /^\s+([a-zA-Z0-9,\/. ]+)\s*$/
        raise "invalid sh vlan summary output" unless vlan
        if $1.strip.length > 0
          vlan[:interfaces] += $1.strip.split(/\s*,\s*/)
        end
      else
        next 
      end
    end
    vlans
  end

  def update_vlan(id, is = {}, should = {})
    if should[:ensure] == :absent
      Puppet.info "Removing VLAN #{id} from the device"
      execute("conf t")
      out = execute("no vlan #{id}")
      execute("exit")
      return
    end

    # We're creating or updating an entry
    execute("conf t")
    execute("vlan #{id}")
    [is.keys, should.keys].flatten.uniq.each do |property|
      Puppet.debug("trying property: #{property}: #{should[property]}")
      next if property != :vlanname
      execute("name #{should[property]}")
      Puppet.info "Created VLAN #{id}"
    end
    execute("exit")
    execute("exit")
  end

end
