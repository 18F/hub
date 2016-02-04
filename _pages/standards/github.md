---
title: GitHub standards
---
# {{ page.title }}

Git and GitHub are the [standard
tools](https://github.com/18F/DevOps#approved-toolchain) for revision control at
18F. These tools [not just for
developers](https://18f.gsa.gov/2015/03/03/how-to-use-github-and-the-terminal-a-guide/)
or as a repository for code under development - you can use
[GitHub](https://guides.github.com/introduction/flow/) whenever you have the
need to manage documentation or to collaborate.


## Security

We **require all new members** (including PIFs) to follow **[security
standards](https://github.com/fisma-ready/github#readme)** which include using
two-factor authentication (2FA) and completing a GitHub user profile prior to
joining the organization. 

### Credentials / Private Configuration Data:

- **Do not store sensitive information in Git and GitHub**

Do not store sensitive information in Git, GitHub, or any other revision control
system. This includes sensitive environmental variables and other private
configuration data. In the event that such information is pushed to a GitHub
repository accidentally, and exposed even momentarily, consider it compromised.
Revoke or change the credentials immediately. If sensitive information about the
public was released, contact DevOps.

If you're unsure how to protect this information consult with [DevOps on
GitHub](https://github.com/18F/DevOps/issues) or in the
[`#admins-github`](https://18f.slack.com/messages/admins-slack/) channel in
Slack. Some projects use [Citadel](https://github.com/poise/citadel) to store
secrets.

### GitHub integrations:

- **Ask DevOps first and prefer services which request granular permissions**

Many websites offer the option to "Sign in with GitHub". Integrations may ask
for "personal user data" which may include your public or private email address,
all the way up to accessing *18F's private repositories*.

For this reason, we ask that all organization members refrain from authorizing
integrations and request any desired integrations through a [DevOps
issue](https://github.com/18F/DevOps/issues).

### Repositories:

- **Ask before creating private repositories**
- **Do not delete repositories**
- **Use descriptive names which include the project name**

For general guidance around contributions, licensing, and the practice of
[working in
public](https://18f.gsa.gov/2014/07/31/working-in-public-from-day-1/) at 18F,
please refer to [our open source
policy](https://github.com/18F/open-source-policy/blob/master/practice.md).

We need you to ask permission for private repositories, since they cost money,
and will need to be billed to the appropriate partner.
