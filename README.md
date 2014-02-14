#Cisoconexus5k

####Table of Contents

1. [Overview](#overview)
2. [VLAN](#vlan)
3. [Alias](#alias)
4. [Zone](#zone)
5. [Zoneset](#zoneset)

##Overview

The cisconexus5k module allows the user to manage VLANs, aliases, zones and zonesets on a Cisco Nexus 5000 series switch. The module uses net-ssh and net-telnet to communicate with the switch.

This module was developed by Dell which is why the name of the repo starts with dell-.   The name dell-cisconexus5k does not imply a partnership, agreement or other special relationship between Dell and Cisco.  Cisco Nexus® is a registered trademark of Cisco Systems, Inc.

##VLAN

###Description

The VLAN type/provider supports the functionality to create and delete the VLANs 
on the Nexus 5000 switch.

####Summary of Properties

#####VLAN properties:

1. _vlanname_ - This parameter defines the name of the VLAN to be created.

#####Interface properties:

1. _interface_ - This parameter defines the interface to be added to the VLAN.

2. _istrunkforinterface_ - This parameter decides if the mode is access or trunk. The valid values are true or false. The default value is "true".

3. _interfaceencapsulationtype_ - This parameter sets the encapsulation type for the interface. The default value is "dot1q".

4. _isnative_ - This parameter decides whether or not the interface will be added to the native VLAN. The valid values are true or false. The default value is "true".

5. _deletenativevlaninformation_ - This parameter decides whether or not the native VLAN is to be deleted from the interface. The possible values are true or false. The default value is "true".

6. _unconfiguretrunkmode_ - This parameter defines the un-configured trunk mode on the interface. The valid values are true or false. The default value is "true".

7. _shutdownswitchinterface_ - This parameter defines whether or not to shutdown the interface. The possible values are true or false. The default value is "true".

8. _interfaceoperation_ - This parameter defines the operation to be performed for the interface. The possible values are "add" or "remove".

9. _nativevlanid_ - This parameter defines the user specified native VLAN Id to be set for the interface. The default value is "1".

10. _removeallassociatedvlans_ - This parameter removes all the associated VLANs. The possible values are true or false. The default value is "true".

#####Portchannel properties:

1. _portchannel_ - This parameter defines the Portchannel to be added.

2. _istrunkforportchannel_ -  This parameter decides if the mode is access or trunk. The possible values are true or false. The default vause is "true".

3. _portchannelencapsulationtype_ -  This parameter sets the encapsulation type for the portchannel. The default value is "dot1q".

4. _portchanneloperation_ - This parameter defines the operation to be performed on the portchannel. The possible values are "add" or "remove".


####Usage

The Nexus 5000 module can be used by calling the VLAN type from site.pp, as 
shown in the example below:

    vlan {
      "100":
        ensure                        => "present",
        vlanname                      => "TestVLAN100",
        interface                     => "Eth1/12",
        interfaceoperation            => "add",
        istrunkforinterface           => "true",
        interfaceencapsulationtype    => "dot1q",
        isnative                      => "true",
        deletenativevlaninformation   => "true",
        unconfiguretrunkmode          => "true",
        shutdownswitchinterface       => "true",
        portchannel                   => "11",
        portchanneloperation          => "remove",
        istrunkforportchannel         => "true",
        portchannelencapsulationtype  => "dot1q"
    }

## Alias

###Description

The alias type supports the functionality to create and delete aliases on the Cisco nexus switch.

####Summary of properties

1. _member_ - This is the WWPN of the member that is to be added to the alias

####Usage

Aliases can be created using the following manifest

```
	alias {"hostwwpn":
    	member      => "20:01:74:86:7a:d7:cb:57",
        ensure      => "present",
    }
```

##Zone

- Create zones
- Delete zones
- Add members to zones
- Remove members from zones

###Description

The zone type/provider supports functionality to create and delete zones on the 
Nexus 5000 switch. 

####Summary of Properties

1. _member_ - This parameter defines the comma seperated list of members to be added to the zone.

2. _membertype_ - This parameter denotes the member type to be added to the zone. The valid values are: device-alias, fcalias, fcid, fwwn and pwwn.

3. _vsanid_ - This parameter defines the VSAN Id for the zone.
    
####Usage

The Nexus 5000 module can be used by calling the zone type from the site.pp, as 
shown in the example below:

	zone {
    	"Zone_Demo":
      		member => "51:06:01:69:3e:e0:41:dc,55:06:01:69:3e:e0:41:dc",
      		membertype => "pwwn",
      		vsanid => "1000",
      		ensure => "present"
  	}

##Zoneset

###Description

The zoneset type/provider supports the functionality to create and delete 
zonesets on the Nexus 5000 switch. 

####Summary of Properties

1. _member_ - (Optional) This parameter defines the comma separated list of member zones for the zoneset. If this parameter is omitted then the existing zoneset members will not be affected.
    
2. _vsanid_ - (Mandatory) This parameter defines the VSAN Id for the zoneset.
    
3. _active_ - (Optional) This parameter defines whether to activate or deactivate the given zoneset on a given VSAN. The valid values are "true" or "false". If this parameter is omitted then the zoneset state is not be affected.
    
4. _force_ - (Optional)	This parameter defines whether or not to forcefully activate the given zoneset, if another zoneset is already active on the given VSAN. The valid values are "true" or "false". This parameter must be used with the "active" parameter.
    
####Usage

The Nexus 5000 module can be used by calling the zoneset type from site.pp, as 
shown in the example below:

- Create zoneset

```
	zoneset { "Zoneset_Demo":
    	vsanid => "999",
        ensure => "present",
    }
```

- Add zone to zone set

```
	zoneset { "Zoneset_Demo":
    	member => "Zone_Demo1,Zone_Demo2,Zone_Demo3",
        vsanid => "999",
        ensure => "present",
    }
```

- Remove zone from zoneset (removes the Zone_Demo2 and Zone_Demo3)

```
	zoneset { "Zoneset_Demo":
        member => "Zone_Demo1",
        vsanid => "999",
        ensure => "present",
    }
```

