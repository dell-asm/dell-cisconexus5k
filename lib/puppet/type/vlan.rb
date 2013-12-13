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

      newvalues(/^\d+/)
    end

    newproperty(:vlanname) do
      desc "VLAN name."
    end

    newproperty(:interface) do
      desc "Interfaces to be added to the vlan"
    end

    newproperty(:portchannel) do
      desc "portchannels"
    end
    
    newparam(:device_url) do
      desc "The URL of the router or switch maintaining this VLAN."
    end
end
