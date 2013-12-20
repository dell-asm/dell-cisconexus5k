#-------------------------------------------------------------------------------
# Access Mechanism
#-------------------------------------------------------------------------------

The Cisco Nexus 5000 module uses ssh via the net-ssh ruby gem to interact with 
the Nexus switch.

#-------------------------------------------------------------------------------
# Functionality supported
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

The VLAN type/provider supports functionality to create and delete VLANs on the
Nexus 5000 switch. 

#-------------------------------------------------------------------------------
# Summary of Properties
#-------------------------------------------------------------------------------

VLAN properties

    1. vlanname - Name of the VLAN to be created.

Interface properties

    1. interface - Interface to be added to the VLAN.

    2. istrunkforinterface - Decides wether mode is access or trunk. Possible 
                             values are true or false. Default - true

    3. interfaceencapsulationtype - Sets the encapsulation type for the 
                                    interface. Default - dot1q

    4. isnative - Decides wether interface will be added to the native VLAN or 
                  not. Possible values are true or false. Default - true

    5. deletenativevlaninformation - Decides if native VLAN is to be deleted
                                     from the interface. Possible values are
                                     true or false. Default - true

    6. unconfiguretrunkmode - Unconfigured trunk mode on the interface. Possible
                              values are true or false. Default - true

    7. shutdownswitchinterface - Shutdown interface or not. Possible values
                                 are true or false. Default - true

    8. interfaceoperation - Operation to be performed for the interface.
                            Possible values are add or remove.

    9. nativevlanid - User specified native VLAN Id to be set for the interface.
                      Default - 1

    10. removeallassociatedvlans - Removes all associated VLANs. Possible
                                   values are true or false. Default - true.

Portchannel properties


    1. portchannel - Portchannel to be added.

    2. istrunkforportchannel -  Decides wether mode is access or trunk. Possible 
                                values are true or false. Default - true

    3. portchannelencapsulationtype -  Sets the encapsulation type for the 
                                        portchannel. Default - dot1q

    4. portchanneloperation - Operation to be performed for the portchannel.
                              Possible values are add or remove.

#-------------------------------------------------------------------------------
# Usage
#-------------------------------------------------------------------------------

The Nexus 5000 module can be used by calling the vlan type from site.pp as
shown in the example below

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



