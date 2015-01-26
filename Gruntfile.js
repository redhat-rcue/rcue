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
    jekyll: {
      options: {
        src: 'components/patternfly/tests-src'
      },
      tests: {
        options: {
          config: '_config.yml',
          dest: 'tests'
        }
      }
    },
    less: {
      development: {
        files: {
          "dist/css/rcue.css": "less/rcue.less",
          "components/patternfly/tests-src/_includes/login-standalone.css": "less/login-standalone.less",
          "components/patternfly/tests-src/_includes/login-standalone-origin.css": "less/login-standalone-origin.less"
        },
        options: {
          paths: ["less/"]
        }
      },
      production: {
        files: {
          "dist/css/rcue.min.css": "less/rcue.less",
          "components/patternfly/tests-src/_includes/login-standalone.min.css": "less/login-standalone.less",
          "components/patternfly/tests-src/_includes/login-standalone-origin.min.css": "less/login-standalone-origin.less"
        },
        options: {
          cleancss: true,
          paths: ["less/"]
        }
      }
    },
    watch: {
      css: {
        files: 'less/*.less',
        tasks: ['less'],
      },
      jekyll: {
        files: ['_config.yml', 'components/patternfly/tests-src/**/*'],
        tasks: ['jekyll']
      },
      livereload: {
        files: [
          'dist/css/*.css',
          'tests/*.html'
        ]
      },
      options: {
        livereload: 35730
      }
    }
  });

  grunt.registerTask('build', [
    'jekyll',
    'less'
  ]);

  grunt.registerTask('server', [
    'connect:server',
    'watch'
  ]);

  grunt.registerTask('default', ['build']);
};
