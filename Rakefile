# -*- mode: ruby -*-

task :default => [ :spec ]

task :spec do
  require 'rubygems'
  require 'bundler/setup'
  require 'minitest/autorun'

  $LOAD_PATH << "spec"

  Dir['spec/*_spec.rb'].each { |f| require File.expand_path(f).sub(/.rb$/, '') }
end

# vim: syntax=Ruby
