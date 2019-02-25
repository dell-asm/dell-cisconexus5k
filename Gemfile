source 'https://rubygems.org'

group :development, :test do
  gem 'rake' , '~>12.2.1'
  gem 'rspec', '~>3.4.0', :require => false
  gem 'puppetlabs_spec_helper', '0.4.1', :require => false
  gem 'json_pure', '2.0.1'
  gem 'nokogiri', '1.6.8'
  gem 'hashie'
  gem 'i18n', '0.6.9'
  gem 'dell-asm-util', :git => 'https://github.com/dell-asm/dell-asm-util.git', :branch => 'master'
  gem 'sequel', '~> 4.45'
  gem 'rbvmomi', '1.6.0'
  gem 'concurrent-ruby', '~>1.0.0'
  if puppetversion = ENV['PUPPET_GEM_VERSION']
    gem 'puppet', puppetversion
  else
    gem 'puppet', '3.4.2'
  end
end
