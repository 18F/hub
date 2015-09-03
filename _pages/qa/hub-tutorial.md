---
layout: q-and-a
permalink: /tutorial-for-hub/
title: Add and edit Hub pages
---

For more in-depth discussion of how the `_data/` and `pages/` directories
work, read [Internal vs. Public Hubs](../../101/internal-vs-public/).

### Add a page to the Hub

**1.** The Hub is located at [18F/hub-pages-private](https://github.com/18F/hub-pages-private) on GitHub.

>We've been adding new pages to the [qa folder](https://github.com/18F/hub-pages-private/tree/master/qa).

**2.** To add a new page, click the "+" button located above the files:

![Screenshot of + button](../assets/images/onboarding/new-file.png)

>Name the new file "name-of-your-file.md"

**3.** Add front matter to the page. It should look like this:

```
---
layout: {{ page.layout }}
permalink: {{ page.permalink }}
title: {{ page.title }}
---
```

**4.** You can now edit the page in GitHub and make a pull request for it to be added to the Hub.

### Edit an existing page on the Hub from the Hub itself by scrolling to the bottom of that page,

![Screenshot of Hub](../assets/images/onboarding/hub.png)

and clicking the “Edit this page" button.

![Screenshot of Edit This Page](../assets/images/onboarding/edit-page.png)

This will take you to that file in Github, already open in edit mode.

Once you're finished with your changes, write about your changes in the "Commit changes" box. Select "Create a new branch" radio button and click on the "Propose file change" button. On the next page click the "Create a pull request" button.

Congrats! You've edited a Hub page.

## How to edit team information

TODO

## How to edit project information

TODO
