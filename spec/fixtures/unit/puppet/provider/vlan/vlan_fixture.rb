class Vlan_fixture
  def initialize
  end

  def  get_dataforupdatevlan
    Puppet::Type.type(:vlan).new(
    :ensure                         => 'present',
    :name                           => '111',
    :vlanname                       => 'demovlan',
    :istrunkforinterface            => 'true',
    :interface                      => 'Eth1/17',
    :interfaceoperation             => 'add',
    :interfaceencapsulationtype     => 'dot1q',
    :isnative                       => 'true',
    :nativevlanid                   => '1',
    :removeallassociatedvlans       => 'true',
    :deletenativevlaninformation    => 'true',
    :unconfiguretrunkmode           => 'true',
    :shutdownswitchinterface        => 'true',
    :portchannel                    => '11',
    :portchanneloperation           => 'add',
    :istrunkforportchannel          => 'true',
    :portchannelencapsulationtype   => 'dot1q'
    )
  end

  def  get_datafordeletevlan
    Puppet::Type.type(:vlan).new(
    :ensure                         => 'absent',
    :name                           => '111',
    :vlanname                       => 'demovlan',
    :istrunkforinterface            => 'true',
    :interface                      => 'Eth1/17',
    :interfaceoperation             => 'add',
    :interfaceencapsulationtype     => 'dot1q',
    :isnative                       => 'true',
    :nativevlanid                   => '1',
    :removeallassociatedvlans       => 'true',
    :deletenativevlaninformation    => 'true',
    :unconfiguretrunkmode           => 'true',
    :shutdownswitchinterface        => 'true',
    :portchannel                    => '11',
    :portchanneloperation           => 'add',
    :istrunkforportchannel          => 'true',
    :portchannelencapsulationtype   => 'dot1q'
    )
  end
end
