Gem::Specification.new do |s|
  s.name     = 'gem-patch'
  s.version  = '0.1.6'
  s.platform = Gem::Platform::RUBY
  s.summary     = 'RubyGems plugin for patching gems.'
  s.description = <<-EOF
                    gem-patch is a RubyGems plugin that helps to patch gems without manually opening and rebuilding them.
                    It opens a given .gem file, extracts it, patches it with system patch command,
                    clones its spec, updates the file list and builds the patched gem.
                  EOF
  s.homepage = 'http://github.com/strzibny/gem-patch'
  s.licenses = ['MIT']
  s.author   = 'Josef Stribny'
  s.email    = 'strzibny@strzibny.name'
  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = '>= 1.8.0'
  s.files = Dir['README.md', 'LICENCE', 'rakefile.rb',
                'lib/**/*.rb', 'test/**/test*.rb']
end
