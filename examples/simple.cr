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
(0..9).each do |i|
  w.put(Termbox::Cell.new(i.to_s.char_at(0), Termbox::Position.new(5 + i, 5), 56, 190))
end

w.write_string(Termbox::Position.new(3, 3), "this is a test of write line")

startat2 = Termbox::Position.new(w.width - "this goes off the".size, w.height - 1)
w.write_string(startat2, "this goes off the page")

# Place the cursor at 3, 3
w.cursor(Termbox::Position.new(3, 3))

# Draw vertical line on left margin
Termbox::Line.new(Termbox::Cell.new('|', Termbox::Position.new(1, 1)), 15, true).draw(w)

# Draw box
Termbox::Box.new(Termbox::Cell.new('-', Termbox::Position.new(4, 4)), 15, 6).draw(w)

# Draw double box
Termbox::Box.new(Termbox::Cell.new('-', Termbox::Position.new(20, 4)), 15, 6, "double").draw(w)

# Draw dotted box with solid box over it
Termbox::Box.new(Termbox::Cell.new('-', Termbox::Position.new(36, 4)), 15, 6, "dotted").draw(w)
Termbox::Box.new(Termbox::Cell.new('-', Termbox::Position.new(38, 5)), 15, 6, "solid").draw(w)

# Draw custom box (at signs)
Termbox::Box.new(Termbox::Cell.new('-', Termbox::Position.new(54, 4)), 15, 6, '@').draw(w)

# Render the screen
w.render()

# So we can see things for a bit
sleep(1)

# Write 0 - 9 again on 6th row, clearing 5th row as we go
(0..9).each do |i|
  w.put(Termbox::Cell.new(i.to_s.char_at(0), Termbox::Position.new(5 + i, 6), 56, 190))
  w.clear_cell(Termbox::Position.new(5 + i, 5))
  sleep(0.1)
  w.render()
end

sleep(2)

# Essential to call shutdown to reset lower-level
# terminal flags
w.shutdown()
