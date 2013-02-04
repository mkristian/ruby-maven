#
# Copyright (C) 2013 Christian Meier
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
require 'fileutils'
require 'maven/tools/rails_project'
require 'maven/ruby/version'

module Maven
  module Ruby
    class PomMagic

      def initialize(pom = '.pom.xml')
        @pom = pom
      end

      def new_rails_project
        ::Maven::Tools::RailsProject.new
      end

      def pom_xml(dir = '.')
        File.join(dir, @pom)
      end

      def generate_pom(dir = '.', *args)
        pom = nil
        dir = File.expand_path( dir )
        Dir.chdir(dir) do
          if index = (args.index("-f") || args.index("--file"))
            filename = args[index + 1]
            if filename =~ /.gemspec$/
              proj = ::Maven::Tools::GemProject.new
              proj.load_gemspec(filename)
            elsif filename =~ /Gemfile/
              proj = ::Maven::Tools::GemProject.new
              proj.load_gemfile(filename)
            end
          else
            gemfiles = Dir[File.join('.', "*Gemfile")]
            gemfiles.delete_if {|g| g =~ /.pom/}
            if gemfiles.size > 0
              proj =
                if File.exists? File.join( 'config', 'application.rb' )
                  new_rails_project
                else
                  ::Maven::Tools::GemProject.new
                end
              filename = gemfiles[0]
              proj.load_gemfile(filename)
            else
              gemspecs = Dir[File.join('.', "*.gemspec")]
              gemspecs.delete_if {|g| g =~ /.pom/}
              if gemspecs.size > 0
                proj = ::Maven::Tools::GemProject.new
                filename = File.basename(gemspecs[0])
                proj.load_gemspec(filename)
              end
            end
          end
          if proj
            proj.load_jarfile(File.join(File.dirname(filename), 'Jarfile'))
            proj.load_gemfile(File.join(File.dirname(filename), 'Mavenfile'))
            proj.add_defaults( :jruby_plugins => JRUBY_MAVEN_PLUGINS_VERSION )
            pom = pom_xml(dir)
            File.open(pom, 'w') do |f|
              f.puts proj.to_xml
            end
          end
        end
        pom
      end

      def dump_pom(dir = '.', force = false, file = 'pom.xml')
        if force || !File.exists?(file)
          FileUtils.cp(generate_pom(dir), file)
        end
      end
    end
  end
end