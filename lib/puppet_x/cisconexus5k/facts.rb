require 'pp'
require 'json'
require 'nokogiri'
require 'puppet_x/cisconexus5k/cisconexus5k'
require 'puppet/util/network_device/ipcalc'

#
# This retrieves facts from a cisco device
#

class PuppetX::Cisconexus5k::Facts

  attr_reader :transport
  def initialize(transport)
    @transport = transport
  end

  def retrieve
    facts = {}

    out = @transport.command("sh ver")

    for line in out.split("\n")
      if (line =~ /BIOS:\s+version\s+(\S+)/)
        facts["biosversion"] = $1
      end
      if (line =~ /NXOS:\s+version\s+(\S+)/)
        facts["nxosversion"] = $1
      end
      if (line =~ /kickstart:\s+version\s+(\S+)/)
        facts["kickstartversion"] = $1
      end
      if (line =~ /system:\s+version\s+(\S+)/)
        facts["systemversion"] = $1
      end
      if (line =~ /kickstart\ image\ file\ is:\s+(\S+)/)
        facts["kickstartimage"] = $1
      end
      if (line =~ /system\ image\ file\ is:\s+(\S+)/)
        facts["systemimage"] = $1
      end
      if (line =~ /cisco\s+(\S+)\s+Chassis/) || (line =~ /cisco\s+(\S+)\s+(\S+)\s+chassis/) || (line =~ /cisco\s+(\S+)\s+(\S+)\s+Chassis/)
        if $2.nil?
          facts["model"] = $1
        else
          if $1 == "Nexus"
            facts["model"] = $1 + $2
          else
            facts["model"] = $1
          end
        end
      end
      if (line =~ /Device\s+name:\s+(\S+)/)
        facts["hostname"] = $1
      end
    end

    # vpc feature status on the switch
    result = @transport.command("show feature  | grep vpc")
    facts["vpc_feature"] = result.split("\n")[1].include?("enabled") ? "enabled" : "disabled"

    # mac_address of the switch
    out = @transport.command("show interface mac-address")
    out.split("\n").each do |line|
      if ( line =~ /^mgmt0/ )
        res = line.split(" ")
        management_mac = res[1]
        facts["macaddress"]  = normalize_mac(management_mac)
      end
    end

    # power_state of the switch
    begin
      out = @transport.command("show environment power")
      status = []
      out.split("\n").each do |line|
        if line =~ /^\d+(\s+\S+){7}\s+(\w+)/
          status << $2
        end
      end

      if status.all? {|s| s == "Ok" || s == "absent"}
        facts["powerstate"] = "Ok"
      else
        facts["powerstate"] = "Critical"
      end
    end

    out=@transport.command("show snmp community")
    item = out.scan(/(\S+)\s+\w+-\w+/).flatten

    unless item.empty?
      facts["snmp_community_string"] = item.to_json
    end

    protocols = ""
    out = @transport.command("show feature")
    lines = out.split("\n")
    lines.shift; lines.shift; lines.shift; lines.pop
    count = 1
    for line in lines
      if (line =~ /^(\S+)\s+\d+\s+enabled/)
        if count == 1
          protocols = $1
          count = count + 1
        else
          protocols = protocols + "," + $1
        end
      end
    end
    facts["protocols_enabled"] = protocols

    out = @transport.command("show system resources")
    if (out =~ /Memory usage:\s+(\S+) total,\s+(\S+) used,\s+(\S+) free/)
      facts["mem_total"] = $1
      facts["mem_used"] = $2
      facts["mem_free"] = $3
    end

    if (out =~ /CPU states\s+:\s+(\S+) user,\s+(\S+) kernel,\s+(\S+) idle/)
      facts["cpu_user"] = $1
      facts["cpu_kernel"] = $2
      facts["cpu_idle"] = $3
    end

    interface_res = @transport.command("show interface brief")
    fact = nil
    ethernet_interface_count = 0
    fiberchannel_interface_count = 0
    for line in interface_res.split("\n")
      if ( line =~ /^Eth(\d+)/ )
        ethernet_interface_count = ethernet_interface_count + 1
        res = line.split(" ")
        interface_name = res[0]
        length = res.length
        vlan_info = @transport.command("show interface #{interface_name} switchport")
        for templine in vlan_info.split("\n")
          if (templine =~ /Access\s*Mode\s*VLAN:\s*(\S*)/)
            taggedvlan = $1
          end
          if (templine =~ /Trunking\s*Native\s*Mode\s*VLAN:\s*(\S*)/)
            untaggedvlan = $1
          end
        end

        out = @transport.command("show interface #{interface_name} mac-address")

        #puts "====>output: #{out}  ====?interface name: #{interface_name} ===="

        lines = out.split("\n")
        lines.shift; lines.shift; lines.shift; lines.shift; lines.shift; lines.pop

        #puts ("line =====> #{lines}")
        unless lines[0].nil?
          line = lines[0].split(" ")
          mac_address = normalize_mac(line[2])
          # get the cable speed with transceiver details
          transceiver_res = @transport.command("show interface #{interface_name} transceiver")
          speed = ""
          port_max_speed = nil
          cable_max_speed = nil
          cable_type = nil
          unless transceiver_res.split("\n").any? {|line| line.include?("transceiver is not present")}
            transceiver_res.split("\n").each do |line|
              if line.include?("type is")
                cable_type = line.split(" ").last
                port_speed = get_speed_from_cable(cable_type)
                cable_max_speed = port_speed if port_speed
              end
            end
            # get the max speed capability of interface only if cable is connected
            interface_speed_res = @transport.command("show interface #{interface_name} capabilities")
            interface_speed_res.split("\n").find {|line| line =~ /^\s+Speed:\s+(\S+)/}

            if $1 && cable_max_speed
              port_max_speed = $1.split(",").reject {|speed| speed == "auto"}.last
            end

            if port_max_speed && cable_max_speed
              speed = ([Integer(port_max_speed), cable_max_speed].min).to_s
            end
          end

          fact = {:interface_name => res[0], :type => res[2], :mode => res[3], :status => res[4], :speed => res[length - 2],
                  :portchannel => res[length - 1], :reason => res[5..length - 3], :tagged_vlan => taggedvlan,
                  :untagged_vlan => untaggedvlan, :macaddress => mac_address, :max_speed => speed, :cable_type => cable_type}
          facts[fact[:interface_name]] = fact.to_json
        end
      end
      if ( line =~ /^fc(\d+)/ )
        fiberchannel_interface_count = fiberchannel_interface_count + 1
        res = line.split(" ")
        length = res.length
        fact = { :interface_name => res[0], :status => res[4], :speed => res[length - 2], :portchannel => res[length - 1] }
        facts[fact[:interface_name]] = fact.to_json
      end
      if ( line =~ /^mgmt0/ )
        res = line.split(" ")
        management_ip = res[3]
        facts[:managementip] = management_ip
        # using Internal management IP as a work-around for LUD-511
        facts[:management_ip] = @transport.host
      end
    end
    out = @transport.command("show inventory")
    if ( out =~ /NAME:\s+"Chassis",\s+DESCR:.*\n.*SN:\s+(\S+)/ )
      facts[:chassisserialnumber] = $1
    end

    # Get FLOGI information
    out = @transport.command("show flogi database")
    flogi_info = []
    fc_interfaces = out.scan(/^(fc\d+\/\d+)\s*(\d+)\s+(\S+)\s+(\S+)\s+(\S+)/m)
    vfc_interfaces = out.scan(/^(vfc\d+)\s*(\d+)\s+(\S+)\s+(\S+)\s+(\S+)/)
    if fc_interfaces
      fc_interfaces.each do |fc_interface|
        flogi_info.push(fc_interface)
      end
    end
    if vfc_interfaces
      vfc_interfaces.each do |vfc_interface|
        flogi_info.push(vfc_interface)
      end
    end

    # Name Server Information
    nameserver_info = []
    out = @transport.command('show fcns database detail')
    ns_info = out.scan(/VSAN:(\d+)\s+FCID:(\S+).*?port-wwn\s+\(vendor\)\s+:(\S+).*?node-wwn\s+:(\S+).*?symbolic-port-name\s+:(.*?)port-type/m)
    if ns_info
      nameserver_info = ns_info
    end
    # Get VSAN information
    vsan_zoneset_info = []
    out = @transport.command('show zoneset active')
    vsan_zoneset_info = out.scan(/^zoneset\s+name\s*(\S+)\s+vsan\s+(\d+)/)

    # Adding show version command to clear the buffer prompts
    out = @transport.command("show version")

    # Remote LLDP information from the switch
    lldp_info = @transport.command('show lldp neighbors detail')
    remote_device_info = lldp_info.scan(/Chassis.+?\n\n/m).map do |entry|
      entry = Hash[entry.each_line.select do |line|
        line.match(/^.+?:.+/)
      end.map do |line|
        line.chomp!
        line.split(/:\s/) unless line.match(/(:\s.*){2,}/)
      end.compact]

      next if entry.empty?

      {:interface => entry["Local Port id"], :location => normalize_mac(entry["Port id"]), :remote_mac => normalize_mac(entry["Chassis id"])}
    end.compact


    # Port channel information
    out = @transport.command('show port-channel summary')
    port_channel_out = out.scan(/^(\d+)\s+(Po\d+).*?Eth\s+(\w+)\s+(.*?)$/m)
    port_channels = {}
    if !port_channel_out.empty?
      port_channel_out.each do |port_channel|
        port_channel = { :port_channel => port_channel[0].strip, :name => port_channel[1].strip ,:protocol => port_channel[2].strip, :ports => port_channel[3].strip }
        port_channels[port_channel[:port_channel]] = port_channel
      end
    end

    # Feature list enabled on the switch
    out = @transport.command('show running-config | inc feature')
    features = out.scan(/^feature\s+(\S+)$/m)
    configured_features= []
    if !features.empty?
      features.map {|x| configured_features.push(x[0])}
    end

    # VSAN Membership
    out = @transport.command("show vsan")
    vsans = ( out.scan(/^vsan\s+(\d+)\s+/) || [] ).flatten
    vsan_info = {}
    vsans.each do |vsan|
      out = @transport.command("show vsan #{vsan} membership")
      members = ( out.scan(/(fc\d+\/\d+|vfc\d+|san-port-channel\s+\d+)/) || [] ).flatten
      if !members.empty?
        vsan_info[vsan] = members
      end
    end

    # fex information
    out = @transport.command("show fex")
    fex = ( out.scan(/^(\d+)/).flatten || [] )

    fex_info = {}
    fex.each do |f|
      fex_info[f] = {}
      out = @transport.command("show fex #{f} detail")
      fex_info[f]['Extender Serial'] = out.scan(/^\s+Extender Serial:\s+(\S+)/).flatten.first
      fex_info[f]['Service Tag'] = out.scan(/^\s+Service Tag:\s*(\S*)$/).flatten.first
      fex_info[f]['Enclosure'] = out.scan(/^\s*Enclosure:\s*(.*)$/).flatten.first
      fex_info[f]['Interfaces'] = out.scan(/^\s+(Eth#{f}\S+)/).flatten
    end

    # Zone Membership info
    zone_member = {}
    zone_out = @transport.command("show zone")
    zones = ( zone_out.scan(/zone name\s*(\S+)\s*vsan\s*\d+/).flatten || [] )
    (vsans || []) .each do |vsan|
      zone_member[vsan] = {}
      (zones || []).each do |zone|
        zone_detail_pattern = "zone name\\s*#{zone}\\s*vsan\\s*#{vsan}(.*?)(zone|#{facts["hostname"]})"
        zone_info = (zone_out.scan(/#{zone_detail_pattern}/m) || []).flatten.first
        next if zone_info.nil? || zone_info.empty?
        zone_member[vsan][zone] = []
        zone_members = (zone_info.scan(/pwwn\s+(\S+)/m) || []).flatten
        zone_member[vsan][zone].push(*zone_members) if zone_members
      end
    end


    # Get VSAN Zoneset information
    # since we can communicate with the switch, set status to online
    # TODO: Find a method to get status programmatically
    facts[:ethernet_interface_count] = ethernet_interface_count
    facts[:fiberchannel_interface_count] = fiberchannel_interface_count
    facts[:status] = "online"
    facts[:manufacturer] = "Cisco"
    facts[:flogi_info] = flogi_info
    facts[:nameserver_info] = nameserver_info.to_json
    facts[:vsan_zoneset_info] = vsan_zoneset_info.to_json
    facts[:remote_device_info] = remote_device_info.to_json
    facts[:port_channels] = port_channels.to_json
    facts[:features] = configured_features
    facts[:vsan_member_info] = vsan_info.to_json
    facts[:fex] = fex.to_json
    facts[:fex_info] = fex_info.to_json
    facts[:vlan_information] = get_vlan_information.to_json
    facts[:zone_member] = zone_member.to_json

    facts
  end

  # d067.e572.13ce => d0:67:e5:72:13:ce
  def normalize_mac(mac)
    if mac.match(/^\w{4}[.]\w{4}[.]\w{4}/)
      return mac.gsub('.', '').scan(/../).join(':') if mac
    end

    mac
  end

  # Gets the port speed form the given cable_type
  def get_speed_from_cable(cable_type)
    if cable_type =~ /(\w+-)?((\d?(\D+))?(\d+\/)?)(\d+)(GB|G)?(Gbase|GBASE)?(-\w+)?/
      return (Integer($6) * 1000) if $6
    end

    nil
  end

  def vlan_data
    {
      "tagged_tengigabit" => [],
      "untagged_tengigabit" => [],
      "tagged_fortygigabit" => [],
      "untagged_fortygigabit" => [],
      "tagged_portchannel" => [],
      "untagged_portchannel" =>[]
    }
  end

  def pg_parser(vlan_map, native_vlans, vlan_id, pg)
    iface_set = []
    iface_range = pg.scan(/(\d*-*\d*)/).flatten.reject{|c| c.empty?}
    stack = pg.scan(/.*\//).flatten.reject{|c| c.empty?}
    if iface_range.last.include? "-"
      first = iface_range.last.split("-")[0].to_i
      last = iface_range.last.split("-")[1].to_i
      (first..last).each do |i|
        if stack.empty?
          iface_set << "Po#{i.to_s}"
        else
          iface_set << stack.first + i.to_s
        end
      end
    else
      iface_set << pg
    end
    vlan_map[vlan_id] ||= vlan_data
    iface_set.each do |v|
      interface_name = interface_name_norm(v)
      if native_vlans[v] == vlan_id
        vlan_map[vlan_id]["untagged_tengigabit"] << interface_name if interface_name.start_with? "Te"
        vlan_map[vlan_id]["untagged_portchannel"] << interface_name if interface_name.start_with? "Po"
      else
        vlan_map[vlan_id]["tagged_tengigabit"]<< interface_name if interface_name.start_with? "Te"
        vlan_map[vlan_id]["tagged_portchannel"] << interface_name if interface_name.start_with? "Po"
      end
    end
  end

  def interface_name_norm(v)
    if v.include? "port-channel"
      v.gsub("port-channel","Po")
    else
      v.gsub("Ethernet","Te")
    end
  end

  def sh_vlan_brief
    @transport.command("show vlan brief | xml").lines.to_a[1..-1].join
  end

  def sh_int_trunk
    @transport.command("show interface trunk | xml").lines.to_a[1..-1].join
  end

  def get_vlan_information
    Puppet.debug("About to call sh_vlan_brief...")
    sh_vlans = sh_vlan_brief
    Puppet.debug("Done calling sh_vlan_brief...")

    sh_vlan_doc = Nokogiri::XML.parse(sh_vlans)
    vlans = []
    sh_vlan_doc.css("//vlanshowbr-vlanid").each {|vlan| vlans << vlan.text}
    Puppet.debug("Found vlans: #{vlans}")
    Puppet.debug("About to call sh_int_trunk")
    sh_int_trunk_data = sh_int_trunk
    Puppet.debug("Done calling sh_vlan_brief")
    sh_trunk_doc = Nokogiri::XML.parse(sh_int_trunk_data)
    Puppet.debug("Parsed sh_trunk_doc")

    interface_list = []
    native_vlans = {}
    vlan_map = {}

    sh_trunk_doc.css("//TABLE_vtp_pruning").each do |i|
      next if i.css("interface").empty?
      interface_list << i.css("interface").text
    end

    sh_trunk_doc.css("//TABLE_interface").each_with_index do |n, index|
      next if n.css("native").empty?
      native_vlans[interface_list[index]] = n.css("native").text
    end
    sh_vlan_doc.css("//ROW_vlanbriefxbrief").each do |v|
      vlan_id = v.css("vlanshowbr-vlanid").text
      ifaces = v.css("vlanshowplist-ifidx").text
      next if ifaces.empty?
      ifaces.split(",").each do |pg|
        pg_parser(vlan_map, native_vlans, vlan_id, pg)
      end
    end

    # clean up data
    vlan_map.each do |vlan, data|
      data.each do |type, ports|
        next unless ports
        if ports.empty?
          ports = ""
        else
          ports = ports.uniq.join(",") if ports.class == Array
        end
        data[type] = ports
      end
    end
    Puppet.debug("Exiting, successfully calculated vlan_map")
    vlan_map
  end

end

