require_relative "../_plugins/joiner"
require_relative "page"

require "jekyll"
require "jekyll/site"
require "minitest/autorun"

module Hub
  class DeepMergeTest < ::Minitest::Test
    def test_raise_if_classes_differ
      assert_raises JoinerImpl::MergeError do
        JoinerImpl.deep_merge({}, [])
      end
    end

    def test_raise_if_not_mergeable
      assert_raises JoinerImpl::MergeError do
        JoinerImpl.deep_merge(true, false)
      end
    end

    def test_merge_into_empty_hash
      lhs = {}
      rhs = {:foo => true}
      JoinerImpl.deep_merge lhs, rhs
      assert_equal rhs, lhs
    end

    def test_merge_into_empty_array
      lhs = []
      rhs = [{:foo => true}]
      JoinerImpl.deep_merge lhs, rhs
      assert_equal rhs, lhs
    end

    def test_rhs_hash_overwrites_nonmergeable_lhs_hash_values
      lhs = {:foo => false}
      rhs = {:foo => true}
      JoinerImpl.deep_merge lhs, rhs
      assert_equal rhs, lhs
    end

    def test_rhs_appends_values_to_lhs
      lhs = [{:foo => false}]
      rhs = [{:foo => true}]
      JoinerImpl.deep_merge lhs, rhs
      assert_equal [{:foo => false}, {:foo => true}], lhs
    end

    def test_recursively_merge_hashes
      lhs = {
        'name' => 'mbland',
        'languages' => ['C++'],
        'age' => 'None of your business',
        'guitars' => {
          'strats' => 'too many',
          'acoustics' => 1,
          },
        }
      rhs = {
        'full_name' => 'Mike Bland',
        'languages' => ['Python', 'Ruby'],
        'age' => 'Not gonna say it',
        'guitars' => {
          'strats' => 'not enough',
          'les_pauls' => 1,
          },
        }
      JoinerImpl.deep_merge lhs, rhs

      expected = {
        'name' => 'mbland',
        'full_name' => 'Mike Bland',
        'languages' => ['C++', 'Python', 'Ruby'],
        'age' => 'Not gonna say it',
        'guitars' => {
          'strats' => 'not enough',
          'acoustics' => 1,
          'les_pauls' => 1,
          },
        }

      assert_equal expected, lhs
    end
  end

  class PromoteDataTest < ::Minitest::Test
    def test_ignore_if_not_a_collection
      assert_nil JoinerImpl.promote_data 27, 'private'
      assert_nil JoinerImpl.promote_data 'foobar', 'private'
      assert_nil JoinerImpl.promote_data :msb, 'private'
      assert_nil JoinerImpl.promote_data true, 'private'
    end

    def test_no_effect_on_empty_collections
      hash_data = {}
      JoinerImpl.promote_data hash_data, 'private'
      assert_empty hash_data

      array_data = []
      JoinerImpl.promote_data array_data, 'private'
      assert_empty array_data
    end

    def test_promote_private_hash_data
      data = {
        'name' => 'mbland',
        'private' => {'email' => 'michael.bland@gsa.gov'},
        'full_name' => 'Mike Bland',
      }

      expected = {
        'name' => 'mbland',
        'email' => 'michael.bland@gsa.gov',
        'full_name' => 'Mike Bland',
      }

      JoinerImpl.promote_data data, 'private'
      assert_equal expected, data
    end

    def test_promote_private_array_data
      data = [
        {'name' => 'mbland', 'full_name' => 'Mike Bland'},
        {'private' => [{'name' => 'foobar'}]},
      ]

      expected = [
        {'name' => 'mbland', 'full_name' => 'Mike Bland'},
        {'name' => 'foobar'},
      ]

      JoinerImpl.promote_data data, 'private'
      assert_equal expected, data
    end

    def test_promote_private_data_in_array_at_different_depths
      data =[
        {'name' => 'mbland',
         'full_name' => 'Michael S. Bland',
         'languages' => ['C++'],
         'private' => {
           'full_name' => 'Mike Bland',
           'email' => 'michael.bland@gsa.gov',
           'languages' => ['Python', 'Ruby'],
         },
        },
        {'private' => [
           {'name' => 'foobar',
            'full_name' => 'Foo Bar',
            'email' => 'foo.bar@gsa.gov',
           },
         ],
        },
      ]

      expected = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland',
         'email' => 'michael.bland@gsa.gov',
         'languages' => ['C++', 'Python', 'Ruby'],
        },
        {'name' => 'foobar',
         'full_name' => 'Foo Bar',
         'email' => 'foo.bar@gsa.gov',
        },
      ]

      JoinerImpl.promote_data data, 'private'
      assert_equal expected, data
    end
  end

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
           {'private' => [{'name' => 'foobar'}]}]))
    end
  end

  class JoinArrayDataTest < ::Minitest::Test
    def test_empty_arrays
      assert_empty JoinerImpl.join_array_data('unused', [], [])
    end

    def test_assert_raises_if_lhs_and_rhs_are_not_arrays
      assert_raises JoinerImpl::JoinError do
        assert_empty JoinerImpl.join_array_data('unused', [], {})
      end

      assert_raises JoinerImpl::JoinError do
        assert_empty JoinerImpl.join_array_data('unused', {}, [])
      end

      assert_raises JoinerImpl::JoinError do
        assert_empty JoinerImpl.join_array_data('unused', {}, {})
      end
    end

    def test_assert_raises_if_key_field_is_missing
      assert_raises JoinerImpl::JoinError do
        assert_empty JoinerImpl.join_array_data('key', [{'key'=>true}], [{}])
      end

      assert_raises JoinerImpl::JoinError do
        assert_empty JoinerImpl.join_array_data('key', [{}], [{'key'=>true}])
      end
    end

    def test_leave_lhs_alone_if_rhs_is_empty
      lhs = [{'key'=>true}]
      rhs = []
      JoinerImpl.join_array_data('key', lhs, rhs)
      assert_equal [{'key'=>true}], lhs
    end

    def test_lhs_matches_rhs_if_lhs_is_empty
      lhs = []
      rhs = [{'key'=>true}]
      JoinerImpl.join_array_data('key', lhs, rhs)
      assert_equal [{'key'=>true}], lhs
    end

    def test_join_single_item
      lhs = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland',
         'languages' => ['C++'],
        },
      ]
      rhs = [
        {'name' => 'mbland',
         'email' => 'michael.bland@gsa.gov',
         'languages' => ['Python', 'Ruby'],
        },
      ]
      expected = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland',
         'email' => 'michael.bland@gsa.gov',
         'languages' => ['C++', 'Python', 'Ruby'],
        },
      ]
      JoinerImpl.join_array_data('name', lhs, rhs)
      assert_equal expected, lhs
    end

    def test_join_multiple_items
      lhs = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland',
         'languages' => ['C++'],
        },
        {'name' => 'foobar',
         'full_name' => 'Foo Bar',
        },
      ]
      rhs = [
        {'name' => 'foobar',
         'email' => 'Foo.Bar@gsa.gov',
        },
        {'name' => 'mbland',
         'email' => 'michael.bland@gsa.gov',
         'languages' => ['Python', 'Ruby'],
        },
        {'name' => 'bazquux',
         'full_name' => 'Baz Quux',
         'email' => 'baz.quux@gsa.gov',
        },
      ]
      expected = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland',
         'email' => 'michael.bland@gsa.gov',
         'languages' => ['C++', 'Python', 'Ruby'],
        },
        {'name' => 'foobar',
         'full_name' => 'Foo Bar',
         'email' => 'Foo.Bar@gsa.gov',
        },
        {'name' => 'bazquux',
         'full_name' => 'Baz Quux',
         'email' => 'baz.quux@gsa.gov',
        },
      ]
      JoinerImpl.join_array_data('name', lhs, rhs)
      assert_equal expected, lhs
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
