---
layout: q-and-a
permalink: /outside-18f-github/
title: Giving partners and collaborators access to 18F GitHub repositories
---
# {{ page.title }}

Sometimes we might want to give contractors, federal partners, or other outside collaborators:

* Read or write access to our private repositories
* Write access to our public repositories (if they're a core contributor)

This is allowed and encouraged to facilitate work and build community. Here's our current process to address both operational and security concerns.

* Ask if they have *two-factor* authentication enabled. If they need help, here's [guidance on how to set it up](https://help.github.com/articles/configuring-two-factor-authentication-via-a-totp-mobile-app).

* Create a team whose access we can turn off/on with _one_ button: Separate a staff-only team from a contractor/mixed/collaborator team. In the case of our previous work with contractors, because they did work across 18F, we just had the team be called `INSERT CONTRACTOR NAME HERE`. In other cases, if the collaborators are scoped to a particular project, you can name the team something like `PROJECT NAME - COLLABORATORS|SKILL SET`.

* In the "Description" of the team, put something reasonable plus a point of contact email address for the collaborators, if relevant. Ideally this is the address of someone senior, someone we could email if issues come up, someone who can rally the troops. We need this contact information because people don't always list their email on their GitHub profile.

* A mixed or collaborator team should, at maximum, have the "Write" permission. Admin rights should be limited exclusively to our staff.

* Add the members - check on the team page 2FA/MFA (an orange warning sign) is enabled for them. 18F DevOps check this on onboarding/biweekly audits, but since a user could turn it off at any time and retain their membership in the organization with no notification back to owners, it's always good to triple check.

* Add the relevant repositories. 
