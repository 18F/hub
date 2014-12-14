module Hub
  # Generates artifacts used by authenticated login features.
  class Auth

    # Generate authentication artifacts unless +site.config[+'public'] is
    # true.
    # +site+:: Jekyll site object
    def self.generate_artifacts(site)
      return if site.config['public']
      team = site.data['team'].values.select {|i| i.member? 'email'}
      guests = site.data['guest_users'] || []
      return if team.empty? and guests.empty?

      groups = {
        team => 'team_member_auth_include.html',
        guests => 'guest_user_auth_include.html',
      }

      groups.each do |group, layout|
        group.each do |user|
          generate_user_authentication_include(site, user, layout)
        end
      end

      generate_hub_authenticated_emails(site, team, guests)
    end

    private

    # Generates the upper-right-corner divs used to identify the authenticated
    # user as html snippets under +_site/auth+. The snippets are imported via
    # a Server Side Include directive in +_layouts/bare.html+ using the
    # +$REMOTE_USER+ variable set by the web server, which in turn is
    # determined by the authentication proxy.
    #
    # In the specific case of the internal 18F Hub, the +google_auth_proxy+ is
    # configured with +pass_basic_auth = true+, which passes the authenticated
    # username as part of the HTTP Basic Auth +Authorization: Basic+ header:
    #   http://word.bitly.com/post/47548678256/google-auth-proxy
    # See the +p.SetBasicAuth+ block in +ServeHTTP()+ from:
    #   https://github.com/bitly/google_auth_proxy/blob/master/oauthproxy.go
    #
    # Nginx, in turn, sets the username from this header as the value of the
    # embedded variable +$remote_user+, which is available to the SSI engine:
    #   http://nginx.com/resources/admin-guide/web-server/ (Variables section)
    #   http://nginx.org/en/docs/http/ngx_http_core_module.html#var_remote_user
    #
    # More info:
    #   http://tools.ietf.org/html/rfc3875#section-4.1.11
    #   http://tools.ietf.org/html/rfc2617#section-2
    #
    # +site+:: Jekyll site object
    # +user+:: user hash
    # +layout+:: determines the layout of the HTML snippet
    def self.generate_user_authentication_include(site, user, layout)
      username = user['email'].sub(/@.+$/, '')
      page = Page.new(site, File.join('auth', username), 'index.html',
        layout, "#{user['full_name']} Authentication Include")
      page.data['user'] = user
      site.pages << page
    end

    # Generates the list of email addresses permitted to access the Hub after
    # passing through the google_auth_proxy. See deploy/README.md for details.
    # +site+:: Jekyll site object
    # +team+:: array of team member hashes
    # +guests+ array of guest user hashes
    def self.generate_hub_authenticated_emails(site, team, guests)
      page = Page.new(site, 'auth', 'hub-authenticated-emails.txt',
        'hub-authenticated-emails.txt', 'Authenticated Emails')
      page.data['addrs'] = team.map {|i| i['email']}
      page.data['addrs'].concat(guests.map {|i| i['email']})
      page.data['addrs'].sort!
      site.pages << page
    end
  end
end
