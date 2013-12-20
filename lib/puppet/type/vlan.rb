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
          raise ArgumentError, "The VLAN Id should be in the range 1-4093."
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

    newproperty(:istrunkforinterface) do
      desc "Trunking is true or false for interface."
      newvalues(:true, :false)
      defaultto(:true)
      munge do |value|
        if value.strip.length == 0
          value.to_s
        else
          value.to_s
        end
      end
    end

    newproperty(:interface) do
      desc "The interface name."
      munge do |value|
        value.to_s
      end

      validate do |value|
        if value.strip.length == 0
          raise ArgumentError, "The Interface value should not be blank."
        end
      end
    end

    newproperty(:interfaceoperation) do
      desc "The interface operation."
      newvalues(:add, :remove)
      munge do |value|
        if value.strip.length == 0
          value.to_s
        else
          value.to_s
        end
      end
    end

    newproperty(:interfaceencapsulationtype) do
      desc "Encapsulationtype for interface."
      defaultto "dot1q"
      munge do |value|
        value.to_s
      end
    end

    newproperty(:isnative) do
      desc "The interface is associated with native vlan or not"
      newvalues(:true, :false)
      defaultto(:true)
      munge do |value|
        if value.strip.length == 0
          value.to_s
        else
          value.to_s
        end
      end
    end

    newproperty(:nativevlanid) do
      desc "The native vlan id."
      defaultto "1"
      munge do |value|
        value.to_i
      end

      validate do |value|
        if value !~ /^\d+/
          raise ArgumentError, "The native VLAN Id should be positive integer."
        end
        if value.to_i == 0
          raise ArgumentError, "The native VLAN Id 0 is invalid."
        end
      end
    end

    newproperty(:removeallassociatedvlans) do
      desc "Remove all associated vlans or not."
      newvalues(:true, :false)
      defaultto(:true)
      munge do |value|
        value.to_s
      end
    end

    newproperty(:deletenativevlaninformation) do
      desc "Delete native vlan information or not."
      newvalues(:true, :false)
      defaultto(:true)
      munge do |value|
        if value.strip.length == 0
          value.to_s
        else
          value.to_s
        end
      end
    end

    newproperty(:unconfiguretrunkmode) do
      desc "Un configure trunk mode or not."
      newvalues(:true, :false)
      defaultto(:true)
      munge do |value|
        if value.strip.length == 0
          value.to_s
        else
          value.to_s
        end
      end
    end

    newproperty(:shutdownswitchinterface) do
      desc "Shutdown switch interface or or not."
      newvalues(:true, :false)
      defaultto(:true)
      munge do |value|
        if value.strip.length == 0
          value.to_s
        else
          value.to_s
        end
      end
    end

    newproperty(:portchannel) do
      desc "Port channel number."

      validate do |value|
        if value !~ /^\d+/
          raise ArgumentError, "The Port channelId should be positive integer."
        end
        if value.to_i == 0
          raise ArgumentError, "The Port channelId 0 is invalid."
        end
      end
    end

    newproperty(:portchanneloperation) do
      desc "The port channel operation."
      newvalues(:add, :remove)
      munge do |value|
        if value.strip.length == 0
          value.to_s
        else
          value.to_s
        end
      end
    end

    newproperty(:istrunkforportchannel) do
      desc "Trunking is true or false for portchannel."
      newvalues(:true, :false)
      defaultto(:true)
      munge do |value|
        if value.strip.length == 0
          value.to_s
        else
          value.to_s
        end
      end
    end

    newproperty(:portchannelencapsulationtype) do
      desc "Encapsulationtype for portchannel."
      defaultto "dot1q"
      munge do |value|
        value.to_s
      end
    end

end
