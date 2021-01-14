require 'cve_schema/exceptions'

module CVEList
  # Base class for all git related exceptions.
  class GitError < RuntimeError
  end

  # Raised when a `git clone` failed.
  class GitCloneFailed < GitError
  end

  # Raised when a `git pull` failed.
  class GitPullFailed < GitError
  end

  class NotFoundError < RuntimeError
  end

  class YearDirNotFound < NotFoundError
  end

  class RangeDirNotFound < NotFoundError
  end

  class CVENotFound < NotFoundError
  end

  InvalidJSON = CVESchema::InvalidJSON
  MissingJSONKey = CVESchema::MissingJSONKey
  UnkownJSONValue = CVESchema::UnknownJSONValue
end
