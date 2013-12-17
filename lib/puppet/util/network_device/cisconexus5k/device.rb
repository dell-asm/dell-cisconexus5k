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
IF = {
    :FastEthernet => %w{FastEthernet FastEth Fast FE Fa F},
    :GigabitEthernet => %w{GigabitEthernet GigEthernet GigEth GE Gi G},
    :TenGigabitEthernet => %w{TenGigabitEthernet TE Te},
    :Ethernet => %w{Ethernet Eth E},
    :Serial => %w{Serial Se S},
    :PortChannel => %w{PortChannel Port-Channel Po},
    :POS => %w{POS P},
    :VLAN => %w{VLAN VL V},
    :Loopback => %w{Loopback Loop Lo},
    :ATM => %w{ATM AT A},
    :Dialer => %w{Dialer Dial Di D},
    :VirtualAccess => %w{Virtual-Access Virtual-A Virtual Virt}
  }

  def canonalize_ifname(interface)
    IF.each do |k,ifnames|
      if found = ifnames.find { |ifname| interface =~ /^#{ifname}\s*\d/i }
        found = /^#{found}(.+)\Z/i.match(interface)
        return "#{k.to_s}#{found[1]}".gsub(/\s+/,'')
      end
    end
    interface
  end
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
 def parse_zones
   zones = {}
   out = execute("show zone")
   lines = out.split("\n")
   lines.shift; lines.pop
   zone = nil
   lines.each do |l|
    if l =~ /^zone name\s*(\S*)\s*vsan\s*(\d*)/
        zone = { :name => $1, :vsanid => $2, :membertype => [], :member => [] }
    end
    if l =~ /pwwn\s*(\S*)/
        zone[:member] += $1.map{ |ifn| canonalize_ifname(ifn) }
        zone[:membertype] += 'pwwn'.map{ |ifn| canonalize_ifname(ifn) }
    end
    if l =~/fcalias name\s*(\S*)\s*vsan\s*(\d*)/
        zone[:member] += $1.map{ |ifn| canonalize_ifname(ifn) }
        zone[:membertype] += 'fcalias'.map{ |ifn| canonalize_ifname(ifn) }
    end
    zones[zone[:name]] = zone
   end 
   zones 
 end
 
  def parse_alias
       malias ={}
       out=execute("show device-alias database") 
        Puppet.debug "show device-alias database \n  #{out} "
       lines = out.split("\n")
       lines.shift ; lines.pop
       lines.each do |l|
             if l =~ /device-alias\s*name\s*(\S*)\s*(\S*)\s*(\S*)/
                 m_alias = { :name => $1, :member => $3 }        
                 malias[m_alias[:name]] = m_alias
             end
        end
       malias
   end 

  def update_alias(id, is = {}, should = {})  
    member=should[:member]
    if should[:ensure] == :absent
      Puppet.debug "Removing #{id} from device alias"
        execute("conf t")
        execute("device-alias database")
        execute("no device-alias name #{id} ")   
        execute("device-alias commit")
        execute("exit")
        execute("exit")
      return
      end
        Puppet.debug "Creating Alias id #{id} member #{member} "
        execute("conf t")
        execute("device-alias database")
        Puppet.debug "id #{id} member #{member}  "
        out = execute("device-alias name  #{id} pwwn #{member}")
       if ( out =~ /% Invalid/ )
         raise "invalid command input #{member}"
        end 
        if (out =~ /already present/)
            raise "Another device-alias already present with the same pwwn"
        end
        execute("device-alias commit") 
        execute("exit")
        execute("exit")
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
  def update_zone(id, is = {}, should = {},membertype = {}, member = {})
    vsanid = should[:vsanid]
    mem = member.split(",")
    puts "zoneName : #{id} vsanid : #{vsanid} membertype : #{membertype} member : #{member} "
    if should[:ensure] == :absent
      Puppet.info "Removing #{id} from device zone"
      execute("conf t")
      Puppet.debug "conf t"
      out = execute("zone name #{id} vsan #{vsanid}")
      Puppet.debug "zone name #{id} vsan #{vsanid}"
      if ( out =~ /% Invalid/ )
        raise "invalid vsan id"
      end
      if ( out =~ /not configured/ )
        raise "invalid vsam id"
      end
      mem.each do |memberval|
       out = execute("no member #{membertype} #{memberval}")
       Puppet.debug "no member #{membertype} #{memberval}"
       #if ( out =~ /% Invalid/ )
       #  raise "invalid command input #{memberval}"
       #end
      end
      #check whether its was a last member of not
      out = execute("show zone name #{id} vsan #{vsanid}")
      Puppet.debug "show zone name #{id} vsan #{vsanid}"
      lines = out.split("\n")
      lines.shift; lines.pop
      outputlength = lines.length
      if ( outputlength == 1 )
        #No last member need to remove the zone"
        execute("no zone name #{id} vsan #{vsanid}")
        Puppet.debug "no zone name #{id} vsan #{vsanid}"
      end
      execute("exit")
      execute("exit")
      return
    end
	Puppet.info "Creating #{id} from device zone"
    # We're creating or updating an entry
    execute("conf t")
    Puppet.debug "conf t"
    out = execute("zone name #{id} vsan #{vsanid}")
    Puppet.debug "zone name #{id} vsan #{vsanid}"
    if ( out =~ /% Invalid/ )
      raise "invalid vsan id"
    end
    if ( out =~ /not configured/ )
      raise "invalid vsam id"  
    end
      
    mem.each do |memberval|
      out =  execute("member #{membertype} #{memberval}")
      Puppet.debug "member #{membertype} #{memberval}"
      if ( out =~ /% Invalid/ )
        raise "invalid command input #{memberval}"
      end
    end
    execute("exit")
    execute("exit")
  end
end
