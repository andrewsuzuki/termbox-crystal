require "./element"

module Termbox
  # A cell is a coordinate with content and foreground/background colors
  class Cell < Termbox::Element
    getter :position, :char, :foreground, :background

    # Make a cell with a specified foreground and background
    def initialize(@char : Char, @position : Position, @foreground : Int, @background : Int)
    end

    # Make a cell with default colors
    def initialize(char : Char, position : Position)
      initialize(char, position, COLOR_NIL, COLOR_NIL)
    end

    # Make a new cell with a position transformed by x and y
    def new_transform(x : Int, y : Int)
      Cell.new(@char, @position.new_transform(x, y), @foreground, @background)
    end

    # Render as list of cells
    def render : Array(Cell)
      [self]
    end
  end
end
