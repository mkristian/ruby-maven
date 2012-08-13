# ruby maven [![Build Status](https://secure.travis-ci.org/mkristian/ruby-maven.png)](http://travis-ci.org/mkristian/ruby-maven) #

once installed it is a fully functional maven installaton with *rmvn* as command.

it also provides an easy way to embed maven with your ruby scripts

    require 'maven/ruby/maven'
	mvn = Maven::Ruby::Maven.new
    mvn.exec( 'install', '-f' 'my-pom.xml' )

in case if JRuby it will run within the same JVM otherwise it will launch java. so you need java installed in any case.

ruby-maven also understands how to use a gemspec file or Gemfile/Jarfile from (J)Bundler as DSL:some magc creates a .pom.xml which is used to run maven.

## rails magic

for a rails application the magic knows how to pack war file of the rails-application
   
    rmvn package -Pproduction

now you can run your war-file with a servlet engine. for example using jetty-run gem:

    jetty-run war my.war

## executable jar

for gem project to build an executable single jar with all the classes including jruby itself and all the gems declared. it also packs all the files from the *bin* directory as well the executable from your embedded gems.

    rmvn package -Pexecutable

now you can start your jar with
   
    java -jar my.jar my_command

## installation

    gem install ruby-maven

or with jruby

    jgem install ruby-maven
    
MRI performs much better due to the fast startup of the interpreter.

## build the gem and run specs

to build the gem you need [http://maven.apache.org](maven)

    mvn package
	
will create the gem in _target_ directory.

to run the specs it is sufficient to run

    mvn process-resources
	
to get all the files for the gem in place (downloaded via maven). now

    rake
	
or

    jruby -S rake

will run the specs.

## hacking

the directory layout uses the one which comes from maven itself and thus the ruby code is located under **lib/ruby**.

## DSL

`rmvn` magic obeys following files

* <name>.gemspec which provides project metadata as well gem dependencies and jar dependencies (via the `requirements` array of the gemspec)
* Gemfile,Gemfile.lock provides gem dependencies [bundler](http://gembundler.com/)
* Jarfile,Jarfile.lock provides jar dependencies [jbundler](https://github.com/mkristian/jbundler) (using maven-tools gem)
* Mvnfile is ruby [DSL](https://github.com/torquebox/maven-tools/wiki/DSL) as replacement for pom.xml (using maven-tools gem)
* any jar dependencies in the gemspec `requirements` of any gem is honourede#
rts and pull request are most welcome.

# meta-fu #

bug-reports and pull request are most welcome.


