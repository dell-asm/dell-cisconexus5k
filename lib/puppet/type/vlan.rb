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
          raise ArgumentError, "The value of the VLAN Id must be a positive integer."
        end
        if value.to_i <= 1 || value.to_i >= 4094
          raise ArgumentError, "A valid VLAN Id value must not be less than 1,  and must not exceed 4093."
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
          raise ArgumentError, "The VLAN name must contain a value. It cannot be null."
        end
      end
    end

    newproperty(:istrunkforinterface) do
      desc "Trunking is true or false for interface."
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

    newproperty(:interface) do
      desc "The interface name."
      munge do |value|
        value.to_s
      end

      validate do |value|
        if value.strip.length == 0
          raise ArgumentError, "The Interface property must contain a value. It cannot be null."
        end
      end
    end

    newproperty(:interfaceoperation) do
      desc "The interface operation."
      newvalues("add", "remove")
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

    newproperty(:nativevlanid) do
      desc "The native vlan id."
      defaultto "1"
      munge do |value|
        value.to_i
      end

      validate do |value|
        if value !~ /^\d+/
          raise ArgumentError, "The value of the native VLAN Id must be a positive integer."
        end
        if value.to_i == 0
          raise ArgumentError, "The entered native VLAN Id 0 is invalid."
        end
      end
    end

    newproperty(:removeallassociatedvlans) do
      desc "Remove all associated vlans or not."
      newvalues("true", "false")
      defaultto("true")
      munge do |value|
        value.to_s
      end
    end

    newproperty(:deletenativevlaninformation) do
      desc "Delete native vlan information or not."
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

    newproperty(:unconfiguretrunkmode) do
      desc "Un configure trunk mode or not."
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

    newproperty(:shutdownswitchinterface) do
      desc "Shutdown switch interface or or not."
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

    newproperty(:portchannel) do
      desc "Port channel number."

      validate do |value|
        if value !~ /^\d+/
          raise ArgumentError, "The value of the Port Channel Id must be a positive integer."
        end
        if value.to_i == 0
          raise ArgumentError, "The entered value of the Post Channel Id 0 is invalid."
        end
      end
    end

    newproperty(:portchanneloperation) do
      desc "The port channel operation."
      newvalues("add", "remove")
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

    newproperty(:portchannelencapsulationtype) do
      desc "Encapsulationtype for portchannel."
      defaultto "dot1q"
      munge do |value|
        value.to_s
      end
    end

end
