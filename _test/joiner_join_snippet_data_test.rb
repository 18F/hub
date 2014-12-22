require_relative "../_plugins/joiner"
require_relative "site"

require "minitest/autorun"

module Hub
  class JoinSnippetDataTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @site.data['private']['snippets'] = {'v1' => {}, 'v2' => {}, 'v3' => {}}
      @site.data['private']['team'] = []
      @impl = JoinerImpl.new(@site)
      @expected = {}
    end

    def set_team(team_list)
      @site.data['private']['team'] = team_list
      @impl.create_team_by_email_index
      @impl.join_data 'team', 'name'
      @impl.convert_to_hash 'team', 'name'
    end

    def add_snippet(version, timestamp, name, full_name,
      email, public_or_private, last_week, this_week, expected: true)
      snippets = @site.data['private']['snippets'][version]
      unless snippets.member? timestamp
        snippets[timestamp] = []
      end
      collection = snippets[timestamp]

      case version
      when "v1"
        collection << {
          'Timestamp' => timestamp,
          'Username' => email,
          'Name' => full_name,
          'Snippets' => last_week
        }
      when "v2"
        unless ['Private', ''].include? public_or_private
          raise Exception.new("Invalide public_or_private for v2: "+
            "#{public_or_private}")
        end
        collection << {
          'Timestamp' => timestamp,
          'Public vs. Private' => public_or_private,
          'Last Week' => last_week,
          'This Week' => this_week,
          'Username' => email,
        }
      when "v3"
        unless ['Public', ''].include? public_or_private
          raise Exception.new("Invalide public_or_private for v3: "+
            "#{public_or_private}")
        end
        collection << {
          'Timestamp' => timestamp,
          'Public' => public_or_private,
          'Username' => email,
          'Last week' => last_week,
          'This week' => this_week,
        }
      else
        raise Exception.new "Unknown version: #{version}"
      end

      if expected
        snippet = collection.last
        s = {}
        snippet.each {|k,v| s[Canonicalizer.canonicalize k] = v}
        s['name'] = name
        s['full_name'] = full_name
        s['version'] = version
        unless @expected.member? timestamp
          @expected[timestamp] = []
        end
        @expected[timestamp] << s
      end
    end

    def test_empty_snippet_data
      set_team([])
      @impl.join_snippet_data
      assert_empty @site.data['snippets']
      assert_nil @site.data['private']['snippets']
    end

    def test_publish_nothing_if_no_team
      set_team([])
      add_snippet('v1', '20141218', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', 'unused', '- Did stuff', 'unused',
        expected:false)
      add_snippet('v2', '20141225', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', '', '- Did stuff', '', expected:false)
      add_snippet('v3', '20141231', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', 'Public', '- Did stuff', '', expected:false)
      @impl.join_snippet_data
      assert_empty @site.data['snippets']
      assert_nil @site.data['private']['snippets']
    end

    def test_publish_all_snippets_internally
      set_team([
        {'name' => 'mbland', 'full_name' => 'Mike Bland',
         'email' => 'michael.bland@gsa.gov'},
      ])
      add_snippet('v1', '20141218', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', 'unused', '- Did stuff', 'unused')
      add_snippet('v2', '20141225', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', '', '- Did stuff', '')
      add_snippet('v3', '20141231', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', 'Public', '- Did stuff', '')
      @impl.join_snippet_data
      assert_equal @expected, @site.data['snippets']
      assert_nil @site.data['private']['snippets']
    end

    def test_publish_only_public_v3_snippets_in_public_mode
      @site.config['public'] = true
      @impl = JoinerImpl.new(@site)

      set_team([
        {'name' => 'mbland', 'full_name' => 'Mike Bland',
         'email' => 'michael.bland@gsa.gov'},
      ])
      add_snippet('v1', '20141218', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', 'unused', '- Did stuff', 'unused',
        expected:false)
      add_snippet('v2', '20141225', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', '', '- Did stuff', '', expected:false)
      add_snippet('v3', '20141231', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', 'Public', '- Did stuff', '')
      add_snippet('v3', '20150107', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', '', '- Did stuff', '', expected:false)

      @impl.join_snippet_data
      assert_equal @expected, @site.data['snippets']
      assert_nil @site.data['private']['snippets']
    end
  end
end
