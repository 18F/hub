---
---
require.config({
  paths: {
    'angular': '{{ "vendor/angular/angular" | asset_path | trim_suffix:".js" }}',
    // 'angular-route': '.../angular-route.min',
    'angularAMD': '{{ "vendor/angularAMD/angularAMD" | asset_path | trim_suffix:".js" }}',
    'liveSearch': '{{ "vendor/angular-livesearch/liveSearch" | asset_path | trim_suffix:".js" }}',
    'lunr': '{{ "vendor/lunr.js/lunr" | asset_path | trim_suffix:".js" }}'
  },
  shim: {
    'angularAMD': ['angular'],
    // 'angular-route': ['angular'],
    'liveSearch': ['angular'],
    'lunr': []
  },
  deps: ['{{ "search" | asset_path }}']
});
