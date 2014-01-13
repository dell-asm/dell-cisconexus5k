class Zoneset_fixture
  def initialize
  end

  def  get_dataforupdatezoneset
    Puppet::Type.type(:zoneset).new(
    :ensure                         => 'present',
    :name                           => 'Demo_Zoneset1',
    :member                         => 'Demo_Zone2',
    :vsanid                         => '999'
    )
  end

  def  get_datafordeletezoneset
    Puppet::Type.type(:zoneset).new(
    :ensure                         => 'absent',
    :name                           => 'Demo_Zoneset1',
    :vsanid                         => '999',
    :active                         => "false"
    )
  end

end
