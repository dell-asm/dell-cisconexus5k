#
# Manages a Zone on a given router or switch
#

Puppet::Type.newtype(:zone) do
    @doc = "Manages a ZONE on a router or switch."

    apply_to_device

    ensurable

    newparam(:name) do
      desc "Zone name."
      isnamevar
      newvalues(/^\S+/)
      validate do |value|
        if value.strip.length == 0
            raise ArgumentError, "Invalid zone name."
        end
      end
    end

    newproperty(:vsanid) do
      desc " vsanid "
      newvalues(/^\d+/)
      validate do |value|
        if value.strip.length == 0
            raise ArgumentError, "Invalid vsan id."
        end
      end

    end
    newproperty(:membertype) do
      desc " member type  "
      newvalues(:'device-alias', :fcalias, :fcid, :fwwn, :pwwn)
    end
    newproperty(:member) do
      desc " member wwpn "
    end

end
