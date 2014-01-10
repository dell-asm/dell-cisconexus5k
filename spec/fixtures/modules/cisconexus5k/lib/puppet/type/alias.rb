#
# Manages an alias
#
Puppet::Type.newtype(:alias) do
    @doc = "Manages an alias"
    apply_to_device
    ensurable

    newparam(:aliasname) do
        desc "The string type alias name."
        isnamevar
        newvalues(/^\S+/)
        validate do |value|
            if value.strip.length == 0
                raise ArgumentError , "Alias name cannot be empty."
            end
        end      
    end
    
    newproperty(:member) do
        desc "Member WWPN - supported format XX:XX:XX:XX:XX:XX:XX:XX  "
        Puppet.debug "member validation check"
        validate do |value|
            if value.strip.length == 0
                raise ArgumentError , "member name cannot be empty." 
            end 
       
            unless value  =~ /([0-9a-f]{2}:){7}[0-9a-f]{2}/
                raise ArgumentError, " member WWPN supported format XX:XX:XX:XX:XX:XX:XX:XX." 
            end    
        end
    end
end
