---
title: Hub 101 - Internal vs. Public Hubs
permalink: /101/internal-vs-public/
---
# {{ page.title }}

The Hub has the capability to filter out "internal" information to produce a
"public" version of the Hub. This enables a team to expose as much of its
information and structure to the world as possible while still keeping
sensitive information visible only within the team.

## How `_data/private` works

The `_data/private` directory is a mount point for the [18F
data-private repository](https://github.com/18F/data-private) imported as a
git submodule. This repository is private and accessible only to 18F team
members. If the submodule is available, its data will be used to generate both
the "internal" and "public" versions of the Hub, by either promoting or
deleting data marked as `private:` within the YAML files.

**Note:** Files in `_data` corresponding to files in `_data/private` will be
ignored if the `_data/private` submodule is available.

See [Git Submodules](git-submodules/) for more information on how to work
with the `_data/private` submodule. The [hash-joiner
Gem](https://rubygems.org/gems/hash-joiner) implements the `private:` data
promotion/removal; follow the "Documentation" link on that page for details.

## How `_data` works

If `_data/private` is empty, then files from `_data` will be used to generate
both the "internal" and "public" versions of the Hub. The `_data` directory is
populated with data imported from `_data/private` using the
[`_data/import-public.rb` script](../_data/import-public.rb). This script
generates new data files with all `private:` information removed. This enables
the Hub to be built by other teams who wish to experiment with running their
own Hub, using public 18F team data as a starting point.

`_data/import-public.rb` is run automatically by the internal 18F Hub
deployment environment with every update to the [18F data-private
repository](https://github.com/18F/data-private) (via [GitHub
Webooks](https://help.github.com/articles/about-webhooks/)), ensuring that
`_data/public` remains fresh.

## How `pages` and `pages/private` work

All documents intended only for the internal Hub should be stored in
`pages/private`. Documents that can be shared on the public Hub can be stored
in `pages`. Pages in either directory should contain a `permalink:` property
in their front matter. For example:

```yaml
---
title: About the 18F Hub
permalink: /about/
---
```

Pages in `pages/private` should ensure that this `permalink:` always begins
with `/private/`. For example:

```yaml
---
title: 18F Private Team Documentation
permalink: /private/docs/
---
```

All `pages/private` pages are filtered out by the [`joiner.rb`
plugin](../_plugins/joiner.rb) when generating the public Hub. Sections of
pages outside `pages/private` that link to documents in `pages/private` should
be surrounded by the following
[Liquid](https://github.com/Shopify/liquid/wiki/Liquid-for-Designers)
conditional:

```
  {% unless site.public %}
    ...
  {% endunless %}
```

## Rationale

Partitioning the private team data into a separate private repository, mounted
as a git submodule, accomplishes two objectives:

* Potentially sensitive and personal data that we wish to keep private is
  firewalled inside a private repository.
* Team members only have to update their data in a single place, and from
  there it will propagate to the Hub, to the [18F Home
  Page](https://18f.gsa.gov), and the [18F Project
  Dashboard](https://18f.gsa.gov/dashboard).

The private repository/git submodule solution is effective because it:

* allows the Hub code to be open-sourced in its entirety, without the need for
  a separately-maintained private fork;
* ensures there is one authoritative source for both public and private data
  across projects; and
* commits to the master data repo trigger GitHub webhooks to launch staging
  builds of affected projects.
