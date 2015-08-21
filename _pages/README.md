---
title: Adding and Organizing Hub Pagess
permalink: /hub-pages/
---

# Adding and Organizing Hub Pages

## Publicly-visible pages

[The `_pages/` directory](https://github.com/18F/hub/tree/master/pages) of [the Hub repository](https://github.com/18F/hub) is where publicly-visible Hub content should be collected. Nearly everything in this subdirectory should be stored as Markdown files editable by 18F team members. The `permalink:` attribute in the front matter will determine the location of each document in the generated site.

## Internal-only pages

The `_pages/private` directory is where internal-only Hub content should be collected. As with the `/pages` directory, nearly everything should be stored as Markdown files. The structure of this directory can/should mirror the structure of the public content organized under `/pages`.

The content in this directory is actually stored in the [private 18F/hub-pages-private repository](https://github.com/18F/hub-pages-private) and integrated into the Hub repository as a git submodule. Consequently, before making changes to this submodule on your own machine, you should check out a new branch:

```
$ cd _pages/private
$ git checkout -b new-private-content
```

After your changes are complete, merge your changes into the `master` branch of the submodule, push them upstream, and then update the Hub repository itself:

```
$ git add [changed files]
$ git commit
...

$ git checkout master
$ git pull origin master
$ git merge new-private-content

# If there are no conflicts, or once conflicts are resolved:
$ git push -u origin master
$ cd ../..
$ git add _pages/private
$ git commit -m 'Updated private content'
```
