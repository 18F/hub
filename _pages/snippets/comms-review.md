---
title: Snippets Comms Review
permalink: /snippets/comms-review/
---
# {{ page.title }}

We want to share as much information as we can with the public, but there are certain details of our operations that we do need to keep confidential. Consequently, some of these items are being kept for internal purposes only, and our team will review the public snippets before publication. This describes the flow of the comms review and the policies involved.

## 1. New snippets announced internally

The weekly snippets batch will be committed to [18F/data-private/snippets/v3](https://github.com/18F/data-private/tree/master/snippets/v3) in CSV format, using a filename in the format `YYYYMMDD.csv`. The published snippets, both [internal](https://hub.18f.us/snippets) and [public](https://hub.18f.us/hub/snippets), will be announced on [18f-team](https://groups.google.com/a/gsa.gov/forum/?hl=en#!forum/govx).

## 2. New comms review ticket opened

[Mike Bland](/team/mbland) will open a comms review ticket in the [data-private GitHub repo](https://github.com/18F/data-private/issues), set it to the `comms-ready` milestone, and assign it to [Ori Hoffer](/team/ori). The ticket will contain the link to the new snippets, e.g. <https://hub.18f.us/hub/snippets/20141208>.

## 3. Comms review initiated

Ori will review the snippets for the following types of material that should be redacted/edited:

- **Language/Style**: Reporters, industry watchdogs, congressional staffers could be reading these, so comments will be edited for clarity.
- **Announcements of new projects**: Snippets is not the place to make news; let’s save that for the blog, which already has its own comms review process.
- **Internal arguments/debates**: Sharing our decision-making process only opens us up to second-guessing from the outside.


## 4. Redactions/edits committed

Ori will add any necessary <code>&#123;&#123;</code> and <code>&#125;&#125;</code> redaction tokens and make any necessary edits to the CSV file via GitHub's web interface. Until GitHub webhooks are implemented, Mike will regenerate the updated public snippets and confirm with Ori that the updates appear as intended.

## 5. Ticket approved

When Ori deems the snippets are suitable for public release, he will set the GitHub issue to the `comms-approved` milestone and assign it back to Mike.

## 6. Public release initiated

Mike initiates the public release and closes the ticket.
