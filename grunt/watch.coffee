
module.exports =
  options:
    nospawn: false
    debounceDelay: 500
    interval: 500

  coffee:
    files: [
      'lib/**/*.coffee'
    ]
    tasks: ['coffee','mochaTest']

  test:
    files: [
      'test/*.coffee'
    ]
    tasks: ['newer:mochaTest']
