---
title: 18F Terms and Conditions Standards
---
# {{ page.title }}

## Introduction

These are the standards that should be included in every 18F project as terms and conditions of our work.

## Background

18F is a digital services delivery team located within the General Services Administration (GSA). We are a team of public servants who work as developers, designers, and bureaucracy hackers. Our mission (and strategy) is to deliver great software at low cost to our Federal partners. 18F's expertise is in software delivery, human centered design, and agile consulting.

## Delivery methodology

18F follows a simplified four-phase software development cycle, which is integrated with our human centered design process. While the phase of a latest release is listed on our dashboard, the work is iterative and cyclical, as new research leads to producing new functionality.

### Discovery

To be included.

### Alpha

To be included.

### Beta

To be included.

#### Live

To be included.

## Development operations (DevOps)

For software that we develop, procure, or operate at 18F, our DevOps team will provide _continuous_:

* configuration management - we use tools such as Chef and Cloudformation to represent our infrastructure as code (IaC). Ensuring your entire system as IaC ensures a high degree of repeatability, auditability, and security. Just like all of our code, we check our IaC into a distributed version control system (DVCS) using git.

* monitoring - we use tools such as Cloudtrail and Splunk

* integration and deployment - we use tools such as Capistrano and Jenkins

* incident response - if there is an incident on your systems, we will contact your Technical Lead per the [Federal incident notification guidelines](https://www.us-cert.gov/government-users/reporting-requirements#tax). T
We work closely and monitor alerts from US-CERT and the open source community more broadly.

## Service standards

### An open source team

We place a premium on developing digital services in the open. Doing so improves everything we create. Our policy is to pursue these goals:

* use Free and Open Source Software (FOSS) in our projects and to contribute back to the open source community;
* create an environment where _any_ project can be developed in the open
* publish all source code created or modified by 18F publicly

A FOSS project provides critical technical benefits like unrestrained product customization and interoperability between tools. Other benefits include:

* Flexible usage: open source is particularly suitable for rapid prototyping and experimentation. The testing process generates minimal costs, and the process encourages the identification and elimination of defects not recognized by the original development team.  

* Community involvement: publicly available source code enables continuous and broad peer review. Whether simply publishing the completed code or opening the development process, the practice of expanding the review and testing process to a wider audience—beyond the development team—ensures increased software reliability and security. Developing in the open also allows for other opinions to help adjust the direction of a product to maximize its usefulness to the community it serves

* Cost-savings: the ability to modify FOSS enables 18F to respond rapidly to changing missions and markets. Support and maintenance of open source code—as opposed to more burdensome usages of proprietary software—provides a real cost advantage where multiple copies of software are required, or when the user base grows. The total cost of ownership is shared with a community, rather than solely 18F.

* Reusability: the code we create belongs to the American people as a part of the public domain. The code we work on was paid for by the American people, but the end-product is not the only way they should be able to interact with their government. By coding in FOSS, we help populate a larger commons that cities, states, businesses, and citizens can participate in. This creates real economic value by lowering the burden of replicating similar work or by allowing the private sector to build off of and create new businesses around code developed at 18F.

The 18F open source policy was developed after consulting previous work done by the Department of Defense (DoD), the Consumer Financial Protection Bureau (CFPB), and the Office of Management and Budget (OMB).

### IPv6

While 18F and GSA fully concurs with the move to IPv6, currently AWS does not support IPv6 in VPCs. The operational performance and security gains achieved by this best practice architecture outweigh the IPv6 compliance need. This is one area where OMB's "cloud first" initiatives directly contradict other guidance.

The main purpose of the IPv6 policy is to ensure Federal operations are not disrupted by an eventual exhaustion of IPv4 addresses. AWS has been very proactive in obtaining IPv4 blocks for its customers and we do not anticipate any disruption of operations. 

One strategy that 18F uses to mitigate the risks of IPv4 address exhaustion is through the use of Elastic Load Balancers (ELBs). ELBs themselves are a single IP that sits atop a pool of private instances - the ELB itself is an abstraction that does not provide a "true" IPv4 address, but instead is a FQDN that dynamically represents the pool of private instances. 18F always pre-reserves an address for its ELBs, so long before we enter production, we know if there will be an issue.

At the same time, many of our Federal partners, (inclusive of GSA itself) does not have IPv6 compatible network systems, making it impossible to successfully test IPv6 functionality within the networks we operate. So even if IPv6 capabilities were deployed tomorrow, we would be reticent to make commitments to a feature we ourselves cannot test.

AWS is planning on deploying IPv6 capabilities to VPCs in the future and long before the IPv4 exhaustion impacts AWS customers such as 18F. We hope GSA and our partners have fully enabled internal and external IPv6 networks by that point.

## Software as a service

18F uses industry-standard infrastructure as a service (IaaS) solutions to deliver software as a service (SaaS) to our partners. Under this model, 18F abstracts *all* the complexity away from you. 

When 18F is selected to provide SaaS for our partners, we need certain guarantees of operational and infrastructural autonomy to effectively fulfill our mission of delivering government services, securely, speedily, and at scale.

In exchange for this autonomy, 18F provides unprecedented operational transparency to our partners. This enables our partners to rely on our operations, without being subject to unpredictable manual processes. This also allows us to deliver results at a fraction of the time and cost.

We manage:

* infrastructure 
* procurement
* security
* privacy
* information collections

### Amazon Web Services

We currently offer only one IaaS solution, Amazon Web Services (AWS) in the US-East/US-West (E/W) regions and in the AWS GovCloud. We operate our IaaS under a _DevOps_ model. While we do have a fundamental "separation of concerns" between our developers and our operations staff (engineering, architecture, and cybersecurity), under DevOps, these teams work closely together to deliver working software. Everyone is responsible for every step in the process to deliver software into production.

18F strongly recommends the use of the AWS E/W for all net-new system development, unless you require compliance with [International Traffic in Arms Regulations (ITAR)](https://www.pmddtc.state.gov/regulations_laws/itar.html]. There are multiple value-added components within AWS E/W that are unavailable in the AWS GovCloud; many of these directly help with the auditability and security of the system. AWS E/W services are also available at a lower rate than those in the AWS GovCloud.

####  DNS delegation

18F will manage the Domain Name System (DNS) for any service's second-level domains or above. This means that DNS responsibility is *fully delegated* to 18F’s infrastructure. 

18F leverages AWS' world-class DNS solution, Route53, to load balance your application and provide an unparalleled level of availability, disaster recovery, and overall system flexibility. DNS services are only available if 18F is hosting your system. 

Partners should expect to create point name server (NS) records pointing to 18F's infrastructure for all relevant domains. 'relevant domain or sub-domain’s nameservers to 18F. Any further DNS records (such as but not limited to [MX, A, TXT, or CNAME](http://en.wikipedia.org/wiki/List_of_DNS_record_types) records) will be managed inside 18F’s DNS and infrastructure providers.

This also requiresmeans that 18F expects that services projects to be deployed to unique domains or subdomains (e.g. newserviceproject.agency.gov), and _not_ at URL paths on existing domains (e.g. agency.gov/newservicenewproject).

Full DNS delegation allows 18F to manage resources in a rapid, flexible, and auditable manner without prolonged or frequent manual actions, which are prone to mis-communication, delays, and failures.agency coordination. It also allows us to provision secondary resources that use the domain, and to confirm domain ownership to third parties when necessary to provide additional services to our partners.

DNSSEC capabilities at the recursive nameserver level are not currently available using this service. As none of the major web browsers currently support DNSSEC validation capabilities, true DNSSEC compliance is not yet achievable, regardless of your DNS provider. 

Additional challenges with DNSSEC is that if you are already using a content delivery network (CDN) like Akamai, Cloudfront, or Cloudflare you are already out of compliance with DNSSEC, since no Federal CDN vendor has yet to solve the problem of dynamically changing zone files with millions of entries every few seconds.

18F is committed to working with the community on DNSSEC and DNS security in general. We will closely monitor browser DNSSEC capabilities along with other clients and actively explore compensating controls.

To ameliorate this issue, if you are connecting into 18F’s backend systems to exchange sensitive data, we ensure you are working with the correct IP address before activating an exchange. If you are connecting into 18F’s front-end systems (like an API) to exchange sensitive data, we will use the appropriate authentication mechanism (e.g., API keys, TLS encryption, OAuth 2.0) to protect your data.

DNSSEC encryption between nameservers is available from the root domain, to the .gov domain, and to your second-level domain (e.g. agency.gov).

####  Digital certificate management

18F will manage the approval, issuance, renewal, and overall lifecycle of all [digital certificates](http://en.wikipedia.org/wiki/Public_key_certificate) required for the operation of services. This includes but is not limited to digital certificates required to enable Transport Layer Security (TLS) or other public-key infrastructures (PKI).


DNS delegation, as described above, is both necessary and sufficient to ensure that 18F can prove domain ownership and issue TLS certificates.

### Procurement

We maintain blanket purchase agreements (BPAs) and issue task orders for specific clients if additional infrastructure capacity is needed on the procurement vehicle. We have Federal staff available to help you create an independent government cost estimate (IGCE) for your future costs.

### Security

We only use FedRAMP IaaS at 18F. The FedRAMP program is run by our colleagues at GSA, with additional partners at the DoD, DHS, and NIST. FedRAMP is an extension of the controls recommended by the NIST 800-53 guidance. It's specifically targeted at "cloud solutions" like IaaS. Both AWS E/W (Virginia, Oregon, California) and the AWS GovCloud are located in the continental United States. When appropriate, our systems go through a formal FISMA process to obtain an Authority to Operate (ATO) which includes: 

  * software test coverage
  * continuous configuration management, monitoring, and integration/deployment.
  * vulnerability scanning (e.g., Nessus, Tripwire)
  * static code analysis (e.g., HP Fortify, Checkmarx, Hariki)
  * penetration testing
  * system security plan
  
### Privacy

We conduct our own privacy impact assessments (PIAs) and file system of records notices (SORNs) when appropriate.

### Information collection

We conduct our own Paperwork Reduction Act (PRA) clearances and have a close working relationship with OIRA/OMB. 


## Infrastructure as a service

If you deploy _your own_ services on our IaaS, you are **completely responsible** for the compliance, performance, and operation of your systems.

### Shared responsibility 

In cases where you have engineers, developers, or other users who wish to share the responsibility of the system with 18F, we are able to provision your users if they meet the above standards. Depending on the nature of the responsibility, your users would have "administrative-like" permissions but only to VPCs that pertain to your systems. 

These users must go through the same training as 18F staff, regardless of their expertise with AWS or any other infrastructure. Experience with Linux, preferably Debian/Ubuntu but RedHat Enterprise Linux or CentOS is acceptable, is also required for access.
 

## Service Level Agreement

### [ServiceName] Background

[insert content here]

### Scope

“[ServiceName]” means major releases of the software (e.g., 1.x, 2.x) in its final production architecture. This agreement does not include releases before a 1.0, or in a non-production architecture (dev, test, QA, performance testing, etc). 18F will strive to meet all SLA requirements for all releases, but these cannot be guaranteed. 

### Definitions

18F follows a simplified four-phase software development cycle, which is integrated with our human centered design process. While the phase of a latest release is listed on our dashboard, the work is iterative and cyclical, as new research leads to producing new functionality.

### Response Time and capacity management

Ninetieth (90th) percentile response time of a webpage request should be within 7 seconds. In cases where there is a temporary or permanent surge in traffic that is resulting in slower response times, the AWS infrastructure will scale-up automatically using pre-deployed scripts in order to speed-up response times.

Due the high-profile nature of the [ServiceName] program, there will be spikes in website traffic as a result of promotional campaign activities and media coverage. To ensure the highest levels of availability and performance, the Treasury Product Owner should communicate to the 18F Product Lead in advance of such planned or known events. The lead time for such notices can be as short as 1 hour.

### Uptime

18F inherits the uptime numbers in the AWS Service Level Agreement (SLA). You can find the SLA of some of the most common AWS components online:

* [EC2](http://aws.amazon.com/ec2/sla/)
* [S3](http://aws.amazon.com/s3/sla/)
* [RDS](http://aws.amazon.com/rds/sla/)

At the application level, 18F strives for 99% uptime. We don't yet have any historical data substantiating our application level uptime, since we're a new team. Any outage at the application level will trigger an automated alert to our support team who will act to restore the service to full operation (e.g., workaround) immediately. We will notify the Treasury Technical Lead of the outage within 2 hours along with an explanation of the outage and steps to remediate the underlying cause(s) within seven (7) business days.

### Infrastructure failover

[ServiceName] will be setup in the AWS US-East region in multiple zones. In the event of a multi-zone failure in the AWS US-East region, we will deploy the [ServiceName] website to the AWS US-West region within 2 hours.

### Data ownership

Data and source code for the [ServiceName] system, and all of its dependencies, can be exported and transferred at any time, at no cost to you.

### Finances

We manage our federal partnerships through interagency agreements (IAAs) with program offices at Federal agencies. Everything we do is managed under a "charge back" model. We charge for our time, our infrastructure, and our platforms. While our time and our platforms may have a small amount of overhead, this is purely for our general team operations. We do not make a profit and are expressly prohibited from doing so. Our infrastructure is pure pass-thru. We don't charge any overhead or fees for its use - whatever we pay our vendors is what you pay.

### Design and code fixes

(needs to be worked into a proper template) 

18F identifies issues from a variety of sources such as direct user feedback provided to XXX via the email [ServiceName]@XXX.gov or phone number 800-553-2663 posted on the website, ongoing user research and testing, issues reported by the public directly to the [[ServiceName] Github repo](https://github.com/18F/[ServiceName]/issues), and the Treasury Product Owner.

Per the 18F-XXX IAA, the XXX Product Owner determines the priority of all product backlog items, including bugs. The 18F delivery team will work to implement and deploy those items in a manner that is commensurate with the priority (e.g., if the retirement savings calculator is not functioning as intended, a fix will be deployed as soon as possible).

All product backlog items, including bugs, are recorded in the [[ServiceName] Github repo](https://github.com/18F/[ServiceName]/issues). Each issue logged is labeled according to priority, workflow status, etc. Those with the highest level priorities will be implemented and deployed first.

### Third-party services

(needs work)

18F uses multiple third-party services to help ensure the quality and security of [ServiceName]. 
####  Email marketing

We use MailChimp to handle email marketing campaigns. We have accepted the Terms of Service and cybersecurity risk of the underlying technology behind MailChimp and administrative access to the platform is limited to the 18F DevOps team via two-factor authentication. 

## Errata

#### 18F Current Clients

The following agencies are already hosting development or production systems with 18F:

* United States Citizenship and Immigration Services (USCIS) at the Department of Homeland Security (DHS)
* Department of Education (DoED)
* Federal Elections Commission (FEC)
* Department of Justice (DoJ)
* General Services Administration (GSA)

#### Contact information

General inquiries: 18F@gsa.gov
DevOps: devops@gsa.gov
Interagency Agreements: aaron.snow@gsa.gov

[insert project here] Project Lead: [insert lead here]
[insert project here] Technical Lead: [insert lead here]


