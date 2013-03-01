# -*- mode:ruby -*-

plugin :dependency do  |d|
  d.in_phase('process-sources').execute_goal(:unpack).with :outputAbsoluteArtifactFilename => false, :artifactItems => 
    [ { :groupId => 'org.apache.maven',
        :artifactId => 'apache-maven',
        :version => '${maven.version}',
        :classifier => 'bin',
        :type => 'zip',
        :outputDirectory => '${project.build.directory}' } ]
end # maven-dependency-plugin

plugin :gem do |g|
  g.extensions true

  # TODO really needed ?
  g.in_phase( 'prepare-package' ).execute_goal( :initialize )  

  # copy .pom.xml from ruby-maven
  g.in_phase( :validate ).execute_goal( :pom ).with( :tmpPom => '.pom.xml', :skipGeneration => true )

  g.with :gemspec => 'ruby-maven.gemspec', :includeOpenSSL => true
  g.gem 'thor'#, '0.14.6'
  g.gem 'maven-tools'#, '0.32.1'
end

plugin(:clean, '2.5' ) do |c|
  c.with :filesets =>
    [ { :directory => 'lib',
        :includes => ['*jar', 'ext/**' ] },
      { :directory => 'bin',
        :includes => ['*'],
        :excludes => ['rmvn'] },
      { :directory => './',
        :includes => ['*.txt', 'Gemfile.lock'] } ]
end

build.resources.add do |r|
  r.target_path "${project.basedir}"
  r.directory "${project.build.directory}/apache-maven-${maven.version}"
end

# just lock the versions
properties['jruby.plugins.version'] = '0.29.4'
properties['jruby.version'] = '1.7.2'

# overwrite via cli -Djruby.versions=1.6.7
properties['jruby.versions'] = ['1.5.6','1.6.8','1.7.2'].join(',')
# overwrite via cli -Djruby.use18and19=false
properties['jruby.18and19'] = true

# vim: syntax=Ruby
