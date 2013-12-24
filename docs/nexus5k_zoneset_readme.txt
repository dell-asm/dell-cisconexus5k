#-------------------------------------------------------------------------------
# Access Mechanism
#-------------------------------------------------------------------------------

The Cisco Nexus 5000 module uses the SSH via the net-ssh ruby gem to interact 
with the Nexus switch.

#-------------------------------------------------------------------------------
# Functionality Supported
#-------------------------------------------------------------------------------

- Create zoneset
- Add zone to zone set
- Remove zone from zoneset
- Activate zoneset
- De-activate zoneset
- Delete zoneset

#-------------------------------------------------------------------------------
# Description
#-------------------------------------------------------------------------------

The zoneset type/provider supports functionality to create and delete zonesets 
on the Nexus 5000 switch. 

#-------------------------------------------------------------------------------
# Summary of Properties
#-------------------------------------------------------------------------------

    1. member - This parameter (Optional) defines the comma separated list of 
				member zones for the zoneset.
				If parameter is omitted then zoneset's zone members won't be touched.
    
    2. vsanid - This parameter (Mandatory) defines the VSAN Id for the zoneset.
    
	3. active - This parameter (Optional) defines whether to activate or deactivate the 
				given zoneset on a given VSAN. The valid values are "true" or "false". 
                If parameter is omitted then zoneset activation state won't be touched.
    
	4. force - 	This parameter (Optional) defines whether or not to forcefully
				activate the given zoneset if another zoneset is already active on given VSAN.
				The valid values are "true" or "false". 
                This parameter make sense only when used along with "active" parameter.
    
#-------------------------------------------------------------------------------
# Usage
#-------------------------------------------------------------------------------

The Nexus 5000 module can be used by calling the zoneset type from the site.pp, as 
shown in the example below:

Usage:- Create zoneset
    zoneset {
      "Zoneset_Demo":
        vsanid => "999",
        ensure => "present",
    }

Usage:- Add zone to zone set
    zoneset {
      "Zoneset_Demo":
        member => "Zone_Demo1,Zone_Demo2,Zone_Demo3",
        vsanid => "999",
        ensure => "present",
    }

Usage:- Remove zone from zoneset (will remove Zone_Demo2 and Zone_Demo3)
    zoneset {
      "Zoneset_Demo":
        member => "Zone_Demo1",
        vsanid => "999",
        ensure => "present",
    }

Usage:- Activate zoneset
    zoneset {
      "Zoneset_Demo":
        vsanid => "999",
        ensure => "present",
        active => "true",
        force => "true",
    }


Usage:- De-activate zoneset
    zoneset {
      "Zoneset_Demo":
        vsanid => "999",
        ensure => "present",
        active => "false",
    }


Usage:- Delete zoneset
    zoneset {
      "Zoneset_Demo":
        vsanid => "999",
        ensure => "absent",
    }

Example:- Create, add member zones and force active
    zoneset {
      "Zoneset_Demo":
        member => "Zone_Demo1,Zone_Demo2",
        vsanid => "999",
        ensure => "present",
        active => "true",
        force => "true",
    }

Example:- deactivate zoneset and delete it
    zoneset {
      "Zoneset_Demo":
        vsanid => "999",
        ensure => "absent",
        active => "false",
    }
