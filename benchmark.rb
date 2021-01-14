#!/usr/bin/env ruby

require 'bundler/setup'
require 'cvelist/repository'
require 'json'
require 'benchmark'

CVELIST = ENV.fetch('CVELIST',File.join(Gem.user_home,'src','cvelist'))

repo = if File.directory?(CVELIST)
         CVEList::Repository.new(CVELIST)
       else
         puts "Cloning #{CVEList::Repository::URL} into #{CVELIST} ..."
         CVEList::Repository.clone(CVELIST)
       end

begin
  n = repo.total_cves

  puts "Warming up the disk cache with a first run. This may take a while ..."
  repo.each do |cve|
    # no-op
  end

  puts "Parsing all #{n} CVE .json files ..."

  results = Benchmark.measure do
    repo.each do |cve|
      # no-op
    end
  end

  puts
  puts "Total:\t#{results}"
  puts "Avg:\t#{results / n}"
rescue Interrupt
  exit 130
end
