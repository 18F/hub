## 18F Hub Data

There are three levels of data sources:

* [_data/public](https://github.com/18F/data-public): shared with 18f.gsa.gov, Dashboard
* [_data/private](https://github.com/18F/data-private): private team and project data
* [_data](.): Hub-specific data (potentially public)

### Data Importing

The [public/import.sh](https://github.com/18F/data-public/blob/master/import.sh) script imports [team member data](https://github.com/18F/data-public/blob/master/team.yml) from the [18f.gsa.gov repo](https://github.com/18F/18f.gsa.gov/) and [project data](https://github.com/18F/data-public/blob/master/projects.yml) from the [18F Dashboard repo](https://github.com/18F/dashboard). It is run manually, and the updated static YAML files are then checked into the repository.

[Snippet data](https://github.com/18F/data-private/tree/master/snippets) is checked-in manually after downloading the most recent round of weekly snippets from Google Sheets as a CSV file.

### Data Processing

The [plugins README](../_plugins/README.md) goes into detail regarding how the different bodies of data are merged and processed.

### Rationale and Future Directions

Since interest in the Hub has grown, there's been a concern that manual importing data that is now duplicated between repositories is already leading to unnecesary friction. Also, I (@mbland) have a strong desire to see a public version of the Hub published, along with the Hub code repository. (A new one will have to be started from scratch, so private info doesn't appear in the history.)

Structuring the data into these three components, then using plugins to join the data sets as needed, has proven a workable solution when it comes to generating Hub content. How best to share the data between multiple projects is an open question, but I've linked to `_data/public` and `_data/private` as git submodules as a proof-of-concept.

More discussion is needed, and there may be a learning curve, but submodules (i.e. keeping the content of `_data/public` and `_data/private` in separate repos, the latter being private) may be the most straightforward and convenient alternative to continuing to edit the data across projects and importing it into the Hub:

* Submodules ensure there is one authoritative source for both public and private data across projects.
* Submodules allow the possibility that the Hub code may be open-sourced in its entirety, without the need for a separately-maintained private fork, since private data will be firewalled behind a private repo.
* Commits to the master data repos can trigger GitHub webhooks to launch staging builds of affected projects.

Regardless of the shape of the final implementation, being able to open-source the Hub and at least some of its information would be a boon to the larger mission of reforming US Federal Government IT. See my proposal [Going Public with the Hub, Snippets, and Working Groups](https://docs.google.com/a/gsa.gov/document/d/1tsjqPI73PlXvauM8O7F9BvVvAexEACGVl6_rfmaQ3MU/edit?usp=sharing) for details.
