#! /usr/bin/env ruby
#
# Imports data from _data/private into _data/public.
#
# Expects to be run directly within the _data directory with the _data/private
# submodule present. All 'private:' data is stripped from the _data/private
# files before it is dumped into _data/public.
#
# Author: Mike Bland (michael.bland@gsa.gov)
# Date:   2014-12-22

require 'csv'
require 'hash-joiner'
require 'jekyll'
require 'jekyll/site'
require 'safe_yaml'

require_relative '../_plugins/joiner.rb'

Dir.mkdir('public') unless Dir.exists? 'public'

YAML_FILES = [
  'departments.yml',
  'projects.yml',
  'team.yml',
  'working_groups.yml',
]

YAML_FILES.each do |yaml_file|
  source = File.join('private', yaml_file)
  data = SafeYAML.load_file(source, :safe=>true)
  unless data
    puts "Failed to parse #{source}"
    exit 1
  end

  target = File.join('public', yaml_file)
  data = HashJoiner.remove_data data, 'private'
  puts "#{source} => #{target}"
  open(target, 'w') {|outfile| outfile.puts data.to_yaml}
end

site = ::Jekyll::Site.new ::Jekyll::Configuration::DEFAULTS
site.read_data('.')
joiner_impl = ::Hub::JoinerImpl.new site

snippet_dir = 'private'
target_dir = 'public'
['snippets', 'v3'].each do |subdir|
  snippet_dir = File.join(snippet_dir, subdir)
  target_dir = File.join(target_dir, subdir)
  Dir.mkdir(target_dir) unless Dir.exists? target_dir
end

Dir.foreach(snippet_dir) do |snippets|
  next if ['.', '..'].include? snippets
  source = File.join(snippet_dir, snippets)
  target = File.join('public', 'snippets', 'v3', snippets)
  puts "#{source} => #{target}"

  CSV.open(target, 'w') do |outfile|
    CSV.foreach(source) do |row|
      # Skip header row and private snippets.
      if row[0] == 'Timestamp'
        outfile << row
        next
      end
      next unless row[1] == 'Public'
      row[2] = joiner_impl.team_by_email[row[2]]

      # Redact "Last week" and "This week" items
      [row[3], row[4]].each do |section|
        next unless section
        section.gsub!(/\n?\{\{.*?\}\}/m,'')
        section.gsub!(/^\n\n+/m, '')
      end
      outfile << row
    end
  end
end
