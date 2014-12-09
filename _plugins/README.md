## 18F Hub Plugins

Plugins are used to create data joins and cross-references, as well as generate pages based on that data. The basic flow is:

* Join private data with public data
* Build cross-references between data elements
* Perform canonicalization of names and their ordering
* Copy private asset files to the generated site
* Generate authentication configuration and artifacts
* Generate API endpoints based on the joined, cross-referenced data
* Generate cross-linked pages, and index pages based on the joined, cross-referenced data

[hub.rb](hub.rb) is the entry point for this entire process. It contains `Hub::Generator`, which performs all of the above steps in order.

There is some coupling between the data in [_data](../_data), the plugins in this directory, and the page templates in [_layouts](../_layouts) and [_includes](../_includes).

### Data Joining

[joiner.rb](joiner.rb) contains the plugins that join public, private, and local data into the `site.data['team']` and `site.data['projects']` hashes. See the [Data README](../_data/README.md) for details on data importing and organization.

### Cross-Referencing

[cross_referencer.rb](cross_referencer.rb) builds links between `site.data` data collections which are used to generate cross-referenced pages.

### Canonicalization

[canonicalizer.rb](canonicalizer.rb) contains functions used to canonicalize names and the sort order of collections in `site.data`.

### Copying Private Assets

[private_assets.rb](private_assets.rb) contains functions to copy private assets to the generated site, as well as to check for the existence of private assets. It is presumed that private assets may come from a git submodule, rather than appear in the main repository.

### Generating Authentication Configuration and Artifacts

[auth.rb](auth.rb) generates all authentication-related artifacts, including the logged-in user link and image for each team member and the `hub-authenticated-emails.txt` file used by the `google_auth_proxy` as described in the [Deployment README](../deploy/README.md).

### API Endpoint Generation

[api.rb](api.rb) generates all API endpoints and provides an index under `/api`.

### Page Generation

The remaining plugins use the joined, canonicalized, cross-linked data to generate cross-referenced Hub pages. All of these make use of the `Hub::Page` class from [page.rb](page.rb).

- [team.rb](team.rb)

- [locations.rb](locations.rb)

- [projects.rb](projects.rb)

- [departments.rb](departments.rb)

- [working_groups.rb](working_groups.rb)

- [snippets.rb](snippets.rb)

- [skills.rb](skills.rb)

### Filters

[filters.rb](filters.rb) contains Hub-specific Liquid template filters used in page templates.

### News index generation

[news_index.rb](news_index.rb) generates archive listings for items in the [_posts](../_posts) directory. _TODO(mbland): Still a work-in-progress._
