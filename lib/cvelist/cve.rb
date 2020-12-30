require 'cve_schema/cve'
require 'multi_json'

module CVEList
  class CVE < CVESchema::CVE

    # The path to the CVE JSON.
    #
    # @return [String]
    attr_reader :path

    #
    # Initializes the CVE.
    #
    # @param [String] path
    #   The path to the CVE JSON.
    #
    def initialize(path, **kwargs)
      super(kwargs)

      @path = path
    end

    #
    # Parses the JSON in the given file.
    #
    # @param [String] file
    #   The path to the file.
    #
    # @return [Hash{String => Object}]
    #   The parsed JSON.
    #
    # @raise [InvalidJSON]
    #   Could not parse the JSON in the given file.
    #
    # @api semipublic
    #
    def self.parse(file)
      MultiJson.load(File.read(file))
    rescue MultiJson::ParseError => error
      raise(InvalidJSON,error.message)
    end

    #
    # Loads the CVE JSON from the given file.
    #
    # @param [String] file
    #   The path to the file.
    #
    # @return [CVE]
    #   The loaded CVE object.
    #
    # @raise [InvalidJSON, MissingJSONKey, UnknownJSONValue]
    #   Failed to load the CVE JSON.
    #
    def self.load(file)
      new(path: file, **from_json(parse(file)))
    end

  end
end
