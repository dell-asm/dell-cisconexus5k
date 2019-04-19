Puppet::Type.newtype(:cisconexus5k_firmwareupdate) do
  @doc = "This will perform firmware update on Dell Force10 switch."

  newparam(:name) do
    desc "Firmware name, can be any unique name"
    isnamevar
  end

  newparam(:force) do
    desc "This flag denotes force apply of firmware"
    Puppet.debug(" cisconexus5k_firmwareupdate force update value")
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:copy_to_http) do
    "2 element array, ['path to http share','path under http share']\nFor example: ['/var/lib/razor/repo-store/firmware','catalog1/firmware.bin']\n***Requires path param"
  end

  newparam(:path) do
    "The original firmware location path.  This has to be used in conjuction with to copy_to_http param"
  end

  newproperty(:url) do
    desc "URL of Firmware location "
    validate do |url|
      raise ArgumentError, "Command must be a String, got value of class #{url.class}" unless url.is_a? String
    end

  end

  newproperty(:returns, :event => :executed_command) do |property|
    munge do |value|
      value.to_s
    end

    def event_name
      :executed_command
    end

    defaultto "#"

    def change_to_s(currentvalue, newvalue)
      Puppet.debug(" current value: #{currentvalue} new value is : #{newvalue}")
      "executed successfully"
    end

    def retrieve
    end

    def sync
      event = :executed_command
      self.resource[:copy_to_http] ? copy_to_http = self.resource[:copy_to_http] : nil
      self.resource[:path] ? path = self.resource[:path] : nil
      Puppet.debug("cisco copy_to_http value: #{copy_to_http} new path is : #{path}")
      out = provider.run(self.resource[:url], self.resource[:force], copy_to_http, path)
      event
    end
  end

  @isomorphic = false

  def self.instances
    []
  end

end
