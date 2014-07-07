require 'rbconfig'
require 'tmpdir'
require 'rubygems/package'

##
# Gem::Patcher is used to patch .gem files
# by calling system patch command

class Gem::Patcher
  include Gem::UserInteraction

  if Gem::VERSION < '2.0'
    require 'rubygems/package-1.8'
  end

  class PatchCommandMissing < StandardError; end

  def initialize(gemfile, output_dir)
    @gemfile    = gemfile
    @output_dir = output_dir

    # @target_dir is a temporary directory where the gem files live
    tmpdir      = Dir.mktmpdir
    basename    = File.basename(gemfile, '.gem')
    @target_dir = File.join(tmpdir, basename)
  end

  ##
  # Patch the gem, move the new patched gem
  # to +options[:outfile]+ and return the path

  def patch_with(patches, options)
    @std, @output = [], []

    check_patch_command_is_installed
    extract_gem
    copy_in(options[:copy_in], @target_dir) if options[:copy_in]

    # Apply all patches
    patches.each do |patch|
      info 'Applying patch ' + patch
      @std << apply_patch(patch, options)
    end
    remove(options[:remove], @target_dir) if options[:remove]
    build_patched_gem

    options[:outfile] ||= File.join(@output_dir, @package.spec.file_name)
    FileUtils.mv((File.join @target_dir, @package.spec.file_name), options[:outfile]) unless options[:dry_run]

    # Return the path to the patched gem
    options[:outfile]
  end

  ##
  # Apply one +patch+ at a time using +options+
  #
  # Default options:
  #  options[:strip] = 1
  #  options[:fuzz]  = 2

  def apply_patch(patch, options)
    options[:strip] ||= 1
    options[:fuzz]  ||= 2
    
    patch_path = File.expand_path(patch)
    info 'Path to the patch to apply: ' + patch_path
    copy_in(options[:copy_in], @target_dir) if options[:copy_in]

    # Apply the patch by calling 'patch -pNUMBER < patch'
    Dir.chdir @target_dir do
      opts = ["--verbose",  "-p#{options[:strip]}", "--fuzz=#{options[:fuzz]}", "#{options[:patch_options]}"]
      IO.popen("patch #{opts.join(' ')} < #{patch_path} 2>&1") do |out|
        std = out.readlines
        out.close
        info std

        unless $?.nil?
          if $?.exitstatus == 0
            @output << "Succesfully patched with #{patch}"
          else
            @output << "Error: Unable to patch with #{patch}."

            unless Gem.configuration.really_verbose
              @output << 'Run gem patch with --verbose option to swich to verbose mode.'
            end
          end
        end
	std
      end
    end
  end

  ##
  # Print results from patching if
  # Gem.configuration.really_verbose

  def print_results
    @output.each do |msg|
      say msg 
    end
  end

  ##
  # Return output lines

  def output
    @output
  end

  ##
  # Return standard output
  # from patch command

  def std
    @std
  end

  private

  def extract_gem
    @package = Gem::Package.new @gemfile

    # Unpack
    info "Unpacking gem '#{@gemfile}' in " + @target_dir
    @package.extract_files @target_dir
  end

  def build_patched_gem
    patched_package = Gem::Package.new @package.spec.file_name
    patched_package.spec = @package.spec.clone
    patched_package.spec.files = files_in_gem

    # Change dir and build the patched gem
    Dir.chdir @target_dir do
      patched_package.build false
    end
  end

  def copy_in(paths, target)
    origins = paths.split(',')
    origins.each do |p|
      if Dir.exists?(p) || File.exists?(p)
        FileUtils.cp_r(p, File.join(target, File.basename(p)))
      else
        FileUtils.cp_r(File.join(Dir.pwd, p), File.join(target, p))
      end
    end
  end

  def remove(paths, target)
    removals = paths.split(',')
    removals.each do |r|
      FileUtils.rm_r File.join(target, r)
    end
  end

  def info(msg)
    say msg if Gem.configuration.really_verbose
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

    delete_original_files(files)
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

  def delete_original_files(files)
    files.each do |file|
      files.delete file if /\.orig/.match(file)
    end
  end

  def check_patch_command_is_installed
    begin 
      IO.popen('patch --version') 
    rescue Exception
      raise PatchCommandMissing, \
        'Calling `patch` command failed. Do you have it installed?'
    end
  end
end
