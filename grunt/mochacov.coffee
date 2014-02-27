
module.exports =
  options:
    reporter: 'html-cov',
    output: 'test/coverage.html'
    require: ['coffee-script']
  all: [
    'test/*.coffee'
  ]
