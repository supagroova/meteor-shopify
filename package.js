Npm.depends({
  'sinon':'1.10.2',
});

Package.describe({
  summary: "A simple Shopify API client, which connects via an application's credentials. This only runs on the server."
});

Package.on_use(function(api) {
  api.use(['coffeescript', 'underscore', 'http'], 'server');
  api.add_files('lib/shopify.coffee', 'server');
  api.export('Shopify');
});

Package.on_test(function(api) {
  api.use(['coffeescript', 'underscore', 'test-helpers', 'tinytest', 'http'], 'server');
  api.use('shopify', 'server');
  api.add_files(["tests/shopify-test.coffee"], 'server');
});

