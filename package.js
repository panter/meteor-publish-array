Package.describe({
  name: 'panter:publish-array',
  summary: 'Publish non-mongo-arrays and collection to a client',
  version: '1.0.0',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.0.1');
  api.use('coffeescript',['client','server']);
  api.addFiles('panter:publish-array.coffee');
});
