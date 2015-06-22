module.exports = function(grunt){
	require('jit-grunt')(grunt);

	grunt.initConfig({
		less:{
			developement: {
				options: {
					compress: true,
					yuicompress: true,
					optimization: 2
				},
				files:{
					"css/main.css": "less/main.less" // destination file and source file
				}
			}
		},

		watch: {
			files: ['less/**/*.less'], // which files to watch
			tasks: ['less', 'watch'],
			options: {
				nospawn: true
			}
		}
	});

	grunt.loadNpmTasks('grunt-nodemon');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.registerTask('default', ['less', 'watch']);

};