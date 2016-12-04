require "./element"

module Termbox
  # A container is a "sandbox" for content
  class Container < Termbox::Element
    property :pivot, :width, :height
    getter :elements

    # Accepts a pivot (top left position), width, and height
    def initialize(@pivot : Position, @width : Int32, @height : Int32)
      @elements = [] of Element
    end

    def put(el : Element)
      @elements << el
    end

    # Alias put (append operator)
    def <<(el : Element)
      put(el)
    end

    # Render as list of cells
    def render : Array(Cell)
      final = [] of Cell
      @elements.each do |el|
        el.render().each do |cell|
          final << cell.new_transform(@pivot.x, @pivot.y)
        end
      end

      final
    end
  end
end
