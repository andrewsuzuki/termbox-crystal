
module Termbox
	class Event
		def self.new(e : TermboxBindings::Event)
			case e.type
			when Termbox::EVENT_KEY
				::Termbox::Event::Key.new e.mod, e.key, e.ch
			when Termbox::EVENT_MOUSE
				::Termbox::Event::Mouse.new e.key, e.x, e.y
			when Termbox::EVENT_RESIZE
				::Termbox::Event::Resize.new e.w, e.h
			end
		end

		class Resize
			getter w : Int32
			getter h : Int32

			def initialize(@w, @h)
			end
		end

		class Mouse
			getter x : Int32
			getter y : Int32
			getter key : UInt16

			def initialize(@key, @x, @y)
			end
		end

		class Key
			getter mod : UInt8
			getter key : UInt16 | Char

			def initialize(@mod, key, ch : UInt32)
				@key = if key != 0
					key
				else
					ch.chr
				end
			end
		end
	end
end

