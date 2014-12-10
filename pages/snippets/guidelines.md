---
layout: bare
permalink: /snippets/guidelines/index.html
---
# Guidelines for Writing Snippets

## Writing and reading snippets is optional

The best best practices catch on because they are useful, not because they're mandated. Feel free to participate or not as you desire. If you've nothing of interest to report, then skip posting this week!

## Be professional

Snippets aren't the place to vent frustration. Concrete, objective information will prove the most helpful to yourself and everyone else who might peruse your snippets.

## Don't read every snippet

You are not compelled to read every person's every snippet every week. Nothing's stopping you, but there are no gold stars for reading them all.

## The first audience is the author

The author of a snippet is free to write as much or as little as he or she finds helpful to track his or her own progress. It's largely a personal practice that, coincidentally, may prove helpful or informative for others.

## Brevity is the soul of wit

That said, one should strive for conciseness. It does make it easier for others to peruse your snippets, which can lead to fruitful, serendipitous discussions and insights.

## Private by default

Currently snippets are visible only to other 18F team members. However, support for publicly-visible snippets is underway. If you want _any_ of your snippets to be visible outside of 18F, click the _Public_ box on the form.

## Redact specific information

If most of your snippets are OK for public consumption, and you've selected the _Public_ box on the form, yet there are details you'd like to omit, you can redact spans of text by surrounding them with `&#123;&#123;` and `&#125;&#125;` tokens.

## Last Week and This Week

The *Last Week* and *This Week* sections encourage separation between past and future items. However, if you want to put everything into the *Last week* section, you are free to do so.

## Plaintext or Markdown

[Markdown syntax](http://daringfireball.net/projects/markdown/) is supported, but is not required; plaintext will always continue to work.

## Use the preview tool

Use the [snippet-preview.rb](https://github.com/mbland/mbland-18f-utils/blob/master/snippets/snippet-preview.rb) tool to generate sample HTML of both complete and redacted snippets. (Longer term: We'll have an online preview tool.) To download and execute:

<pre>
$ wget https://raw.githubusercontent.com/mbland/mbland-18f-utils/master/snippets/snippet-preview.rb

# If redcarpet isn't already installed
$ gem install redcarpet

$ ruby snippet-preview.rb path/to/snippet
</pre>

This will print a local `file://` URL that you can view in your browser. You can also view differences between complete and redacted versions via:

<pre>
$ ruby snippet-preview.rb path/to/snippet
$ ruby snippet-preview.rb path/to/snippet --redact
$ diff snippet-preview.html snippet-preview-redacted.html
</pre>
