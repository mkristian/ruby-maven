require 'ruby_maven'
require 'stringio'

describe Maven::Ruby::Maven do

  subject { Maven::Ruby::Maven.new }
  let(:log){ 'target/output.log' }
  let(:out){ StringIO.new }

  it 'should show maven' do
    subject.exec('--version').must_equal true
  end

  it 'should launch maven' do
    subject.exec('-l', log)
    File.read(log).must_match /BUILD FAILURE/
  end

  it 'should launch maven with dependency:resolve' do
    subject.exec('dependency:resolve', '-l', log)
    File.read(log).must_match /BUILD SUCCESS/
  end
end
