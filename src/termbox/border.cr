require "./element"

module Termbox
  class Border < Termbox::Element
    getter :pivot, :width, :height, :mode, :char
    property :foreground, :background

    def initialize(parent : Container, mode : String)
      initialize(Position.new(0, 0), parent.width, parent.height, mode)
    end

    def initialize(parent : Container)
      initialize(Position.new(0, 0), parent.width, parent.height)
    end

    def initialize(parent : Container, char : Char)
      initialize(Position.new(0, 0), parent.width, parent.height, char)
    end

    # For special-mode borders (normal, double, solid, cloth_low, cloth_med, cloth_high, dotted)
    def initialize(pivot : Position, width : Int32, height : Int32, mode : String)
      # Decide on border character given mode
      # For normal/double/char modes, just use X (no use)
      case mode
      when "solid"
        char = '█'
      when "cloth_low"
        char = '░'
      when "cloth_med"
        char = '▒'
      when "cloth_high"
        char = '▓'
      when "dotted"
        char = '·'
      else
        char = 'X'
      end

      initialize(pivot, width, height, mode == "double" || mode == "normal" ? mode : "char", char)
    end

    # Normal mode
    def initialize(pivot : Position, width : Int32, height : Int32)
      initialize(pivot, width, height, "normal")
    end

    # Border based on a single character
    def initialize(pivot : Position, width : Int32, height : Int32, char : Char)
      initialize(pivot, width, height, "char", char)
    end

    # Master internal constructor
    private def initialize(@pivot : Position, @width : Int32, @height : Int32, @mode : String, @char : Char)
      @foreground = COLOR_NIL
      @background = COLOR_NIL
    end

    # Render border
    def render : Array(Cell)
      final = [] of Cell

      # Shorten
      fg = @foreground
      bg = @background

      # Make four border lines (without corner pieces)
      cell_top = Cell.new(symbol("top"), @pivot.new_transform(1, 0), fg, bg)
      cell_bottom = Cell.new(symbol("bottom"), @pivot.new_transform(1, @height - 1), fg, bg)
      cell_left = Cell.new(symbol("left"), @pivot.new_transform(0, 1), fg, bg)
      cell_right = Cell.new(symbol("right"), @pivot.new_transform(@width - 1, 1), fg, bg)

      # Render lines
      final += Line.new(cell_top, @width - 2, false).render()
      final += Line.new(cell_bottom, @width - 2, false).render()
      final += Line.new(cell_left, @height - 2, true).render()
      final += Line.new(cell_right, @height - 2, true).render()

      # Render corner pieces
      final << Cell.new(symbol("topleft"), @pivot, fg, bg)
      final << Cell.new(symbol("topright"), @pivot.new_transform(@width - 1, 0), fg, bg)
      final << Cell.new(symbol("bottomleft"), @pivot.new_transform(0, @height - 1), fg, bg)
      final << Cell.new(symbol("bottomright"), @pivot.new_transform(@width - 1, @height - 1), fg, bg)

      final
    end

    # Determine which symbol to use (depending on mode and position)
    private def symbol(position : String) : Char
      if @mode == "char"
        return @char
      end

      case position
      when "top", "bottom"
        return @mode == "normal" ? '─' : '═'
      when "left", "right"
        return @mode == "normal" ? '│' : '║'
      when "topleft"
        return @mode == "normal" ? '┌' : '╔'
      when "topright"
        return @mode == "normal" ? '┐' : '╗'
      when "bottomleft"
        return @mode == "normal" ? '└' : '╚'
      when "bottomright"
        return @mode == "normal" ? '┘' : '╝'
      else
        return 'X'
      end
    end
  end
end
