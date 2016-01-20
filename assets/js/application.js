function initBody() {
  $('body').removeClass('no-js');
}

$(document).ready(function() {
  initBody();
  $('table').addClass('tablesaw-stack');

  var tableOfContentsToggle = 
    $('<a href="#" class="table-of-contents--toggle">Show table of contents</a>')
      .click(function(){
        $('body').toggleClass('show-table-of-contents');
        if ($('body').hasClass('show-table-of-contents')) {
          $('.table-of-contents--toggle').text('Hide table of contents');
        } else {
          $('.table-of-contents--toggle').text('Show table of contents');
        }
      });

  $('nav.nav-main ol.breadcrumbs').before(tableOfContentsToggle);
});