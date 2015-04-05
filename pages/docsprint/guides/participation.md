---
permalink: /docsprint/guides/participation/
---

# Doc Sprint Participation Guide

A well-organized doc sprint is designed to improve team documentation quickly and efficiently. Making sure 18F's documentation is accessible and comprehensive is critical for scaling what we do.  

Documentation includes, but is not limited to:

* READMEs, especially making sure that anyone can easily build/run a project in minutes (if not seconds)
* Onboarding guides a la https://hub.18f.us/private/18f-site/onboarding/
* Updating our [18F Guides](http://18f.github.io/guides/)

**Here are some helpful materials and resources for participating in a doc sprint.**

## <a name="todo"></a>Event Specific To-Do Lists

Specific information and to-do list for each doc sprint:

* [April 17 Onboarding Doc Sprint](../../onboarding/)

## For All Doc Sprints

### You Will Need
To participate in an 18F doc sprint, you will need:

* A [GitHub account](https://help.github.com/articles/signing-up-for-a-new-github-account/) with [two-factor authentication enabled](https://help.github.com/articles/about-two-factor-authentication/). (**Insert link to GitHub section below**)

### Ways to Contribute
Each doc sprint will have a specific [to-do](#todo) list. You can participate by:

* Creating or updating documentation on the to-do list.
* Suggesting new documentation. The method for making a suggestion will depend on the project, but might be a GitHub issue or a Trello task.
* Giving feedback about documentation that others are creating during the doc sprint. This kind of conversation usually happens in a GitHub issue.
* Testing documentation created by others. For example, trying to stand up a local version of a project by following the directions in its README file.

### Tools

#### Markdown

Most 18F documentation is written in Markdown, a language that converts text to HTML.

* The syntax for Markdown is listed [here](http://daringfireball.net/projects/markdown/).
* You can find a cheatsheet [here](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet). 
* You can also use a program like [Dillinger](http://dillinger.io/) which shows you how the Markdown will look as you type it. 
* If you're more comfortable writing in a Google Doc, you can later convert a .docx file using [Pandoc](http://johnmacfarlane.net/pandoc/) on the command line with the following command: `pandoc -f docx -t markdown ~/path/to/file.docx -o ~/Desktop/post.md`
* For documentation hosted on GitHub, note that [GitHub-flavored markdown is in effect](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet). It's very similar to regular Markdown but has some slight differences as well as some extra features like syntax highlighting.

#### Git and GitHub

A large amount of 18F documentation is managed via git repositories. These are hosted on GitHub, which makes it easy to track version of documents, track issues, and make changes, which are called _pull requests_. If you're not familiar with Git and GitHub, these resources can get you started. You definitely don't need to be a git power user, and you can always ask questions in the `#git` `#questions` or `#wg-documentation` Slack channel(s).

We recommend starting with this [extensive guide](https://18f.gsa.gov/2015/03/03/how-to-use-github-and-the-terminal-a-guide/) we wrote for working with GitHub and the terminal. The first step in the guide details how to [set up your computer to work on 18F projects](https://18f.gsa.gov/2015/03/03/how-to-use-github-and-the-terminal-a-guide/#turn-your-mac-into-a-web-development-machine). Please complete this step, which will install the necessary software you need to work at 18F, regardless of which project you plan to tackle during the sprint. (If you're new to GitHub, feel free to work through the rest of the steps, which acclimate you to both GitHub and the terminal.)
* GitHub also maintains a very good help section on [mastering GitHub basics](https://guides.github.com/activities/hello-world/), [mastering Issues](https://guides.github.com/features/issues/), and a [guide to the various commands](https://training.github.com/kit/downloads/github-git-cheat-sheet.pdf) you'll use on the Command line.
* If you do not want to use the command line, that's okay too. You can download GitHub for Mac, which is a program that allows you to work within GitHub without using the command line. GitHub provides a very good tutorial for GitHub for Mac [here](https://mac.github.com/help.html).
* If you're working in The Hub, we've written up a guide for how to edit GitHub documents online using prose.io, which is similar to GitHub for Mac in that you do not need to use the command line. [insert link to Mel's prose.io doc]


#### Slack

If you have questions about doc sprints, the documenation working group is happy to help. You can find us on Slack:

* `#wg-documentation`: questions about the Hub and doc sprint events
* `#questions`: triage point for other questions that come up during the doc sprint
