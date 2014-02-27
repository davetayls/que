
expect = require('chai').expect

Que = require('../lib/Que')

describe 'Que', ->

  it 'should be able to create a new instance', ->
    q = new Que()
    expect(q).be.instanceOf Que

  it 'should push a new job in to the stack', ->
    q = new Que(new Que.MemoryStore())
    job = q.create 'new job',
      a: 1
      b: 2
    expect(job.data.a).equal(1)
    expect(q.store.store).length(1)

  it 'can add a process', ->
    q = new Que(new Que.MemoryStore())
    q.process 'share', (job, done) ->

  it 'can start running the queue', (dn) ->
    q = new Que(new Que.MemoryStore())
    q.process 'share', (job, done) ->
      expect(job.key).to.equal('share')
      expect(job.data.to).to.equal('foobar')
      done()
      dn()
    q.create 'share',
      to: 'foobar'
    q.start()

  it 'can run the queue sequentially', (dn) ->
    q = new Que(new Que.MemoryStore())

    i = 0
    q.process 'share', (job, done) ->
      if job.data.to is 'foobar'
        expect(i).equal(0)
      else if job.data.to is 'baz'
        expect(i).equal(1)
      i++
      setTimeout =>
        done()
        if i is 2 then dn()
      , 100

    q.create 'share',
      to: 'foobar'
    q.create 'share',
      to: 'baz'
    q.start()



