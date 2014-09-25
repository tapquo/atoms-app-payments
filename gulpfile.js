"use strict"

// -- DEPENDENCIES -------------------------------------------------------------
var gulp    = require('gulp');
var coffee  = require('gulp-coffee');
var concat  = require('gulp-concat');
var connect = require('gulp-connect');
var header  = require('gulp-header');
var uglify  = require('gulp-uglify');
var gutil   = require('gulp-util');
var stylus  = require('gulp-stylus');
var pkg     = require('./package.json');

// -- FILES --------------------------------------------------------------------
var path = {
  build : './',
  js    : ['atoms.build/atoms.js', 'atoms.build/extension.*.js'],
  css   : ['atoms.build/atoms.css','atoms.build/extension.*.css']};

var source = {
  coffee: [ 'molecules/*.coffee',
            'molecules/*.*.coffee',
            ],
  styl  : [ 'style/*.styl',
            'style/*.*.styl',
          ],

var banner = ['/**',
  ' * <%= pkg.name %> - <%= pkg.description %>',
  ' * @version v<%= pkg.version %>',
  ' * @link    <%= pkg.homepage %>',
  ' * @author  <%= pkg.author.name %> (<%= pkg.author.site %>)',
  ' * @license <%= pkg.license %>',
  ' */',
  ''].join('\n');

// -- TASKS --------------------------------------------------------------------
gulp.task('core', function() {
  gulp.src(path.js)
    .pipe(concat('atoms.js'))
    .pipe(gulp.dest(path.build + '/js'));

  gulp.src(path.css)
    .pipe(concat('atoms.css'))
    .pipe(gulp.dest(path.build + '/css'));
});

gulp.task('coffee', function() {
  gulp.src(source.coffee)
    .pipe(concat('atoms.' + pkg.name + '.coffee'))
    .pipe(coffee().on('error', gutil.log))
    .pipe(uglify({mangle: false}))
    .pipe(header(banner, {pkg: pkg}))
    .pipe(gulp.dest(path.build + '/js'))
    .pipe(connect.reload());
});

gulp.task('styl', function() {
  gulp.src(source.styl)
    .pipe(concat('atoms.' + pkg.name + '.styl'))
    .pipe(stylus({compress: true, errors: true}))
    .pipe(header(banner, {pkg: pkg}))
    .pipe(gulp.dest(path.build + '/css'))
    .pipe(connect.reload());
});

gulp.task('init', function() {
  gulp.run(['coffee', 'styl'])
});

gulp.task('default', function() {
  gulp.run(['webserver'])
  gulp.watch(source.coffee, ['coffee']);
  gulp.watch(source.styl, ['styl']);
});