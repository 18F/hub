var gulp = require('gulp');

gulp.task('vendorize', function() {
  var modules = ['chai', 'mocha'];
  modules.forEach(function(module) {
    gulp.src('./node_modules/' + module + '/' + module + '.js')
      .pipe(gulp.dest('./assets/js/tests/'));
  });
  gulp.src('./node_modules/chai-things/lib/chai-things.js')
    .pipe(gulp.dest('./assets/js/tests/'));
});
