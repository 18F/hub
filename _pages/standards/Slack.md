---
title: Slack Standards
permalink: /standards/slack/
---
# {{ page.title }}

Instead of maintaining our own [IRC](https://en.wikipedia.org/wiki/Internet_Relay_Chat) servers for chat capabilities, 18F uses [Slack](https://slack.com/). This living document is the 18F team standards and practices for our use of Slack. **Any change to this standard, or any global technical change to our Slack account, will be announced via an `@channel` in `#news`** (the default channel to which all users are subscribed and unable to leave).

## Summary

Everything in this standard is **required**, unless explicitly stated otherwise. TL;DR:

* Complete [your profile](https://18f.slack.com/account/profile)
* Adhere to our [Code of Conduct](https://github.com/18F/code-of-conduct/blob/master/code-of-conduct.md), i.e. treat everyone with respect
* Treat Slack as a public forum, i.e. assume you have no privacy
* Use [two-factor authentication](https://slack.zendesk.com/hc/en-us/articles/204509068-Enabling-two-factor-authentication)


## Complete your profile

Because we are a distributed team, Slack is often the first way we "meet" each other. [**Please fully complete your profile**](https://18f.slack.com/account/profile) so people have a better chance of knowing who you are. This includes first name, last name, a unique profile picture (photos are preferred, but not required), phone number, and a summary of what you do, what teams you're on, and where you're located.

## Code of Conduct 

Just like an in-person meeting or event, conduct on Slack is governed by the all relevant laws and GSA policies, in addition to the [18F Code of Conduct](https://github.com/18F/code-of-conduct/blob/master/code-of-conduct.md). Please read our Code of Conduct carefully. Bottom line: Don't say something on Slack that you wouldn't feel comfortable saying to someone's face. Note that sarcasm is hard to communicate online - sincerity is usually easier to understand.

If you see anyone violating our Code of Conduct, please report it immediately in `#admins-slack`. If you don't feel comfortable reporting it there, you can send a direct message to either Noah Kunin [`@noah`] or Hillary Hartley [`@hillary`].

### Who can use Slack?

Slack is required for all 18F staff. We can also invite people outside 18F to have access to a **single channel** on our Slack account. These single-channel users are free, and don't need financial authorization from TeamOps or security clearance from DevOps. These users may include:

* vendors *under contract* (not just a Terms of Service) with 18F
* partners at federal agencies whose projects are under an Interagency Agreement with 18F
* federal staff with government email addresses (for example, friends at the USDS, CFPB, other teams inside GSA, etc.)
* members of the public collaborating on an open source project in a public channel via [chat.18f.gov](https://chat.18f.gov)

#### Project stakeholders

Projects are free to invite their government partners to specific channels to foster collaboration and asynchronous communication with the team. Several projects have set up specific channels for this communication that end with `-partners`. Our partners may be invited as `single-channel guests` at no cost to the project or agency. If you would like for your partners to have access to more than one channel, this expense will need to be part of the IAA and cleared by TeamOps and DevOps.

#### Friends

Friends from other government teams can be invited into a project's channel or a general purpose channel like `#friends`. If the individual is a federal employee, and the main purpose of inviting them is to work on government projects, the invite should be sent to their `.gov` email address. 

#### Teammates from the United States Digital Service (USDS)

One of our biggest collaborators is the USDS. You may see channels that end with `-usds` — members of the USDS across government are in these channels. In order to keep the signal to noise ratio high, please keep discussion focused on the project or task at hand in each channel. 

#### The public

Projects that desire chat-like engagement with the public may create public channels. These channels end with `-public` to signify a channel the public can join. Treat these channels like you would a town hall or other type of public meeting. Members of the public must also comply with GSA standards and the [18F Code of Conduct](https://github.com/18F/code-of-conduct/blob/master/code-of-conduct.md). To invite people to a public Slack channel, send them to [chat.18f.gov](https://chat.18f.gov/) and have them select the appropriate channel from the drop-down.

## Records policy

Per the mandatory [General Records Schedule 3.1](http://www.archives.gov/records-mgmt/memos/ac33-2014.html) issued by the National Archives and Records Administration (NARA), basically everything in Slack channels and groups is considered at minimum a temporary record. 

To ensure compliance with the possibility that we might create permanent or long-lived records in Slack, the records retention policy is set to **retain all messages forever AND also retain edit and deletion logs for all messages**. Users are prohibited from deleting messages. Do not abuse the `edit` command in Slack to effectively delete your message by replacing it with null or symbolic content. Edits for clarity or typos are fine. If Hubot or Giphy ever posts something inappropriate, please call for a clean-up in `admins-slack`.

This policy applies to all types of Slack communications: public channels, private groups, even direct messages. **Nothing is private.** We use the [compliance export](https://slack.zendesk.com/hc/en-us/articles/203950296-FAQs-about-Slack-s-policy-update#complianceexport) capability in Slack to view all messages. The Primary Team Owner is responsible for ensuring monthly exports and backing these exports up in GSA's Google Drive.

During regular operations, only the Slack Owners and the Executive Director of 18F have access to the exports. There is no regular monitoring of these messages. However, various legal actions (e.g. a Freedom of Information Act request) or security operations approved by the Infrastructure Director may require others to view the exports. The team will be notified at the earliest possible time that the exports have been accessed. Notifications of access may not be made in real-time.

## Security

### Two-factor authentication

Starting on September 1st, 2015, two-factor authentication (2FA) is required to use Slack. If you don't have it enabled, your account will be deactivated. [Activating 2FA is really easy](https://slack.zendesk.com/hc/en-us/articles/204509068-Enabling-two-factor-authentication). In general, you should have 2FA enabled [wherever possible](https://twofactorauth.org/).

### Infrastructure security

Slack is currently built on Amazon Web Services (AWS), which from a federal security perspective, already has a host of protections verified through GSA's [FedRAMP program](https://www.fedramp.gov/marketplace/compliant-systems/amazon-web-services-aws-eastwest-us-public-cloud/). 

However, there are currently *no* assurances that Slack employees can't read any and all of the messages sent via Slack. In fact, Slack [makes it clear](https://slack.com/security) that its employees *do* have this ability, and just don't use it without customer permission:

> All of our employees are bound to our policies regarding customer data and we treat these issues as matters of the highest importance within our company. If, in order to diagnose a problem you are having with the service, we would need to do something which would expose your data to one of our employees in a readable form, we will always ask you prior to taking action and will not proceed without your permission. Our platform will automatically generate an audit entry of any such access.

This is the case with most software as a service offerings. We're working with Slack to better map out the process where those permissions are granted. Regardless, we currently do not, and may never, authorize Slack to handle sensitive team or project data. 

## Conclusion

* **Don't say anything on Slack you would feel uncomfortable being attributed to you in public.** Treating Slack as *if* it was a public IRC server is a great best practice. Everything you say is one screen shot away from going public.

* **Don't post anything to Slack that would make our systems vulnerable if it fell into the wrong hands.** If you need to share sensitive data (environmental variables, passwords, etc) use [Fugacious](https://fugacious.18f.gov), an awesome tool built by our very own [@jgrevich](https://github.com/jgrevich), to create a short message that is auto-deleted. If you have something that is very complex, please share it using a GSA Google Drive folder, and then promptly delete it once you're done sharing.

* **Treat everyone with respect and get to know the [18F Code of Conduct](https://github.com/18F/code-of-conduct/blob/master/code-of-conduct.md).** The same rules of the road apply to Slack that you would use in person, in a meeting, or at an event.
