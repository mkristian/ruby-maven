require 'fileutils'
require 'java' if defined? JRUBY_VERSION

module Maven
  module Ruby
    class Maven

      private

      def launch_jruby(args)
        java.lang.System.setProperty("classworlds.conf", 
                                     File.join(self.class.maven_home, 'bin', "m2.conf"))

        java.lang.System.setProperty("maven.home", self.class.maven_home)

        cw = self.class.class_world
        org.apache.maven.cli.MavenCli.doMain( args, cw ) == 0
      end

      def self.class_world
        @class_world ||= class_world!
      end

      def self.class_world!
        (classpath_array + classpath_array('lib')).each do |path|
          require path
        end
        org.codehaus.plexus.classworlds.ClassWorld.new("plexus.core", java.lang.Thread.currentThread().getContextClassLoader())
      end
      
      def self.classpath_array(dir = 'boot')
        Dir.glob(File.join(maven_home, dir, "*jar"))
      end
      
      def launch_java(*args)
        system "java -cp #{self.class.classpath_array.join(':')} -Dmaven.home=#{File.expand_path(self.class.maven_home)} -Dclassworlds.conf=#{File.expand_path(File.join(self.class.maven_home, 'bin', 'm2.conf'))} org.codehaus.plexus.classworlds.launcher.Launcher #{args.join ' '}"
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

      def self.class_world
        @class_world ||= class_world!
      end

      def self.maven_home
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
