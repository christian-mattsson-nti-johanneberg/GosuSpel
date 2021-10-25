require 'gosu'


class Colors
    attr_reader :black, :gray, :white, :aqua, :red, :green, :blue, :yellow, :cyan

    def initialize()
        @black = Gosu::Color.argb(0xff_000000)
        @gray = Gosu::Color.argb(0xff_808080)
        @white = Gosu::Color.argb(0xff_ffffff)
        @aqua = Gosu::Color.argb(0xff_00ffff)
        @red = Gosu::Color.argb(0xff_ff0000)
        @green = Gosu::Color.argb(0xff_00ff00)
        @blue = Gosu::Color.argb(0xff_0000ff)
        @yellow = Gosu::Color.argb(0xff_ffff00)
        @cyan = Gosu::Color.argb(0xff_00ffff)
    end
end


def draw_rect(x, y, width, height, color, hollow=false)
    if hollow
        Gosu.draw_line(x, y, color, x + width, y, color)
        Gosu.draw_line(x + width, y, color, x + width, y + width, color)
        Gosu.draw_line(x + width, y + width, color, x, y + width, color)
        Gosu.draw_line(x, y + width, color, x, y, color)
    else
        Gosu.draw_rect(x, y, width, height, color)
    end
end


class Cell

    attr_reader :row, :column, :sizeX, :sizeY, :colors
    attr_accessor :visited, :visiting

    def initialize(row, column, sizeX, sizeY, colors, visited=false, visiting=false)
        @row, @column = row, column
        @sizeX, @sizeY = sizeX, sizeY
        @colors = colors

        @visited = visited
        @visiting = visiting
    end

    def draw()
        if @visited
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:visited], false)
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, 0xffffffff, true)
        elsif @visiting
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:visiting], false)
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, 0xffffffff, true)
        else
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:default], false)
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, 0xffffffff, true)
        end
    end
end


class Grid

    attr_reader :width, :height, :rows, :columns, :cellSizeX, :cellSizeY, :color

    def initialize(width, height, rows, columns, cellColors={"default": 0x00000000, "visiting": 0xffffffff, "visited": 0xffffffff})
        @width, @height = width, height
        @rows, @columns = rows, columns
        @cellSizeX, @cellSizeY, = @width / @columns, @height / @rows
        @colors = cellColors

        @cells = []
        for row in 0..@rows do
            for col in 0..@columns
                @cells.append(Cell.new(row, col, @cellSizeX, @cellSizeY, @colors, false, false))
            end
        end
    end

    def get_adjacent(cell)
        row, col = cell

        possible = []

        for r in [-1, 1] do
            if row + r <= @rows && row + r >= 0
                possible.append([row + r, col])
            end
        end

        for c in [-1, 1] do
            if col + c <= @columns && col + c >= 0
                possible.append([row, col + c])
            end
        end

        return possible
    end

    def draw
        for cell in @cells do
            cell.draw
        end
    end

end


class Game < Gosu::Window

    def initialize(colors=nil)
        @windowW, @windowH = [600, 600]
        
        if colors == nil
            c = Colors.new
            colors = {"default": colors.black, "visited": colors.red, "visiting": colors.green}
        end
        
        @grid = Grid.new(@windowW, @windowH, 20, 20, cellCollors=colors)
        
        @end = [rand(0...@grid.rows), rand(0..@grid.columns)]
        @start = [rand(0...@grid.rows), rand(0..@grid.columns)]

        super @windowW, @windowH
        self.caption = "Game"
    end
    
    def event_loop

    end

    def draw
        # @font.draw_text("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
        @grid.draw
    end

    def update
        
    end

end

colors = Colors.new
window = Game.new({"default": colors.black, "visited": colors.red, "visiting": colors.green})
window.show()
