# prerequisites #

* ruby 1.8.7 + rubygems

* jruby >1.5.x

# installation

    gem install ruby-maven

or
    jgem install ruby-maven
    
MRI performs much better due to the fast startup of the interpreter.

# rmvn command

that is basically a proper maven with a ruby launcher. on top of it can use a gemspec file or a Gemfile as POM. originally the idea of non-xml POMs is coming from [http://github.com/sonatype/polyglot-maven](http://github.com/sonatype/polyglot-maven). see [https://github.com/sonatype/polyglot-maven/tree/master/pmaven-jruby](https://github.com/sonatype/polyglot-maven/tree/master/pmaven-jruby) for more details about the ruby DSL, etc

# jetty-run command

just starts a jetty server inside a rails application if the Gemfile is suitable for jruby and suitable for maven (gems prereleased version are still a problem). if the Gemfile is suitable then just execute

$ jetty-run

and you will get an http port on 8080 and an https port on 8443 with selfsigned certifacte for localhost.

# gwt command

this is a helper which allows to setup a rails application with a GWT UI and helps to run some gwt specific commands.

see [http://github.com/mkristian/rails-resty-gwt](http://github.com/mkristian/rails-resty-gwt) for more details.
