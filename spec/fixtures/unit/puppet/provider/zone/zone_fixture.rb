class Zone_fixture
  def initialize
  end

  def  get_dataforupdatezone
    Puppet::Type.type(:zone).new(
    :ensure                         => 'present',
    :name                           => 'Demo_Zone1',
    :member                         => '51:06:01:69:3e:e0:41:dc,55:06:01:69:3e:e0:41:dc',
    :membertype                     => 'pwwn',
    :vsanid                         => '999'
    )
  end

  def  get_datafordeletezone
    Puppet::Type.type(:zone).new(
    :ensure                         => 'absent',
    :name                           => 'Demo_Zone1',
    :member                         => '51:06:01:69:3e:e0:41:dc,55:06:01:69:3e:e0:41:dc',
    :membertype                     => 'pwwn',
    :vsanid                         => '999'
    )
  end

end
