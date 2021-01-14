# cvelist.rb

* [Homepage](https://github.com/postmodern/cvelist.rb#readme)
* [Issues](https://github.com/postmodern/cvelist.rb/issues)
* [Documentation](http://rubydoc.info/gems/cvelist/frames)
* [Email](mailto:postmodern.mod3 at gmail.com)

## Description

A Ruby library for parsing the CVE JSON in the [cvelist] git repository.

## Features

* Supports downloading/updating [cvelist] Git repository.
* Supports [CVE JSON Schema v4.0][1]

## Examples

    require 'cvelist'

Cloning the [cvelist] repository:

    repo = CVEList::Repository.clone('path/to/cvelist')

Using an existing [cvelist] repository:

    repo = CVEList::Repository.new('path/to/cvelist')

Updating an existing [cvelist] repository:

    repo.pull!

Enumerating over every [CVE] in a repository:

    repo.each do |cve|
      puts cve.id
    end

## Requirements

* [multi_json] ~> 1.0
* [cve_schema] ~> 0.1

## Install

    $ gem install cvelist

## Copyright

Copyright (c) 2020-2021 Hal Brodigan

See {file:LICENSE.txt} for details.

[cvelist]: https://github.com/CVEProject/cvelist
[1]: https://github.com/CVEProject/cve-schema/blob/master/schema/v4.0/DRAFT-JSON-file-format-v4.md

[multi_json]: https://github.com/intridea/multi_json#readme
[cve_schema]: https://github.com/postmodern/cve_schema.rb#readme

[CVE]: https://rubydoc.info/gems/cve_schema/CVESchema/CVE/frames
