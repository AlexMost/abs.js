gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
nodeunit = require  'gulp-nodeunit'

SRC_PATH = './src/**/*.coffee'
SRC_TEST_PATH = './test/**/*.coffee'


gulp.task 'default', ->
    gulp.src(SRC_PATH)
        .pipe(coffeelint())
        .pipe(coffeelint.reporter())
        .pipe(coffee({bare: true}).on('error', gutil.log))
        .pipe(gulp.dest('./lib'))


gulp.task 'test', ->
    gulp.src(SRC_TEST_PATH)
        .pipe(coffeelint())
        .pipe(coffeelint.reporter())
        .pipe(nodeunit({reporter: "default"}))


gulp.task 'watch', ->
    gulp.watch SRC_PATH, ['default']
    gulp.watch SRC_TEST_PATH, ['test']