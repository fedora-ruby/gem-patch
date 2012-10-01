require 'rubygems/package_task'
require 'rake/testtask' 

gemspec = Gem::Specification.new do |s|
  s.name     = "gem-patch"
  s.version  = "0.0.1"
  s.platform = Gem::Platform::RUBY
  s.summary     = "RubyGems plugin for patching gems."
  s.description = <<-EOF
                    `gem-patch` is a RubyGems plugin that helpes to patch gems without manually opening and rebuilding them.
                    It openes a given .gem file, extracts it, patches it with system "patch" command,
                    clones its spec, updates the file list and builds the patched gem.
                  EOF
  s.licenses = [""]
  s.author   = "Josef Stribny"
  s.email    = "jstribny@redhat.com"
  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.8.0"
  s.files = FileList["README.md", "rakefile.rb",
                      "lib/**/*.rb", "test/**/test*.rb"]
end

Gem::PackageTask.new gemspec do |pkg|
end

Rake::TestTask.new('test') do |t|
  t.libs << 'test'
  t.pattern = 'test/**/test*.rb'
  t.verbose = true
end

task :default => [:test]