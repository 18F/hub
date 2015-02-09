---
title: About the 18F Hub
permalink: /about/
---
# {{ page.title }}

The Hub helps [18F](https://18f.gsa.gov/) organize its information and explore
the connections between team members, projects, and skill sets. It serves as
the go-to place for all team information, whether that information is
integrated into the Hub directly or provided as links to Google Drive
documents, Google Sites, GitHub READMEs and microsites, etc.

## The Big Picture

For more information regarding the design goals of the Hub and how it figures
into 18F's Federal IT development culture change strategy, see the 18f.gsa.gov
blog post: "[The 18F Hub: Documentation, Snippets, and
Connections](https://18f.gsa.gov/2014/12/23/hub/)".

## Hub 101

For an overview of Hub development and deployment details, visit the [Hub 101
docs](/101/).

## Working with Hub Docs

Most documents will have an **Edit this page »** link at the bottom of the
page. Click this link to open the [GitHub in-browser editing
interface](https://help.github.com/articles/github-flow-in-the-browser/) and
make changes directly. This interface allows you to create, edit, rename, move
or delete Hub files.

Cloning the [Hub repository](https://github.com/18F/hub), editing the files,
and [running Jekyll locally](http://jekyllrb.com/docs/quickstart/) also works,
of course.

## Working with Hub Data

The master copy of 18F team data is stored within the [private
18F/data-private repository](https://github.com/18F/data-private), to which
only 18F team members have access. All updates to team information should
happen in that repository.

A copy of the team data with internal details removed will be imported into
the `_data/public` directory to facilitate deployment of the [public Hub
instance](https://18f.gsa.gov/hub) and enable people outside the 18F team to
run a demonstration instance.

## Hacking the Hub

The [Hub repository](https://github.com/18F/hub) is freely available for
cloning and experimentation. We've also begun publishing a rudimentary [Hub
API]({{ site.baseurl }}/api) that we expect to develop and build upon in the
coming months.
