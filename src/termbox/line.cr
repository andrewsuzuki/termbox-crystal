require "./element"

module Termbox
  class Line < Termbox::Element
    getter :cell, :size, :is_vertical

    def initialize(@cell : Cell, @size : Int, @is_vertical : Bool = true)
    end

    def render : Array(Cell)
      final = [] of Cell

      (0..(@size - 1)).each do |i|
        final << (@is_vertical ? @cell.new_transform(0, i) : @cell.new_transform(i, 0))
      end

      final
    end
  end
end
