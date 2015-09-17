#
# The vfc interface type/provider supports functionality to add / update / delete vfc interface on the 
# Nexus 5000 switch. 
#

Puppet::Type.newtype(:cisconexus5k_vfc) do
  @doc = "Manages a vfc interface for Cisco Nexus switch."

  #apply_to_device

  ensurable

  newparam(:name) do
    desc "VFC Interface name."
    validate do |value|
      if value !~ /^\d+/
        raise ArgumentError, "The value of the vfc interface must be a positive integer."
      end
      if value.to_i <= 1 || value.to_i >= 4094
        raise ArgumentError, "A valid vfc interface value must not be less than 1,  and must not exceed 4093."
      end
    end
  end

  newproperty(:bind_interface) do
    desc "interface that needs to be binded to the VFC"
  end

  newproperty(:bind_macaddress) do
    desc "MAC Address that needs to be binded to the VFC"
  end
  
  newproperty(:shutdown) do
    desc "Shutdown state of the vfc interface"
    newvalues('true','false')
    defaultto('false')
  end

end
