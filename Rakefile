require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << '_test'
  t.test_files = FileList['_test/*test.rb']
end

desc "Run HashJoiner tests"
task :default => :test

# https://github.com/jasmine/jasmine-gem#configuration
ENV['JASMINE_CONFIG_PATH'] = '_test/javascripts/support/jasmine.yml'
require 'jasmine'
load 'jasmine/tasks/jasmine.rake'
