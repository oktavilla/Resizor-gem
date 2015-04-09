# -*- encoding: utf-8 -*-
require File.expand_path('../lib/resizor/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'resizor'
  s.version     = Resizor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Oktavilla']
  s.email       = ['hello@resizor.com']
  s.homepage    = 'http://github.org/oktavilla/resizor-gem'
  s.summary     = 'Client for Resizor.com API'
  s.description = 'Lets you easily interface with the Resizor.com REST API. Includes Rails helpers.'

  s.required_rubygems_version = '>= 1.3.6'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'minitest', '>= 5.5.1'

  s.add_dependency(%q<rest-client>, ['>= 1.4.2'])
  s.add_dependency(%q<json>, ['>= 1.2'])

  s.files        = Dir.glob("{test,lib}/**/*") + %w(README.rdoc resizor.gemspec Rakefile Gemfile)
  s.require_path = 'lib'
end
