var index = lunr(function() {
  this.ref('url');

  this.field('title', {boost: 10});
  this.field('tags', {boost: 10});
  this.field('url', {boost: 5});
  this.field('body');
});
