require "rbconfig"
require "tmpdir"
require "rubygems/installer"

class Gem::Patcher
  include Gem::UserInteraction

  def initialize(gemfile, output_dir)
    @gemfile    = gemfile
    @output_dir = output_dir
  end

  ##
  # Patch the gem, move the new patched gem to working directory and return the path

  def patch_with(patches, strip_number)
    package = Gem::Installer.new @gemfile

    # Create a temporary dir
    tmpdir      = Dir.mktmpdir
    basename    = File.basename(@gemfile, '.gem')
    @target_dir = File.join(tmpdir, basename)

    # Unpack
    info "Unpacking gem '#{basename}' in " + @target_dir
    package.unpack @target_dir

    # Apply all patches
    patches.each do |patch|
      info 'Applying patch ' + patch
      apply_patch(patch, strip_number)
    end

    # Files for gemspec, add new files and remove old ones
    @files = [] 

    files_in_gem.each do |file|
      @files << file unless /\.orig/.match(file)
    end

    # New gem file that will be generated
    patched_gem = package.spec.file_name

    package.spec.files = @files
    patched_package = Gem::Builder.new package.spec.clone

    # Change dir and build the patched gem
    Dir.chdir @target_dir do
      patched_package.build
    end

    # Move the newly generated gem to working directory
    system("cd #{@output_dir};mv #{File.join @target_dir, patched_gem} patched-#{patched_gem}")

    # Return the path to the patched gem
    File.join @output_dir, "patched-#{patched_gem}"
  end

  def apply_patch(patch, strip_number)
    patch_path = File.expand_path(patch)
    info 'Path to the patch to apply: ' + patch_path

    # Apply the patch by calling 'patch -pNUMBER < patch'
    if system("cd #{@target_dir};patch --verbose -p#{strip_number} < #{patch_path}")
        info 'Succesfully patched by ' + patch
      else
        info 'Error: Unable to patch with ' + patch
      end
  end

  private

  def info(msg)
    say msg if Gem.configuration.verbose
  end

  def files_in_gem
    files = []

    Dir.foreach(@target_dir) do |file|
      if File.directory? File.join @target_dir, file
        files += files_in_dir(file) unless /\./.match(file)
      else
        files << file
      end
    end

    files
  end

  def files_in_dir(dir)
    files = []

    Dir.foreach(File.join @target_dir, dir) do |file|
      if File.directory? File.join @target_dir, dir, file
        files += files_in_dir(File.join dir, file) unless /\./.match(file)
      else
        files << File.join(dir, file)
      end
    end

    files
  end
end