# encoding:utf-8

Gem::Specification.new do |s|
  s.name        = 'fb_client'
  s.version     = '0.2.0'
  s.date        = '2015-04-22'
  s.summary     = "FB Tokener for Rasi"
  s.description = "Post and mentions elasticsearch"
  s.authors     = ["Tomas Hrabal"]
  s.email       = 'hrabal.tomas@gmail.com'
  s.files       = [
    "lib/fb_client.rb",
    "lib/fb_client/token.rb",
    "lib/fb_client/fetch.rb",
    "lib/fb_client/request.rb",
  ]
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.homepage    =
    'http://github.com'
  s.license       = 'MIT'

  s.add_dependency 'curburger'
  s.add_dependency 'oj', '~> 2.11'
  s.add_development_dependency "test-unit"
end