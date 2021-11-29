require_relative 'colors.rb'

class Sub_Window

    def initialize(x, y, width, height, background=colors.black)
        @x, @y = [x, y]
        @pos = [x, y]

        @width, @height = width, height
        @size = [@width, @height]

        @background = background_color
    end

    
    #def over?(x, y, w, h)
    #    return @x >= x && @x <= x+w && @y >= y && @y <= y+h
    #end
    
end

