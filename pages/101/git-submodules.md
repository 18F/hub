---
title: Hub 101 - Working with Git Submodules
permalink: /101/git-submodules/
---
# {{ page.title }}

The Hub uses git submodules mounted at `_data/private` and `pages/private`.
The reason for using these submodules is described in
[Internal vs. Public Hubs](internal-vs-public/). This guide explains how to
work with them.

- **If you're an 18F team member**: You have access to the private
  repositories referenced by these submodules; follow these directions to
  begin working with them.
- **Otherwise**: You do not need to use git submodules to work with the Hub.
  However, if you wish to set up your own private submodules, this guide may
  prove helpful.

## Initializing the submodules

Since the submodules are optional, the `./go` development commands do not
manage them. To import the submodules into the project:

```
$ git submodule init
$ git submodule update
```

## What just happened?

Submodules are essentially _separate git repositories_ nestled within your
clone of the Hub repository. If you `cd _data/private` or `cd pages/private`,
you'll find a `.git` directory, and any `git` commands you run will pertain to
that repository, not the Hub repository.

## How do these submodules work?

Each branch of the Hub references specific SHA hashes from the `master` branch
of each of these repositories. Fresh clones of the Hub repository will produce
output based on the referenced versions of the submodules. These references
will not change until explicitly updated. This allows the `_data/private` and
`pages/private` repositories to be updated independently of the Hub
repository.

## Updating a submodule

Changes made to a submodule in your local clone of the Hub _will_ be reflected
in the generated output, even if you do not explicitly update the current Hub
branch to use the new data. This allows you to see the effects of data changes
before:

- committing them to the submodule repository,
- pushing the changes upstream, and
- "blessing" the new submodule version by updating the Hub branch to refer to
  it explicitly.

The easiest way to update a submodule is to:

- Enter the submodule directory: `cd _data/private` or `cd pages/private`
- Create a new branch if desired: `git checkout -b my-update`
- Make the desired changes
- Rebuild the Hub and inspect the results
- Enter the submodule directory again, if necessary
- Commit the changes and push the branch upstream

## Pulling updates into the Hub

Once changes to a submodule have been pushed upstream, they can be pulled into
a local Hub repository by running:

```
$ git submodule update --remote
```

If there have been changes, the output of `git status` will reflect that the
current branch is out-of-date with respect to the submodules:

```
$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   _data/private (new commits)
        modified:   pages/private (new commits)
```

If the results of regenerating the Hub using the updated submodules look good,
you can update the SHA references for the current branch by running:

```
$ git add _data/private pages/private
$ git status
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        modified:   _data/private
        modified:   pages/private

$ git commit -m 'Updated private submodules'
$ git push
```

## Advanced submodule commands

Everything described so far should suffice for Hub development. However, the
[git submodules](http://git-scm.com/book/en/v2/Git-Tools-Submodules)
section of the online _Pro Git_ book much deeper into the `git submodules`
command and what you can do with it.
