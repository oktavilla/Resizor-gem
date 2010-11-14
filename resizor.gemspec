# -*- encoding: utf-8 -*-
require File.expand_path("../lib/resizor/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "resizor"
  s.version     = Resizor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Winston Design"]
  s.email       = ["hello@resizor.com"]
  s.homepage    = "http://rubygems.org/gems/resizor-client"
  s.summary     = "Client for Resizor.com API"
  s.description = "Lets you easily interface with Resizor.com's REST API. Includes Rails helpers."

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "bundler", ">= 1.0.0"
  
  s.add_dependency(%q<rest-client>, [">= 1.4"])
  s.add_dependency(%q<json>, [">= 1.2"])

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
