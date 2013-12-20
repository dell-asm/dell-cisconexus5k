#-------------------------------------------------------------------------------
# Access Mechanism
#-------------------------------------------------------------------------------

The Cisco Nexus 5000 module uses ssh via the net-ssh ruby gem to interact with 
the Nexus switch.

#-------------------------------------------------------------------------------
# Functionality supported
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

    1. member - Comma seperated list of members to the added to the zone.

    2. membertype - Denotes the member type to be added to the zone. Possible
                    values are device-alias, fcalias, fcid, fwwn and pwwn.

    3. vsanid - VSAN Id for the zone.
    
#-------------------------------------------------------------------------------
# Usage
#-------------------------------------------------------------------------------

The Nexus 5000 module can be used by calling the zone type from site.pp as
shown in the example below

  zone {
    "Zone_Demo":
      member => "51:06:01:69:3e:e0:41:dc,55:06:01:69:3e:e0:41:dc",
      membertype => "pwwn",
      vsanid => "1000",
      ensure => "present"
  }
}

