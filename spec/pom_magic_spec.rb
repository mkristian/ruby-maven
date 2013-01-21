require 'maven/ruby/pom_magic'
require 'fileutils'

describe Maven::Ruby::PomMagic do

  describe 'given name' do

    subject { Maven::Ruby::PomMagic.new('_pom.xml') }
    
    it 'should generate project specific pom.xml with given name' do
      pom = File.expand_path( 'it/project/_pom.xml' )
      subject.generate_pom(File.join('it', 'project')).must_equal pom
      File.read(pom).must_match /<name><..CDATA.project - gem..><.name>/
    end

  end

  subject { Maven::Ruby::PomMagic.new }

  it 'should skip generation of pom.xml' do
    subject.generate_pom(File.join('it', 'rails'), 
                         '-f', 
                         'pom.xml').must_be_nil
    subject.generate_pom(File.join('it', 'rails'), 
                         '--file', 
                         'pom.xml').must_be_nil
  end

  it 'should generate rails specific pom.xml' do
    pom =  File.expand_path( 'it/rails/.pom.xml' )
    subject.generate_pom(File.join('it', 'rails')).must_equal pom
    File.read(pom).must_match /<name><..CDATA.rails - rails application..><.name>/
  end

  it 'should generate project specific pom.xml' do
    pom = File.expand_path( 'it/project/.pom.xml' )
    subject.generate_pom(File.join('it', 'project')).must_equal pom
    File.read(pom).must_match /<name><..CDATA.project - gem..><.name>/
  end

  it 'should generate project specific pom.xml using gemspec' do
    pom = File.expand_path( 'it/project/.pom.xml' )
    subject.generate_pom(File.join('it', 'project'), 
                         '-f', 
                         'minimal.gemspec').must_equal pom
    File.read(pom).must_match /<name><..CDATA.minimal - gem..><.name>/
  end

  it 'should generate project specific pom.xml using Gemfile with gemspec' do
    pom = File.expand_path( 'it/project/.pom.xml' )
    subject.generate_pom(File.join('it', 'project'), 
                         '-f', 
                         'Gemfile2').must_equal pom
    File.read(pom).must_match /<name><..CDATA.minimal - gem..><.name>/
  end

  it 'should generate project specific pom.xml without Gemfile' do
    subject.generate_pom(File.join('it', 'project_no_gemfile')).must_equal File.expand_path( 'it/project_no_gemfile/.pom.xml' )
  end

end
