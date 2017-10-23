module.exports = function(grunt) {
  grunt.initConfig({
    azureDeploy: {
      options: {
        credential_file: process.env['HOME'] + '/.azure/creds.json'
      },
      directory: './',
      website_name: 'cloneCraftApp'
    },
    clean: {
      working: ['./.temp/', './debug/', './dist/']
    },
    coffee: {
      app: {
        cwd: './.temp/',
        src: '**/*.coffee',
        dest: './.temp/',
        expand: true,
        ext: '.js',
        options: {
          sourceMap: true
        }
      },
      debug: {
        cwd: './debug/',
        src: '**/*.coffee',
        dest: './debug/',
        expand: true,
        ext: '.js'
      }
    },
    coffeelint: {
      scripts: './src/scripts/**/*.coffee',
      options: {
        indentation: {
          value: 1
        },
        max_line_length: {
          level: 'ignore'
        },
        no_tabs: {
          level: 'ignore'
        }
      }
    },
    copy: {
      app: {
        files: [
          {
            cwd: './src/',
            src: '**',
            dest: './.temp/',
            expand: true
          }, {
            cwd: './bower_components/angular/',
            src: 'angular.*',
            dest: './.temp/scripts/libs/',
            expand: true
          }, {
            cwd: './bower_components/angular-animate/',
            src: 'angular-animate.*',
            dest: './.temp/scripts/libs/',
            expand: true
          }, {
            cwd: './bower_components/angular-resource/',
            src: 'angular-resource.*',
            dest: './.temp/scripts/libs/',
            expand: true
          }, {
            cwd: './bower_components/angular-route/',
            src: 'angular-route.*',
            dest: './.temp/scripts/libs/',
            expand: true
          }, {
            cwd: './bower_components/bootstrap/less/',
            src: '*',
            dest: './.temp/styles/',
            expand: true
          }, {
            cwd: './bower_components/bootstrap/fonts/',
            src: '*',
            dest: './.temp/fonts/',
            expand: true
          }, {
            cwd: './bower_components/html5shiv/dist/',
            src: 'html5shiv-printshiv.js',
            dest: './.temp/scripts/libs/',
            expand: true
          }, {
            cwd: './bower_components/json3/lib/',
            src: 'json3.min.js',
            dest: './.temp/scripts/libs/',
            expand: true
          }, {
            cwd: './bower_components/requirejs/',
            src: 'require.js',
            dest: './.temp/scripts/libs/',
            expand: true
          }, {
            cwd: './bower_components/angular-socket-io/',
            src: 'socket.js',
            dest: './.temp/scripts/libs/',
            expand: true
          }, {
            cwd: './documentation/images/',
            src: '**',
            dest: './.temp/views/images/',
            expand: true
          }
        ]
      },
      dev: {
        cwd: './.temp/',
        src: '**',
        dest: './dist/',
        expand: true
      },
      debug: {
        files: [
          {
            cwd: './src/',
            src: ['**/*.js', '**/*.coffee'],
            dest: './debug/',
            expand: true
          }, {
            cwd: './server/',
            src: ['**/*.js', '**/*.coffee', '**/*.json'],
            dest: './debug/server/',
            expand: true
          }, {
            cwd: './spec/',
            src: ['**/*.js', '**/*.coffee'],
            dest: './debug/tests/',
            expand: true
          }, {
            cwd: './ShellScripts/',
            src: ['*'],
            dest: './debug/ShellScripts/',
            expand: true
          }
        ]
      },
      fakeProd: {
        files: [
          {
            cwd: './.temp/fonts/',
            src: '**',
            dest: './dist/fonts/',
            expand: true
          }, {
            cwd: './.temp/images/',
            src: '**',
            dest: './dist/images/',
            expand: true
          }, {
            cwd: './.temp/',
            src: ['scripts/ie.min.js', 'scripts/scripts.min.js'],
            dest: './dist/',
            expand: true
          }, {
            cwd: './.temp/',
            src: 'styles/styles.min.css',
            dest: './dist/',
            expand: true
          }, {
            './dist/index.html': './.temp/index.min.html'
          }, {
            cwd: './.temp/views/',
            src: '**',
            dest: './dist/views/',
            expand: true
          }
        ]
      },
      prod: {
        files: [
          {
            cwd: './.temp/fonts/',
            src: '**',
            dest: './dist/fonts/',
            expand: true
          }, {
            cwd: './.temp/images/',
            src: '**',
            dest: './dist/images/',
            expand: true
          }, {
            cwd: './.temp/',
            src: ['scripts/ie.min.*.js', 'scripts/scripts.min.*.js'],
            dest: './dist/',
            expand: true
          }, {
            cwd: './.temp/',
            src: 'styles/styles.min.*.css',
            dest: './dist/',
            expand: true
          }, {
            './dist/index.html': './.temp/index.min.html'
          }, {
            cwd: './.temp/views/',
            src: '**',
            dest: './dist/views/',
            expand: true
          }
        ]
      }
    },
    file_append: {
      default_options: {
        files: {
          './server.js': {
            append: "//"
          }
        }
      }
    },
    hash: {
      images: './.temp/images/**/*',
      scripts: {
        src: ['./.temp/scripts/ie.min.js', './.temp/scripts/scripts.min.js']
      },
      styles: './.temp/styles/styles.min.css'
    },
    jasmine_node: {
      all: {
        options: {
          specNameMatcher: '-spec',
          extensions: 'coffee',
          requirejs: false,
          forceExit: false,
          includeStackTrace: false,
          projectRoot: './debug/tests/'
        }
      },
      game: {
        options: {
          specNameMatcher: '-spec',
          extensions: 'coffee',
          requirejs: false,
          forceExit: false,
          includeStackTrace: false,
          projectRoot: './debug/tests/game-spec/'
        }
      },
      server: {
        options: {
          specNameMatcher: '-spec',
          extensions: 'coffee',
          requirejs: false,
          forceExit: false,
          includeStackTrace: false,
          projectRoot: './debug/tests/server-spec/'
        }
      }
    },
    less: {
      app: {
        files: {
          './.temp/styles/styles.css': './.temp/styles/styles.less'
        }
      }
    },
    markdown: {
      all: {
        files: [
          {
            expand: true,
            src: './documentation/*.md',
            dest: './.temp/views/',
            ext: '.html',
            flatten: true
          }
        ]
      }
    },
    minifyHtml: {
      prod: {
        files: {
          './.temp/index.min.html': './.temp/index.html'
        }
      }
    },
    ngShim: {
      scripts: {
        cwd: './.temp/scripts/',
        angular: 'libs/angular.min.js',
        modules: [
          {
            'ngAnimate': 'libs/angular-animate.min.js',
            'ngResource': 'libs/angular-resource.min.js',
            'ngRoute': 'libs/angular-route.min.js'
          }
        ],
        src: '**/*.coffee',
        dest: 'main.coffee'
      }
    },
    ngTemplateCache: {
      views: {
        files: {
          './.temp/scripts/views.js': './.temp/views/**/*.html'
        },
        options: {
          trim: './.temp'
        }
      }
    },
    open: {
      server: {
        url: 'http://localhost:6108'
      }
    },
    requirejs: {
      scripts: {
        options: {
          baseUrl: './.temp/scripts/',
          findNestedDependencies: true,
          logLevel: 0,
          mainConfigFile: './.temp/scripts/main.js',
          name: 'main',
          onBuildWrite: function(moduleName, path, contents) {
            var modulesToExclude, shouldExcludeModule;
            modulesToExclude = ['main'];
            shouldExcludeModule = modulesToExclude.indexOf(moduleName) >= 0;
            if (shouldExcludeModule) {
              return '';
            }
            return contents;
          },
          optimize: 'uglify2',
          out: './.temp/scripts/scripts.min.js',
          preserveLicenseComments: false,
          skipModuleInsertion: true,
          uglify: {
            no_mangle: false
          },
          useStrict: true,
          wrap: {
            start: '(function(){\'use strict\';',
            end: '}).call(this);'
          }
        }
      },
      styles: {
        options: {
          baseUrl: './.temp/styles/',
          cssIn: './.temp/styles/styles.css',
          logLevel: 0,
          optimizeCss: 'standard',
          out: './.temp/styles/styles.min.css'
        }
      }
    },
    template: {
      indexDev: {
        files: {
          './.temp/index.html': './.temp/index.html'
        }
      },
      index: {
        files: '<%= template.indexDev.files %>',
        environment: 'prod'
      }
    },
    uglify: {
      scripts: {
        files: {
          './.temp/scripts/ie.min.js': ['./.temp/scripts/libs/json3.js', './.temp/scripts/libs/html5shiv-printshiv.js']
        }
      }
    },
    watch: {
      dev: {
        files: ['./documentation/**', './src/index.html', './src/fonts/**', './src/images/**', './src/scripts/**', './src/styles/**', './src/views/**'],
        tasks: ['build']
      },
      run: {
        files: ['./documentation/**', './src/index.html', './src/fonts/**', './src/images/**', './src/scripts/**', './src/styles/**', './src/views/**', './server/**/*.js', './server/**/*.coffee'],
        tasks: ['default']
      },
      server: {
        files: ['./server/**/*.coffee', './server/**/*.js', './spec/**/*.coffee', './spec/**/*.js'],
        tasks: ['test-server']
      },
      game: {
        files: ['./server/**/*.coffee', './server/**/*.js', './spec/**/*.coffee', './spec/**/*.js'],
        tasks: ['test-game']
      },
      none: {
        files: 'none'
      }
    }
  });
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-requirejs');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-hustler');
  grunt.loadNpmTasks('grunt-open');
  grunt.loadNpmTasks('grunt-markdown');
  grunt.loadNpmTasks('grunt-jasmine-node');
  grunt.loadNpmTasks('grunt-file-append');
  grunt.loadNpmTasks('grunt-azure-deploy');
  grunt.loadNpmTasks('load-grunt-tasks')
  grunt.registerTask('launch', 'Start a custom web server', function() {
    return require('./server/server');
  });
  grunt.registerTask('build', ['clean:working', 'coffeelint', 'copy:app', 'ngShim', 'coffee:app', 'less', 'markdown', 'template:indexDev', 'copy:dev']);
  grunt.registerTask('default', ['build']);
  grunt.registerTask('server', ['build', 'launch', 'watch:dev']);
  grunt.registerTask('azure', ['build']);
  grunt.registerTask('test-server', ['clean:working', 'copy:debug', 'coffee:debug', 'jasmine_node:server']);
  grunt.registerTask('watch-server', ['test-server', 'watch:server']);
  grunt.registerTask('test-game', ['clean:working', 'copy:debug', 'coffee:debug', 'jasmine_node:game']);
  grunt.registerTask('watch-game', ['test-game', 'watch:game']);
  grunt.registerTask('test', ['clean:working', 'copy:debug', 'coffee:debug', 'jasmine_node:all']);
  grunt.registerTask('watch-tests', ['test', 'watch:server']);
  return grunt.registerTask('prod', ['clean:working', 'coffeelint', 'copy:app', 'ngShim', 'coffee:app', 'less', 'requirejs', 'uglify', 'template:indexDev', 'copy:fakeProd', 'file_append']);
};