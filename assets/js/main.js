require.config({
  paths: {
    'angular': 'vendor/angular/angular',
    // 'angular-route': '.../angular-route.min',
    'angularAMD': 'vendor/angularAMD/angularAMD',
    'liveSearch': 'vendor/angular-livesearch/liveSearch',
    'lunr': 'vendor/lunr.js/lunr'
  },
  shim: {
    'angularAMD': ['angular'],
    // 'angular-route': ['angular'],
    'liveSearch': ['angular'],
    'lunr': []
  },
  deps: ['search']
});
