#
# Manages a VLAN 
#

Puppet::Type.newtype(:vlan) do
    @doc = "Manages a VLAN."

    apply_to_device

    ensurable

    newparam(:name) do
      desc "The numeric VLAN ID."
      isnamevar
      validate do |value|
        if value =~ /0/
          raise ArgumentError, "The VLAN Id 0 is invalid."
        end
        if value !~ /^\d+/
          raise ArgumentError, "The VLAN Id should be numeric."
        end
      end
    end

    newproperty(:vlanname) do
      desc "VLAN name."
    end

end
