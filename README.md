# termbox-crystal

Crystal bindings and wrapper for termbox

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  termbox:
    github: andrewsuzuki/termbox-crystal
```

Don't have termbox-c? Just run `./install-termbox.sh`, it will clone termbox into lib-termbox and symlink it to within /usr/local/lib. Or check out the [termbox](https://github.com/nsf/termbox) project page for more information.

## Usage

```crystal
require "termbox"
```

See [termbox.h](https://github.com/nsf/termbox/blob/master/src/termbox.h) and examples for now.

### Examples

See `examples/simple.cr` for basic usage.

## Contributing

1. Fork it (https://github.com/andrewsuzuki/termbox-crystal/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [andrewsuzuki](https://github.com/andrewsuzuki) Andrew Suzuki - creator, maintainer
