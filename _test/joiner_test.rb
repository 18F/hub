require_relative "../_plugins/joiner"
require_relative "page"

require "jekyll"
require "jekyll/site"
require "minitest/autorun"

module Hub
  class RemovePrivateDataTest < ::Minitest::Test
    def test_ignore_if_not_a_collection
      assert_nil JoinerImpl.remove_private_data 27
      assert_nil JoinerImpl.remove_private_data 'foobar'
      assert_nil JoinerImpl.remove_private_data :msb
      assert_nil JoinerImpl.remove_private_data true
    end

    def test_ignore_empty_collections
      assert_equal({}, JoinerImpl.remove_private_data({}))
      assert_equal([], JoinerImpl.remove_private_data([]))
    end

    def test_remove_top_level_private_data_from_hash
      assert_equal({'name' => 'mbland', 'full_name' => 'Mike Bland'},
        JoinerImpl.remove_private_data(
          {'name' => 'mbland', 'full_name' => 'Mike Bland',
           'private' => {'email' => 'michael.bland@gsa.gov'}}))
    end

    def test_remove_top_level_private_data_from_array
      assert_equal([{'name' => 'mbland', 'full_name' => 'Mike Bland'}],
        JoinerImpl.remove_private_data(
          [{'name' => 'mbland', 'full_name' => 'Mike Bland'},
           {'private' => {'name' => 'foobar'}}]))
    end

    def test_remove_private_data_from_object_array_at_different_depths
      assert_equal([{'name' => 'mbland', 'full_name' => 'Mike Bland'}],
        JoinerImpl.remove_private_data(
          [{'name' => 'mbland', 'full_name' => 'Mike Bland',
            'private' => {'email' => 'michael.bland@gsa.gov'}},
           {'private' => {'name' => 'foobar'}}]))
    end
  end

  class ImportGuestUsersTest < ::Minitest::Test
    def setup
      @site = ::Jekyll::Site.new ::Jekyll::Configuration::DEFAULTS
    end

    def test_no_private_data
      assert_nil JoinerImpl.new(@site).import_guest_users
    end

    def test_no_hub_data
      @site.data['private'] = {}
      assert_nil JoinerImpl.new(@site).import_guest_users
      assert_nil @site.data['guest_users']
    end

    def test_no_guest_users
      @site.data['private'] = {'hub' => {}}
      assert_nil JoinerImpl.new(@site).import_guest_users
      assert_nil @site.data['guest_users']
    end

    def test_guest_users_moved_to_top_level
      guests = [
        {'email' => 'michael.bland@gsa.gov',
         'full_name' => 'Mike Bland'},
        ]
      @site.data['private'] = {'hub' => {'guest_users' => guests}}
      assert_equal guests, JoinerImpl.new(@site).import_guest_users
      assert_equal guests, @site.data['guest_users']
      assert_nil @site.data['private']['hub']['guest_users']
    end
  end

  class FilterPrivatePagesTest < ::Minitest::Test
    def setup
      @site = ::Jekyll::Site.new ::Jekyll::Configuration::DEFAULTS
      @all_page_names = []
      @public_page_names = []
    end

    def add_public_page(filename)
      @site.pages << DummyTestPage.new(@site, '/pages', filename)
      @all_page_names << filename
      @public_page_names << filename
    end

    def add_private_page(filename)
      @site.pages << DummyTestPage.new(@site, '/pages/private', filename)
      @all_page_names << filename
    end

    def filter_pages_in_internal_mode
      @site.config.delete 'public'
      JoinerImpl.new(@site).filter_private_pages
    end

    def filter_pages_in_public_mode
      @site.config['public'] = true
      JoinerImpl.new(@site).filter_private_pages
    end

    def page_names
      @site.pages.map {|p| p.name}
    end

    def test_no_pages
      filter_pages_in_internal_mode
      assert_empty page_names
      filter_pages_in_public_mode
      assert_empty page_names
    end

    def test_single_public_page
      add_public_page 'public.html'
      filter_pages_in_internal_mode
      assert_equal(@all_page_names, page_names)
      filter_pages_in_public_mode
      assert_equal(@public_page_names, page_names)
    end

    def test_single_private_page
      add_private_page 'private.html'
      filter_pages_in_internal_mode
      assert_equal(@all_page_names, page_names)
      filter_pages_in_public_mode
      assert_empty page_names
    end

    def test_public_and_private_pages
      add_private_page 'private-0.html'
      add_public_page 'public-0.html'
      add_private_page 'private-1.html'
      add_public_page 'public-1.html'
      add_private_page 'private-2.html'
      filter_pages_in_internal_mode
      assert_equal(@all_page_names, page_names)
      filter_pages_in_public_mode
      assert_equal(@public_page_names, page_names)
    end
  end
end
