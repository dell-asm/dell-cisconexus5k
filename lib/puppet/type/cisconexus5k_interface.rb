Puppet::Type.newtype(:cisconexus5k_interface) do
  @doc = "configures cisconexus5k switch interface"

  ensurable

  newparam(:name) do
    desc "Name of the interface. Valid value start with Eth or Ethernet followed by module/port."
    isrequired
    validate do |value|
      unless value=~/Eth\s*\S+$/ or value=~/Ethernet\s*\S+$/
        raise ArgumentError, "%s is not a valid interface name. Valid interface name shouyld start with 'Eth' or 'Ethernet'followed by module/port" %value
      end
    end
    isnamevar
  end

  newproperty(:tagged_general_vlans) do
    desc "VLANs to add to a general port. Specify non consecutive VLAN IDs with a comma and no spaces. Use a hyphen to designate a range of VLAN IDs."
    validate do |value|
      return if value == :absent
      raise ArgumentError, "Invalid vlan list: #{value}" if value.include?(',') && !(value.split(',').size > 0)
      value.split(',').each do |vlan_value|
        raise ArgumentError, "Invalid range definition: #{value}" if value.include?('-') && value.split('-').size != 2
        vlan_value.split('-').each do |vlan|
          all_valid_characters = vlan =~ /^[0-9]+$/
          raise ArgumentError, "An invalid VLAN ID #{vlan_value} is entered.All VLAN values must be between 1 and 4094." unless all_valid_characters && vlan.to_i >= 1 && vlan.to_i <= 4094
        end
      end
    end
  end

  newproperty(:untagged_general_vlans) do
    desc "Untagged VLANs to add to a general port. Specify non consecutive VLAN IDs with a comma and no spaces. Use a hyphen to designate a range of VLAN IDs."
    validate do |value|
      return if value == :absent || value.empty?
      raise ArgumentError, "Invalid vlan list: #{value}" if value.include?(',') && !(value.split(',').size > 0)
      value.split(',').each do |vlan_value|
        raise ArgumentError, "Invalid range definition: #{value}" if value.include?('-') && value.split('-').size != 2
        vlan_value.split('-').each do |vlan|
          # vlan needs to be removed if value is NONE, skipping validation in this case
          next if vlan == "NONE"
          all_valid_characters = vlan =~ /^[0-9]+$/
          raise ArgumentError, "An invalid VLAN ID #{vlan_value} is entered.All VLAN values must be between 1 and 4094." unless all_valid_characters && vlan.to_i >= 1 && vlan.to_i <= 4094
        end
      end
    end
  end

  newproperty(:switchport_mode) do
    desc "Configure the VLAN membership mode of an interface. Valid values are access, trunk, or general."
    newvalues(:trunk, :access)
  end

  newproperty(:mtu) do
    desc "MTU value"
    defaultto(:absent)
    newvalues(:absent, /^\d+$/)
    validate do |value|
      return if value == :absent
      raise ArgumentError, "An invalid 'mtu' value is entered. The 'mtu' value must be between 594 and 12000" unless value.to_i >=594 && value.to_i <= 12000
    end
  end

  newproperty(:speed) do
    desc "speed value"
    defaultto(:Auto)
    newvalues(:Auto, /^\d+$/)
  end

  newproperty(:shutdown) do
    desc "Disable the interface. Default value is 'false'"
    defaultto(false)
    newvalues(true, false)
  end

  newproperty(:interfaceoperation) do
    desc "interface opearion either 'add' or 'remove'"
    newvalues("add", "remove")
  end

  newproperty(:port_channel) do
    desc "Port channel number."

    validate do |value|

      if value !~ /^\d+/
        raise ArgumentError, "The value of the Port Channel Id must be a positive integer."
      end
      if Integer(value) == 0
        raise ArgumentError, "The entered value of the Post Channel Id 0 is invalid."
      end
    end
  end

  newproperty(:interfaceencapsulationtype) do
    desc "Encapsulationtype for portchannel."
    defaultto "dot1q"
    munge do |value|
      value.to_s
    end
  end

  newproperty(:deletenativevlaninformation) do
    desc "Delete native vlan information or not."
    newvalues("true", "false")
    munge do |value|
      if value.strip.length==0
        value.to_s
      else
        value.to_s
      end
    end
  end

  newproperty(:enforce_portchannel) do
    desc "flag that indicates if port-channel should be forced to be configured"
    newvalues("true", "false")
    defaultto "false"
    munge do |value|
      if value.strip.length == 0
        value.to_s
      else
        value.to_s
      end
    end
  end

  newproperty(:access_vlan) do
    desc "vlan for access port when interface is not in trunk mode"
    validate do |value|
      return if value == :absent || value.empty?
      raise ArgumentError, "Invalid vlan list: #{value}" if value.include?(',') && !(value.split(',').size > 0)

      raise ArgumentError, "There should only one access vlan for access port: #{value}" if value.split(",").size() > 1
    end
  end

  newproperty(:is_lacp) do
    desc "interface port-channel protocol"
    newvalues("true", "false")
    defaultto("false")
  end

  newproperty(:unconfiguretrunkmode) do
    desc " Un configure trunk mode or not."
    newvalues("true", "false")
    munge do |value|
      if value.strip.length == 0
        value.to_s
      else
        value.to_s
      end
    end
  end

  newproperty(:shutdownswitchinterface) do
    desc "Shutdown switch interface or not."
    newvalues("true", "false")
    munge do |value|
      if value.strip.length == 0
        value.to_s
      else
        value.to_s
      end
    end
  end

  newproperty(:removeallassociatedvlans) do
    desc "Remove all associated vlans or not."
    newvalues("true", "false")
    munge do |value|
      value.to_s
    end
  end

  newproperty(:istrunkforinterface) do
    desc "Trunking is true or flase for interface."
    newvalues("true", "false")
    defaultto("true")
    munge do |value|
      if value.strip.length == 0
        value.to_s
      else
        value.to_s
      end
    end
  end

  newproperty(:save_start_up_config) do
    desc "saves running-config to startup config"
    validate do |value|
      return unless value
    end
  end
end
