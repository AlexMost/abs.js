Rx = require 'rx'
through = require 'through2'


run_gulp_task = (sequence) -> (file) ->
    Rx.Observable.create((obs)->
        stream = through.obj()
        sequence(stream)
        .on('data', (data) ->
            obs.onNext data
            obs.onCompleted()
        )
        stream.write file
    )


module.exports = {run_gulp_task}
