require 'fileutils'

module Maven
  module Ruby
    class PomMagic

      def new_rails_project
        Maven::Tools::RailsProject.new
      end

      def pom_xml
        ".pom.xml"
      end

      def generate_pom(*args)
        unless args.member?("-f") || args.member?("--file")
          gemfiles = Dir["*Gemfile"]
          gemfiles.delete_if {|g| g =~ /.pom/}
          if gemfiles.size > 0
            proj =
              if File.exists? File.join( 'config', 'application.rb' )
                new_rails_project
              else
                Maven::Tools::GemProject.new
              end
            filename = gemfiles[0]
            proj.load_gemfile(filename)
          else
            gemspecs = Dir["*.gemspec"]
            gemspecs.delete_if {|g| g =~ /.pom/}
            if gemspecs.size > 0
              proj = Maven::Tools::GemProject.new
              filename = gemspecs[0]
              proj.load_gemspec(filename)
            end
          end
          if proc
            proj.load_jarfile(File.join(File.dirname(filename), 'Jarfile'))
            proj.load_gemfile(File.join(File.dirname(filename), 'Mavenfile'))
            proj.add_defaults
            File.open(pom_xml, 'w') do |f|
              f.puts proj.to_xml
            end
            args << '-f'
            args << pom_xml
          end
        end
        args
      end

      def dump_pom(force = false, file = 'pom.xml')
        if force || !File.exists?(file)
          generate_pom
          FileUtils.cp(pom_xml, file)
        end
      end
    end
  end
end
