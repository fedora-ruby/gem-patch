require "rubygems/command"
require "rubygems/patcher"

class Gem::Commands::PatchCommand < Gem::Command
  def initialize
    super "patch", "Patch the gem with the given patches and generate the patched gem",
      :output => Dir.pwd, :strip => 0

    # Same as 'patch -pNUMBER' on Linux machines
    add_option('-pNUMBER', '--strip=NUMBER', 'Set the file name strip count to NUMBER') do |number, options|
      options[:strip] = number
    end
    
    # Number of lines to ignore in looking for places to install a hunk
    add_option('-FNUMBER', '--fuzz=NUMBER', 'Set NUMBER of lines to ignore in looking for places to install a hunk') do |number, options|
      options[:fuzz] = number
    end
    
    # Set output file to FILE instead of overwritting
    add_option('-oFILE', '--output=FILE', 'Set output FILE') do |file, options|
      options[:outfile] = file
    end
    
    # Dry run only shows expected output from the patching process
    add_option('--dry-run', 'Print the results from patching, but do not change any files') do |file, options|
      options[:dry_run] = true
    end
  end

  def arguments # :nodoc:
    args = <<-EOF
          GEMFILE           path to the gem file to patch
          PATCH [PATCH ...] list of patches to apply
    EOF
    return args.gsub(/^\s+/, '')
  end

  def description # :nodoc:
    desc = <<-EOF
           gem-patch is a RubyGems plugin that helps to patch gems without manually opening and rebuilding them.
           It opens a given .gem file, extracts it, patches it with system `patch` command,
           clones its spec, updates the file list and builds the patched gem.
    EOF
    return desc.gsub(/^\s+/, '')
  end

  def usage # :nodoc:
    "#{program_name} GEMFILE PATCH [PATCH ...]"
  end

  def execute
    gemfile = options[:args].shift
    patches = options[:args]
    
    # No gem
    unless gemfile
      raise Gem::CommandLineError,
        "Please specify a gem file on the command line (e.g. gem patch foo-0.1.0.gem PATCH [PATCH ...])"
    end

    # No patches
    if patches.empty?
      raise Gem::CommandLineError,
        "Please specify patches to apply (e.g. gem patch foo-0.1.0.gem foo.patch bar.patch ...)"
    end

    patcher = Gem::Patcher.new(gemfile, options[:output])
    patcher.patch_with(patches, options) 
    patcher.print_results
  end
end
