path = require 'path'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
gulp = require 'gulp'
header = require 'gulp-header'
abs = require '../src/abs'


###
config structure
Temporary mock config for building prototype.
Later will be decomposed into small parts.
###


single_file_adapter =
    was_changed: (module, cb) ->
        path = require 'path'
        # XXX hardcoded recipe path
        cb null, true

    get_files: (module, cb) ->
        file_real_path = path.resolve './test/fixtures/', module.path
        cb null, [file_real_path]


compilers =[
    {
        name: "js"
        ext: ".js"
        cast: (stream) -> stream
    }
    {
        name: "coffee"
        ext: ".coffee"
        cast: (stream) -> stream.pipe(coffee())
    }
]


adapters =
    single_file: single_file_adapter
    commonjs_file: single_file_adapter


modules =
    single_file:
        cast: (stream, module) ->
            stream
            .pipe(concat("#{module.name}.js"))
            .pipe(header("//single_file #{module.name}\n"))

    commonjs_file:
        cast: (stream, module) ->
            stream
            .pipe(concat("#{module.name}.js"))
            .pipe(header("//commonjs file #{module.name}\n"))


config =
    compilers: compilers

    adapters: adapters

    modules: modules

    bundles:
        default:
            cast: (stream, bundle) ->
                stream
                .pipe(concat("#{bundle.name}.js"))
                .pipe(header("// ---> bundle #{bundle.name}\n"))
                


abs(config)("./test/fixtures/recipe_data.yaml")