var index = lunr(function() {
  this.ref('url');

  for (var field_name in index_fields) {
    var boost = index_fields[field_name];
    this.field(field_name, boost);
  }
});

var url_to_doc = {};

corpus.entries.forEach(function(page) {
  index.add(page);
  url_to_doc[page.url] = {url: page.url, title: page.title};
});

var result = JSON.stringify({
  index: index.toJSON(),
  url_to_doc: url_to_doc
});
