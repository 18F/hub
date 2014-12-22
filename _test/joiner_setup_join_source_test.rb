require_relative "../_plugins/joiner"
require_relative "site"

require "minitest/autorun"

module Hub
  class SetupJoinSourceTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @site.data['private']['team'] = [
        {'name' => 'mbland', 'full_name' => 'Mike Bland',
         'private' => {'email' => 'michael.bland@gsa.gov'}
        },
        {'private' => [
          {'name' => 'foobar', 'full_name' => 'Foo Bar'},
          ],
        },
      ]
    end

    def test_remove_private_data
      @site.config['public'] = true
      impl = JoinerImpl.new(@site)
      impl.setup_join_source
      assert_equal(
        [{'name' => 'mbland', 'full_name' => 'Mike Bland'}],
        @site.data['private']['team'])
    end

    def test_promote_private_data
      impl = JoinerImpl.new(@site)
      impl.setup_join_source
      assert_equal(
        [{'name' => 'mbland', 'full_name' => 'Mike Bland',
          'email' => 'michael.bland@gsa.gov',
         },
         {'name' => 'foobar', 'full_name' => 'Foo Bar'},
        ],
        @site.data['private']['team'])
    end
  end
end
