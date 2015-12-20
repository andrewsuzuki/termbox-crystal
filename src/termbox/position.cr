module Termbox
  # A position is a simple coordinate
  struct Position
    getter :x, :y

    def initialize(@x : Int, @y : Int)
    end

    def new_transform(x : Int, y : Int)
      Position.new(@x + x, @y + y)
    end
  end
end
