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
    was_changed: (module, cached_module, cb) ->
        path = require 'path'
        # XXX hardcoded recipe path
        cb null, true

    get_files: (module, config, cb) ->
        recipe_path = path.dirname config.recipe_path
        file_real_path = path.resolve recipe_path, module.get_path()
        cb null, [file_real_path]


config =
    recipe_path: "./test/fixtures/recipe_data.yaml"

    compilers: [
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

    adapters:
        single_file: single_file_adapter
        commonjs_file: single_file_adapter

    modules:
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

    bundles:
        default:
            cast: (stream, bundle) ->
                stream
                .pipe(concat("#{bundle.name}.js"))
                .pipe(header("// ---> bundle #{bundle.name}\n"))
                

abs(config)