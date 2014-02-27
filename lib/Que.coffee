
EventEmitter = require('events').EventEmitter

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
    record = @store.next()
    if record
      job = new Job(record.key, record.data)
      process = @processes[job.key]
      if process
        _done = => @next()
        process.call @, job, _done
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

class Job
  constructor: (key, data) ->
    @key = key
    @data = data

class exports.Store
  constructor: (name) ->
    @name = name

class exports.MemoryStore extends exports.Store
  constructor: (name) ->
    super name
    @store = []

  add: (job) ->
    @store.push
      key: job.key
      data: JSON.stringify(job.data)
    job

  next: ->
    top = @store.shift()
    if top
      top.data = JSON.parse(top.data)
      top

class exports.LocalStorageStore extends exports.Store
  save: (key, data) ->
    localStorage.setItem(@name + '-' + key, JSON.stringify(data))

