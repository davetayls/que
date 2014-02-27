

module.exports =
  options:
    bare: true
  dist:
    files: [
      expand: true
      cwd: 'lib'
      src: '*.coffee'
      dest: 'dist'
      ext: '.js'
    ]

