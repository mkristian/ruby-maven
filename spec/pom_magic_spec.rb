require 'maven/ruby/pom_magic'
require 'fileutils'

describe Maven::Ruby::PomMagic do

  describe 'given name' do

    subject { Maven::Ruby::PomMagic.new('_pom.xml') }
    
    it 'should generate project specific pom.xml with given name' do
      pom = 'it/project/_pom.xml'
      subject.generate_pom(File.join('it', 'project')).must_equal pom
      File.read(pom).must_match /<name><..CDATA.ruby-maven - gem..><.name>/
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
    pom = 'it/rails/.pom.xml'
    subject.generate_pom(File.join('it', 'rails')).must_equal pom
    File.read(pom).must_match /<name><..CDATA.ruby-maven - rails application..><.name>/
  end

  it 'should generate project specific pom.xml' do
    pom = 'it/project/.pom.xml'
    subject.generate_pom(File.join('it', 'project')).must_equal pom
    File.read(pom).must_match /<name><..CDATA.ruby-maven - gem..><.name>/
  end

  it 'should generate project specific pom.xml using gemspec' do
    pom = 'it/project/.pom.xml'
    subject.generate_pom(File.join('it', 'project'), 
                         '-f', 
                         'it/project/minimal.gemspec').must_equal pom
    File.read(pom).must_match /<name><..CDATA.minimal - gem..><.name>/
  end

  it 'should generate project specific pom.xml using Gemfile with gemspec' do
    pom = 'it/project/.pom.xml'
    subject.generate_pom(File.join('it', 'project'), 
                         '-f', 
                         'it/project/Gemfile2').must_equal pom
    File.read(pom).must_match /<name><..CDATA.minimal - gem..><.name>/
  end

  it 'should generate project specific pom.xml without Gemfile' do
    subject.generate_pom(File.join('it', 'project_no_gemfile')).must_equal 'it/project_no_gemfile/.pom.xml'
  end

end
