require 'spec_helper'

RSpec.shared_examples "CVE methods" do
  describe "#each" do
    let(:malformed_cves) { %w[CVE-2021-2999.json CVE-2021-2998.json] }
    let(:malformed_cve_paths) do
      Dir[File.join(path,"{**/}{#{malformed_cves.join(',')}}")]
    end

    let(:cve_paths) { Dir[File.join(path,'{**/}CVE-*.json')] }
    let(:valid_cve_paths) { cve_paths - malformed_cve_paths }

    context "when a block is given" do
      it "must yield CVE objects "do
        results = []
        subject.each { |cve| results << cve }

        expect(results).to all(be_kind_of(CVE))
      end
    end

    context "when no block is given" do
      it "must return an Enumerator object" do
        expect(subject.each).to be_kind_of(Enumerator)
      end
    end

    it "must find the valid CVE-*.json files in the repository" do
      expect(subject.each.map(&:path)).to match_array(valid_cve_paths)
    end

    it "must omit malformed CVEs" do
      expect(subject.each.map(&:path)).to_not include(malformed_cve_paths)
    end
  end

  describe "#each_malformed" do
    let(:malformed_cves) { %w[CVE-2021-2999.json CVE-2021-2998.json] }
    let(:malformed_cve_paths) do
      Dir[File.join(path,"{**/}{#{malformed_cves.join(',')}}")]
    end

    let(:cve_paths) { Dir[File.join(path,'{**/}CVE-*.json')] }
    let(:valid_cve_paths) { cve_paths - malformed_cve_paths }

    context "when a block is given" do
      it "must yield MalformedCVE objects "do
        results = []
        subject.each_malformed { |cve| results << cve }

        expect(results).to all(be_kind_of(MalformedCVE))
      end
    end

    context "when no block is given" do
      it "must return an Enumerator object" do
        expect(subject.each_malformed).to be_kind_of(Enumerator)
      end
    end

    it "must find the malformed CVE-*.json files in the repository" do
      expect(subject.each_malformed.map(&:path)).to match_array(malformed_cve_paths)
    end

    it "must omit valid CVEs" do
      expect(subject.each_malformed.map(&:path)).to_not include(valid_cve_paths)
    end
  end

  describe "#has_cve?" do
    let(:cve_id) { 'CVE-2021-2001' }

    it "must find the .json file with the matching CVE ID in the repository" do
      expect(subject.has_cve?(cve_id)).to be(true)
    end

    context "when the given .json file cannot be found" do
      let(:cve_id) { 'CVE-2021-2010' }

      it "must return false" do
        expect(subject.has_cve?(cve_id)).to be(false)
      end
    end
  end

  describe "#[]" do
    let(:cve_year)   { '2021' }
    let(:cve_number) { '2001' }
    let(:cve_id)     { "CVE-#{cve_year}-#{cve_number}" }

    let(:cve_range)  { '2xxx' }
    let(:cve_path) do
      File.join(cvelist_dir,cve_year,cve_range,"#{cve_id}.json")
    end

    subject { super()[cve_id] }

    it "must return a CVE object" do
      expect(subject).to be_kind_of(CVE)
    end

    it "must load the CVE from the .json file with the matching CVE ID" do
      expect(subject.path).to eq(cve_path)
    end

    context "when the repository does not have a matching year directory" do
      let(:cve_id) { 'CVE-3000-1234' }

      it "must return nil" do
        expect(subject).to be(nil)
      end
    end

    context "when the repository does not have a matching range directory" do
      let(:cve_id) { 'CVE-2021-9999' }

      it "must return nil" do
        expect(subject).to be(nil)
      end
    end

    context "when the repository does not have the CVE .json file" do
      let(:cve_id) { 'CVE-2021-2010' }

      it "must return nil" do
        expect(subject).to be(nil)
      end
    end
  end
end
