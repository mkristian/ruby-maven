require 'fileutils'
require 'java' if defined? JRUBY_VERSION

module Maven
  module Ruby
    class Maven

      private

      def launch_jruby(args)
        classpath_array.each do |path|
          require path
        end

        java.lang.System.setProperty("classworlds.conf", 
                                     File.join(@maven_home, 'bin', "m2.conf"))

        java.lang.System.setProperty("maven.home", @maven_home)

        org.codehaus.plexus.classworlds.launcher.Launcher.main(args)
      end

      def classpath_array
        Dir.glob(File.join(@maven_home, "boot", "*jar"))
      end
      
      def launch_java(*args)
        system "java -cp #{classpath_array.join(':')} -Dmaven.home=#{File.expand_path(@maven_home)} -Dclassworlds.conf=#{File.expand_path(File.join(@maven_home, 'bin', 'm2.conf'))} org.codehaus.plexus.classworlds.launcher.Launcher #{args.join ' '}"
      end
      
      def options_string
        options_array.join ' '
      end
      
      def options_array
        options.collect do |k,v|
          if k =~ /^-D/
            v = "=#{v}" unless v.nil?
          else
            v = " #{v}" unless v.nil?
          end
          "#{k}#{v}"
        end
      end

      public

      def maven_home
        @maven_home = File.expand_path(File.join(File.dirname(__FILE__),
                                                 '..',
                                                 '..',
                                                 '..',
                                                 '..'))
      end

      def options
        @options ||= {}
      end

      def verbose= v
        @verbose = v
      end

      def property(key, value = nil)
        options["-D#{key}"] = value
      end

      def verbose
        if @verbose.nil?
          options.delete('--verbose').to_s == 'true'
        else
          @verbose
        end
      end

      def exec(*args)
        a = args.dup + options_array
        a.flatten!
        puts "mvn #{a.join(' ')}" if verbose
        if defined? JRUBY_VERSION
          launch_jruby(a)
        else
          launch_java(a)
        end
      end

      def exec_in(launchdirectory, *args)
        succeeded = nil
        FileUtils.cd(launchdirectory) do
          succeeded = exec(args)
        end
        succeeded
      end
    end
  end
end
