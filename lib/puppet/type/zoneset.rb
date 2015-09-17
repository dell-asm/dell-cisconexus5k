#
# The zoneset type/provider supports the functionality to create and delete 
# zonesets on the Nexus 5000 switch. 
#

Puppet::Type.newtype(:zoneset) do
  @doc = "Manage Cisco nexus zoneset creation, modification and deletion."

  #apply_to_device

  ensurable

  newparam(:name) do
    desc "The zoneset name. Valid characters are a-z, 1-9 & underscore."
    isnamevar
    validate do |value|
      unless value =~ /^\w+$/
        raise ArgumentError, "\'%s\' is not a valid zoneset name." % value
      end
    end
  end

  newproperty(:vsanid) do
    desc "The VSAN id."
    isrequired
    #defaultto "1g"
    validate do |value|
      unless value =~ /^\d+$/
        raise ArgumentError, "\'%s\' is not a valid vsan id." % value
      end
    end
  end

  newproperty(:member) do
    desc "member zones"
    validate do |value|
      unless value =~ /^((\w+)(.*)(,*))*$/
        raise ArgumentError, "\'%s\' is not a valid format." % value
      end
    end
  end

  newproperty(:active) do
    desc "Activate/deavtivate a Zoneset. Default value is \"false\""
    #defaultto "false"
    # newvalues(:'true', :'false')
    validate do |value|
      unless (value =~ /^true$/ || value =~ /^false$/)
        raise ArgumentError, "\'%s\' is not a valid value, enter \"true\" or \"false\"." % value
      end
    end
  end

  newproperty(:force) do
    desc "Forcefully activates a Zoneset on a given vSAN. Default value is \"false\""
    #defaultto "false"
    #    newvalues(:'true', :'false')
    validate do |value|
      unless (value =~ /^true$/ || value =~ /^false$/)
        raise ArgumentError, "\'%s\' is not a valid value, enter \"true\" or \"false\"." % value
      end
    end
  end

end
