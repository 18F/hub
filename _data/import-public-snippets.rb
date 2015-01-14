#! /usr/bin/env ruby
#
# 18F Hub - Docs & connections between team members, projects, and skill sets
#
# Written in 2014 by Mike Bland (michael.bland@gsa.gov)
# on behalf of the 18F team, part of the US General Services Administration:
# https://18f.gsa.gov/
#
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication along
# with this software. If not, see
# <https://creativecommons.org/publicdomain/zero/1.0/>.
#
# ---
#
# Imports snippet data from _data/private into _data/public.
#
# Expects to be run directly within the _data directory with the _data/private
# submodule present.
#
# @author Mike Bland (michael.bland@gsa.gov)
# Date:   2014-12-22

require 'csv'
require 'jekyll'
require 'jekyll/site'
require 'weekly_snippets/publisher'
require 'weekly_snippets/version'

require_relative '../_plugins/joiner.rb'

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
    data = CSV.read(source, :headers => true).map(&:to_hash)
    outfile << data.first.keys

    publisher = ::WeeklySnippets::Publisher.new(
      headline: 'unused', public_mode: true)
    data.each do |snippet|
      if snippet['Public']
        snippet['Username'] = joiner_impl.team_by_email[snippet['Username']]
        publisher.redact!(snippet['Last week'] || '')
        publisher.redact!(snippet['This week'] || '')
        outfile << snippet.values
      end
    end
  end
end
