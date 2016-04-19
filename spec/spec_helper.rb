dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, 'spec_lib')

# Don't want puppet getting the command line arguments for rake or autotest
ARGV.clear

begin
  require 'rubygems'
rescue LoadError
end

require 'puppet'
gem 'rspec', '>=2.0.0'
require 'rspec/expectations'

# So everyone else doesn't have to include this base constant.
module PuppetSpec
  FIXTURE_DIR = File.join(dir = File.expand_path(File.dirname(__FILE__)), "fixtures") unless defined?(FIXTURE_DIR)

  def self.fixture_path(fixture)
    File.join(FIXTURE_DIR, fixture)
  end

  def self.load_fixture(fixture)
    File.read(fixture_path(fixture))
  end
end

require 'pathname'
require 'tmpdir'
require 'fileutils'

require 'puppet_spec/verbose'
#require 'puppet_spec/setupcleanup'
require 'puppet_spec/files'
require 'puppet_spec/settings'
require 'puppet_spec/fixtures'
require 'puppet_spec/deviceconf'
require 'puppet_spec/matchers'
require 'puppet_spec/database'
#require 'puppet_spec/factervalue'
#require 'puppet_spec/validation'
#require 'monkey_patches/alias_should_to_must'
#require 'puppet/test/test_helper'

RSpec.configure do |config|
  include PuppetSpec::Fixtures
  include PuppetSpec::Deviceconf
  # include PuppetSpec::Setupcleanup
  #include PuppetSpec::Validation
  #include PuppetSpec::Factervalue

  #c.module_path = File.join(fixture_path, 'modules')
  #c.manifest_dir = File.join(fixture_path, 'manifests')

  config.filter_run_excluding :broken => true

  #config.mock_with :mocha

  tmpdir = Dir.mktmpdir("rspecrun")
  oldtmpdir = Dir.tmpdir()
  ENV['TMPDIR'] = tmpdir

  if Puppet::Util::Platform.windows?
    config.output_stream = $stdout
    config.error_stream = $stderr

    config.formatters.each do |f|
      if not f.instance_variable_get(:@output).kind_of?(::File)
        f.instance_variable_set(:@output, $stdout)
      end
    end
  end
  config.after :suite do
    if ENV['LOG_SPEC_ORDER']
      File.open("./spec_order.txt", "w") do |logfile|
        config.instance_variable_get(:@files_to_run).each { |f| logfile.puts f }
      end
    end
    ENV['TMPDIR'] = oldtmpdir
    FileUtils.rm_rf(tmpdir) if File.exists?(tmpdir) && tmpdir.to_s.start_with?(oldtmpdir)
  end
end
