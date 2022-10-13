# cvelist

[![CI](https://github.com/postmodern/cvelist.rb/actions/workflows/ruby.yml/badge.svg)](https://github.com/postmodern/cvelist.rb/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/postmodern/cvelist.rb.svg)](https://codeclimate.com/github/postmodern/cvelist.rb)

* [Homepage](https://github.com/postmodern/cvelist.rb#readme)
* [Issues](https://github.com/postmodern/cvelist.rb/issues)
* [Documentation](http://rubydoc.info/gems/cvelist/frames)

## Description

A Ruby library for parsing the CVE JSON in the [cvelist] git repository.

## Features

* Supports downloading/updating [cvelist] Git repository.
* Supports [CVE JSON Schema v4.0][1].
* Uses [multi_json] for configurable JSON parser.

## Examples

```ruby
require 'cvelist'
```

Cloning the [cvelist] repository:

```ruby
repo = CVEList::Repository.clone('path/to/cvelist')
```

Using an existing [cvelist] repository:

```ruby
repo = CVEList::Repository.new('path/to/cvelist')
```

Updating an existing [cvelist] repository:

```ruby
repo.pull!
```

Get the total number of CVEs in the repository:

```ruby
repo.size
```

Access an individual [CVE] in the repository:

```ruby
repo['CVE-2020-0001']
```

Enumerating over every [CVE] in the repository:

```ruby
repo.each do |cve|
  puts cve.id
end
```

Enumerating over every [CVE] in a certain year:

```ruby
repo.year(2020).each do |cve|
  puts cve.id
end
```

## Requirements

* [multi_json] ~> 1.0
* [cve_schema] ~> 0.1

## Install

```shell
$ gem install cvelist
```

### Gemfile

```ruby
gem 'cvelist', '~> 0.1'
```

## Benchmark

    Warming up the disk cache with a first run. This may take a while ...
    Parsing all 192879 CVE .json files ...
    
    Total:	 18.285097   1.651155  19.936252 ( 20.144566)
    Avg:	  0.000095   0.000009   0.000103 (  0.000104)

## Copyright

Copyright (c) 2020-2021 Hal Brodigan

See {file:LICENSE.txt} for details.

[cvelist]: https://github.com/CVEProject/cvelist
[1]: https://github.com/CVEProject/cve-schema/blob/master/schema/v4.0/DRAFT-JSON-file-format-v4.md

[multi_json]: https://github.com/intridea/multi_json#readme
[cve_schema]: https://github.com/postmodern/cve_schema.rb#readme

[CVE]: https://rubydoc.info/gems/cve_schema/CVESchema/CVE/frames
