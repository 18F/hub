---
layout: q-and-a
permalink: /macbook-security/
title: MacBook security
---
# {{ page.title }}

* You should [require password immediately](http://support.apple.com/kb/PH18669?viewlocale=en_US) when your computer sleeps or shows screensaver.
* Lock your computer before leaving it. The command for this is `control + shift + power button` for newer MacBooks and `control + shift + eject` for older MacBooks with optical drives. If you use Alfred, you can open Alfred and just type ``lock``.
* [Encrypt your hard drive](http://support.apple.com/en-us/HT4790) with FileVault.
  * If you already have an iCloud account associated with your GSA email (e.g. for an iPhone) it makes sense to enable the option to store your FileVault key in iCloud. You can then use your iCloud account name and password to unlock your startup drive or reset your password should your laptop credentials become invalid.
  * If you do not have an iCloud account, you may create one for this purpose or create a recovery key and make alternate arrangements for storing the credential.

Resources
* [NSA tips on hardening MacOS](https://www.nsa.gov/ia/_files/factsheets/macosx_10_6_hardeningtips.pdf)
