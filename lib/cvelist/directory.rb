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
    # Joins the file/directory name(s) with the directory path.
    #
    # @param [Array<String>] names
    #   The file/directory name(s).
    #
    # @return [String]
    #
    def join(*names)
      File.join(@path,*names)
    end

    #
    # Determines whether the directory has the given file.
    #
    # @param [String] name
    #
    # @return [Boolean]
    #
    def file?(name)
      File.file?(join(name))
    end

    #
    # Determines whether the directory has the given directory.
    #
    # @param [String] name
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
      Dir[join(pattern)]
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
