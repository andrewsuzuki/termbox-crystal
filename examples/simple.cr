require "../src/termbox"

include Termbox

# Instantiate new termbox window
w = Window.new

# Use 256 color mode
w.set_output_mode(OUTPUT_256)
# Use red foreground, periwinkle background
w.set_primary_colors(196, 189)
# Reset things
w.clear()

# Write a string
w.write_string(Position.new(3, 3), "this is a test of write line")

# Write a string that goes "off the screen"
startat2 = Position.new(w.width - "this goes off the".size, w.height - 1)
w.write_string(startat2, "this goes off the page")

# Place the cursor at 3, 3
w.cursor(Position.new(3, 3))

# Draw vertical line on left margin
w.put(Line.new(Cell.new('|', Position.new(1, 1)), 15, true))

# Draw box
w.put(Border.new(Position.new(4, 4), 15, 6, '-'))

# Draw double box
w.put(Border.new(Position.new(20, 4), 15, 6, "double"))

# Draw dotted box with solid box over it
w.put(Border.new(Position.new(36, 4), 15, 6, "dotted"))
w.put(Border.new(Position.new(38, 5), 15, 6, "solid"))

# Draw custom border (at-signs) on the border of a container

contain = Container.new(Position.new(54, 4), 15, 6)
  contain.put(Border.new(contain, '@'))
  contain.put(Cell.new('A', Position.new(2, 2), 231, 82))
  w.put(contain)

# Render the screen
w.render()

# So we can see things for a bit
sleep(1)

# Write 0 - 9 again on 6th row, clearing 5th row as we go
(0..9).each do |i|
  w.put(Cell.new(i.to_s.char_at(0), Position.new(5 + i, 6), 56, 190))
  w.clear_cell(Position.new(5 + i, 5))
  # Put cursor after this cell
  w.cursor(Position.new(6 + i, 6))
  sleep(0.1)
  w.render()
end

sleep(2)

# Essential to call shutdown to reset lower-level
# terminal flags
w.shutdown()
