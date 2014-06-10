class Shopify
  constructor: (options) ->
    @host    = options.host
    @api_key = options.api_key || options.username
    @pass    = options.pass    || options.password
    @timeout = options.timeout || 2000 # Default to 2s
    @format  = options.json    || 'json'
    
    @path        = null
    @controllers = []
    @action      = null
  
  # 
  # Helpers
  # 
  objKey: ->
    last_ctl = _.last(@controllers)
    last = last_ctl.length-1
    obj_key = if last_ctl[last] is 's' then last_ctl.slice(0,last) else last_ctl
    obj_key
    
  appendController: (name, id) =>
    @action = null
    
    if @controllers and @controllers[0] isnt name
      @controllers.push name
    
    if id then @controllers.push id
    console.log "@Controllers: ", @controllers
    this
    
  fetch: (method, options) ->
    path = '/' + @controllers.join('/')
    path += if @action then "/#{@action}.json" else ".json"
    @path = path
    [@controllers, @action] = [[], null]
    @call method, @path, options
  
  # Override the HTTPS.call methods and 
  call: (method, path, options, asyncCallback) ->
    
    # Append the Host name
    url = "https://#{@host}#{path}"
    
    options ||= {}
    options.auth ||= "#{@api_key}:#{@pass}"
    
    @response = HTTP.call method, url, options, asyncCallback
    this
  
  # 
  # Controllers
  # 
  products : (id) =>
    @appendController('products', id)

  orders : (id) =>
    @appendController('orders', id)

  # 
  # Actions
  # 
  all: (params) =>
    @action = null
    @fetch 'GET', params: params 
      
  count: (params) =>
    @action = 'count'
    @fetch 'GET', params: params 
    
  details: (id, fields) ->
    params = if fields then fields: (fields || []).join(',') else {}
    @action = id
    @fetch 'GET', params: params
    
  create: (data) ->
    key = @objKey()
    if !_.keys(data)[0] is key
      data = key: data
    
    @fetch 'POST', data: data
    
  update: (id, data) ->
    @action = id
    key = @objKey()
    if !_.keys(data)[0] is key
      data = key: data
    
    @fetch 'PUT', data: data
    
  destroy: (id) ->
    @action = id
    @fetch 'DELETE'

    