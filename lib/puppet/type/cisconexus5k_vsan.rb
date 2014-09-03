#
# The VSAN type/provider supports the functionality to create and delete the VSAN
# on the Nexus 5000 switch.
#

Puppet::Type.newtype(:cisconexus5k_vsan) do
  @doc = "Manages a VSAN."

  apply_to_device

  ensurable

  newparam(:name) do
    desc "The numeric VSAN ID."
    validate do |value|
      if value !~ /^\d+/
        raise ArgumentError, "The value of the VSAN Id must be a positive integer."
      end
      if value.to_i < 1 || value.to_i > 4094
        raise ArgumentError, "A valid VLAN Id value must not be less than 1,  and must not exceed 4093."
      end
      if value.to_i == 0
        raise ArgumentError, "The VSAN Id 0 is invalid."
      end
    end
  end

  newproperty(:vsanname) do
    desc "VSAN description."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "The VSAN description must contain a value. It cannot be null."
      end
    end
  end

  newproperty(:membership) do
    desc "Members that needs to be added / removed from VSAN"
    munge do |value|
      value.to_s
    end
  end

  newproperty(:membershipoperation) do
    desc "VSAN Membership operation add / delete."
    newvalues("add", "remove")
    munge do |value|
      if value.strip.length == 0
        value.to_s
      else
        value.to_s
      end
    end
  end

  newproperty(:fcoemap) do
    desc "FC MAP Id that needs to be associated with VSAN"
  end

end
