
module.exports =
  all:
    expand: true
    cwd: "dist/"
    src: ["*.js"]
    dest: "amd/"
