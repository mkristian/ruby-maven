require 'fileutils'
require 'maven/tools/rails_project'

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
          gemfiles = Dir[File.join(dir, "*Gemfile")]
          gemfiles.delete_if {|g| g =~ /.pom/}
          if gemfiles.size > 0
            proj =
              if File.exists? File.join( dir, 'config', 'application.rb' )
                new_rails_project
              else
                ::Maven::Tools::GemProject.new
              end
            filename = gemfiles[0]
            proj.load_gemfile(filename)
          else
            gemspecs = Dir[File.join(dir, "*.gemspec")]
            gemspecs.delete_if {|g| g =~ /.pom/}
            if gemspecs.size > 0
              proj = ::Maven::Tools::GemProject.new
              filename = gemspecs[0]
              proj.load_gemspec(filename)
            end
          end
        end
        if proj
          proj.load_jarfile(File.join(File.dirname(filename), 'Jarfile'))
          proj.load_gemfile(File.join(File.dirname(filename), 'Mavenfile'))
          proj.add_defaults
          File.open(pom_xml(dir), 'w') do |f|
            f.puts proj.to_xml
          end
          pom_xml(dir)
        end
      end

      def dump_pom(dir = '.', force = false, file = 'pom.xml')
        if force || !File.exists?(file)
          FileUtils.cp(generate_pom(dir), file)
        end
      end
    end
  end
end
