require 'cvelist/directory'
require 'cvelist/exceptions'
require 'cvelist/range_dir'

module CVEList
  class YearDir < Directory

    include Enumerable

    # Path to the year directory.
    #
    # @return [String]
    attr_reader :path

    # The year of the directory.
    #
    # @return [Integer]
    attr_reader :year

    #
    # Initializes the year dir.
    #
    # @param [String] path
    #   The path to the year directory.
    #
    def initialize(path)
      super(path)

      @year = File.basename(@path).to_i
    end

    #
    # Access a range directory within the year directory.
    #
    # @param [String] range
    #   The "xxx" range.
    #
    # @return [RangeDir]
    #   The range directory.
    #
    # @raise [RangeDirNotFound]
    #   Could not find the given range directory within the year directory.
    #
    def range(xxx_range)
      range_dir_path = join(xxx_range)

      unless File.directory?(range_dir_path)
        raise(RangeDirNotFound,"#{xxx_range.inspect} not found within #{@path.inspect}")
      end

      return RangeDir.new(range_dir_path)
    end

    alias / range

    #
    # The `xxx` number ranges within the directory.
    #
    # @return [Array<String>]
    #
    def directories
      glob('*xxx').sort
    end

    #
    # Enumerates over the range directories within the year directory.
    #
    # @yield [range_dir]
    #   The given block will be passed each range directory from within the
    #   year directory.
    #
    # @yieldparam [Rangedir] range_dir
    #   A range directory.
    #
    # @return [Enumerator]
    #   If no block is given, an Enumerator will be returned.
    #
    def ranges(&block)
      range_dirs = directories.map do |dir|
        yield RangeDir.new(dir)
      end

      range_dirs.each(&block) if block
      return range_dirs
    end

    #
    # Enumerates over each CVE, in each range directory, within the year
    # directory.
    #
    # @yield [cve]
    #   The given block will be passed each CVE in the year dir.
    #
    # @yieldparam [CVE] cve
    #   A CVE within one of the range directories.
    #
    # @return [Enumerator]
    #   If no block is given, an Enumerator will be returned.
    #
    def each
      return enum_for(__method__) unless block_given?

      ranges do |range_dir|
        range_dir.each(&block)
      end
    end

    #
    # Enumerates over every malformed CVE within the year directories.
    #
    # @yield [malformed_cve]
    #   The given block will be passed each malformed CVE from within the
    #   year directory.
    #
    # @yieldparam [MalformedCVE] malformed_cve
    #   A malformed CVE from within the year directory.
    #
    # @return [Enumerator]
    #   If no block is given, an Enumerator will be returned.
    #
    def each_malformed
      return enum_for(__method__) unless block_given?

      ranges do |range_dir|
        range_dir.each_malformed(&block)
      end
    end

    #
    # Determines whether a CVE exists with the given ID, within any of the range
    # directories, within the year directory.
    #
    # @param [String] cve_id
    #   The given CVE ID.
    #
    # @return [Boolean]
    #   Specifies whether the CVE exists.
    #
    def has_cve?(cve_id)
      xxx_range = cve_to_xxx_range(cve_id)

      has_range?(xxx_range) && range(xxx_range).has_cve?(cve_id)
    end

    #
    # Loads a CVE.
    #
    # @param [String] cve_id
    #   The CVE ID.
    #
    # @return [CVE]
    #   The loaded CVE.
    #
    # @raise [CVENotFound]
    #   The CVE could not be found in the range directory.
    #
    def [](cve_id)
      xxx_range = cve_to_xxx_range(cve_id)

      range(xxx_range)[cve_id]
    end

    private

    def cve_to_xxx_range(cve_number)
      cve_number = cve_id[cve_id.rindex('-')+1 ..]
      cve_number[-3,3] = 'xxx'

      return cve_number
    end

  end
end
