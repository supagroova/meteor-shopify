sinon = Npm.require 'sinon'
client_opts = 
  host: 'my-shop.shopify.com'
  api_key: 'foo'
  pass: 'bar'
  
client = new Shopify client_opts 

Tinytest.add "Shopify instance created with params", (test) ->
  
  _.each client_opts, (val, key, l) ->
    test.equal val, client[key]

Tinytest.add "Shopify mathod chaining paths", (test) ->
  
  req_stub = sinon.stub HTTP, "call"
  
  test.equal client.products().all().path,                  '/admin/products.json'
  test.equal client.products().count().path,                '/admin/products/count.json'
  test.equal client.products().details('x').path,           '/admin/products/x.json'
  test.equal client.products().update('x', 'id': 'x').path, '/admin/products/x.json'
  test.equal client.products().create('id': 'x').path,      '/admin/products.json'
  test.equal client.products().destroy('x').path,           '/admin/products/x.json'

  test.equal client.orders().all().path,                    '/admin/orders.json'
  test.equal client.orders().count().path,                  '/admin/orders/count.json'
  test.equal client.orders().details('x').path,             '/admin/orders/x.json'
  test.equal client.orders().update('x', 'id': 'x').path,   '/admin/orders/x.json'
  test.equal client.orders().create('id': 'x').path,        '/admin/orders.json'
  test.equal client.orders().destroy('x').path,             '/admin/orders/x.json'

  test.equal client.products('y').orders().all().path,                  '/admin/products/y/orders.json'
  test.equal client.products('y').orders().count().path,                '/admin/products/y/orders/count.json'
  test.equal client.products('y').orders().details('x').path,           '/admin/products/y/orders/x.json'
  test.equal client.products('y').orders().update('x', 'id': 'x').path, '/admin/products/y/orders/x.json'
  test.equal client.products('y').orders().create('id': 'x').path,      '/admin/products/y/orders.json'
  test.equal client.products('y').orders().destroy('x').path,           '/admin/products/y/orders/x.json'
  
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

Tinytest.add "Shopify response is a Object", (test) ->
  
  req_stub = sinon.stub HTTP, "call"
  req_stub.returns(
    statusCode: 200
    content: "Success"
    data:
      products: []
  )
  
  resp = client.products().all().response
  
  test.isTrue req_stub.called
  test.instanceOf resp.data, Object
  test.equal resp.statusCode, 200
  test.isNotNull resp.data.products
  test.instanceOf resp.data.products, Array
  
  HTTP.call.restore()
  