---
title: TeamOps Statements - myRA Service Level Agreement (SLA)
permalink: /team-ops/statements/myra-sla/
---
# {{ page.title }}

## 18F Background

We are a new digital services delivery team located within the General Services Administration. We are a team of civil servants who work as developers, designers, and bureaucracy hackers. Our mission (and strategy) is to deliver great software at low cost to our Federal partners. 18F's expertise is in iterative software development, infrastructure as a service (IaaS), and DevOps. 

## myRA Background

myRA is a static website developed and hosted by 18F. It is entirely written in HTML, CSS, and JavaScript. Content is created in [Markdown](http://daringfireball.net/projects/markdown/syntax) and then rendered into HTML pages using [Jekyll](http://jekyllrb.com/). Neither is a dependency - the site could be maintained and run with pure HTML content. They exist as a convenience to content creators who many not have the prerequisite knowledge to write HTML.

### Definitions

“myRA” means major releases of the software (ex: 1.x, 2.x) in its final production architecture. 

## Capacity assessment

myRA will be able to support per month:

* 100,000 pageviews
* 100,000 email subscribers
* 1,200,000 emails

## Data ownership

Data and source code for the myRA system, and all of its dependencies, can be exported and transferred at any time, at no cost to you.

## Operational and finance model

We manage our federal partnerships through interagency agreements (IAAs) with program offices at Federal agencies. Everything we do is managed under a "charge back" model. We charge for our time, our infrastructure, and our platforms. While our time and our platforms may have a small amount of overhead, this is purely for our general team operations. We do not make a profit and are expressly prohibited from doing so. Our infrastructure is pure pass-thru. We don't charge any overhead or fees for its use - whatever we pay our vendors is what you pay.

### An open source team

We place a premium on developing digital tools and services in the open. Doing so improves the final product we create. Our policy is to pursue these goals:

* use Free and Open Source Software (FOSS) in our projects and to contribute back to the open source community;
* create an environment where _any_ project can be developed in the open
* publish all source code created or modified by 18F publicly

A FOSS project provides critical technical benefits like unrestrained product customization and interoperability between tools. Other benefits include:

* Flexible usage: open source is particularly suitable for rapid prototyping and experimentation. The testing process generates minimal costs, and the process encourages the identification and elimination of defects not recognized by the original development team.


* Community involvement: publicly available source code enables continuous and broad peer review. Whether simply publishing the completed code or opening the development process, the practice of expanding the review and testing process to a wider audience—beyond the development team—ensures increased software reliability and security. Developing in the open also allows for other opinions to help adjust the direction of a product to maximize its usefulness to the community it serves


* Cost-savings: the ability to modify FOSS enables 18F to respond rapidly to changing missions and markets. Support and maintenance of open source code—as opposed to more burdensome usages of proprietary software—provides a real cost advantage where multiple copies of software are required, or when the user base grows. The total cost of ownership is shared with a community, rather than solely 18F.


* Reusability: the code we create belongs to the American people as a part of the public domain. The code we work on was paid for by the American people, but the end-product is not the only way they should be able to interact with their government. By coding in FOSS, we help populate a larger commons that cities, states, businesses, and citizens can participate in. This creates real economic value by lowering the burden of replicating similar work or by allowing the private sector to build off of and create new businesses around code developed at 18F.


The 18F open source policy was developed after consulting previous work done by the Department of Defense (DoD), the Consumer Financial Protection Bureau (CFPB), and the Office of Management and Budget (OMB).

## Infrastructure as a Service (as a Service)

18F uses industry standard IaaS solutions to deliver software as a service (SaaS) to our partners. Under this model, 18F abstracts *all* the complexity away from you. 

We manage:

* the infrastructure itself - we currently offer only one IaaS solution, Amazon Web Services (AWS) in the US-East/US-West (E/W) regions and in the AWS GovCloud. We operate our IaaS under a _DevOps_ model. While we do have a fundamental "separation of concerns" between our developers and our operations staff (engineering, architecture, and cybersecurity), under DevOps, these teams work closely together to deliver working software. Everyone is responsible for every step in the process to deliver software into production. 


* procurement - we maintain blanket purchase agreements (BPAs) and issue task orders for specific clients if additional capacity is needed on the procurement vehicle. We have Federal staff available to help you create an independent government cost estimate (IGCE) for your future costs.


* cybersecurity compliance - we only use FedRAMP IaaS at 18F. The FedRAMP program run by our colleagues at GSA, with additional partners at the DoD, DHS, and NIST. FedRAMP is an extension of the controls recommended by the NIST 800-53 guidance. It's specifically targeted at "cloud solutions" like IaaS. Both AWS E/W (Virginia, Oregon, California) and the AWS GovCloud are located in the continental United States. When appropriate, our systems go through a formal FISMA process to obtain an Authority to Operate (ATO) which includes: 
  * software test coverage
  * continuous configuration management, monitoring, and integration/deployment.
  * vulnerability scanning (Nessus, Tripwire)
  * static code analysis (HP Fortify, Checkmarx, Hariki)
  * penetration testing
  * system security plan

* privacy compliance - we conduct our own privacy impact assessments (PIAs) and file system of records notices (SORNs) where appropriate.

* Paperwork Reduction Act (PRA) - we conduct our own PRAs and have a close working relationship with OIRA/OMB.

18F strongly recommends the use of the AWS E/W for all net-new system development, unless you require compliance with [International Traffic in Arms Regulations (ITAR)](https://www.pmddtc.state.gov/regulations_laws/itar.html]. There are multiple value-added components within AWS E/W that are unavailable in the AWS GovCloud; many of these directly help with the auditability and security of the system. AWS E/W services are also available at a lower rate than those in the AWS GovCloud.

If you deploy your own applications on our IaaS, you are **completely responsible** for the compliance, performance, and operation of your systems.

### Uptime

18F inherits the uptime numbers in the AWS Service Level Agreement (SLA). You can find the SLA of some of the most common AWS components online:

* [EC2](http://aws.amazon.com/ec2/sla/)
* [S3](http://aws.amazon.com/s3/sla/)
* [RDS](http://aws.amazon.com/rds/sla/)

At the application level, 18F strives for 99% uptime. We don't yet have any historical data substantiating our application level uptime, since we're a new team. Any outage at the application level will result in a notification to you within 24 hours, with an explanation of the outage and remediation steps within seven (7) business days.

## DevOps

For software that we develop, procure, or operate at 18F, our DevOps team will provide _continuous_:

* configuration management - we use Chef or Puppet, and Cloudformation to represent our infrastructure as code (IaC). Ensuring your entire system as IaC ensures a high degree of repeatability, auditability, and security. Just like all of our code, we check our IaC into a distributed version control system (DVCS) using git.

* monitoring - we use Cloudtrail and Splunk

* integration and deployment - we use Capistrano and Jenkins

* incident response - if there is an incident on your systems, we will contact your Technical Lead within 24 hours or as soon as any immediate threat is resolved. We work closely and monitor alerts from US-CERT and the open source community more broadly.

### Concept of Operations

The 18F DevOps team manages the AWS infrastructure, in direct collaboration and consultation with our senior application developers and the GSA Security Engineering team. The root user is Noah Kunin, 18F's Delivery Architect (noah.kunin@gsa.gov). Administrative users (with almost all the powers of the root user) are limited to users trained on AWS. All users, regardless of their permission levels, must sign into the platform using a password of [insert entropy here] and using 2-factor authentication (2FA).

Firewalls and overall data flow through the system are maintained by the usage of security groups. Each resource in AWS is limited by a pure whitelist - an 18F administrator must specifically enumerate ports. Each system developed by 18F receives its own internet gateway and virtual private cloud (VPC) to logically separate it from other systems in the environment. Identity access management is mediated through permission policies written in JSON. SSH Key-pairs are then assigned to appropriate users. Key-pairs are only ever stored in a GSA enclave or locally on staff laptops. The security group policy on the VPC or specific instance then limits SSH access to a GSA CIDR block, or other known and trusted entities based on system design or functionality.

18F works hard to ensure every component of our applications, and as much of our IaaS as possible, is based on free and open source (FOSS) technologies and we have the strongest FOSS policy in the Federal community to back it up. We always evaluate open source solutions first. If you choose not to use 18F's IaaS in the future, the vast majority of the system should be able to be transferred without any need to purchase licenses or negotiate intellectual property rights. 18F will provide you a comprehensive system architecture diagram before your system moves into production, noting where non-open source components are used.

### Shared responsibility 

In cases where you have engineers, developers, or other users who wish to share the responsibility of the system with 18F, we are able to provision your users if they meet the above standards. Depending on the nature of the responsibility, your users would have "administrative-like" permissions but only to VPCs that pertain to your systems. These users must go through the same training as 18F staff, regardless of their expertise with AWS or any other infrastructure. Experience with Linux, preferably Debian/Ubuntu but RedHat Enterprise Linux or CentOS is acceptable, is also required for access.

## Technical service notes

Ancillary to our application development and DevOps are other services your system may need when deployed to production.

### Domain Name Service (DNS)

18F leverages AWS' world-class DNS solution, Route53, to load balance your application and provide an unparalleled level of availability, disaster recovery, and overall system flexibility. DNS services are only available if 18F is hosting your system. 

If you require a:

* second-level domain (example.gov): 18F will work with the Federal CIO, OMB, and the DotGov.gov team (located at GSA) on your behalf to get the necessary permissions to launch.

* third-level domain (example.youragencyhere.gov): 18F will work with your Network team to establish a CNAME record (an alias) from the desired URL to the 18F AWS infrastructure. This is usually achieved by your Network team adding a CNAME record for the URL to the fully qualified domain name (FQDN) of the primary Elastic Load Balancer (ELB) on your system. You can also fully delegate control over the third-level domain over to 18F.

* fourth-level domains and above: 18F does not recommend the use of publicly accessible domains beyond the third-level. They are difficult to type for users and difficult to use in marketing and communications. If you think you have a discrete need for a fourth-level or higher domain, please contact 18F as soon as possible, so we can first look at re-architecting your system. Fourth-level and higher domains are appropriate for non-production environments (ex: staging.example.youragencyhere.gov)

DNSSEC capabilities are not currently available using this service. As none of the major web browsers currently support DNSSEC validation capabilities, true DNSSEC compliance is not yet achievable, regardless of your DNS provider. 

The other challenge with DNSSEC is that if you are already using a content delivery network (CDN) like Akamai, you are already out of compliance with DNSSEC, since no Federal CDN vendor has yet to solve the problem of dynamically changing zone files with millions of entries every few seconds.

18F is committed to working with the community on DNSSEC and DNS security in general. We will closely monitor browser DNSSEC capabilities along with other clients and actively explore compensating controls.

In the meantime, if you are connecting into 18F’s backend systems to exchange sensitive data, we ensure you are working with the correct IP address before activating an exchange. If you are connecting into 18F’s front-end systems (like an API) to exchange sensitive data, we use API keys to authenticate identities and strong SSL/TLS encryption to protect your data.

### IPv6

While 18F and GSA fully concurs with the move to IPv6, currently AWS does not support IPv6 for Elastic Load Balancers (ELBs) in VPCs. The operational performance and security gains achieved by this best practice architecture outweigh the IPv6 compliance need. This is one area where OMB's "cloud first" initiatives directly contradict other guidance.

The main purpose of the IPv6 policy is to ensure Federal operations are not disrupted by an eventual exhaustion of IPv4 addresses. AWS has been very proactive in obtaining IPv4 blocks for its customers and we do not anticipate any disruption of operations. ELBs are themselves a single IP that sits atop a pool of private instances - the ELB itself is an abstraction that does not provide a "true" IPv4 address, but instead is a FQDN that dynamically represents the pool of private instances. 18F always pre-reserves an address for its ELBs, so long before we enter production, we know if there will be an issue.

At the same time, many of our Federal partners, (inclusive of GSA itself) does not have IPv6 compatible network systems, making it impossible to successfully test IPv6 functionality within the networks we operate. So even if IPv6 capabilities were deployed tomorrow, we would be reticent to make commitments to a feature we ourselves cannot test.

AWS is planning on deploying IPv6 capabilities to VPC ELBs in the future and long before the IPv4 exhaustion impacts AWS customers such as 18F. We hope GSA and our partners have fully enabled internal and external IPv6 networks by that point.

## myRA Compliance Architecture

We have prepared the following breakdown of various compliance checks:

- Section 508: myRA will receive a 508 analysis from a trained evaluator.

- PRA: No OMB control # is required as the myRA site does not collect any information via methods that fall under the

- SORN: No SORN is required as no information that falls under the Privacy Act is collected. 

The following datum is collected from potential myRA users: email. Emails that are not paired with a verifiable identifier cannot be PII as the identity of the individual who submits the email cannot be directly or indirectly inferreed.

The following data is collected from employers: company name, number of employees. Employers acting in their official capacity [are not afforded Privacy Act rights](http://www.justice.gov/opcl/definitions). Individuals who are sole-proprietorships will be directed to the Individual sign-up page. 

All data is collected before the site starts to link to the fiscal agent system. After the fiscal agent's system launches, no data will be collected on the myRA system.

Overall analytics data will be collected via the GSA-run Government Enterprise Google Analytics account as long as the system is in operation. 

- ATO: After leveraging FedRAMP controls, we will assess myRA for the following controls:

- AC-2 Account Management
- AU-2 Audit Events
- AU-6 Audit Review, Analysis, and Reporting
- CM-3 Configuration Change Control
- CM-6 Configuration Settings
- IA-2 Identification and Authentication (Organizational Users)
- IA-2 (1) Identification and Authentication (Organizational Users) | Network Access to Privileged Accounts
- IA-2 (2) Identification and Authentication (Organizational Users) | Network Access to Non-Privileged Accounts
- PL-8 Information Security Architecture
- SI-2 Flaw Remediation
- SI-10 Information Input Validation
- CA-8 Penetration Testing RA-5 Vulnerability Scanning
- SA-11 (1) Developer Security Testing and Evaluation | Static Code Analysis
- CM-2 Baseline Configuration
- SC-7 Boundary Protection
- CM-8 Information System Component Inventory
myRA uses MailChimp to handle email addresses. We have accepted the Terms of Service and cybersecurity risk of the underlying technology behind MailChimp and administrative access to the platform is limited to the 18F DevOps team via two-factor authentication. 
#### 18F Current Clients

The following agencies are already hosting development or production systems with 18F:

* United States Citizenship and Immigration Services (USCIS) at the Department of Homeland Security (DHS)
* Department of Education (DoED)
* Federal Elections Commission (FEC)
* Department of Justice (DoJ)
* General Services Administration (GSA)

#### Contact information

**General inquiries:** 
18F@gsa.gov

**DevOps:** 
devops@gsa.gov

**Interagency Agreements:**
Aaron Snow, aaron.snow@gsa.gov

**myRA Project Lead:** 
Chris Cairns, christopher.cairns@gsa.gov

**myRA Technical and Design Lead:** 
Noah Manger, noah.manger@gsa.gov
