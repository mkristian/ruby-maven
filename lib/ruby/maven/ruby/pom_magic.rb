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
      
      def initialize( default_pom = '.pom.xml' )
        @default_pom = default_pom
      end

      def dump_pom( dir = '.', force = false, file = 'pom.xml' )
        if force || !File.exists?( file )
          generate_pom( dir, '--pom', file )
        end
      end

      def generate_pom( dir = '.', *args )
        dir = File.expand_path( dir )
        Dir.chdir(dir) do
          skip_some_files = false
          if index = (args.index("-f") || args.index("--file"))
            filename = args[index + 1]
            if filename =~ /.gemspec$/
              skip_some_files = true
              proj = ::Maven::Tools::GemProject.new
              proj.load_gemspec(filename)
            elsif filename =~ /Gemfile/
              skip_some_files = true
              proj = ::Maven::Tools::GemProject.new
              proj.load_gemfile(filename)
            end
          else
            proj =
              if File.exists? File.join( 'config', 'application.rb' )
                ::Maven::Tools::RailsProject.new
              else
                ::Maven::Tools::GemProject.new
              end
          end
          if proj

            ensure_mavenfile( dir )

            load_standard_files( dir, proj, skip_some_files )

            pom_xml( dir, proj, args )

          end
        end
      end

      protected

      def load_standard_files( dir, proj, skip_some_files = false )
        gemspec = first_gemspec( dir ) unless skip_some_files
        proj.load_gemspec( gemspec ) if gemspec
        proj.load_gemfile( file( 'Gemfile', dir ) ) unless skip_some_files
        proj.load_jarfile( file( 'Jarfile', dir ) )
        proj.load_mavenfile( file( 'Mavenfile', dir ) )
        proj.add_defaults
      end

      def ensure_mavenfile( dir, source = File.dirname( __FILE__ ), filter_map = {} )
        mavenfile = File.join( dir, 'Mavenfile' )
        unless File.exists?( mavenfile )
          content = File.read( File.join( source, 'Mavenfile' ) )
          File.open( mavenfile, 'w' ) do |f|
            filter_map.each do |k,v|
              content.gsub!( /#{k}/, v )
            end
            f.puts content
          end
          warn "created Mavenfile with some locked down versions."
        end
      end

      def file( name, dir = '.' )
        File.expand_path( File.join( dir, name ) )
      end

      def pom_xml( dir, proj, args )
        dir ||= '.'
        #index = args.index( '-f' ) || args.index( '--file' )
        index = args.index( '--pom' )
        name = args[ index + 1 ] if index
        pom = File.join( dir, name || @default_pom )
        File.open(pom, 'w') do |f|
          f.puts proj.to_xml
        end
        f_index = args.index( '-f' ) || args.index( '--file' )
        if f_index
          args[ f_index + 1 ] = pom
        elsif index
          args[ index ] = '-f'
        else
          args += ['-f', pom]
        end
        args
      end

      def first_gemspec( dir = '.' )
        gemspecs = Dir[ File.join( dir, "*.gemspec" ) ]
        if gemspecs.size > 0
          File.expand_path( gemspecs[ 0 ] )
        end
      end

    end
  end
end
