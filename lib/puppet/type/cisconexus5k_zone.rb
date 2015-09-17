#
# The zone type/provider supports functionality to create and delete zones on the 
# Nexus 5000 switch. 
#

Puppet::Type.newtype(:cisconexus5k_zone) do
  @doc = "Manages a ZONE on a router or switch."

  #apply_to_device

  ensurable

  newparam(:name) do
    desc "Zone name."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "The zone name is invalid."
      end
      if value =~/^\d/
        raise ArgumentError, "The zone name is invalid, Zone name cannot start with a digit"
      end
      if value !~ /^\S{1,64}$/
        raise ArgumentError, "The zone name is invalid."
      end
    end
  end

  newproperty(:vsanid) do
    desc "vsanid"

    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "The VSAN Id is invalid."
      end
      if value.to_i == 0
        raise ArgumentError, "The VSAN Id 0 is invalid."
      end
      if value !~ /^\d+/
        raise ArgumentError, "The VSAN Id should be numeric."
      end
    end

  end

  newproperty(:membertype) do
    desc "member type"
    newvalues(:'device-alias', :fcalias, :fcid, :fwwn, :pwwn)
  end

  newproperty(:member) do
    desc "member wwpn"
  end

end
