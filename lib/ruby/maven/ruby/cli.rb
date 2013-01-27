#
# Copyright (C) 2013 mkristian
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
require 'maven/ruby/maven'
require 'maven/ruby/pom_magic'
module Maven
  module Ruby
    class Cli

      private

      # make the command line for the goals of the jruby-maven-plugins nicer
      PLUGINS = {
        :rake => [:rake],
        :jruby => [:jruby, :compile],
        :gem => [:package, :install, :push, :exec, :pom, :initialize, :irb],
        :rails3 => [:new, :generate, :rake, :server, :console, :dbconsole, :pom, :initialize],
        :cucumber => [:test],
        :rspec => [:test],
        :runit => [:test],
        :mini => [:test,:spec],
        :bundler => [:install, :update]
      }
      ALIASES = {
        :ruby => :jruby, 
        :spec => :rspec, 
        :rails => :rails3, 
        :bundle => :bundler
      }

      def prepare(args)
        if args.size > 0 
          name = args[0].to_sym
          name = ALIASES[name] || name
          if PLUGINS.member?(name)
            start = 1
            if args.size > 1
              if PLUGINS[name].member? args[1].to_sym
                goal = args[1].to_sym
                start = 2
              else
                goal = PLUGINS[name][0]
              end
            else
              goal = PLUGINS[name][0]
            end
            # determine the version and delete from args if given
            version = args.detect do |a|
              a =~ /^-Dplugin.version=/
            end
            version ||= options['-Dplugin.version']

            if version
              args.delete(version)
              version = ":" + version.sub(/^-Dplugin.version=/, '')
            end
            aa = if index = args.index("--")
                   args[(index + 1)..-1]
                 else
                   []
                 end
            ruby_args = (args[start, (index || 1000) - start] || []).join(' ')

            aa << "de.saumya.mojo:#{name}-maven-plugin#{version}:#{goal}"
            aa << "\"-Dargs=#{ruby_args}\"" if ruby_args.size > 0
            args.replace(aa)
          else
            args.delete("--")
          end
        end
        args
      end

      def log(args)
        log = File.join('log', 'rmvn.log')
        if File.exists? File.dirname(log)
          File.open(log, 'a') do |f|
            f.puts "#{$0.sub(/.*\//, '')} #{args.join ' '}"
          end
        end
      end

      def maybe_print_help(args)
        if args.size == 0 || args[0] == "--help"
          puts "ruby-maven version #{VERSION} using jruby-maven-plugins version #{JRUBY_MAVEN_PLUGINS_VERSION}"
          puts "usage: rmvn [<plugin-name> [<args>] [-- <maven-options>]] | [<maven-goal>|<maven-phase> <maven-options>] | --help"
          PLUGINS.each do |name, goals|
            puts
            print "plugin #{name}"
            print " - alias: #{ALIASES.invert[name]}" if ALIASES.invert[name]
            puts
            if goals.size > 1
              print "\tgoals       : #{goals.join(',')}"
              puts
            end
            print "\tdefault goal: #{goals[0]}"
            puts
          end
          puts
          ["--help"]
        else
          args
        end
      end

      def command_line(args)
        args = prepare(args)
        args = maybe_print_help(args)
        args
      end

      def setup(dir = '.', *args)
        log(args)
        args = command_line(args.dup.flatten)
        args = magic_pom(dir, *args) unless options.delete('--no-pom')
        args
      end

      def mvn
        @mvn ||= Maven.new 
      end

      protected
      
      def magic_pom(dir = '.', *args)
        file = PomMagic.new.generate_pom(File.expand_path(dir), *args)
        args += ['-f', file] if file && !(args.member?("-f") || args.member?("--file"))  
        args.flatten     
      end

      public

      def options
        mvn.options
      end

      def exec(*args)
        mvn.exec(setup('.', *args))
      end

      def exec_in(launchdirectory, *args)
        mvn.exec_in(launchdirectory, setup(launchdirectory, *args))
      end
    end
  end
end