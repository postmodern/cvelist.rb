module CVEList
  # Base class for all git related exceptions.
  class GitError < RuntimeError
  end

  # Raised when a `git clone` failed.
  class CloneFailedError < GitError
  end

  # Raised when a `git pull` failed.
  class PullFailedError < GitError
  end

  class NotFoundError < RuntimeError
  end

  class YearDirNotFound < NotFoundError
  end

  class RangeDirNotFound < NotFoundError
  end

  class CVENotFound < NotFoundError
  end
end
