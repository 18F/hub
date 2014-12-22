require_relative "../_plugins/joiner"
require_relative "site"

require "minitest/autorun"

module Hub
  class JoinDataTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
    end

    def test_join_team_data_from_private_source
      @site.data['team'] = [
        {'name' => 'mbland', 'full_name' => 'Mike Bland'},
      ]
      @site.data['private']['team'] = [
        {'name' => 'mbland', 'email' => 'michael.bland@gsa.gov'},
      ]
      impl = JoinerImpl.new(@site)
      impl.join_data 'team', 'name'
      assert_equal(
        [{'name' => 'mbland', 'full_name' => 'Mike Bland',
          'email' => 'michael.bland@gsa.gov'}],
        @site.data['team'])
    end
  end
end
