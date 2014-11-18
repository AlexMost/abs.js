# Simple compiler mock for testing gulp tasks
# Lightweight implementation of gulp header
through = require('through2')

module.exports = (opt) ->

  prefix = opt.prefix or "<compiled-file>"

  transform = (file, enc, cb) ->
    if file.isNull()
      return cb(null, file)

    if file.isStream()
      return cb(new Error('mock compiler', 'Streaming not supported'))

    str = file.contents.toString('utf8')
    data = prefix + str
    file.compiled = new Buffer(data);
    cb(null, file)
  
  through.obj transform
