---
title: Standards
permalink: /standards/
---
# {{ page.title }}

We are all accountable for the entire process of delivering services to the public: from discovery to supporting the system live in production.

## Delivery Infrastructure

All information systems in the Federal Government must comply with *all* relevant laws, but there few that are almost always relevant to digital services.

### Security

The Federal Information Security Management Act, or FISMA, is the law covering the **security of digital systems**. The vast majority of compliance with FISMA is maintained by the 18F DevOps team and GSA InfoSec, but there a [few things developers should know about the security of digital systems](https://github.com/18F/DevOps/blob/master/standards/security.md).

### Privacy

The Privacy Act is the law covering the **privacy protections covering personally identifiable information or PII**. [More info and guides WIP, will be part of Digital Service Implementation Guide].

### Information collection 

The Paperwork Reduction Act, or PRA, is the law covering the **collection of information from members of the public**, whether or not that collection is done through a digital system or through a manual process. [More info and guides WIP, will be part of Digital Service Implementation Guide].

### Accessibilty 

The Section 508 Amendment to the Rehabilitation Act of 1973 is the law covering the **accessibility of digital systems for those with disabilities**. [More info and guides WIP, will be part of Digital Service Implementation Guide].

## Change management

Take a look at our [current architecture](https://docs.google.com/a/gsa.gov/spreadsheet/ccc?key=0AinIxtx-CfkddGVaNU9lMHp3TGh2RThEVWExS0dwNmc&usp=drive_web#gid=1). Need something to be different? Want something new? [File an issue.](https://github.com/18F/DevOps/issues/new). There's a bit of a backlog, but help is on the way. 

### DevOps

At 18F, the DevOps team is empowered to set standards on the internal use of technology. Everything collected here is **mandatory**. 

We design standards for:

* simplicity
* delight
* safety

Our objective is to deliver the best environment to do development work in the Federal government. Unfortunately, sometimes law or policy at a higher level (ex: GSA or OMB), directly conflicts with our design goals and our objective. We constantly negotiate for improvements. 

The work here is also subject to constant improvement. Pull requests from anyone at 18F, from any team, are **strongly encouraged**.

- [AWS](https://pages.18f.gov/before-you-ship/aws/)
- [Slack](slack/)
- [GitHub](github/)
- [Security](https://pages.18f.gov/before-you-ship/security/)
- [Terms and Conditions](terms-and-conditions/)

### A quick note on delight

In User Experience, the concept of "delight" is often referenced. Beyond being of value, in and of itself, delight is often used as a piece of gold standard user feedback that some piece of UX is actually *working*. 

For a DevOps team, the core goal is for a fantastic [Developer Experience](http://uxmag.com/articles/effective-developer-experience). Without diving so deep into the intricacies of user or developer experience, most developers would agree that a great experience is one that keeps them in [flow](https://en.wikipedia.org/wiki/Flow_%28psychology%29) and makes them feel like an [expert](http://headrush.typepad.com/photos/uncategorized/2007/04/06/kickasscurvetwo.jpg).

Delight shouldn't be a success metric just for public facing systems - it also helps guide the development of internal systems.

## Approved toolchain

- **Version control**: Git and GitHub
- **Infrastructure as a service**: Amazon Web Services East/West
- **Server operating system**: Ubuntu 14.04 LTS
- **Platform as a service**: CloudFoundry
- **Server configuration management**: Chef
- **Code scanning**: Nessus and Hakiri- 
- **Telecommunicaitons orchestration**: Twilio
- **Chat platform**: Slack
