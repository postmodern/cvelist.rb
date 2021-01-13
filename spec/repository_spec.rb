require 'spec_helper'
require 'cvelist/repository'

describe Repository do
  let(:fixture_dir) { File.expand_path('../fixtures',__FILE__)  }

  describe ".clone" do
    subject { described_class }

    let(:depth) { 1 }
    let(:url) { described_class::URL }
    let(:path) { File.join(fixture_dir,'new_cvelist') }

    context "when only given the path argument" do
      it "must execute `git clone --depth 1 URL path` command" do
        expect(subject).to receive(:system).with(
          'git', 'clone', '--depth', depth.to_s, url, path
        ).and_return(true)

        subject.clone(path)
      end
    end

    context "when given a custom url: argument" do
      let(:url) { 'https://github.com/some_other/cvelist.git' }

      it "must pass the `URL` git argument to `git clone`" do
        expect(subject).to receive(:system).with(
          'git', 'clone', '--depth', depth.to_s, url, path
        ).and_return(true)

        subject.clone(path, url: url)
      end
    end

    context "when given a custom depth: argument" do
      let(:depth) { 2 }

      it "must pass the `--depth DEPTH` option to `git clone`" do
        expect(subject).to receive(:system).with(
          'git', 'clone', '--depth', depth.to_s, url, path
        ).and_return(true)

        subject.clone(path, depth: depth)
      end
    end

    context "when the `git clone` command succeeds" do
      it do
        expect(subject).to receive(:system).with(
          'git', 'clone', '--depth', depth.to_s, url, path
        ).and_return(true)

        expect(subject.clone(path)).to be_kind_of(described_class)
      end
    end

    context "when the `git clone` command fails" do
      it do
        expect(subject).to receive(:system).with(
          'git', 'clone', '--depth', depth.to_s, url, path
        ).and_return(false)

        expect {
          subject.clone(path)
        }.to raise_error(GitCloneFailed)
      end
    end
  end

  let(:path) { File.join(fixture_dir,'cvelist') }

  subject { described_class.new(path) }

  describe "#git?" do
    it "must test for the presence of a '.git' directory" do
      expect(subject).to receive(:directory?).with('.git')

      subject.git?
    end
  end

  describe "#pull!" do
    context "when the repository is a git repository" do
      before { expect(subject).to receive(:git?).and_return(true) }

      let(:remote) { 'origin' }
      let(:branch) { 'master' }

      context "when no arguments are given" do
        it "must run a `git pull REMOTE BRANCH` command" do
          expect(subject).to receive(:system).with(
            'git', 'pull', remote, branch
          ).and_return(true)

          subject.pull!
        end
      end

      context "when a remote: argument is given" do
        let(:remote) { 'other' }

        it "must pass the `REMOTE` argument to the `git pull` command" do
          expect(subject).to receive(:system).with(
            'git', 'pull', remote, branch
          ).and_return(true)

          subject.pull!(remote: remote)
        end
      end

      context "when a branch: argument is given" do
        let(:branch) { 'other_branch' }

        it "must pass the `BRANCH` argument to the `git pull` command" do
          expect(subject).to receive(:system).with(
            'git', 'pull', remote, branch
          ).and_return(true)

          subject.pull!(branch: branch)
        end
      end

      context "when the `git pull` command succeeds" do
        it "must return true" do
          expect(subject).to receive(:system).with(
            'git', 'pull', remote, branch
          ).and_return(true)

          expect(subject.pull!).to eq(true)
        end
      end

      context "when the `git pull` command fails" do
        it do
          expect(subject).to receive(:system).with(
            'git', 'pull', remote, branch
          ).and_return(false)

          expect {
            subject.pull!
          }.to raise_error(GitPullFailed)
        end
      end
    end

    context "when the repository is not a git repository" do
      before { expect(subject).to receive(:git?).and_return(false) }

      it "must return false" do
        expect(subject.pull!).to eq(false)
      end
    end
  end

  describe "#has_year?" do
    it "should test if a repository has a directory for the given year" do
      expect(subject.has_year?('1999')).to eq(true)
    end

    context "when the given year does not exist in the repository" do
      it "must return false" do
        expect(subject.has_year?('3000')).to eq(false)
      end
    end
  end

  let(:dirs) do
    %w[
        1999  2001  2003  2005  2007  2009  2011  2013  2015  2017  2019  2021
        2000  2002  2004  2006  2008  2010  2012  2014  2016  2018  2020
      ]
  end
  let(:dir_paths) do
    dirs.map { |dir| File.join(path,dir) }
  end

  let(:sorted_dirs) { dirs.sort }
  let(:sorted_dir_paths) do
    sorted_dirs.map { |dir| File.join(path,dir) }
  end

  describe "#directories" do
    subject { super().directories }

    it "must return all year directories" do
      expect(subject).to match_array(dir_paths)
    end

    it "must sort the directories" do
      expect(subject).to eq(sorted_dir_paths)
    end
  end

  describe "#years" do
    subject { super().years }

    it do
      expect(subject).to_not be_empty
      expect(subject).to all(be_kind_of(YearDir))
    end

    it "must map the #directories to YearDir objects" do
      expect(subject.map(&:path)).to eq(sorted_dir_paths)
    end
  end

  describe "#year" do
    let(:year_number) { '2001' }

    subject { super().year(year_number) }

    it "must return a YearDir object for the given year" do
      expect(subject).to be_kind_of(YearDir)
      expect(subject.path).to eq(File.join(path,year_number))
    end

    context "when the given year does not exist in the repository" do
      let(:year_number) { '3000' }

      it do
        expect { subject }.to raise_error(YearDirNotFound)
      end
    end
  end

  describe "#each" do
    let(:cve_paths) { Dir[File.join(path,'**/**/CVE-*.json')] }
  end

  describe "#each_malformed" do
  end

  describe "#has_cve?" do
    let(:cve_id) { 'CVE-2021-2001' }

    it "must find the .json file with the matching CVE ID in the repository" do
      expect(subject.has_cve?(cve_id)).to eq(true)
    end

    context "when the given .json file cannot be found" do
      let(:cve_id) { 'CVE-2021-2010' }

      it "must return false" do
        expect(subject.has_cve?(cve_id)).to eq(false)
      end
    end
  end

  describe "#[]" do
    let(:cve_year)   { '2021' }
    let(:cve_number) { '2001' }
    let(:cve_id)     { "CVE-#{cve_year}-#{cve_number}" }

    it "must return a CVE object" do
      expect(subject[cve_id]).to be_kind_of(CVE)
    end

    let(:cve_range)  { '2xxx' }
    let(:cve_path)   { File.join(path,cve_year,cve_range,"#{cve_id}.json") }

    it "must load the CVE from the .json file with the matching CVE ID" do
      expect(subject[cve_id].path).to eq(cve_path)
    end

    context "when the repository does not have a matching year directory" do
      let(:cve_id) { 'CVE-3000-1234' }

      it "must return nil" do
        expect(subject[cve_id]).to eq(nil)
      end
    end

    context "when the repository does not have a matching range directory" do
      let(:cve_id) { 'CVE-2021-9999' }

      it "must return nil" do
        expect(subject[cve_id]).to eq(nil)
      end
    end

    context "when the repository does not have the CVE .json file" do
      let(:cve_id) { 'CVE-2021-2010' }

      it "must return nil" do
        expect(subject[cve_id]).to eq(nil)
      end
    end
  end
end
