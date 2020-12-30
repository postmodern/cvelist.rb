module CVEList
  #
  # Represents malformed/invalid CVE JSON that could not be loaded.
  #
  class MalformedJSON

    # Path to the JSON file.
    #
    # @return [String]
    attr_reader :path

    # The exception encountered when parsing the JSON file.
    #
    # @return [StandardError]
    attr_reader :exception

    #
    # Initializes the malformed json.
    #
    # @param [String] path
    #   Path to the JSON file.
    #
    # @param [StandardError] exception
    #   The exception encountered when parsing the JSON file.
    #
    def initialize(path,exception)
      @path      = path
      @exception = exception
    end

    #
    # Converts the malformed JSON back into a String.
    #
    # @return [String]
    #   The String containing the {#path}, the {#exception} class and message.
    #
    def to_s
      "#{@path}: #{@exception.class}: #{@exception.message}"
    end

  end
end
