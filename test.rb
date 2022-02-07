require 'gosu'
require_relative 'colors.'

def draw_rect(x, y, width, height, color, hollow=false)
    if hollow
        Gosu.draw_line(x, y, color, x + width, y, color)
        Gosu.draw_line(x + width, y, color, x + width, y + width, color)
        Gosu.draw_line(x + width, y + width, color, x, y + width, color)
        Gosu.draw_line(x, y + width, color, x, y, color)
    else
        Gosu.draw_rect(x, y, width, height, color, z=0, mode=:add)
    end
end


class Test < Gosu::Window

    def initialize()
        @colors = Colors.new
        @image = Gosu::Image.from_blob(50, 50, rgba = "\255\0\0\255" * (50 * 50))
        @image2 = Gosu::Image.from_blob(50, 50, rgba = "\255\0\0\255" * (50 * 50))
        super(640, 400)
    end

    def draw()
        draw_rect(0, 0, 640, 400, @colors.white)

        # Gosu.draw_rect(40, 40, 50, 50, @colors.red, z=0, mode=:add)
        # Gosu.draw_rect(50, 40, 50, 50, @colors.red, z=0, mode=:add)
        @image.draw(100, 100, 0, 1, 1, Gosu::Color.new(100, 255, 255, 255))
        @image2.draw(110, 110, 0, 1, 1, Gosu::Color.new(100, 255, 255, 255))
    end
end

Test.new.show