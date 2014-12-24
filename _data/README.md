## 18F Hub Data

There are three levels of data sources:

* [_data/private](https://github.com/18F/data-private): team, project, and snippet data stored in a private repo
* [_data/public](public): team, project, and snippet data stripped of private information
* [_data](.): Hub-specific, publicly-accessible data

`_data/public` serves two purposes:

* In the near future, updates to this data will trigger an automated deployment of the [18F Public Hub](https://18f.gsa.gov/hub). See [the deployment README](../deploy/README.md) for more details.
* It serves as demonstration data for people running their own Hub instance out-of-the-box as described in the [top-level README](../README.md).

### Data Importing

18F team members have access to the [18F/data-private](https://github.com/18F/data-private) repository, and can mount it under `_data/private` via `git submodule init && git submodule update --remote`. They can make updates directly to this private data, and can manually check-in [snippet data](https://github.com/18F/data-private/tree/master/snippets) after downloading the most recent round of weekly snippets from Google Sheets as a CSV file.

18F team members can also run the [import-public.rb](import-public.rb) script manually to import data files from `_data/private` into `_data/public` with all the private information stripped out.

### Data Processing

The [plugins README](../_plugins/README.md) goes into detail regarding how the different bodies of data are merged and processed.

### Rationale and Future Work

Structuring the data into these three components, then using plugins to join the data sets as needed, has proven a workable solution when it comes to generating Hub content. Partitioning the private team data into a separate submodule accomplishes two objectives:

* Potentially sensitive and personal data that we wish to keep private is firewalled inside a private repository.
* Team members only have to update their data in a single place, and from there it will propagate to the Hub, to the [18F Home Page](https://18f.gsa.gov), and the [18F Project Dashboard](https://18f.gsa.gov/dashboard).

A single git repository containing this data, mounted as a submodule, is effective because it:

* allows the Hub code to be open-sourced in its entirety, without the need for a separately-maintained private fork;
* ensures there is one authoritative source for both public and private data across projects; and
* commits to the master data repo can trigger GitHub webhooks to launch staging builds of affected projects.

This first point is already in effect. Work is underway to adapt the 18F Home Page and the Dashboard to this model, and after that is complete, we can set up webhook-triggered staging builds.
