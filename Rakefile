require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << '_test'
  t.test_files = FileList['_test/*test.rb']
end

desc "Run HashJoiner tests"
task :default => :test

check_yml = Gem::Specification.find_by_name 'about_yml'
load "#{check_yml.gem_dir}/lib/about_yml/tasks/check_about_yml.rake"
