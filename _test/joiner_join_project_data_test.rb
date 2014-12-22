require_relative "../_plugins/joiner"
require_relative "site"

require "minitest/autorun"

module Hub
  class JoinProjectDataTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @site.data['private']['team'] = {}
      @site.data['private']['projects'] = [
        {'name' => 'MSB-USA', 'status' => 'Hold'}
      ]
    end

    def test_join_project
      @impl = JoinerImpl.new(@site)
      @impl.join_project_data
      assert_equal([{'name' => 'MSB-USA', 'status' => 'Hold'}],
        @site.data['projects'])
    end

    def test_hide_hold_projects_in_public_mode
      @site.config['public'] = true
      @impl = JoinerImpl.new(@site)
      @impl.join_project_data
      assert_empty @site.data['projects']
    end
  end
end
