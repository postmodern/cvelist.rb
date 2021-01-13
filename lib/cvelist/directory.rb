module CVEList
  #
  # Represents a directory within the {Repository}.
  #
  class Directory

    # The path to the directory.
    #
    # @return [String]
    attr_reader :path

    #
    # Initializes the directory.
    #
    # @param [String] path
    #   The path to the directory.
    #
    def initialize(path)
      @path = File.expand_path(path)
    end

    #
    # Joins the file/directory name with the directory path.
    #
    # @return [String]
    #
    def join(name)
      File.join(@path,name)
    end

    #
    # Determines whether the directory has the givne file.
    #
    # @return [Boolean]
    #
    def file?(name)
      File.file?(join(name))
    end

    #
    # Determines whether the directory has the given directory.
    #
    # @return [Boolean]
    #
    def directory?(name)
      File.directory?(join(name))
    end

    #
    # Finds all files and directories matching the pattern.
    #
    # @param [String] pattern
    #   The glob pattern.
    #
    # @return [Array<String>]
    #   The matching file and directory paths.
    #
    def glob(pattern)
      Dir[join(@path,pattern)]
    end

    #
    # Converts the directory to a String.
    #
    # @return [String]
    #   The path to the directory.
    #
    def to_s
      @path
    end

  end
end
