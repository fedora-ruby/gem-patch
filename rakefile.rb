require 'rubygems/package_task'
require 'rake/testtask' 

gemspec = Gem::Specification.new do |s|
  s.name     = "gem-patch"
  s.version  = "0.0.1"
  s.platform = Gem::Platform::RUBY
  s.summary     = "RubyGems plugin for patching gems."
  s.description = ""
  s.homepage = "https://github.com/strzibny/gem-patch"
  s.licenses = [""]
  s.author   = ""
  s.email    = ""
  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 2.0.a"
  #s.add_development_dependency 'rake', '~> 0.9.2.2'
  #s.add_development_dependency 'minitest', '~> 3.2'
  s.files = FileList["README.md", "rakefile.rb",
                      "lib/**/*.rb", "test/**/test*.rb", ".gemtest"]
end

Gem::PackageTask.new gemspec do |pkg|
end

Rake::TestTask.new('test') do |t|
  t.libs << 'test'
  t.pattern = 'test/**/test*.rb'
  t.verbose = true
end

task :default => [:test]