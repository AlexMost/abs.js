coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
gulp = require 'gulp'
header = require 'gulp-header'

###
config structure
Temporary mock config for building prototype.
Later will be decomposed into small parts.
###

single_file_adapter =
    was_changed: (module, cb) -> cb null, true
    get_files: (module, cb) -> cb null, [module.path]


compilers =
    default:
        ext: ".js"
        cast: (stream) -> stream

    coffee:
        ext: ".coffee"
        cast: (stream) ->
            stream.pipe(coffee())

adapters =
    single_file: single_file_adapter
    commonjs_file: single_file_adapter


config =
    compilers: compilers
    adapters: adapters

    modules:
        single_file: (stream) ->
            stream
            .pipe(header('single_file\n'))

        commonjs_file: (stream, module) ->
            stream
            .pipe(header("commonjs file #{module.name}\n"))

    bundles:
        default:
            cast: (stream, bundle) ->
                stream
                .pipe(concat())
                .pipe(gulp.dest('./tmp'))
