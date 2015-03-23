require_relative "test_helper"
require_relative "../_plugins/hub"
require_relative "site"

require "minitest/autorun"
require "test_temp_file_helper"

module Hub
  class CopyFilesTest < ::Minitest::Test
    def setup
      @temp_file_helper = TestTempFileHelper::TempFileHelper.new
      config = {
        'source' => @temp_file_helper.tmpdir,
        'private_data_path' => File.join('private_assets', 'private_images'),
      }
      @site = DummyTestSite.new(config: config)
      @site.static_files = []
      @source_dir = File.join('assets', 'images', 'team')
    end

    def teardown
      @temp_file_helper.teardown
    end

    def test_private_source_dir_does_not_exist
      Hub::Generator.copy_files(@site, @site.config['private_data_path'],
        'assets')
      assert_empty @site.static_files
    end

    def test_private_source_dir_is_empty
      @temp_file_helper.mkdir(File.join(@site.config['private_data_path'],
        @source_dir))
      Hub::Generator.copy_files(@site, @site.config['private_data_path'],
        'assets')
      assert_empty @site.static_files
    end

    def test_private_assets_copied_over
      img_files = ['mbland', 'afeld', 'gboone'].map {|i| "#{i}.jpg"}
      img_files.each do |filename|
        @temp_file_helper.mkfile(File.join(@site.config['private_data_path'],
            @source_dir, filename))
      end

      Hub::Generator.copy_files(@site, @site.config['private_data_path'],
        'assets')
      expected = img_files.map {|f| File.join @source_dir, f}
      actual = @site.static_files.map {|f| File.join f.relative_path}
      assert_equal expected.sort, actual.sort
    end
  end
end
