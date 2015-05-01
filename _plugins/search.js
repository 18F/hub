var index = lunr(function() {
  this.ref('url');

  this.field('title', {boost: 10});
  this.field('tags', {boost: 10});
  this.field('url', {boost: 5});
  this.field('body');
});

var url_to_doc = {};

corpus.entries.forEach(function(page) {
  index.add(page);
  url_to_doc[page.url] = {url: page.url, title: page.title};
});
