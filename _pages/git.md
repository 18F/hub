---
title: Git
---
## How we use git

At 18F, we use git to version control our code, blog content, and even the words
you are reading right now.

There are many different ways to use Git. Different teams and projects at 18F
use different git workflows. Teams should document their desired git workflow
for each project. The 18F website has [a good example on their GitHub
wiki](https://github.com/18F/18f.gsa.gov/wiki/How-we-Git).

## Git and FOIA

One common way of using git is to create a [git
branch](http://git-scm.com/docs/git-branch) when contributing to a project and
submit the changes in that branch as a [pull
request](https://help.github.com/articles/using-pull-requests/).

In the process of receiving feedback in a pull request, some individuals on some
teams may choose to [amend, reorder, or squash
commits](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History). This type
of "re-writing history" is compliant with the [Freedom of Information Act
(FOIA)](http://www.archives.gov/foia/) when it occurs on a pull request because
git branches are considered a work in progress. These actions are not allowed on
the `master` branch because that is considered the canonical source of
information.
