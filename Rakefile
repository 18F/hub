require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << '_test'
  t.test_files = FileList['_test/*test.rb']
end

base = File.dirname __FILE__
ENV['TEST_DATADIR'] = File.join(base, '_test', 'data')
ENV['TEST_TMPDIR'] = File.join(base, '_test', 'tmp')
system "/bin/rm -rf #{ENV['TEST_TMPDIR']}/*"
Dir.mkdir ENV['TEST_TMPDIR'] unless File.exists? ENV['TEST_TMPDIR']

desc "Run HashJoiner tests"
task :default => :test
