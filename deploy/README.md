## Deploying the 18F Hub

### Set up SSH

Ask Mike Bland or Eric Mill to help add your public key (typically `$HOME/.ssh/id_rsa.pub`) to `$HOME/.ssh/authorized_keys` on `hub.18f.gov` and `18f.gsa.gov`. Then make sure your `$HOME/.ssh/config` file on your machine contains the following entries:

```
Host 18f-site
   Hostname 18f.gsa.gov
   User site
   IdentityFile [$HOME]/.ssh/id_rsa
   IdentitiesOnly yes

Host 18f-hub
   Hostname hub.18f.gov
   User ubuntu
   IdentityFile [$HOME]/.ssh/id_rsa
   IdentitiesOnly yes
```

This configuration allows you to log into each machine as the appropriate user by just running `ssh 18f-hub` or `ssh 18f-site`. It is also required for managing the automated deployment tasks using `fabric` as described below.

### DEPRECATED: `publish.sh` and `publish-prod.sh`

Not much to see here; after regenerating the site with Jekyll, [publish.sh](publish.sh) just `rsync`s it to `hub.18f.gov`. [publish-prod.sh](publish-prod.sh) does the same thing for the Public Hub.

Now that automated deployments are underway (see below), these scripts are deprecated. They remain as examples for those wishing to deploy their own Hub instances quickly.

### AWS

https://hub.18f.gov/ is running as an AWS EC2 instance named `18f-hub` based on 18F's `m3.medium` image. The AWS Elastic IP of the instance is assigned to the `hub.18f.gov` subdomain via the AWS Route 53 panel. The associated AWS Security Group restricts access to the SSH, HTTP, and HTTPS ports (22, 80, and 443), but those ports are reachable from any source IP address.

The Public Hub is served directly from https://18f.gsa.gov/.

### Nginx

For the internal Hub, [/etc/nginx/nginx.conf](etc/nginx/nginx.conf) is the stock 18F nginx config that comes with the image, modified to include the Hub-specific config, [/etc/nginx/vhosts/hub.conf](etc/nginx/vhosts/hub.conf), further described in the OAuth2 Proxy section below:

```
  ##
  # Virtual Host Configs
  ##

  #include /etc/nginx/vhosts/*.conf;
  include /etc/nginx/vhosts/hub.conf;
```

For the public Hub, see the `location /hub` block within the [18f.gsa.gov 18f-site.conf Nginx config file](https://github.com/18F/18f.gsa.gov/blob/staging/deploy/18f-site.conf).

### SSL

For the internal hub, [/etc/nginx/vhosts/hub.conf](etc/nginx/vhosts/hub.conf) is configured to use SSL as per the [18F baseline nginx TLS config](https://github.com/18F/tls-standards/tree/master/configuration/nginx). Contact Eric Mill for access to the private key.

The public Hub is served by the same web server as https://18f.gsa.gov and doesn't require its own configuration.

### OAuth2 Proxy

_This pertains to the internal Hub only._

The [etc](etc) and [usr](usr) subdirectory trees contain the files needed to configure Nginx and the [OAuth2 Proxy](https://github.com/bitly/oauth2_proxy) in concert to ensure only 18F team members can access the Hub. The current version of `oauth2_proxy` running on `hub.18f.gov` was built at commit a80aad04f7bbe821bca9ea9659fef04c869ac970. The latest packaged version can be downloaded from: https://github.com/bitly/oauth2_proxy/releases and unpacked on the Hub machine as `/usr/local/18f/bin/oauth2_proxy`.

* [/etc/init.d/oauth2_proxy](etc/init.d/oauth2_proxy): Enables the `oauth2_proxy` service to be started and stopped like any other standard service, via `sudo service oauth2_proxy [start|stop|restart]`.

* [/etc/nginx/vhosts/hub.conf](etc/nginx/vhosts/hub.conf): All `http://` requests are permanently redirected (301) to the `https://` equivalent by the first `server` block. The second `server` block, listening for `https://` requests, is configured to forward all requests (except for the logo used for the consent screen) to the `oauth2_proxy` service. The content of the site is ultimately served by the final `server` block, accessible only by the running `oauth2_proxy` instance on the localhost, given the AWS Security Group port restrictions.

  *Notice the `port_in_redirect off;` line in the third `server` block:* Without this line, permanent redirects from directory URLs _without_ a trailing slash to directory URLs _with_ a trailing slash will include the local server's port, which will cause the redirect to fail.

* [/usr/local/18f/bin/oauth2_proxy.sh](usr/local/18f/bin/oauth2_proxy.sh): A shim that allows the `oauth2_proxy` logs to be captured in `/var/log/oauth2_proxy/access.log`.

* [/usr/local/18f/etc/oauth2_proxy.cfg](usr/local/18f/etc/oauth2_proxy.cfg): The configuration file for the `oauth2_proxy`, specified as a command line flag by [/etc/init.d/oauth2_proxy](etc/init.d/oauth2_proxy). The `client_id` and `client_secret` fields have been redacted from the repository. Currently they contain Mike Bland's MyUSA app credentials for the 18F Hub.

  Previously they came from Mike Bland's personal account, since https://console.developers.google.com/ is currently disabled for the gsa.gov domain. A dedicated, shared `18f-hub-admin@gsa.gov` account would be ideal. For progress on this front, see 18F DevOps issues [60](https://github.com/18F/DevOps/issues/60) and [79](https://github.com/18F/DevOps/issues/79).

  *Notice the `authenticated_emails_file` setting, and that `google_apps_domains` has been commented out.* Access is granted to the union of these two sets, i.e. to everyone in the `authenticated_emails_file` _or_ in the `google_apps_domains`.

#### Single Sign-On

For the details on how the Hub's `oauth2_proxy` instance is configured as a single sign-on service for multiple 18f.gov domains, see the [Single Sign-On instructions](SSO.md).

#### Adding/removing users

The `authenticated_emails_file` is the list of authenticated users authorized to access the Hub. It is currently generated by the [auth.rb](../_plugins/auth.rb) plugin. Whenever team member email address information is updated in [_data/private/team.yml](../_data/private/team.yml) or [_data/private/hub/guest_users.yml](../_data/private/hub/guest_users.yml), a new version of this file will be generated, and the `oauth2_proxy` will reload the file.

#### Configuration changes

The `oauth2_proxy` must be restarted if you update `/usr/local/18f/etc/oauth2_proxy.cfg`. One you have your `$HOME/.ssh/config` configured as described at the beginning of this document, you can restart the `oauth2_proxy` like so:

```
$ ssh 18f-hub sudo service oauth2_proxy restart
```

### Preparing for automated deployment

The automated deployment of the Hub is accomplished by:

- cloning the Hub's GitHub repository on the deployment host to track a specific deployment branch;
- using `fabric` to launch a `hookshot` server on the deployment host, configured using [fabfile.py](fabfile.py);
- configuring `nginx` on the deployment host to reverse-proxy requests to the local `hookshot` server; and
- configuring the Webhook on GitHub to send a request to the deployment host whenever updates are pushed.

Provisioning the deployment environment still requires manual work at the moment. You need to set up `fabric` on your local machine; install `node`, `ruby` and several `npm` packages on the remote machine; and prepare a clone of the Hub repository on the remote machine.

#### Local: Fabric

On your local machine, using the system Python:
```
$ sudo easy_install pip
$ sudo pip install fabric
```

#### Remote: Node.js

On Eric Mill's advice, for Ubuntu, download the latest Node binary and install it directly on the machine; don't use `apt-get`. You can find the link to the latest version at https://nodejs.org/download/ (the latest was `v0.10.34` at the time of writing).
```
$ ssh 18f-hub
$ wget http://nodejs.org/dist/v0.10.34/node-v0.10.34-linux-x64.tar.gz
$ gzip -dc node-v0.10.34-linux-x64.tar.gz | tar xf -
$ sudo cp node-v0.10.34-linux-x64/bin/node /usr/local/bin
```

#### Remote: NPM packages

```
$ ssh 18f-hub
$ npm install hookshot
$ npm install minimist
$ npm install -g forever
```

#### Remote: Ruby

Using `rbenv` helps ensure a stable Ruby version. It must be installed on `/usr/local` or `/opt`, since the file system serving the `/home` directory has `noexec` set as a mount option.
```
$ ssh 18f-hub
$ export RBENV_ROOT=/usr/local/rbenv
$ sudo mkdir $RBENV_ROOT
$ sudo chown $USER $RBENV_ROOT
$ git clone https://github.com/sstephenson/rbenv.git $RBENV_ROOT
$ echo 'export RBENV_ROOT=/usr/local/rbenv' >> ~/.bashrc
$ echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> ~/.bashrc
$ echo 'eval "$(rbenv init -)"' >> ~/.bashrc
[log out...]

$ ssh 18f-hub
$ cd $RBENV_ROOT
$ git pull
$ git clone https://github.com/sstephenson/ruby-build.git \
  $RBENV_ROOT/plugins/ruby-build
$ rbenv rehash
$ rbenv install -l
[pick a version...]

$ rbenv install [VERSION]
[time passes...]

$ rbenv global [VERSION]
```

#### Remote: GitHub access

In order to access the private submodules, the remote user will need SSH access to GitHub. First you'll need to generate a key for the remote user if `$HOME/.ssh/id_rsa.pub` doesn't yet exist. Enter the following, and do not supply a passphrase when prompted:

```
$ ssh-keygen -b 2048 -t rsa -C "18F Hub internal deployment key"
```

This will generate `$HOME/.ssh/id_rsa.pub`. Copy this key and [add it to your list of SSH keys](https://github.com/settings/ssh).

#### Remote: Git configuration

The remote user's git configuration needs to be set to the following to enable automated updates to the Hub's private submodules (via GitHub webhooks, discussed at the end of this document):

```
$ git config --global push.default simple
$ git config --global user.name "18F Hub automated deployment"
$ git config --global user.email "18f@gsa.gov"
```

#### Remote: Initial cloning and build

Before deploying, clone the repo on the remote host based on the appropriate branch, then perform the first build to ensure that everything is installed properly, including the [hookshot.js](hookshot.js) script.

In the examples below, replace `[BRANCH]` with the name of the repository branch used to trigger the automated deployment.
```
$ ssh 18f-hub
$ git clone https://github.com/18F/hub.git --branch [BRANCH] hub-[BRANCH]
$ cd $HOME/hub-[BRANCH]
$ if [ -a deploy/hookshot.js ]; then echo "OK"; else echo "missing"; fi
OK

$ gem install bundler
$ bundle
[time passes...]

$ git submodule init
$ bundle exec jekyll b --config _config.yml,_config_public.yml
```

#### Local: Launch and manage remote `hookshot` server using `fabric`

In this directory (which contains [fabfile.py](fabfile.py)), you can manage the remote `hookshot` server using the `fab` command.
```
$ fab start --set instance=[INSTANCE_NAME]
$ fab stop --set instance=[INSTANCE_NAME]
$ fab restart --set instance=[INSTANCE_NAME]
```

`INSTANCE_NAME` corresponds to one of the keys to the `SETTINGS` dictionary in
`fabfile.py`:
- `internal`: regenerates the internal Hub and staging instance of the public
  Hub
- `submodules`: automatically updates the internal Hub and staging instance of
  the public Hub to use the current tip of the `master` branch of each private
  submodule
- `public`: regenerates the production instance of the public Hub

#### Remote: Nginx

The Hub-specific config, [/etc/nginx/vhosts/hub.conf](etc/nginx/vhosts/hub.conf), must contain a reverse-proxy block for forwarding GitHub Webhook requests to the `hookshot` server. The port of the `proxy_pass` directive must match the corresponding `port` property associated with the branch as configured in [fabfile.py](fabfile.py).

#### GitHub: Configure Webhooks

[GitHub Webhooks](https://help.github.com/articles/about-webhooks/) are requests that are delivered by GitHub to a URL of your choosing based upon certain repository events. The [Webhooks level up](https://github.com/blog/1778-webhooks-level-up) blog post gives a good high-level introduction, with pictures. The [Webhooks API docs](https://developer.github.com/webhooks/) go into greater detail; note the **Creating webhooks** and **Configuring your server** sections in the section guide on the right of the page.

The [18F Hub](https://github.com/18F/hub) webhooks ensure that updates to the internal Hub, the staging instance of the public Hub, and the production instance of the public Hub are automatically deployed:
- For the internal and staging Hubs, changes committed to the `master` branch are deployed immediately.
- For the public Hub, [open a pull request to merge the `master` branch into `production-public` branch](https://github.com/18F/hub/compare/production-public...master). Merging the pull request will trigger the webhook that will initiate deployment.

The [hub-pages-private](https://github.com/18F/hub-pages-private) webhooks ensure that changes to that repositories are propagated immediately to the internal Hub and staging instance of the public Hub. Those changes will not appear in the production instance of the public Hub until they are merged into the `production-public` branch.
