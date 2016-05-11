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
          all_valid_characters = vlan =~ /^[0-9]+$/
          raise ArgumentError, "An invalid VLAN ID #{vlan_value} is entered.All VLAN values must be between 1 and 4094." unless all_valid_characters && vlan.to_i >= 1 && vlan.to_i <= 4094
        end
      end
    end
  end

  newproperty(:switchport_mode) do
    desc "Configure the VLAN membership mode of an interface. Valid values are access, trunk, or general."
    newvalues(:trunk)
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

  newproperty(:interfaceencapsulationtype) do
    desc "Encapsulationtype for portchannel."
    defaultto "dot1q"
    munge do |value|
      value.to_s
    end
  end
end
