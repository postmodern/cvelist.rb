require 'spec_helper'
require 'cvelist/cve'

describe CVE do
  let(:cve_id) { 'CVE-2020-1994' }
  let(:file)   { File.expand_path("../fixtures/#{cve_id}.json",__FILE__) }

  it { expect(described_class).to be < CVESchema::CVE }

  describe ".parse" do
    subject { described_class }

    it "must parse the given JSON" do
      expect(subject.parse('[1]')).to eq([1])
    end

    context "when given invalid JSON" do
      let(:json) { '[' }

      it do
        expect {
          subject.parse(json)
        }.to raise_error(described_class::InvalidJSON)
      end
    end
  end

  describe ".read" do
    subject { described_class }

    it "must read and parse the JSON in the given file" do
      expect(subject.read(file)).to eq(JSON.parse(File.read(file)))
    end
  end

  describe ".load" do
    subject { described_class.load(file) }

    it "must load a CVE object from the given file" do
      expect(subject).to be_kind_of(described_class)
    end

    it "must set #path" do
      expect(subject.path).to eq(file)
    end

    it "must set other CVE fields" do
      expect(subject.data_meta.id.to_s).to eq(cve_id)
    end
  end
end
