sinon = Npm.require 'sinon'
client_opts = 
  host: 'my-shop.shopify.com'
  api_key: 'foo'
  pass: 'bar'
  
client = new Shopify client_opts 

Tinytest.add "Shopify instance created with params", (test) ->
  
  _.each client_opts, (val, key, l) ->
    test.equal val, client[key]

Tinytest.add "Shopify paths are generated", (test) ->
  
  req_stub = sinon.stub HTTP, "call"
  
  test.equal client.products().all().path, '/products.json'
  test.equal client.products().count().path, '/products/count.json'
  test.equal client.products().details('x').path, '/products/x.json'
  test.equal client.products().update('x', 'id': 'x').path, '/products/x.json'
  test.equal client.products().create('id': 'x').path, '/products.json'
  test.equal client.products().destroy('x').path, '/products/x.json'

  test.equal client.orders().all().path, '/orders.json'
  test.equal client.orders().count().path, '/orders/count.json'
  test.equal client.orders().details('x').path, '/orders/x.json'
  test.equal client.orders().update('x', 'id': 'x').path, '/orders/x.json'
  test.equal client.orders().create('id': 'x').path, '/orders.json'
  test.equal client.orders().destroy('x').path, '/orders/x.json'

  test.equal client.products('y').orders().all().path, '/products/y/orders.json'
  test.equal client.products('y').orders().count().path, '/products/y/orders/count.json'
  test.equal client.products('y').orders().details('x').path, '/products/y/orders/x.json'
  test.equal client.products('y').orders().update('x', 'id': 'x').path, '/products/y/orders/x.json'
  test.equal client.products('y').orders().create('id': 'x').path, '/products/y/orders.json'
  test.equal client.products('y').orders().destroy('x').path, '/products/y/orders/x.json'
  
  HTTP.call.restore()
  
Tinytest.add "Shopify makes requests in SSL", (test) ->
  
  req_stub = sinon.stub HTTP, "call"
  
  client.products().all()
  args = req_stub.getCall(0).args
  
  test.isTrue req_stub.called
  test.equal 'https', args[1].slice(0,5)
  
  HTTP.call.restore()

Tinytest.add "Shopify includes user auth headers", (test) ->
  
  req_stub = sinon.stub HTTP, "call"
  
  client.products().all()
  args = req_stub.getCall(0).args
  
  test.isTrue req_stub.called
  test.equal "#{client.api_key}:#{client.pass}", args[2]['auth']
  
  HTTP.call.restore()
  