# termbox-crystal

Crystal bindings and wrapper for termbox

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  termbox:
    github: andrewsuzuki/termbox-crystal
```

## Usage

```crystal
require "termbox"
```

See [termbox.h](https://github.com/nsf/termbox/blob/master/src/termbox.h) for now.

### Example

```crystal
w = Termbox::Window.new

w.set_output_mode(Termbox::OUTPUT_256)
w.set_primary_colors(89, 207)
w.clear()

(0..10).each do |i|
  w.put(3 + i, 5, 48 + i, 69, 238)
end

w.cursor(3, 3)

w.render()
sleep(5)
w.shutdown()
```

## Contributing

1. Fork it (https://github.com/andrewsuzuki/termbox-crystal/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [andrewsuzuki](https://github.com/andrewsuzuki) Andrew Suzuki - creator, maintainer
