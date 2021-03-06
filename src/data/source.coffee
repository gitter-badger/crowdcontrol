# _ = require 'underscore'

# utils = require '../utils'
# promise = utils.promise
# requestAnimationFrame = utils.shim.requestAnimationFrame
# log = utils.log

# Policy = require('./policy').Policy

# Events =
#   Reload: 'source-reload'
#   Loading: 'source-loading'
#   LoadData: 'source-load-data'
#   LoadError: 'source-load-error'
#   LoadDataPartial: 'source-load-data-partial'

# # A Source serves data either from the backend or from a backing set of data
# class Source
#   @Events: Events

#   ### Static Data ###

#   # data is backing data for non-api loaders if no api is specified.  It may also be used to cache data from the server
#   data: null

#   ### Dynamic Data ###

#   # api is object of API type, specifies the api to hit. If this is not present, then fallback to data
#   # if a string is provided, it will automatically try and use the api by name
#   api: null

#   # path is the api endpoint to hit such as 'user' for https://api.crowdstart.com/user
#   path: ''

#   # policy refers how the Source loads and saves data
#   # policy tells the source how often to reload data and how to batch data for example
#   # policy also preprocesses data
#   _policy: null

#   # policy getter and setter
#   @property 'policy',
#     get: ->
#       return @_policy
#     set: (value) ->
#       log "Set Policy", @policy
#       @_policy.source = null if @_policy?
#       @stop()
#       @_policy = value || Policy.Once
#       @_policy.source = @ if @_policy?
#       @start()

#   # task is the result of calling api's task scheduling
#   _task: null

#   # global event pump, mediator is needed to avoid very confusing pub/sub chains
#   _mediator: utils.mediator

#   constructor: (@options)->
#     policy = @options.policy || Policy.Once
#     delete @options.policy

#     _.extend @, @options

#     @policy = policy

#     @on Events.Reload, ()=>
#       @_load()

#   start: ()->
#     if @api?
#       policy = @policy
#       if policy.intervalTime == Infinity
#         @_task = @api.scheduleOnce (()=>@_load()), 0
#       else
#         @_task = @api.scheduleEvery (()=>@_load()), policy.intervalTime, true
#     else
#       requestAnimationFrame ()=>
#         @_load()

#   stop: ()->
#     @_task.cancel() if @_task?
#     @_task = null

#   _load: ()->
#     @policy.unload()
#     if @api?
#       @trigger Events.Loading

#       success = (data)=>
#         @trigger Events.LoadData, data
#         @data = data
#       error = (err) =>
#         log.warn("THIS IS BAD", err.stack)
#         @trigger Events.LoadError, err

#       load = (res) =>
#         return @policy.load(res).done(success, error)
#       fail = (res) =>
#         log.warn("THIS LESS BAD", res)
#         @trigger Events.LoadError, res.statusText

#       return @api.get(@path).then(load, fail)
#     else
#       return promise.new (resolve, reject)=>
#         requestAnimationFrame ()=>
#           @trigger Events.LoadData, @data
#           resolve @data

#   eventName: (event)->
#     path = @path
#     if @api?
#       path = @api.url + path
#     return path + '.' + event.trim().replace(' ', ' ' + path + '.')

#   on: (event, fn)->
#     @_mediator.on @eventName(event), fn

#   once: (event, fn)->
#     @_mediator.one @eventName(event), fn

#   off: (event, fn)->
#     @_mediator.off @eventName(event), fn

#   trigger: (event)->
#     args = Array.prototype.slice.call arguments
#     args.shift()
#     args.unshift @eventName(event)

#     @_mediator.trigger.apply @, args

# module.exports = Source
