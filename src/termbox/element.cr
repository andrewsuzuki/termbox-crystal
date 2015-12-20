module Termbox
  abstract class Element
    # Render as list of cells
    abstract def render : Array(Cell)
  end
end
