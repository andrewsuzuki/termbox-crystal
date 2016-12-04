module Termbox
  # A position is a simple coordinate
  struct Position
    getter :x, :y

    def initialize(@x : Int32, @y : Int32)
    end

    def new_transform(x : Int32, y : Int32)
      Position.new(@x + x, @y + y)
    end
  end
end
