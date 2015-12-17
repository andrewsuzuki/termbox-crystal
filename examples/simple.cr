require "../src/termbox"

# Instantiate new termbox window
w = Termbox::Window.new

# Use 256 color mode
w.set_output_mode(Termbox::OUTPUT_256)
# Use yellow foreground, pink background
w.set_primary_colors(226, 207)
# Reset things
w.clear()

# Write 0 - 9 on the 5th row, 3rd column
# using gray background and blue font color
(0..9).each do |i|
  w.put(3 + i, 5, 48 + i, 69, 238)
end

# Place the cursor at 3, 3
w.cursor(3, 3)

# Render the screen
w.render()

# So we can see things for a bit
sleep(2)

# Essential to call shutdown to reset lower-level
# terminal flags
w.shutdown()
