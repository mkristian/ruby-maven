# -*- mode: ruby -*-

task :default => [ :spec ]

task :spec do
  require 'minitest/autorun'

  $LOAD_PATH << "spec"

  Dir['spec/*_spec.rb'].each { |f| require File.expand_path(f).sub(/.rb$/, '') }
end

task :headers do
  require 'copyright_header'

  s = Gem::Specification.load( Dir["*gemspec"].first )

  args = {
    :license => 'MIT', 
    :copyright_software => s.name,
    :copyright_software_description => s.description,
    :copyright_holders => s.authors,
    :copyright_years => [Time.now.year],
    :add_path => "lib/ruby",
    :output_dir => './'
  }

  command_line = CopyrightHeader::CommandLine.new( args )
  command_line.execute
end

# vim: syntax=Ruby
