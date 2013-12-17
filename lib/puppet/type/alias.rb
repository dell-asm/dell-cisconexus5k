#
# Manages a Alias  on a given router or switch
#
Puppet::Type.newtype(:alias) do
    @doc = "Manages a VLAN on a router or switch."
    apply_to_device
    ensurable

    newparam(:aliasname) do
      desc "The string type alias name."
      isnamevar
      newvalues(/^\S+/)
      validate do |value|
          Puppet.info "val #{value}"
         
          if value.strip.length == 0
              raise ArgumentError , "Alias name empty ."
          end
      end      
      end
     newproperty(:member) do
      desc "member WWPN supported format XX:XX:XX:XX:XX:XX:XX:XX  "
      Puppet.debug "member validation check"
      validate do |value|
             if value.strip.length == 0
               Puppet.info "inside member val caheck"
                raise ArgumentError , " member name empty ." 
            end 
       
             unless value  =~ /([0-9a-f]{2}:){7}[0-9a-f]{2}/
                  raise ArgumentError, " member WWPN supported format XX:XX:XX:XX:XX:XX:XX:XX." 
            end    
     end
    end

    
end
