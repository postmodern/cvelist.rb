require 'spec_helper'
require 'cvelist/year_dir'

describe YearDir do
  let(:year_number) { 2021 }

  let(:fixture_dir) { File.expand_path('../fixtures',__FILE__)  }
  let(:cvelist_dir) { File.join(fixture_dir,'cvelist') }
  let(:path)        { File.join(cvelist_dir,year_number.to_s) }

  subject { described_class.new(path) }

  describe "#initialize" do
    it "must set #year" do
      expect(subject.year).to eq(year_number)
    end
  end

  describe "#has_range?" do
    let(:xxx_range) { '1xxx' }

    it "must test whether the year directory contains the '*xxx' range dir" do
      expect(subject.has_range?(xxx_range)).to eq(true)
    end

    context "when the year directory does not have the given '*xxx' range dir" do
      let(:xxx_range) { '9xxx' }

      it "must return false" do
        expect(subject.has_range?(xxx_range)).to eq(false)
      end
    end
  end

  describe "#range" do
    context "when the year directory has the given '*xxx' range dir" do
      let(:xxx_range) { '1xxx' }

      subject { super().range(xxx_range) }

      it "must return a RangeDir object for the given '*xxx' range" do
        expect(subject).to be_kind_of(RangeDir)
        expect(subject.path).to eq(File.join(path,xxx_range))
      end
    end

    context "when the year directory does not have the given '*xxx' range dir" do
      let(:xxx_range) { '9xxx' }

      it do
        expect {
          subject.range(xxx_range)
        }.to raise_error(RangeDirNotFound)
      end
    end
  end

  let(:xxx_ranges) { %w[0xxx  1xxx  20xxx  21xxx  2xxx] }
  let(:xxx_range_paths) do
    xxx_ranges.map { |dir| File.join(path,dir) }
  end

  let(:sorted_xxx_ranges) { xxx_ranges.sort }
  let(:sorted_xxx_range_paths) do
    sorted_xxx_ranges.map { |dir| File.join(path,dir) }
  end

  describe "#directories" do
    it "must return the paths to '*xxx' range directories within the year directory" do
      expect(subject.directories).to match_array(xxx_range_paths)
    end

    it "must sort the '*xxx' range directories" do
      expect(subject.directories).to eq(sorted_xxx_range_paths)
    end
  end

  describe "#ranges" do
    it do
      expect(subject.ranges).to_not be_empty
      expect(subject.ranges).to all(be_kind_of(RangeDir))
    end

    it "must map #directories to RangeDir objects" do
      expect(subject.ranges.map(&:path)).to eq(sorted_xxx_range_paths)
    end
  end

  include_examples "CVE methods"
end
