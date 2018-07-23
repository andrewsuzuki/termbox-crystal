require "./container"

module Termbox
  class Window < Termbox::Container
    @@exists = false

    def initialize
      init_termbox()

      @event_master = TermboxBindings::Event.new type: 0, mod: 0, key: 0, ch: 0, w: 0, x: 0, y: 0

      @foreground = COLOR_WHITE
      @background = COLOR_BLACK
      super(Position.new(0, 0), 0, 0)
    end

    private def init_termbox
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

    # If the window [singleton] is GC'd, then shut down Termbox
    def finalize
      shutdown()
    end

    def shutdown
      TermboxBindings.tb_shutdown()
      @@exists = false
    end

    # Get width of termbox
    def width : Int32
      TermboxBindings.tb_width()
    end

    # Get height of termbox
    def height : Int32
      TermboxBindings.tb_height()
    end

    # Clear terminal window
    def clear : Void
      TermboxBindings.tb_clear()
    end

    # Render all children (recursively) as cells,
    # give them to termbox, present them
    def render : Array(Cell)
      # Render as list of cells
      result = super

      result.each do |el|
        put_raw(el)
      end

      render_raw()

      result
    end

    def render_raw : Void
      TermboxBindings.tb_present()
    end

    def cursor(position : Position) : Void
      cursor(position.x, position.y)
    end

    def hide_cursor : Void
      cursor(HIDE_CURSOR, HIDE_CURSOR)
    end

    def put(el : Element)
      super
    end

    def <<(el : Element)
      super
    end

    # Put a cell, bypassing @elements store
    def put_raw(cell : Cell) : Void
      put_raw(cell.position.x, cell.position.y, cell.char.ord, decide_foreground(cell.foreground), decide_background(cell.background))
    end

    # Put a decomposed cell, bypassing @elements store
    def put_raw(position : Position, char : Char, foreground, background) : Void
      put_raw(position.x, position.y, char.ord, decide_foreground(foreground), decide_background(background))
    end

    # Put a decomposed cell, bypassing @elements store, using default colors
    def put_raw(position : Position, char : Char)
      put_raw(position, char, COLOR_NIL, COLOR_NIL)
    end

    # Put a decomposed cell and decomposed position, bypassing @elements store
    private def put_raw(x : Int32, y : Int32, ch : Int32, foreground : Int32, background : Int32) : Void
      TermboxBindings.tb_change_cell(x, y, ch, foreground, background)
    end

    # Clear a single cell
    def clear_cell(position : Position) : Void
      put_raw(position, CHAR_BLANK)
    end

    # Set input mode
    def set_input_mode(mode : Int32) : Int32
      TermboxBindings.tb_select_input_mode(mode)
    end

    # Set output mode
    def set_output_mode(mode : Int32) : Int32
      TermboxBindings.tb_select_output_mode(mode)
    end

    # Set primary colors
    def set_primary_colors(foreground : Int32, background : Int32) : Void
      @foreground = foreground
      @background = background
      TermboxBindings.tb_set_clear_attributes(foreground, background)
    end

    # Move cursor position
    def cursor(position : Position) : Void
      TermboxBindings.tb_set_cursor(position.x, position.y)
    end

    # Events

    def peek(timeout : Int32)
      e = @event_master
      r = TermboxBindings.tb_peek_event(pointerof(e), timeout)
      Event.new(e) if r > 0
    end

    def poll
      e = @event_master
      TermboxBindings.tb_poll_event(pointerof(e))
      Event.new(e)
    end

    # Helpers

    # Write a string horizontal starting at pivot
    def write_string(pivot : Position, string : String)
      write_string(pivot, string, COLOR_NIL, COLOR_NIL)
    end

    # Write a string horizontal starting at pivot
    def write_string(pivot : Position, string : String, foreground : Int32, background : Int32)
      string.each_char_with_index do |char, i|
        put_raw(pivot.new_transform(i, 0), char, foreground, background)
      end
    end
    
    # Decide on foreground (if nil, use default)
    private def decide_foreground(color : Int32)
      color != COLOR_NIL ? color : @foreground
    end

    # Decide on background (if nil, use default)
    private def decide_background(color : Int32)
      color != COLOR_NIL ? color : @background
    end
  end
end
