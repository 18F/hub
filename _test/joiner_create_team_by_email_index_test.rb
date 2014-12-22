require_relative "../_plugins/joiner"
require_relative "site"

require "minitest/autorun"

module Hub
  class CreateTeamByEmailIndexTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @team = []
      @site.data['private'] = {'team' => @team}
    end

    def test_nonexistent_join_source
      @site.data.delete 'private'
      @site.data.delete 'public'
      impl = JoinerImpl.new(@site)
      assert_equal 'public', impl.source
      assert_empty impl.team_by_email
    end

    def test_nonexistent_team
      @site.data.delete 'private'
      impl = JoinerImpl.new(@site)
      assert_equal 'public', impl.source
      assert_empty impl.team_by_email
    end

    def test_empty_team
      impl = JoinerImpl.new(@site)
      assert_equal 'private', impl.source
      assert_empty impl.team_by_email
    end

    def test_single_user_index
      @team << {'name' => 'mbland', 'email' => 'michael.bland@gsa.gov'}
      impl = JoinerImpl.new(@site)
      assert_equal({'michael.bland@gsa.gov' => 'mbland'}, impl.team_by_email)
    end

    def test_single_user_with_private_email_index
      @team << {
        'name' => 'mbland', 'private' => {'email' => 'michael.bland@gsa.gov'},
      }
      impl = JoinerImpl.new(@site)
      assert_equal({'michael.bland@gsa.gov' => 'mbland'}, impl.team_by_email)
    end

    def test_single_private_user_index
      @team << {
        'private' => [
          {'name' => 'mbland', 'email' => 'michael.bland@gsa.gov'},
        ],
      }
      impl = JoinerImpl.new(@site)
      assert_equal({'michael.bland@gsa.gov' => 'mbland'}, impl.team_by_email)
    end

    def test_multiple_user_index
      @team << {'name' => 'mbland', 'email' => 'michael.bland@gsa.gov'}
      @team << {
        'name' => 'foobar', 'private' => {'email' => 'foo.bar@gsa.gov'},
      }
      @team << {
        'private' => [
          {'name' => 'bazquux', 'email' => 'baz.quux@gsa.gov'},
        ],
      }

      expected = {
        'michael.bland@gsa.gov' => 'mbland',
        'foo.bar@gsa.gov' => 'foobar',
        'baz.quux@gsa.gov' => 'bazquux',
      }
      impl = JoinerImpl.new(@site)
      assert_equal expected, impl.team_by_email
    end

    def test_ignore_users_without_email
      @team << {'name' => 'mbland'}
      @team << {'name' => 'foobar', 'private' => {}}
      @team << {'private' => [{'name' => 'bazquux'}]}

      impl = JoinerImpl.new(@site)
      assert_empty impl.team_by_email
    end
  end
end
