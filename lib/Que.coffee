
EventEmitter = require('events').EventEmitter

s4 = ->
  Math.floor((1 + Math.random()) * 0x10000).toString(16).substring 1

_id = ->
  s4() + s4() + "-" + s4() + "-" + s4() + "-" + s4() + "-" + s4() + s4() + s4()

exports = module.exports = class Que extends EventEmitter
  constructor: (store) ->
    @state = exports.STATES.STOPPED
    @store = store
    @processes = {}

  create: (key, data) ->
    job = new Job(key, data)
    @store.add job
    if @state is STATES.WAITING
      setTimeout =>
        @next()
      , 0
    job

  process: (key, fn) ->
    @processes[key] = fn

  next: ->
    job = @store.next()
    if job
      process = @processes[job.key]
      if process
        job.once 'complete', => @next()
        process.call @, job
      else
        throw new Error('Que: no process added with key: ' + job.key)
    else
      @state = STATES.WAITING

  start: ->
    unless @state is STATES.RUNNING
      @state = STATES.RUNNING
      @next()



STATES = exports.STATES =
  STOPPED: 0
  RUNNING: 1
  WAITING: 2

class Job extends EventEmitter
  constructor: (key, data) ->
    @id = _id()
    @key = key
    @data = data
    @attempts = 0

  complete: ->
    @completed = true
    @emit('complete')

  fail: ->
    @attempts++
    @emit 'failed'

  progress: (current, total) ->
    percent = (100/total) * current
    @progressed = percent
    @emit 'progress', percent

class exports.Store
  constructor: (name) ->
    @name = name

class exports.MemoryStore extends exports.Store
  constructor: (name) ->
    super name
    @store = []

  add: (job) ->
    @store.push job

  next: -> @store.shift()


class exports.LocalStorageStore extends exports.Store
  save: (key, data) ->
    localStorage.setItem(@name + '-' + key, JSON.stringify(data))

