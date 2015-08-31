---
title: Public chat rooms
---

18F has specific channels in Slack that are open to the public.

## Inviting people

To invite people to a public Slack channel, send them to [chat.18f.gov](https://chat.18f.gov/) and have them select the appropriate channel from the drop-down. Note that these users are added as [**single-channel** guests](https://slack.zendesk.com/hc/en-us/articles/201314026-Understanding-roles-permissions-inside-Slack).

## Adding new channels

[chat.18f.gov](https://chat.18f.gov/) is an instance of [slackin](https://github.com/18F/slackin). To create a new publicly-joinable channel:

1. Create the channel in Slack, with a `*-public` suffix (just to make it explicit).
1. Run `NEW_CHANNEL=new-channel-name` (replace with the appropriate value).
1. Run:

    ```bash
    cf target -o 18F -s chat
    cf env slackin | grep SLACK_CHANNELS | awk "{print \$2\",$NEW_CHANNEL\"}" | xargs cf set-env slackin SLACK_CHANNELS
    cf restage slackin
    ```

Ask in #devops if you need any help.
