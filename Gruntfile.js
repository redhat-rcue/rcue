/*global module,require*/
var lrSnippet = require('connect-livereload')({
    port: 35730
});
var mountFolder = function (connect, dir) {
    return connect.static(require('path').resolve(dir));
};

module.exports = function (grunt) {
    // load all grunt tasks
    require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

    // configurable paths
    var projectConfig = {
        dist: 'dist',
        src: ''
    };

    try {
        projectConfig.src = require('./bower.json').appPath || projectConfig.src;
    } catch (e) {}

    grunt.initConfig({
        clean: {
            build: '<%= config.dist %>'
        },
        config: projectConfig,
        connect: {
            server: {
                options: {
                    hostname: '0.0.0.0',
                    middleware: function (connect) {
                        return [
                            lrSnippet,
                            mountFolder(connect, projectConfig.src),
                            mountFolder(connect, projectConfig.src + 'tests')
                        ];
                    },
                    port: 9001
                }
            }
        },
        less: {
            development: {
                files: {
                    "dist/css/rcue.css": "less/rcue.less"
                },
                options: {
                    paths: ["less/"]
                }
            },
            production: {
                files: {
                    "dist/css/rcue.min.css": "less/rcue.less"
                },
                options: {
                    cleancss: true,
                    paths: ["less/"]
                }
            }
        },
        uglify: {
          options: {
            mangle: false
          },
          production: {
            files: {
              'dist/js/launcher.min.js': ['dist/js/launcher.js']
            }
          }
        },
        watch: {
            css: {
                files: 'less/*.less',
                tasks: ['less']
            },
            js: {
                files: ['dist/js/*.js', '!dist/js/*.min.js'],
                tasks: ['uglify']
            },
            livereload: {
                files: [
                    'dist/css/*.css',
                    'dist/js/*.js',
                    'tests/*.html'
                ]
            },
            options: {
                livereload: 35730
            }
        }
    });

    grunt.registerTask('build', [
        'less',
        'uglify'
    ]);

    grunt.registerTask('server', [
        'connect:server',
        'watch'
    ]);

    grunt.registerTask('default', ['build']);
};
