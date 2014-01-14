class Device_fixture
  def initialize
  end

  def  get_devicevlans
    vlan_output = <<END
NEXUS-5548-Top# show vlan brief

VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    Po27, Po125, Eth1/18, Eth1/19
                                                Eth1/20, Eth1/21, Eth1/22
                                                Eth1/23, Eth1/24, Eth1/25
                                                Eth1/27, Eth1/28, Eth1/29
                                                Eth1/30
235   vMotion_Net                      active    Po1, Po3, Po5, Po10, Po20
                                                Po125, Po128, Eth1/1, Eth1/2
                                                Eth1/3, Eth1/4, Eth1/5, Eth1/6
                                                Eth1/7, Eth1/8, Eth1/9, Eth1/10
                                                Eth1/17, Eth1/29, Eth1/30
                                                Eth1/31, Eth1/32
288   Hypervisor_Mgmt                  active    Po1, Po3, Po5, Po10, Po20
                                                Po125, Po128, Eth1/1, Eth1/2
                                                Eth1/3, Eth1/4, Eth1/5, Eth1/6
                                                Eth1/7, Eth1/8, Eth1/9, Eth1/10
                                                Eth1/17, Eth1/29, Eth1/30
                                                Eth1/31, Eth1/32
50   VLAN_50                           active
255  VLAN_255                          active
256  VLAN_256                         active
1111 VLAN1111                         active    Po11, Po13, Po15, Po27, Eth1/11
                                                Eth1/12, Eth1/13, Eth1/14
                                                Eth1/15, Eth1/16, Eth1/27
                                                Eth1/28

NEXUS-5548-Top#
END
  end

  def  get_devicezones
    zone_output = <<END
NEXUS-5548-Bottom# show zone
zone name temp vsan 999
  pwwn 50:0a:09:89:88:89:93:0a

zone name EMC_VNX vsan 999

zone name zone6 vsan 999
  pwwn 20:01:74:86:7a:d7:df:4d
  fcalias name EMC_VNX vsan 999
    pwwn 50:09:01:61:3e:e0:39:dc
    pwwn 50:06:09:60:3e:e0:39:dc

zone name Zone_Demo1 vsan 999
  pwwn 20:01:74:76:7a:d7:cb:59 [hostwwpn]
  pwwn 50:00:d3:17:00:5e:c4:24 [netappwwpn3]
  pwwn 50:00:d3:10:70:5e:c4:0a [netappwwpn4]
NEXUS-5548-Bottom#
END
  end

  def get_deviceactivezonesets
    activezoneset_output = <<END
NEXUS-5548-Bottom# show zoneset active
zoneset name Zoneset_Demo1 vsan 999
  zone name Zone_Demo1 vsan 999
  * fcid 0x5f0000 [pwwn 57:0a:09:81:88:89:93:0a]

  zone name abcde6 vsan 999
    pwwn 20:01:74:46:7a:d7:hf:4d
    pwwn 50:06:02:61:3e:e0:34:dc
    pwwn 50:06:03:60:3e:e0:36:dc

  zone name abcde1 vsan 999
    pwwn 50:06:01:61:3e:e0:36:dc
    pwwn 50:06:01:60:3e:e0:39:dc
  * fcid 0x5f0526 [pwwn 20:01:74:86:7a:d7:cb:59] [hostwwpn]
  * fcid 0x5f00f0 [pwwn 50:00:d3:10:00:5e:c4:0a] [netappwwpn4]
  * fcid 0x5f00a5 [pwwn 50:00:d3:10:00:5e:c4:24] [netappwwpn3]

  zone name Zone_Demo1 vsan 999
  * fcid 0x5f0025 [pwwn 20:01:44:86:7a:d7:cb:59] [hostwwpn]
  * fcid 0x5f04a1 [pwwn 50:00:d3:10:00:5e:c4:24] [netappwwpn3]
  * fcid 0x5f30a0 [pwwn 50:00:d2:10:00:5e:c4:0a] [netappwwpn4]
NEXUS-5548-Bottom#
END
  end

  def get_devicezonesets
    @allzoneset_output = <<END
NEXUS-5548-Bottom# show zoneset brief
zoneset name Zoneset_Demo1 vsan 999
  zone Zone_Demo1
  zone abcde6
  zone abcde1
  zone Zone_Demo1
NEXUS-5548-Bottom#
END
  end

  def get_devicealias
    @alias_output = <<END
NEXUS-5548-Bottom# show device-alias database
device-alias name hostwwpn pwwn 20:01:74:86:7n:d7:cb:59
device-alias name Alias_Demo1 pwwn 20:01:00:0e:aa:34:00:07
device-alias name netappwwpn1 pwwn 50:00:d3:17:00:5e:c4:05
device-alias name netappwwpn2 pwwn 50:00:d3:10:70:5e:c4:23
device-alias name netappwwpn3 pwwn 50:00:d3:10:07:5e:c4:24
device-alias name netappwwpn4 pwwn 50:00:d3:10:00:7e:c4:0a
device-alias name abc_4K5JMY1_B2 pwwn 21:00:00:84:ff:4b:53:b3
device-alias name ABC_5K5JMY1_B2 pwwn 21:00:00:94:ff:4b:1b:57
device-alias name ABC_6K5JMY1_B2 pwwn 21:00:00:54:ff:4b:53:4d
device-alias name ABC_7K5JMY1_B2 pwwn 21:00:00:26:ff:4b:52:e9
device-alias name ABC_8K5JMY1_B2 pwwn 21:00:00:64:ff:4b:53:85
device-alias name ABC_CK5JMY1_B2 pwwn 21:00:00:25:ff:4b:18:e5

Total number of entries = 12
NEXUS-5548-Bottom#
END
  end

end
