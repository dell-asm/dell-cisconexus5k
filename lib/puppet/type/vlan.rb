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

end
