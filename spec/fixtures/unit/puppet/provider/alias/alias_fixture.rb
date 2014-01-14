class Alias_fixture

  def initialize
  end

  def  get_dataforcreatealias
     Puppet::Type.type(:alias).new(
           :name                           => 'hostwwpn',
           :ensure                         => 'present',
           :member                         => '20:01:74:86:7a:d7:cb:57',
        )
  end

 def  get_datafordeletealias
 Puppet::Type.type(:alias).new(
           :name                           => 'hostwwpn',
           :ensure                         => 'absent',
        )
  end

end 
