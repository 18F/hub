# Builds the Hub in a temp directory for use by several tests.
#
# Just adding `require_relative 'site_builder'` at the beginning of the test
# file is all that's required.
module Hub
  class SiteBuilder
    BUILD_DIR = File.join(Dir.pwd, '_test', 'tmp')
    unless system(
      "bundle exec jekyll build --destination #{BUILD_DIR} --trace",
      {:out => '/dev/null', :err =>STDERR})
      STDERR.puts "\n***\nSite failed to build for pages_api_test\n***\n"
      exit $?.exitstatus
    end
  end
end
