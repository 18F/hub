require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << '_test'
  t.test_files = FileList['_test/*test.rb']
end

desc "Run HashJoiner tests"
task :default => :test
