require "../termbox"

module TermboxHelpers
  def write_line(x : Int, y : Int, frontground : Int, background : Int, line : String)
    line.each_char_with_index do |char, i|
      put(x + i, y, char, frontground, background)
    end
  end

  def write_line(x : Int, y : Int, line : String)
    write_line(x, y, @frontground, @background, line)
  end

  def write_line(cell : Termbox::Cell, frontground : Int, background : Int, line : String)
    write_line(cell.x, cell.y, frontground, background, line)
  end

  def write_line(cell : Termbox::Cell, line : String)
    write_line(cell.x, cell.y, @frontground, @background, line)
  end
end
