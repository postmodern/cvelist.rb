require 'spec_helper'
require 'cve_methods_examples'
require 'cvelist/range_dir'

describe RangeDir do
  let(:year_number) { 2021   }
  let(:xxx_range)   { '2xxx' }

  let(:fixture_dir) { File.expand_path('../fixtures',__FILE__)  }
  let(:cvelist_dir) { File.join(fixture_dir,'cvelist') }
  let(:path)        { File.join(cvelist_dir,year_number.to_s,xxx_range) }

  subject { described_class.new(path) }

  describe "#initialize" do
    it "must set #range" do
      expect(subject.range).to eq(xxx_range)
    end
  end

  let(:valid_cve_files) do
    %w[
CVE-2021-2000.json  CVE-2021-2003.json  CVE-2021-2006.json  CVE-2021-2009.json
CVE-2021-2001.json  CVE-2021-2004.json  CVE-2021-2007.json
CVE-2021-2002.json  CVE-2021-2005.json  CVE-2021-2008.json
    ]
  end
  let(:malformed_cve_files) { %w[CVE-2021-2998.json  CVE-2021-2999.json] }

  let(:cve_files) { valid_cve_files + malformed_cve_files }
  let(:cve_paths) do
    cve_files.map { |file| File.join(path,file) }
  end

  let(:sorted_cve_files) { cve_files.sort }
  let(:sorted_cve_paths) do
    sorted_cve_files.map { |file| File.join(path,file) }
  end

  describe "#files" do
    it "must find all CVE-*.json files" do
      expect(subject.files).to all(be =~ /\/CVE-\d{4}-\d{4}\.json$/)
    end

    it "must return the paths to 'CVE-*.json' files within the range directory" do
      expect(subject.files).to match_array(cve_paths)
    end

    it "must sort the 'CVE-*.json' files" do
      expect(subject.files).to eq(sorted_cve_paths)
    end
  end

  include_examples "CVE methods"
end
