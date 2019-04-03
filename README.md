# netrcx

[![Build Status](https://travis-ci.org/bsm/netrcx.png?branch=master)](https://travis-ci.org/bsm/netrcx)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A working netrc reader and parser for Ruby.

## Usage (Ruby)

```ruby
require 'netrcx'

# Read from default location
netrc = Netrcx.read

# Read the default entry (if set)
netrc.default # => #<Netrcx::Entry default=true, login="me">

# Find a specific entry
netrc['github.com'] # => #<Netrcx::Entry default=false, host=github.com, login="s3cret/t0ken">
```
