module Maven
  module Ruby
    VERSION = '3.0.4.1.3'
    # allow to overwrite the default from maven-tools
    # since jruby-maven-plugins depend on maven-tools and
    # default version in maven-tools is often behind
    JRUBY_MAVEN_PLUGINS_VERSION = '0.29.3'
  end
end
