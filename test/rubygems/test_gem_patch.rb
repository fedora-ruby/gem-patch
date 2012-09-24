require "rubygems/test_case"
require "rubygems/installer"
require "rubygems/patcher"


class TestGemPatch < Gem::TestCase
	def setup
    super

    @gems_dir  = File.join @tempdir, 'gems'
    @lib_dir = File.join @tempdir, 'gems', 'lib'
    FileUtils.mkdir_p @lib_dir
	end

  ##
  # Test changing a file in a gem with -p1 option

  def test_change_file_patch
    gemfile = util_bake_testing_gem

    patches = []
    patches << util_bake_change_file_patch

    # Creates new patched gem in @gems_dir
    patcher = Gem::Patcher.new(gemfile, @gems_dir)
    patched_gem = patcher.patch_with(patches, 1)

    # Unpack
    package = Gem::Installer.new patched_gem
    package.unpack @gems_dir

    assert_equal util_patched_file, util_file_contents('foo.rb')
  end

  ##
  # Test adding a file into a gem with -p0 option

  def test_new_file_patch
    gemfile = util_bake_testing_gem

    patches = []
    patches << util_bake_new_file_patch

    # Creates new patched gem in @gems_dir
    patcher = Gem::Patcher.new(gemfile, @gems_dir)
    patched_gem = patcher.patch_with(patches, 0)

    # Unpack
    package = Gem::Installer.new patched_gem
    package.unpack @gems_dir

    assert_equal util_original_file, util_file_contents('bar.rb')
  end

  ##
  # Test adding and deleting a file in a gem with -p0 option

  def test_delete_file_patch
    gemfile = util_bake_testing_gem

    patches = []
    patches << util_bake_new_file_patch
    patches << util_bake_delete_file_patch

    # Creates new patched gem in @gems_dir
    patcher = Gem::Patcher.new(gemfile, @gems_dir)
    patched_gem = patcher.patch_with(patches, 0)

    # Unpack
    package = Gem::Installer.new patched_gem
    package.unpack @gems_dir

    # Only foo.rb should stay in /lib, bar.rb should be gone
    assert_raises(RuntimeError, 'File not found') {
      util_file_contents(File.join @lib_dir, 'bar.rb')
    }
  end

  ##
  # Incorrect patch, nothing happens

  def test_gem_should_not_change
    gemfile = util_bake_testing_gem

    patches = []
    patches << util_bake_incorrect_patch

    # Creates new patched gem in @gems_dir
    patcher = Gem::Patcher.new(gemfile, @gems_dir)
    patched_gem = patcher.patch_with(patches, 0)

    # Unpack
    package = Gem::Installer.new patched_gem
    package.unpack @gems_dir

    assert_equal util_original_file, util_file_contents('foo.rb')
    assert_equal util_original_gemspec, util_current_gemspec
  end

  def util_bake_change_file_patch
    patch_path = File.join(@gems_dir, 'change_file.patch')

    File.open(patch_path, 'w') do |f|
      f.write util_change_file_patch
    end

    patch_path
  end

  def util_bake_new_file_patch
    patch_path = File.join(@gems_dir, 'new_file.patch')

    File.open(patch_path, 'w') do |f|
      f.write util_new_file_patch
    end

    patch_path
  end

  def util_bake_delete_file_patch
    patch_path = File.join(@gems_dir, 'delete_file.patch')

    File.open(patch_path, 'w') do |f|
      f.write util_delete_file_patch
    end

    patch_path
  end

  def util_bake_incorrect_patch
    patch_path = File.join(@gems_dir, 'incorrect.patch')

    File.open(patch_path, 'w') do |f|
      f.write util_incorrect_patch
    end

    patch_path
  end

  def util_bake_original_gem_files
    # Create /lib/foo.rb
    file_path = File.join(@lib_dir, 'foo.rb')

    File.open(file_path, 'w') do |f|
      f.write util_original_file
    end

    # Create .gemspec file
    gemspec_path = File.join(@gems_dir, 'foo-0.gemspec')

    File.open(gemspec_path, 'w') do |f|
      f.write util_original_gemspec
    end
  end

  def util_bake_testing_gem
    util_bake_original_gem_files

    #test_package = Gem::Package.open 'foo-0.gem'
    spec = Gem::Specification.load(File.join(@gems_dir, 'foo-0.gemspec'))

    # Build 
    Dir.chdir @gems_dir do
      builder = Gem::Builder.new spec
      builder.build
    end

    File.join(@gems_dir, 'foo-0.gem')
  end

  def util_current_gemspec
    gemspec_path = File.join(@gems_dir, 'foo-0.gemspec')
    gemspec_content = ''

    File.open(gemspec_path, 'r') do |file|
      while line = file.gets
        gemspec_content << line
      end
    end

    gemspec_content
  end

  ##
  # Get the content of the given file in @lib_dir

  def util_file_contents(file)
    file_path = File.join(@lib_dir, file)
    file_content = ''

    begin
      File.open(file_path, 'r') do |file|
        while line = file.gets
          file_content << line
        end
      end
    rescue 
      raise RuntimeError, 'File not found'
    end

    file_content
  end

  def util_original_gemspec
    <<-EOF
      Gem::Specification.new do |s|
        s.platform = Gem::Platform::RUBY
        s.name = 'foo'
        s.version = 0
        s.author = 'A User'
        s.email = 'example@example.com'
        s.homepage = 'http://example.com'
        s.summary = "this is a summary"
        s.description = "This is a test description"
        s.files = ['lib/foo.rb']
      end
    EOF
  end

  def util_original_file
    <<-EOF
      module Foo
        def bar
          'Original'
        end
      end
    EOF
  end

  def util_patched_file
    <<-EOF
      module Foo
        class Bar
          def foo_bar
            'Patched'
          end
        end
      end
    EOF
  end

  def util_change_file_patch
    <<-EOF
diff -u a/lib/foo.rb b/lib/foo.rb
--- a/lib/foo.rb 
+++ b/lib/foo.rb
@@ -1,6 +1,8 @@
       module Foo
-        def bar
-          'Original'
+        class Bar
+          def foo_bar
+            'Patched'
+          end
         end
       end
    EOF
  end

  def util_new_file_patch
    <<-EOF
diff lib/bar.rb lib/bar.rb
--- /dev/null
+++ lib/bar.rb
@@ -0,0 +1,5 @@
+      module Foo
+        def bar
+          'Original'
+        end
+      end
    EOF
  end

  def util_delete_file_patch
    <<-EOF
diff lib/bar.rb lib/bar.rb
--- lib/bar.rb
+++ /dev/null
@@ -1,5 +0,0 @@
-      module Foo
-        def bar
-          'Original'
-        end
-      end
    EOF
  end

  def util_incorrect_patch
    <<-EOF
diff lib/foo.rb lib/foo.rb
--- lib/foo.rb
+++ /dev/null
-      module Foo
-        def bar
-          'Original'
-        end
-      end
    EOF
  end
end