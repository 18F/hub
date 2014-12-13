module Hub
  # Generates artifacts used by authenticated login features.
  class Auth

    # Generate authentication artifacts unless +site.config[+'public'] is
    # true.
    # +site+:: Jekyll site object
    def self.generate_artifacts(site)
      return if site.config['public'] == true
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
    # user. The divs are imported via a Server Side Include directive in
    # _layouts/bare.html.
    # +site+:: Jekyll site object
    # +user+:: user hash
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
