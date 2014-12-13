require_relative "../_plugins/auth"
require_relative "page"

require "jekyll"
require "jekyll/site"
require "minitest/autorun"

module Hub
  class AuthTest < ::Minitest::Test
    def setup
      @site = ::Jekyll::Site.new ::Jekyll::Configuration::DEFAULTS

      @team = {
        'mbland' => {
          'email' => 'michael.bland@gsa.gov',
          'full_name' => 'Mike Bland'},
        'foobar' => {
          'email' => 'foo.bar@notgsa.gov',
          'full_name' => 'Foo Bar'},
        }

      @guests = [
        {'email' => 'mbland@acm.org',
         'full_name' => 'Mike Bland'},
        {'email' => 'baz.quux@notgsa.gov',
         'full_name' => 'Baz Quux'},
      ]
    end

    def actual_auth_include_users
      unless @site.pages.empty?
        @site.pages[0..-2].map {|page| page['user']}
      else
        []
      end
    end

    def actual_auth_emails
      unless @site.pages.empty?
        @site.pages.last['addrs']
      else
        []
      end
    end

    def test_empty_team_and_guests
      @site.data['team'] = {}
      @site.data['guest_users'] = []
      Auth.generate_artifacts @site

      assert_empty actual_auth_include_users
      assert_empty actual_auth_emails
    end

    def test_no_artifacts_in_public_mode
      @site.data['team'] = @team
      @site.data['guest_users'] = @guests
      @site.config['public'] = true
      Auth.generate_artifacts @site

      assert_empty actual_auth_include_users
      assert_empty actual_auth_emails
    end

    def test_team_artifacts_generated
      @site.data['team'] = @team
      Auth.generate_artifacts @site

      assert_equal(
        [@team['mbland'], @team['foobar']],
        actual_auth_include_users)
      assert_equal(
        ['foo.bar@notgsa.gov', 'michael.bland@gsa.gov'],
        actual_auth_emails)
    end

    def test_guest_artifacts_generated
      @site.data['team'] = {}
      @site.data['guest_users'] = @guests
      Auth.generate_artifacts @site

      assert_equal(
        [@guests[0], @guests[1]],
        actual_auth_include_users)
      assert_equal(
        ['baz.quux@notgsa.gov', 'mbland@acm.org'],
        actual_auth_emails)
    end

    def test_team_and_guest_artifacts_generated
      @site.data['team'] = @team
      @site.data['guest_users'] = @guests
      Auth.generate_artifacts @site

      assert_equal(
        [@team['mbland'], @team['foobar'], @guests[0], @guests[1]],
        actual_auth_include_users)
      assert_equal(
        ['baz.quux@notgsa.gov', 'foo.bar@notgsa.gov',
         'mbland@acm.org', 'michael.bland@gsa.gov'],
        actual_auth_emails)
    end
  end
end
