# Rhcf::Utils

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'rhcf-utils'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rhcf-utils (not yet)

## Usage
### Rhcf::Utils::DownloadCache

```ruby
require 'rhcf/utils/download_cache'
cache =  Rhcf::Utils::DownloadCache.new('a_cache_id', ttl=30)
cache.get("http://example.com/a_image.png") # -> "/tmp/.../a_image.png"
```
If you try to download in less then 30 seconds, you will hit the cache

## Contributing

1. Fork it ( http://github.com/romeuhcf/rhcf-utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
