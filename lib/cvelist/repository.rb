# frozen_string_literal: true

require 'cvelist/directory'
require 'cvelist/exceptions'
require 'cvelist/year_dir'

module CVEList
  class Repository < Directory

    include Enumerable

    # The default git URI for the cvelist repository
    URL = 'https://github.com/CVEProject/cvelist.git'

    #
    # Clones a new repository.
    #
    # @param [#to_s] path
    #   The path to where the cvelist repository will be cloned to.
    #
    # @param [#to_s] url
    #   The URL for the cvelist repository.
    #
    # @param [#to_s] depth
    #   The depth of the git clone.
    #
    # @raise [CloneFailedError]
    #   The `git clone` command failed.
    #
    def self.clone(path, url: URL, depth: 1)
      unless system 'git', 'clone', '--depth', depth.to_s, url.to_s, path.to_s
        raise(GitCloneFailed,"failed to clone #{url.inspect} into #{path.inspect}")
      end

      return new(path)
    end

    class << self
      alias download clone
    end

    #
    # Determines whether the repository is a git repository.
    #
    # @return [Boolean]
    #   Specifies whether the repository is a git repository or not.
    #
    def git?
      directory?('.git')
    end

    # The default git remote.
    REMOTE = 'origin'

    # The default git branch.
    BRANCH = 'master'

    #
    # Pulls down new commits from the given remote/branch.
    #
    # @param [#to_s] remote
    #   The git remote.
    #
    # @param [#to_s] branch
    #   The git branch.
    #
    # @return [true, false]
    #   Returns `true` if the `git pull` succeeds.
    #   Returns `false` if the repository is not a git repository.
    #
    # @raise [PullFailedError]
    #   The `git pull` command faild.
    #
    def pull!(remote: REMOTE, branch: BRANCH)
      return false unless git?

      Dir.chdir(@path) do
        unless system('git', 'pull', remote.to_s, branch.to_s)
          raise(GitPullFailed,"failed to pull from remote #{remote.inspect} branch #{branch.inspect}")
        end
      end

      return true
    end

    alias update! pull!

    #
    # Determines if the repository contains a directory for the given year.
    #
    # @param [#to_s] year
    #   The given year.
    #
    # @return [Boolean]
    #   Specifies whether the repository contains the directory for the year.
    #
    def has_year?(year)
      directory?(year.to_s)
    end

    #
    # The year directories within the repository.
    #
    # @return [Array<String>]
    #   The paths to the year directories.
    #
    def directories
      glob('[1-2][0-9][0-9][0-9]').sort
    end

    #
    # The year directories contained within the repository.
    #
    # @yield [year_dir]
    #   If a block is given, it will be passed each year directory.
    #
    # @yieldparam [YearDir] year_dir
    #   A year directory within the repository.
    #
    # @return [Array<YearDir>]
    #   The year directories within the repository.
    #
    def years(&block)
      year_dirs = directories.map do |dir|
        YearDir.new(dir)
      end

      year_dirs.each(&block) if block
      return year_dirs
    end

    #
    # Requests a year directory from the repository.
    #
    # @param [#to_s] year_number
    #   The given year number.
    #
    # @return [YearDir]
    #   The year directory.
    #
    # @raise [YearNotFound]
    #   There is no year directory within the repository for the given year.
    #
    def year(year_number)
      year_dir = join(year_number.to_s)

      unless File.directory?(year_dir)
        raise(YearDirNotFound,"year #{year_number.inspect} not found within #{@path.inspect}")
      end

      return YearDir.new(year_dir)
    end

    alias / year

    #
    # Enumerates over every CVE withing the year directories.
    #
    # @yield [cve]
    #   The given block will be passed each CVE from within the repository.
    #
    # @yieldparam [CVE] cve
    #   A CVE from the repository.
    #
    # @return [Enumerator]
    #   If no block is given, an Enumerator will be returned.
    #
    def each(&block)
      return enum_for(__method__) unless block_given?

      years do |year_dir|
        year_dir.each(&block)
      end
    end

    #
    # Enumerates over every malformed CVE within the repository.
    #
    # @yield [malformed_cve]
    #   The given block will be passed each malformed CVE from within the
    #   repository.
    #
    # @yieldparam [MalformedCVE] malformed_cve
    #   A malformed CVE from within the repository.
    #
    # @return [Enumerator]
    #   If no block is given, an Enumerator will be returned.
    #
    def each_malformed(&block)
      return enum_for(__method__) unless block_given?

      years do |year_dir|
        year_dir.each_malformed(&block)
      end
    end

    #
    # Determines whether the repository contains the given CVE ID.
    #
    # @param [String] cve_id
    #   The given CVE ID.
    #
    # @return [Boolean]
    #
    def has_cve?(cve_id)
      year_number = cve_to_year(cve_id)

      return has_year?(year_number) && year(year_number).has_cve?(cve_id)
    end

    #
    # Accesses a CVE from the repository with the given CVE ID.
    #
    # @param [String] cve_id
    #   The given CVE ID.
    #
    # @return [CVE, nil]
    #   The CVE with the given ID. If no CVE with the given ID could be found,
    #   `nil` will be returned.
    #
    # @raise [CVE::InvalidJSON, CVE::MissingJSONKey, CVE::UnknownJSONValue]
    #   The CVE's JSON is invalid or malformed.
    #
    def [](cve_id)
      year_number = cve_to_year(cve_id)

      if has_year?(year_number)
        year(year_number)[cve_id]
      end
    end

    private

    def cve_to_year(cve_id)
      cve_id[cve_id.index('-')+1 .. cve_id.rindex('-')-1]
    end

  end
end
