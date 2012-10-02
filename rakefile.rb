require 'rubygems/package_task'
require 'rake/testtask' 
require 'rdoc/task'

gemspec = Gem::Specification.new do |s|
  s.name     = "gem-patch"
  s.version  = "0.1.0"
  s.platform = Gem::Platform::RUBY
  s.summary     = "RubyGems plugin for patching gems."
  s.description = <<-EOF
                    `gem-patch` is a RubyGems plugin that helps to patch gems without manually opening and rebuilding them.
                    It opens a given .gem file, extracts it, patches it with system `patch` command,
                    clones its spec, updates the file list and builds the patched gem.
                  EOF
  s.licenses = ["MIT"]
  s.author   = "Josef Stribny"
  s.email    = "jstribny@redhat.com"
  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.8.0"
  s.files = FileList["README.md", "README.rdoc", "rakefile.rb",
                      "lib/**/*.rb", "test/**/test*.rb"]
end

Gem::PackageTask.new gemspec do |pkg|
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

Rake::TestTask.new('test') do |t|
  t.libs << 'test'
  t.pattern = 'test/**/test*.rb'
  t.verbose = true
end

task :default => [:test]
