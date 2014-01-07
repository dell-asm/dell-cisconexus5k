#-------------------------------------------------------------------------------
# Access Mechanism
#-------------------------------------------------------------------------------

The Cisco Nexus 5000 module uses SSH via the net-ssh ruby gem to interact with 
the Nexus switch.

#-------------------------------------------------------------------------------
# Functionality Supported
#-------------------------------------------------------------------------------

- Create VLANs
- Destroy VLANs
- Add Interfaces to VLAN
- Remove Interfaces from VLAN
- Add portchannel to VLAN
- Remove portchannel from VLAN

#-------------------------------------------------------------------------------
# Description
#-------------------------------------------------------------------------------

The VLAN type/provider supports the functionality to create and delete the VLANs 
on the Nexus 5000 switch.

#-------------------------------------------------------------------------------
# Summary of Properties
#-------------------------------------------------------------------------------

VLAN properties:

    1. vlanname - This parameter defines the name of the VLAN to be created.

Interface properties:

    1. interface - This parameter defines the interface to be added to the VLAN.

    2. istrunkforinterface - This parameter decides if the mode is access or 
                             trunk. The valid values are true or false. The 
                             default value is "true".

    3. interfaceencapsulationtype - This parameter sets the encapsulation type 
                                    for the interface. The default value is "dot1q".

    4. isnative - This parameter decides whether or not the interface will be 
                  added to the native VLAN. The valid values are true or false. 
                  The default value is "true".

    5. deletenativevlaninformation - This parameter decides whether or not the 
                                     native VLAN is to be deleted from the interface. 
                                     The possible values are true or false. The 
                                     default value is "true".

    6. unconfiguretrunkmode - This parameter defines the un-configured trunk 
                              mode on the interface. The valid values are true
                              or false. The default value is "true".

    7. shutdownswitchinterface - This parameter defines whether or not to 
                                 shutdown the interface. The possible values 
                                 are true or false. The default value is "true".

    8. interfaceoperation - This parameter defines the operation to be 
                            performed for the interface. The possible values 
                            are "add" or "remove".

    9. nativevlanid - This parameter defines the user specified native VLAN Id
                      to be set for the interface. The default value is "1".

    10. removeallassociatedvlans - This parameter removes all the associated 
                                   VLANs. The possible values are true or false.
                                   The default value is "true".

Portchannel properties:

    1. portchannel - This parameter defines the Portchannel to be added.

    2. istrunkforportchannel -  This parameter decides if the mode is access or 
                                trunk. The possible values are true or false. 
                                The default vause is "true".

    3. portchannelencapsulationtype -  This parameter sets the encapsulation 
                                       type for the portchannel. The default
                                       value is "dot1q".

    4. portchanneloperation - This parameter defines the operation to be 
                              performed on the portchannel. The possible values 
                              are "add" or "remove".

#-------------------------------------------------------------------------------
# Usage
#-------------------------------------------------------------------------------

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



