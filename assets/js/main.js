---
---
require.config({
  paths: {
    'angular': '{{ "vendor/angular/angular" | require_js_asset_path }}',
    'angularAMD': '{{ "vendor/angularAMD/angularAMD" | require_js_asset_path }}',
    'liveSearch': '{{ "vendor/angular-livesearch/liveSearch" | require_js_asset_path }}',
    'lunr': '{{ "vendor/lunr.js/lunr" | require_js_asset_path }}'
  },
  shim: {
    'angularAMD': ['angular'],
    'liveSearch': ['angular'],
    'lunr': []
  },
  deps: ['{{ "search" | asset_path }}']
});
