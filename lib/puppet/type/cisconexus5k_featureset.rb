#
# The featureset type/provider supports functionality to add / update / delete feature set on the
# Nexus 5000 switch. 
#

Puppet::Type.newtype(:cisconexus5k_featureset) do
  @doc = "Manages the features that needs to be installed on the nexus switch."

  apply_to_device

  ensurable

  newparam(:name) do
    desc "resource name."
  end

  newproperty(:feature) do
    desc "name of the feature that needs to be installed"
  end

end
