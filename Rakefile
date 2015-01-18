require 'rake/testtask'
require 'test_temp_file_helper/rake'

Rake::TestTask.new do |t|
  t.libs << '_test'
  t.test_files = FileList['_test/*test.rb']
end

TestTempFileHelper::SetupTestEnvironmentTask.new do |t|
  t.base_dir = File.dirname __FILE__
  t.tmp_dir = File.join '_test', 'tmp'
end

desc "Run HashJoiner tests"
task :default => :test
