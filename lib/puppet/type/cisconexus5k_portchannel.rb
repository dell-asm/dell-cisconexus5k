Puppet::Type.newtype(:cisconexus5k_portchannel) do

  @doc = "configures cisconexus5k port channel"

  ensurable

  newparam(:name) do
    desc "The numeric port channel Id."
    validate do |value|
      if value !~ /^\d+/
        raise ArgumentError, "The value of the port channel Id must be a positive integer."
      end

      if value.to_i < 1
        raise ArgumentError, "A valid port channel Id value must not be less than 1,  and must not exceed 4093."
      end

      if value.to_i == 0
        raise ArgumentError, "The entered value of the Post Channel Id 0 is invalid."
      end
    end
  end

  newproperty(:vpc) do
    desc "vpc number."

    validate do |value|
      if value !~ /^\d+/
        raise ArgumentError, "The value of the vpc Id must be a positive integer."
      end
    end
  end

  newproperty(:untagged_vlan) do
    desc "Untagged VLANs to add to a general port. Specify non consecutive VLAN IDs with a comma and no spaces. Use a hyphen to designate a range of VLAN IDs."
    validate do |value|
      return if value == :absent || value.empty?
      raise ArgumentError, "There should only one untagged vlan for interface port: #{value}" if value.split(",").size() > 1
    end
  end

  newproperty(:tagged_vlan) do
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

  newproperty(:mtu) do
    desc "MTU value"
    defaultto(:absent)
    newvalues(:absent, /^\d+$/)
    validate do |value|
      return if value == :absent
      raise ArgumentError, "An invalid 'mtu' value is entered. The 'mtu' value must be between 594 and 12000" unless value.to_i >= 594 && value.to_i <= 12000
    end
  end

  newproperty(:removeallassociatedvlans) do
    desc "Remove all associated vlans or not."
    newvalues("true", "false")
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

  newproperty(:speed) do
    desc "speed value"
    defaultto(:Auto)
    newvalues(:Auto, /^\d+$/)
  end

  newproperty(:access_vlan) do
    desc "vlan for access port when interface is not in trunk mode"
    validate do |value|
      return if value == :absent || value.empty?
      raise ArgumentError, "Invalid vlan list: #{value}" if value.include?(',') && !(value.split(',').size > 0)

      raise ArgumentError, "There should only one access vlan for access port: #{value}" if value.split(",").size() > 1
    end
  end

  newproperty(:portchanneloperation) do
    desc "interface opearion either 'add' or 'remove'"
    newvalues("add", "remove")
  end

  newproperty(:istrunkforportchannel) do
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
end
