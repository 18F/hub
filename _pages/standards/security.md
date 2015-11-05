---
title: General Security Standards
tags:
- ato
---
# {{ page.title }}

In the Federal government, the principal law governing the security of information systems is the Federal Information Security Management Act or FISMA.

_**Before reading the rest of this policy**_, you must read the [readme file at FISMA Ready](https://github.com/fisma-ready/fisma-ready.github.io/blob/master/README.md), a community project co-managed by 18F. You should also take a quick glance at the [components that are already FISMA Ready](https://github.com/fisma-ready).

## Compliance

Hopefully, at this point you're not **too** burned out on bureacracy! What all of that boils down is we need to always _document_ our security procedures and then be sure to _follow_ them by creating appropriate controls.

## Documentation

There are three tracks of documentation available:

* Limited Authority to Operate (LATO) for **90 Days**
* Limited Authority to Operate (LATO) for **1 Year**
* Continuous Authority to Operate (cATO) **forever** [work in progress, coming in 2015]

### Pre-authorization

You may operate without authorization under the following conditions.

The system is deployed to the [18F AWS East/West environment](https://github.com/18F/hub-pages-private/blob/master/standards/AWS.md).

The system is _only_ available to:

* staff of the General Services Administration
* other Federal staff / agencies (either by IP CIDR block or some kind of auth mechanism, HTTP Basic Auth, Oauth (MyUSA), etc) 

The system does _not_:

* interact with or change the state of any production Federal information system, whether it is operated by 18F or our Federal partners.
* collect or store any [sensitive PII]({{ site.baseurl }}/standards/aws#other-people-39-s-information).


### 90 Day authorization

Once you're ready to move beyond the restrictions of pre-authorization, you must go through the process to obtained a LATO for 90 Days. This authorization can cover any system in the Discovery, Alpha, or Beta phases. 

You **must** have a 90 day authorization before violating _any_ of the restrictions in the section above.

The authorization is rolling, and can be renewed for an additional 90 days as long as you require additional testing. This essentially functions as our **Authority to Test**. 

You do not have to wait for the 90 days to complete before moving to a new authorization. 

#### Getting ready to test

The system's technical stack needs to be relatively stable before authorization. This includes a complete list of:

* AWS services required
* base code language(s) used and their frameworks
* third-party services, regardless of level of integration
* all top-level URLS (ex: staging.18f.us _and_ 18f.gsa.gov)

If during testing the system performs:

* user authentication or authorization
* back-end administrative functions
* encryption

...then those features cannot be "relatively simple" but must in fact be *complete* before an authorization will be given. Note that the use of common web frameworks and 18F TLS standards resolves these issues in almost every case.

Lastly, make sure the `README` file in your repo is fully up to date and clearly explains what the system does and why at a high level. You should also include the above information in your `README`.

#### Writing the system security plan

Once you are ready, 18F DevOps and GSA InfoSec will write the System Security Plan, which will detail the above and guide the next phase of work: greybox testing. For greybox testing, the independent testing team has significant (but not necessarily complete) knowledge of how the system works, as opposed to black box testing, where they have zero knowledge or white box testing, where they have complete knowledge.

#### Greybox testing

Once you are ready, 18F DevOps and GSA InfoSec will start both automated and manual scanning and testing. This includes:

* using SSH to go into your EC2 servers to run tests on the operating system
* checking for web vulnerability scanning on the front-end
* static code analysis on the `master` branch of your repo
* white hat hackers attempting to penetrate the system

All of these tests must be conducted on all environments and stacks, including one _identical to production_. We call this environment and stack "pre-production" and will also affix the designation "scanee" so there is no ambiguity as to what is being scanned.

This also requires a stable `master` branch. You can continue working on `feature` branches and deploy those to a development environment.

#### Resolving vulnerabilities

If any of the testing or scanning reveals vulnerabilities that we categorize as Critical or High findings, they **must** be fixed, and the scans re-run, **before** the system receives a 90 day authorization. 

#### Signing an authorization

Once the entire process is complete, GSA InfoSec will make a recommendation to the head of the GSA Office of Citizen Services and Innovative Technologies (OCSIT), our current Authorizing Official, for signature.

#### Expectation management

Overall, if *no* vulnerabilities are found, this process has been taking approximately 2 weeks for test preparation and system security plan writing and 2 weeks for greybox testing and signature.

Since the time it would take to resolve vulnerabilities is not known until a vulnerability is identified, it is **strongly recommended** that no expectations are set with Federal partners or GSA stakeholders when public testing will begin. Instead, we recommend that the authorization process is seen as part of the delivery process and your definition of "done". 

After the system has been authorized, you can then begin planning a public roll out of your test system.

### 1 Year authorization

The 1 Year is inclusive of all the steps of the 90 Day process. A more thorough penetration test is done, which may reveal other vulnerabilities that will need to be resolved.

### Continuous authorization

Coming soon.

## Controls

[NIST 800-53 Revision 4](http://csrc.nist.gov/groups/SMA/fisma/controls.html) lists the security control baselines that must implemented on all Federal systems.

The default and required NIST controls that 18F and GSA Information Security have agreed upon for all systems are listed here, with a short description of where the controls are implemented.

### Baseline assembly

We use a [hardened baseline](https://github.com/fisma-ready/ubuntu-lts) of Ubuntu 14.04 LTS as our default OS for all products and services.

* CM-2  Baseline configuration
* CM-3  Configuration Change Control
* CM-6  Configuration Settings

### Infrastructure as a service

Development environments are exclusively in the [AWS East/West regions](https://18f.signin.aws.amazon.com/console). All AWS users must go through a DevOps [onboarding session and comply with all relevant policies of use]({{ site.baseurl }}/standards/aws).

* SC-7 Boundary protection
* AC-3 Access enforcement
* AC-6 Least priviliege

### Version control

All code must be checked into a `git` repository and a remote must be placed within the [18F Organization on GitHub.com](https://github.com/18F).

* CM-8  Information system component inventory

### HTTPS Everywhere

All 18F sites are required to use Transport Layer Security (TLS). You must follow the the [18F TLS standards](https://github.com/18F/tls-standards).

* SC-13 Cryptographic protection
* SC-28 (1) Protection of Information At Rest | Cryptographic Protection: applicable to systems with Sensitive Personally Identifiable Information Only

### Authorization and authentication

We use AWS IAM to manage authorization and authentication.

* AC-2 Account Management
* IA-2 Identification and Authentication (Organizational Users) 
* IA-2 (1) Identification and Authentication (Organizational Users) | Network Access to Privileged Accounts  
* IA-2 (2) Identification and Authentication (Organizational Users) | Network Access to Non-Privileged Accounts
* IA-2 (12) Identification and Authentication | Acceptance of PIV Credentials:  consult with DevOps/CyberSec for Applicability

### Continuous integration and testing

InfoSec does penetration testing, everything is 18F DevOps.

* CA-8 Penetration testing
* RA-5 Vulnerability Scanning
* SA-11 (1) Developer Security Testing and Evaluation| Static Code Analysis
* SI-2 Flaw Remediation
* SI-10 Information Input Validation

### Monitoring

CloudWatch, CloudTrail, New Relic, Splunk

* AU-2 Audit Events
* AU-6 Audit Review, Analysis, and Reporting
* SI-4 Information System Monitoring

### Overall system security

There are controls which are general, and the implementation may differ given the underlying technology. 

* PL-8 Information Security Architecture
