#
# Manages a VLAN 
#

Puppet::Type.newtype(:vlan) do
    @doc = "Manages a VLAN."

    apply_to_device

    ensurable

    newparam(:name) do
      desc "The numeric VLAN ID."
      validate do |value|
        if value !~ /^\d+/
          raise ArgumentError, "The VLAN Id should be positive integer."
        end
        if value.to_i <= 1 || value.to_i >= 4094
          raise ArgumentError, "The VLAN Id should be in the range 2-4094."
        end
        #if value.to_i == 0
        #  raise ArgumentError, "The VLAN Id 0 is invalid."
        #end
      end
    end

    newproperty(:vlanname) do
      desc "VLAN name."
      validate do |value|
        if value.strip.length == 0
          raise ArgumentError, "VLAN name property cannot be empty."
        end
      end
    end
end
