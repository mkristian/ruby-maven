require 'fileutils'
require 'ruby-maven'
module Maven
  class CucumberSteps

    def initialize(options = {})
      @options = {:ruby_version => RUBY_VERSION }
      @options[:jruby_version] = JRUBY_VERSION if defined? JRUBY_VERSION
        
      @options.merge!(options || {})
    end

    def rmvn
      @rmvn ||= Maven::RubyMaven.new
    end

    def copy_tests(tests)
      FileUtils.mkdir_p(@app_directory)
      FileUtils.cp_r(File.join('templates', "tests-#{tests}", "."), 
                     File.join(@app_directory, 'test'),
                     :remove_destination => true)
    end

    def copy_specs(specs)
      FileUtils.mkdir_p(@app_directory)
      FileUtils.cp_r(File.join('templates', "specs-#{specs}", "."), 
                     File.join(@app_directory, 'spec'),
                     :remove_destination => true)
    end

    def copy_files(files)
      FileUtils.mkdir_p(@app_directory)
      FileUtils.cp_r(File.join('templates', "files-#{files}", "."), 
                     @app_directory,
                     :remove_destination => true)
    end

    def create_rails_application(template)
      name = template.sub(/.template$/, '')
      @app_directory = File.join('target', name)
      
      # rails version from gemspec
      gemspec = File.read(Dir.glob("*.gemspec")[0])
      rails_version = gemspec.split("\n").detect { |l| l =~ /development_dep.*rails/ }.sub(/'$/, '').sub(/.*'/, '')
      
      rmvn.options['-Dplugin.version'] = @options[:plugin_version] if @options[:plugin_version]
      rmvn.options['-Djruby.version'] = @options[:jruby_version] if @options[:jruby_version]
       if @options[:ruby_version]
         rversion = @options[:ruby_version] =~ /^1.8./ ? '--1.8': '--1.9'
         rmvn.options['-Djruby.switches'] = rversion
       end
      
      rmvn.options['-Drails.version'] = rails_version
      rmvn.options['-Dgem.home'] = ENV['GEM_HOME']
      rmvn.options['-Dgem.path'] = ENV['GEM_PATH']
      rmvn.options['-o'] = nil
      
      FileUtils.rm_rf(@app_directory)
      
      template_file = File.expand_path("templates/#{template}")
      rmvn.exec("rails", "new", @app_directory, "-f", '--', '-e', "-Dtemplate=#{template_file}")
    end

    def given_template(template)
      create_rails_application(template)
    end

    def given_template_and_tests(template, tests)
      create_rails_application(template)
      copy_tests(tests)
    end

    def given_template_and_specs(template, specs)
      create_rails_application(template)
      copy_specs(specs)
    end

    def given_template_and_files(template, files)
      create_rails_application(template)
      copy_files(files)
    end

    def given_application(name)
      @app_directory = File.join('target', name)
    end

    def given_application_and_tests(name, tests)
      @app_directory = File.join('target', name)
      copy_tests(tests)
    end

    def given_application_and_specs(name, specs)
      @app_directory = File.join('target', name)
      copy_specs(specs)
    end

    def given_application_and_files(name, files)
      @app_directory = File.join('target', name)
      copy_files(files)
    end

    def execute(args)
      rmvn.options['-l'] = "output.log"
      rmvn.exec_in(@app_directory, args.split(' '))
    end
      
    def expected_output(expected)
      result = File.read(File.join(@app_directory, "output.log"))
      expected.split(/\"?\s+and\s+\"?/).each do |exp|
        puts exp
        yield(result =~ /.*#{exp}.*/)
      end 
    end
  end
end


steps = Maven::CucumberSteps.new(:plugin_version => '0.28.5-SNAPSHOT')

Given /^I create new rails application with template "(.*)"$/ do |template|
  steps.given_template(template)
end

Given /^I create new rails application with template "(.*)" and "(.*)" tests$/ do |template, tests|
  steps.given_template_and_tests(template, tests)
end

Given /^I create new rails application with template "(.*)" and "(.*)" specs$/ do |template, specs|
  steps.given_template_and_specs(template, specs)
end

Given /^I create new rails application with template "(.*)" and "(.*)" files$/ do |template, files|
  steps.given_template_and_files(template, files)
end

Given /^me an existing rails application "(.*)"$/ do |name|
  steps.given_application(name)
end

Given /^me an existing rails application "(.*)" and "(.*)" tests$/ do |name, tests|
  steps.given_application_and_tests(name, tests)
end

Given /^me an existing rails application "(.*)" and "(.*)" specs$/ do |name, specs|
  steps.given_application_and_specs(name, specs)
end

Given /^me an existing rails application "(.*)" and "(.*)" files$/ do |name, files|
  steps.given_application_and_files(name, files)
end

And /^I execute \"(.*)\"$/ do |args|
  steps.execute(args)
end

Then /^the output should contain \"(.*)\"$/ do |expected|
  steps.expected_output(expected) do |exp|
    exp.should_not be_nil
  end
end

