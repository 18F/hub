---
title: Snippets Process
permalink: /snippets/process/
---
# {{ page.title }}

Snippets are currently collected and processed by [Mike Bland](/team/mbland). As the system evolves, we will replace the manual steps of this process with automated systems.

## Snippets form email sent on Monday

On Monday mornings, Mike will send an email via the [18F Weekly Snippets v3 Google Form](https://docs.google.com/a/gsa.gov/forms/d/1Nxtj-vjIPv0I_HFAclmE6KY0Hkj1Xrgz9ApAdte3C6M/edit?usp=sharing) inviting everyone on `18f-team` to fill out the Snippets form (e.g. [the 2014-12-08 invite](https://groups.google.com/a/gsa.gov/d/msg/govx/w_vescEXEpw/sh2MI9gQTbAJ)). He will follow-up with a late-afternoon ping on the email thread, then a last-call ping on Tuesday.

## Submitted snippets downloaded as CSV

Mike will make a copy of the "Current" sheet within the [18F Weekly Snippets v3 (Responses) Google Sheet](https://docs.google.com/a/gsa.gov/spreadsheets/d/1F3J2Wc8iM2e73oPWpOGm_46dXSA6ZbZAq1elU3WiMaU/edit?usp=sharing) and rename it with the timestamp of the current week's snippets, e.g. 2014-12-08.

He will delete the rows (_not_ just the data in the cells) in the "Current" sheet to prepare for the following week.

He will download the content of the current week's snippet sheet as a CSV file (via *File > Download as > Comma-separated values (.csv, current sheet)*).

## CSV file added to the private data repository

The CSV file will be committed to [18F/data-private/snippets/v3](https://github.com/18F/data-private/tree/master/snippets/v3) using a filename in the format `YYYYMMDD.csv`.

## Internal snippets published, public snippets review initiated

Until GitHub webhooks are implemented, Mike will manually update the Hub's `data-private` submodule, regenerate the internal and private Hub pages, and deploy the new snippets to <https://hub.18f.us/snippets/> and <https://hub.18f.us/hub/snippets> respectively.

Mike will also initiate the [public snippets comms review](/snippets/comms-review) before pushing public snippets to the public Hub.

## Published snippets announced Tuesday or Wednesday

Mike will send a follow-up email to `18f-team` announcing the published snippets (e.g. [Snippets for 2014-12-08](https://groups.google.com/a/gsa.gov/d/msg/govx/69UJWfjAdEQ/gB_3BHCjyYYJ)).
