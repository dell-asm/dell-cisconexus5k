#-------------------------------------------------------------------------------
# Access Mechanism
#-------------------------------------------------------------------------------

The Cisco Nexus 5000 module uses the SSH via the net-ssh ruby gem to interact 
with the Nexus switch.

#-------------------------------------------------------------------------------
# Functionality Supported
#-------------------------------------------------------------------------------

- Create zones
- Delete zones
- Add members to zones
- Remove members from zones

#-------------------------------------------------------------------------------
# Description
#-------------------------------------------------------------------------------

The VLAN type/provider supports functionality to create and delete zones on the 
Nexus 5000 switch. 

#-------------------------------------------------------------------------------
# Summary of Properties
#-------------------------------------------------------------------------------

    1. member - This parameter defines the comma seperated list of members to be 
                added to the zone.

    2. membertype - This parameter denotes the member type to be added to the 
                    zone. The valid values are: device-alias, fcalias, fcid, 
                    fwwn and pwwn.

    3. vsanid - This parameter defines the VSAN Id for the zone.
    
#-------------------------------------------------------------------------------
# Usage
#-------------------------------------------------------------------------------

The Nexus 5000 module can be used by calling the zone type from the site.pp, as 
shown in the example below:

  zone {
    "Zone_Demo":
      member => "51:06:01:69:3e:e0:41:dc,55:06:01:69:3e:e0:41:dc",
      membertype => "pwwn",
      vsanid => "1000",
      ensure => "present"
  }

