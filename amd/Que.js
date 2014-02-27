define(function (require, exports, module) {(function() {
  'use strict';
  var EventEmitter, Job, Que, STATES, exports, s4, _id,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  EventEmitter = require('events').EventEmitter;

  s4 = function() {
    return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
  };

  _id = function() {
    return s4() + s4() + "-" + s4() + "-" + s4() + "-" + s4() + "-" + s4() + s4() + s4();
  };

  exports = module.exports = Que = (function(_super) {
    __extends(Que, _super);

    function Que(store) {
      this.state = exports.STATES.STOPPED;
      this.store = store;
      this.processes = {};
    }

    Que.prototype.create = function(key, data) {
      var job;
      job = new Job(key, data);
      this.store.add(job);
      if (this.state === STATES.WAITING) {
        setTimeout((function(_this) {
          return function() {
            return _this.next();
          };
        })(this), 0);
      }
      return job;
    };

    Que.prototype.process = function(key, fn) {
      return this.processes[key] = fn;
    };

    Que.prototype.next = function() {
      var job, process;
      job = this.store.next();
      if (job) {
        process = this.processes[job.key];
        if (process) {
          job.once('complete', (function(_this) {
            return function() {
              return _this.next();
            };
          })(this));
          return process.call(this, job);
        } else {
          throw new Error('Que: no process added with key: ' + job.key);
        }
      } else {
        return this.state = STATES.WAITING;
      }
    };

    Que.prototype.start = function() {
      if (this.state !== STATES.RUNNING) {
        this.state = STATES.RUNNING;
        return this.next();
      }
    };

    return Que;

  })(EventEmitter);

  STATES = exports.STATES = {
    STOPPED: 0,
    RUNNING: 1,
    WAITING: 2
  };

  Job = (function(_super) {
    __extends(Job, _super);

    function Job(key, data) {
      this.id = _id();
      this.key = key;
      this.data = data;
      this.attempts = 0;
    }

    Job.prototype.complete = function() {
      this.completed = true;
      return this.emit('complete');
    };

    Job.prototype.fail = function() {
      this.attempts++;
      return this.emit('failed');
    };

    Job.prototype.progress = function(current, total) {
      var percent;
      percent = (100 / total) * current;
      this.progressed = percent;
      return this.emit('progress', percent);
    };

    return Job;

  })(EventEmitter);

  exports.Store = (function() {
    function Store(name) {
      this.name = name;
    }

    return Store;

  })();

  exports.MemoryStore = (function(_super) {
    __extends(MemoryStore, _super);

    function MemoryStore(name) {
      MemoryStore.__super__.constructor.call(this, name);
      this.store = [];
    }

    MemoryStore.prototype.add = function(job) {
      return this.store.push(job);
    };

    MemoryStore.prototype.next = function() {
      return this.store.shift();
    };

    return MemoryStore;

  })(exports.Store);

  exports.LocalStorageStore = (function(_super) {
    __extends(LocalStorageStore, _super);

    function LocalStorageStore() {
      return LocalStorageStore.__super__.constructor.apply(this, arguments);
    }

    LocalStorageStore.prototype.save = function(key, data) {
      return localStorage.setItem(this.name + '-' + key, JSON.stringify(data));
    };

    return LocalStorageStore;

  })(exports.Store);

}).call(this);

});
