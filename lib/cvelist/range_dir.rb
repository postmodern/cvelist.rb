# frozen_string_literal: true

require 'cvelist/directory'
require 'cvelist/exceptions'
require 'cvelist/cve'
require 'cvelist/malformed_cve'

module CVEList
  class RangeDir < Directory

    include Enumerable

    # @return [String]
    attr_reader :path

    # @return [String]
    attr_reader :range

    #
    # Initializes the range directory.
    #
    # @param [String] path
    #   The path to the range directory.
    #
    def initialize(path)
      super(path)

      @range = File.basename(@path)
    end

    #
    # Determines whether the range directory contains the given CVE ID.
    #
    # @param [String] cve_id
    #   The given CVE ID.
    #
    # @return [Boolean]
    #
    def has_cve?(cve_id)
      file?("#{cve_id}.json")
    end

    #
    # Loads a CVE.
    #
    # @param [String] cve_id
    #   The CVE ID.
    #
    # @return [CVE, nil]
    #   The loaded CVE of `nil` if the CVE could not be found within the range
    #   directory.
    #
    def [](cve_id)
      cve_file = "#{cve_id}.json"
      cve_path = join(cve_file)

      if File.file?(cve_path)
        CVE.load(cve_path)
      end
    end

    # `Dir.glob` pattern for all CVE `.json` files.
    GLOB = 'CVE-[0-9][0-9][0-9][0-9]-*.json'

    #
    # The JSON files within the range directory.
    #
    # @return [Array<String>]
    #
    def files
      glob(GLOB).sort
    end

    #
    # Enumerates over the CVEs in the range directory.
    #
    # @yield [cve]
    #   The given block will be passed each CVE in the range directory.
    #
    # @yieldparam [CVE] cve
    #   A CVE within the range directory.
    #
    # @return [Enumerator]
    #   If no block is given, an Enumerator object will be returned.
    #
    def each
      return enum_for(__method__) unless block_given?

      files.each do |cve_path|
        begin
          yield CVE.load(cve_path)
        rescue CVE::InvalidJSON
        end
      end
    end

    #
    # Enumerates over the malformed CVEs within the range directory.
    #
    # @yield [malformed]
    #   The given block will be passed each malformed 
    #
    # @yieldparam [MalformedCVE] malformed
    #
    # @return [Enumerator]
    #   If no block is given, an Enumerator object will be returned.
    #
    def each_malformed
      return enum_for(__method__) unless block_given?

      files.each do |cve_path|
        begin
          CVE.load(cve_path)
        rescue CVE::InvalidJSON => error
          yield MalformedCVE.new(cve_path,error)
        end
      end
    end

  end
end
