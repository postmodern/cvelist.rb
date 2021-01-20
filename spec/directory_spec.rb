require 'spec_helper'
require 'cvelist/directory'

describe Directory do
  let(:fixture_dir) { File.expand_path('../fixtures',__FILE__)  }
  let(:path)        { File.join(fixture_dir,'cvelist') }

  subject { described_class.new(path) }

  describe "#initialize" do
    it "must set #path" do
      expect(subject.path).to eq(path)
    end

    context "when given a relative path" do
      let(:relative_path) { File.join(__FILE__,'../fixtures/cvelist') }

      subject { described_class.new(relative_path) }

      it "must expand the relative path" do
        expect(subject.path).to eq(path)
      end
    end
  end

  describe "#join" do
    let(:name) { 'foo' }

    it "must join the path with the directory's #path" do
      expect(subject.join(name)).to eq(File.join(path,name))
    end

    context "when given multiple arguments" do
      let(:names) { %w[foo bar baz] }

      it "must join all arguments together with the directory's #path" do
        expect(subject.join(*names)).to eq(File.join(path,*names))
      end
    end
  end

  describe "#file?" do
    let(:name) { '.gitkeep' }

    it "must test whether the given path is a file within the directory" do
      expect(subject.file?(name)).to be(true)
    end

    context "when the given sub-directory does not exist" do
      it { expect(subject.file?('foo')).to be(false) }
    end
  end

  describe "#directory?" do
    let(:name) { '2000' }

    it "must test whether the given path is a directory within the directory" do
      expect(subject.directory?(name)).to be(true)
    end

    context "when the given sub-directory does not exist" do
      it { expect(subject.directory?('foo')).to be(false) }
    end
  end

  describe "#glob" do
    let(:pattern) { '20*1' }
    let(:dirs) { %w[2001 2011 2021] }
    let(:paths) do
      dirs.map { |dir| File.join(path,dir) }
    end

    it "must perform a Dir.glob within the directory" do
      expect(subject.glob(pattern)).to match_array(paths)
    end
  end

  describe "#to_s" do
    it "must return the #path" do
      expect(subject.to_s).to eq(path)
    end
  end
end
