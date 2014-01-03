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


