require 'rubygems/installer'
require 'rubygems/builder'

##
# Simulate RubyGems 2.0 behavior to use master branch
# of gem-patch plugin with RubyGems 1.8

module Gem::Package
  def self.new gem
    @gem = gem
    self
  end

  def self.extract_files dir
    @installer = Gem::Installer.new @gem
    @installer.unpack dir
    @spec = @installer.spec
  end

  def self.build skip_validation=false
    @builder = Gem::Builder.new @spec
    @builder.build
  end

  def self.spec=(spec)
    @spec = spec
  end

  def self.spec
    @spec
  end
end
