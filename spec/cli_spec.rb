$LOAD_PATH << 'lib/ruby'
require 'maven/ruby/cli'
require 'stringio'

describe Maven::Ruby::Cli do

  subject { Maven::Ruby::Cli.new }
  let(:log){ File.expand_path(File.join('target', 'output.log')) }
  let(:out){ StringIO.new }

  it 'should launch maven with pom.xml' do
    subject.exec('-l', log, 'validate')
    File.read(log).must_match /BUILD SUCCESS/
    File.read(log).must_match /Building maven support for ruby projects/
  end

  it 'should launch maven without pom.xml' do
    subject.exec_in('it', '-l', log)
    File.read(log).must_match /BUILD FAILURE/
    File.read(log).wont_match /Building /
  end

  it 'should launch maven within rails application' do
    subject.exec_in('it/rails', '-l', log)
    File.read(log).must_match /BUILD FAILURE/
    File.read(log).wont_match /Building /
  end
end
