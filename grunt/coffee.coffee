

module.exports =
  options:
    bare: false
  dist:
    files: [
      expand: true
      cwd: 'lib'
      src: '*.coffee'
      dest: 'dist'
      ext: '.js'
    ]

