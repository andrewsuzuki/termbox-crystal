require "./termbox/*"

module Termbox
  struct Position
    getter x, y

    def initialize(@x : Int, @y : Int)
    end

    def new_inc_x(x : Int)
      Position.new(@x + x, @y)
    end

    def new_inc_y(y : Int)
      Position.new(@x, @y + y)
    end
  end

  struct Cell
    getter position, char, foreground, background

    def initialize(@char : Char, @position : Position, @foreground : Int, @background : Int)
    end

    def initialize(char : Char, position : Position)
      initialize(char, position, COLOR_NIL, COLOR_NIL)
    end
  end

  class Window
    @@exists = false

    def initialize
      @foreground = COLOR_WHITE
      @background = COLOR_BLACK
      init()
    end

    private def init
      raise "Only one Window can be instantiated at once" if @@exists

      @@exists = true

      error = TermboxBindings.tb_init()

      if error == E_UNSUPPORTED_TERMINAL
        raise "Terminal is unsupported."
      elsif error == E_FAILED_TO_OPEN_TTY
        raise "Failed to open terminal."
      elsif error == E_PIPE_TRAP_ERROR
        raise "Pipe trap error."
      end
    end

    def finalize
      shutdown()
    end

    def shutdown
      TermboxBindings.tb_shutdown()
      @@exists = false
    end

    def width : Int
      TermboxBindings.tb_width()
    end

    def height : Int
      TermboxBindings.tb_height()
    end

    def clear : Void
      TermboxBindings.tb_clear()
    end

    def render : Void
      TermboxBindings.tb_present()
    end

    def cursor(position : Position) : Void
      cursor(position.x, position.y)
    end

    def hide_cursor : Void
      cursor(HIDE_CURSOR, HIDE_CURSOR)
    end

    def put(cell : Cell) : Void
      # Correct "nil" colors
      foreground = cell.foreground != COLOR_NIL ? cell.foreground : @foreground
      background = cell.background != COLOR_NIL ? cell.background : @background
      put(cell.position.x, cell.position.y, cell.char.ord, foreground, background)
    end

    def put(position : Position, char : Char, foreground, background) : Void
      # Correct "nil" colors
      foreground = foreground != COLOR_NIL ? foreground : @foreground
      background = background != COLOR_NIL ? background : @background
      put(position.x, position.y, char.ord, foreground, background)
    end

    def put(position : Position, char : Char)
      put(position, char, COLOR_NIL, COLOR_NIL)
    end

    def clear_cell(position : Position) : Void
      put(position, CHAR_BLANK, @foreground, @background)
    end

    def set_input_mode(mode : Int) : Int
      TermboxBindings.tb_select_input_mode(mode)
    end

    def set_output_mode(mode : Int) : Int
      TermboxBindings.tb_select_output_mode(mode)
    end

    def set_primary_colors(foreground : Int, background : Int) : Void
      @foreground = foreground
      @background = background
      TermboxBindings.tb_set_clear_attributes(foreground, background)
    end

    private def cursor(x : Int, y : Int) : Void
      TermboxBindings.tb_set_cursor(x, y)
    end

    private def put(x : Int, y : Int, ch : Int, foreground : Int, background : Int) : Void
      TermboxBindings.tb_change_cell(x, y, ch, foreground, background)
    end

    # Helpers

    def write_string(position : Termbox::Position, string : String)
      string.each_char_with_index do |char, i|
        put(position.new_inc_x(i), char)
      end
    end
  end

  struct Box
    getter cell, width, height

    # Specify mode
    def initialize(cell : Termbox::Cell, width : Int, height : Int, mode : String)
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

      initialize(cell, width, height, mode == "double" ? "double" : "char", char)
    end

    # Single-char-based box
    def initialize(cell : Termbox::Cell, width : Int, height : Int, char : Char)
      initialize(cell, width, height, "char", char)
    end

    # Normal box
    def initialize(cell : Termbox::Cell, width : Int, height : Int)
      initialize(cell, width, height, "normal")
    end

    # Internal constructor
    private def initialize(@cell : Termbox::Cell, @width : Int, @height : Int, @mode : String, @char : Char)
      unless ["normal", "double", "char"].includes? @mode
        @mode = "normal"
      end
    end

    def draw(window : Termbox::Window)
      fg = @cell.foreground
      bg = @cell.foreground
      # Draw four lines
      cell_top = Cell.new(symbol("top"), @cell.position.new_inc_x(1), fg, bg)
      cell_bottom = Cell.new(symbol("bottom"), @cell.position.new_inc_x(1).new_inc_y(@height - 1), fg, bg)
      cell_left = Cell.new(symbol("left"), @cell.position.new_inc_y(1), fg, bg)
      cell_right = Cell.new(symbol("right"), @cell.position.new_inc_y(1).new_inc_x(@width - 1), fg, bg)
      Line.new(cell_top, @width - 2, false).draw(window)
      Line.new(cell_bottom, @width - 2, false).draw(window)
      Line.new(cell_left, @height - 2, true).draw(window)
      Line.new(cell_right, @height - 2, true).draw(window)
      # Draw corner pieces
      window.put(Cell.new(symbol("topleft"), @cell.position, fg, bg))
      window.put(Cell.new(symbol("topright"), @cell.position.new_inc_x(@width - 1), fg, bg))
      window.put(Cell.new(symbol("bottomleft"), @cell.position.new_inc_y(@height - 1), fg, bg))
      window.put(Cell.new(symbol("bottomright"), @cell.position.new_inc_y(@height - 1).new_inc_x(@width - 1), fg, bg))
    end

    private def symbol(position : String) : Char
      if @mode == "char"
        return @char
      else
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
        end
      end
      '!'
    end
  end

  class Line
    getter cell, size, is_vertical

    def initialize(@cell : Cell, @size : Int, @is_vertical = true : Bool)
    end

    def draw(window : Window)
      (0..(@size - 1)).each do |i|
        window.put(@is_vertical ? @cell.position.new_inc_y(i) : @cell.position.new_inc_x(i), @cell.char)
      end
    end
  end

  # Keys
  KEY_F1               = (0xFFFF-0)
  KEY_F2               = (0xFFFF-1)
  KEY_F3               = (0xFFFF-2)
  KEY_F4               = (0xFFFF-3)
  KEY_F5               = (0xFFFF-4)
  KEY_F6               = (0xFFFF-5)
  KEY_F7               = (0xFFFF-6)
  KEY_F8               = (0xFFFF-7)
  KEY_F9               = (0xFFFF-8)
  KEY_F10              = (0xFFFF-9)
  KEY_F11              = (0xFFFF-10)
  KEY_F12              = (0xFFFF-11)
  KEY_INSERT           = (0xFFFF-12)
  KEY_DELETE           = (0xFFFF-13)
  KEY_HOME             = (0xFFFF-14)
  KEY_END              = (0xFFFF-15)
  KEY_PGUP             = (0xFFFF-16)
  KEY_PGDN             = (0xFFFF-17)
  KEY_ARROW_UP         = (0xFFFF-18)
  KEY_ARROW_DOWN       = (0xFFFF-19)
  KEY_ARROW_LEFT       = (0xFFFF-20)
  KEY_ARROW_RIGHT      = (0xFFFF-21)
  KEY_MOUSE_LEFT       = (0xFFFF-22)
  KEY_MOUSE_RIGHT      = (0xFFFF-23)
  KEY_MOUSE_MIDDLE     = (0xFFFF-24)
  KEY_MOUSE_RELEASE    = (0xFFFF-25)
  KEY_MOUSE_WHEEL_UP   = (0xFFFF-26)
  KEY_MOUSE_WHEEL_DOWN = (0xFFFF-27)

  # Control keys
  KEY_CTRL_TILDE       = 0x00
  KEY_CTRL_2           = 0x00
  KEY_CTRL_A           = 0x01
  KEY_CTRL_B           = 0x02
  KEY_CTRL_C           = 0x03
  KEY_CTRL_D           = 0x04
  KEY_CTRL_E           = 0x05
  KEY_CTRL_F           = 0x06
  KEY_CTRL_G           = 0x07
  KEY_BACKSPACE        = 0x08
  KEY_CTRL_H           = 0x08
  KEY_TAB              = 0x09
  KEY_CTRL_I           = 0x09
  KEY_CTRL_J           = 0x0A
  KEY_CTRL_K           = 0x0B
  KEY_CTRL_L           = 0x0C
  KEY_ENTER            = 0x0D
  KEY_CTRL_M           = 0x0D
  KEY_CTRL_N           = 0x0E
  KEY_CTRL_O           = 0x0F
  KEY_CTRL_P           = 0x10
  KEY_CTRL_Q           = 0x11
  KEY_CTRL_R           = 0x12
  KEY_CTRL_S           = 0x13
  KEY_CTRL_T           = 0x14
  KEY_CTRL_U           = 0x15
  KEY_CTRL_V           = 0x16
  KEY_CTRL_W           = 0x17
  KEY_CTRL_X           = 0x18
  KEY_CTRL_Y           = 0x19
  KEY_CTRL_Z           = 0x1A
  KEY_ESC              = 0x1B
  KEY_CTRL_LSQ_BRACKET = 0x1B
  KEY_CTRL_3           = 0x1B
  KEY_CTRL_4           = 0x1C
  KEY_CTRL_BACKSLASH   = 0x1C
  KEY_CTRL_5           = 0x1D
  KEY_CTRL_RSQ_BRACKET = 0x1D
  KEY_CTRL_6           = 0x1E
  KEY_CTRL_7           = 0x1F
  KEY_CTRL_SLASH       = 0x1F
  KEY_CTRL_UNDERSCORE  = 0x1F
  KEY_SPACE            = 0x20
  KEY_BACKSPACE2       = 0x7F
  KEY_CTRL_8           = 0x7FCE2

  # Modifiers
  MOD_ALT = 0x01

  # Colors
  COLOR_NIL     = -1
  COLOR_DEFAULT = 0x00
  COLOR_BLACK   = 0x01
  COLOR_RED     = 0x02
  COLOR_GREEN   = 0x03
  COLOR_YELLOW  = 0x04
  COLOR_BLUE    = 0x05
  COLOR_MAGENTA = 0x06
  COLOR_CYAN    = 0x07
  COLOR_WHITE   = 0x08

  # Attributes
  ATTR_BOLD      = 0x0100
  ATTR_UNDERLINE = 0x0200
  ATTR_REVERSE   = 0x0400

  # Event
  EVENT_KEY    = 1
  EVENT_RESIZE = 2
  EVENT_MOUSE  = 3

  # Error codes
  E_UNSUPPORTED_TERMINAL = -1
  E_FAILED_TO_OPEN_TTY   = -2
  E_PIPE_TRAP_ERROR      = -3

  # Input modes
  INPUT_CURRENT = 0
  INPUT_ESC     = 1
  INPUT_ALT     = 2
  INPUT_MOUSE   = 4

  # Output modes
  OUTPUT_CURRENT   = 0
  OUTPUT_NORMAL    = 1
  OUTPUT_256       = 2
  OUTPUT_216       = 3
  OUTPUT_GRAYSCALE = 4

  # Misc
  HIDE_CURSOR = -1
  EOF         = -1
  CHAR_BLANK  = ' '
end
