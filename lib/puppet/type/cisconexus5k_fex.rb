#
# The FEX type/provider supports the functionality to create and delete the FEX
# on the Nexus 5000 switch.
#

Puppet::Type.newtype(:cisconexus5k_fex) do
  @doc = "Manages a FEX Configuration."

  apply_to_device

  ensurable

  newparam(:name) do
    desc 'The numeric FEX ID.'
    validate do |value|
      if value !~ /^\d+/
        raise ArgumentError, 'The value of the VSAN Id must be a positive integer.'
      end
      if value.to_i < 100 || value.to_i > 199
        raise ArgumentError, 'A valid FEX Id value must not be less than 100,  and must not exceed 199.'
      end
    end
  end

  newproperty(:fcoe) do
    desc 'Manage FCoE feature for FEX.'
    newvalues(:true,:false)
  end

end
