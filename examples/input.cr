require "../src/termbox"

include Termbox

# Instantiate new termbox window
w = Window.new

# Set input mode (ESC mode with mouse enabled)
w.set_input_mode(INPUT_ESC | INPUT_MOUSE)

# Use 256 color mode
w.set_output_mode(OUTPUT_256)
# Use red foreground, periwinkle background
w.set_primary_colors(196, 189)
# Reset things
w.clear()

w.render()

loop do
  ev = w.poll()
  if ev.is_a? Termbox::Event::Key
    if [Termbox::KEY_CTRL_C, Termbox::KEY_CTRL_D].includes? ev.key
      break
    end
  elsif ev.is_a? Termbox::Event::Resize
    w.write_string(Position.new(3, 3), "resize!!")
  elsif ev.is_a? Termbox::Event::Mouse
    w.write_string(Position.new(3, 4), "mouse!!", COLOR_MAGENTA - 1, COLOR_CYAN - 1)
  end
  w.render()
end

# Essential to call shutdown to reset lower-level
# terminal flags
w.shutdown()
