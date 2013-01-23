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
  g.in_phase('prepare-package').execute_goal(:initialize)
  g.with :gemspec => 'ruby-maven.gemspec', :includeOpenSSL => true
  g.gem 'thor'#, '0.14.6'
  g.gem 'maven-tools'#, '0.31.0'
end

plugin(:clean, '2.5' ) do |c|
  c.with :filesets =>
    [ { :directory => 'lib',
        :includes => ['*jar', 'ext/**' ] },
      { :directory => 'bin',
        :includes => ['*'],
        :excludes => ['rmvn'] },
      { :directory => './',
        :includes => ['*.txt'] } ]
end

build.resources.add do |r|
  r.target_path "${project.basedir}"
  r.directory "${project.build.directory}/apache-maven-${maven.version}"
end

execute_in_phase( :initialize ) do
  pom = File.read( 'pom.xml' )
  if File.exists? '.pom.xml'
    dot_pom = File.read( '.pom.xml' )
    if pom != dot_pom
      File.open( 'pom.xml', 'w' ) { |f| f.puts dot_pom }
    end
  end
end

# just lock the versions
properties['jruby.plugins.version'] = '0.29.2'
properties['jruby.version'] = '1.7.2'

# overwrite via cli -Djruby.versions=1.6.7
properties['jruby.versions'] = ['1.5.6','1.6.8','1.7.2'].join(',')
# overwrite via cli -Djruby.use18and19=false
properties['jruby.18and19'] = true

# vim: syntax=Ruby
