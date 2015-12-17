require "../src/termbox"

# Instantiate new termbox window
w = Termbox::Window.new

# Use 256 color mode
w.set_output_mode(Termbox::OUTPUT_256)
# Use red foreground, periwinkle background
w.set_primary_colors(196, 189)
# Reset things
w.clear()

# Write 0 - 9 on the 5th row, 3rd column
# using gray background and blue font color
(0..9).each do |i|
  w.put(3 + i, 5, 48 + i, 69, 238)
end

startat = Termbox::Cell.new(1, 1)
w.write_line(startat, "this is a test of write line!")

startat2 = Termbox::Cell.new(w.width - "this goes off the".size, w.height - 1)
w.write_line(startat2, "this goes off the page")

# Place the cursor at 3, 3
w.cursor(3, 3)

# Render the screen
w.render()

# So we can see things for a bit
sleep(2)

# Essential to call shutdown to reset lower-level
# terminal flags
w.shutdown()
