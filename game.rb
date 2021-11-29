require 'gosu'
require_relative 'colors.rb'


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
    attr_accessor :visited, :visiting, :path, :wall

    def initialize(row, column, sizeX, sizeY, colors, wall=false, visited=false, visiting=false, path=false)
        @row, @column = row, column
        @sizeX, @sizeY = sizeX, sizeY
        @colors = colors

        @visited = visited
        @visiting = visiting
        @path = path
        @wall = wall
    end

    def draw()
        if @path
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:path], false)
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, 0xff_000000, true)                
        elsif @visited
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:visited], false)
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, 0xff_000000, true)
        elsif @visiting
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:visiting], false)
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, 0xff_000000, true)
        elsif @wall
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:wall], false)
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, 0xff_000000, true)
        else
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:default], false)
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, 0xff_000000, true)
        end
    end
end


class Grid

    attr_reader :width, :height, :rows, :columns, :cells, :cellSizeX, :cellSizeY, :color

    def initialize(width, height, rows, columns, cellColors={"default": 0xff_000000, "visiting": 0xff_ffffff, "visited": 0xff_ffffff}, updateSpeed=0.001)
        @width, @height = width, height
        @rows, @columns = rows, columns
        @cellSizeX, @cellSizeY, = @width / @columns, @height / @rows
        @colors = cellColors
        @updateSpeed = updateSpeed

        @cells = []
        (0..@rows).each do |row|
            (0..@columns).each do |col|
                @cells.append(Cell.new(row, col, @cellSizeX, @cellSizeY, @colors, false, false))
            end
        end
    end

    def get_adjacent(grid, cell)
        row, col = cell.row, cell.column

        possible = []

        [-1, 1].each do |r|
            if row + r <= @rows && row + r >= 0 && !grid.cells[(row + r) * (grid.columns + 1) + col].wall
                possible.append(grid.cells[(row + r) * (grid.columns + 1) + col])
            end
        end

        [-1, 1].each do |c|
            if col + c <= @columns && col + c >= 0 && !grid.cells[row * (grid.columns + 1) + col + c].wall
                possible.append(grid.cells[row * (grid.columns + 1) + col + c])
            end
        end

        [-1, 1].each do |r|
            [-1, 1].each do |c|
                if col + c <= @columns && col + c >= 0 && row + r <= @rows && row + r >= 0 && !grid.cells[(row + r) * (grid.columns + 1) + col + c].wall
                    possible.append(grid.cells[(row + r) * (grid.columns + 1) + col + c])
                end
            end
        end

        return possible
    end

    def BFS(startCell, endCell)
        Thread.new do
            queue = Queue.new
            queue << [startCell]

            while !queue.empty? do
                currentPath = queue.pop
                currentCell = currentPath[-1]

                if currentCell.visited || currentCell.wall
                    next
                elsif currentCell == endCell
                    currentPath.each { |cell| cell.path = true }
                    break
                end

                currentCell.visited = true
                get_adjacent(self, currentCell).each do |cell|
                    cell.visiting = true
                    queue << currentPath + [cell]
                    sleep(@updateSpeed)
                end
            end
        end
    end

    def DFS(startCell, endCell)
        Thread.new do
            stack = []
            stack << startCell

            while not stack.empty? do
                current = stack.pop

                if current.visited
                    next
                elsif current == endCell
                    break
                end
                current.visited = true
                get_adjacent(self, current).each do |cell|
                    cell.visiting = true
                    stack << cell
                    sleep(@updateSpeed)
                end
            end

        end
    end

    def draw
        @cells.each { |cell| cell.draw }
    end

    def reset
        @cells.each do |cell|
            cell.visited = false
            cell.visiting = false
            cell.wall = false
        end
    end
end



class Game < Gosu::Window

    def initialize(colors=nil, updateSpeed=0.001)
        @windowW, @windowH = [600, 600]
        
        if colors == nil
            c = Colors.new
            colors = {"default": colors.white, "wall": colors.black, "visited": colors.red, "visiting": colors.yellow, "path": colors.green}
        end
        
        @grid = Grid.new(@windowW, @windowH, 20, 20, colors, updateSpeed)

        @end = @grid.cells[rand(0...@grid.rows) * (@grid.columns + 1) + rand(0..@grid.columns)]
        @start = @grid.cells[rand(0...@grid.rows) * (@grid.columns + 1) + rand(0..@grid.columns)]
        @start.path = true
        @end.path = true

        super @windowW, @windowH
        self.caption = "Game"

        @simulate = false
    end

    def draw
        # @font.draw_text("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
        @grid.draw()
    end

    def events
        if button_down?(Gosu::KbSpace)
            @simulate = true
        end


        if button_down?(Gosu::MsLeft) || button_down?(Gosu::MsRight)
            if mouse_y >= 0 && mouse_y <= @windowH && mouse_x >= 0 && mouse_x <= @windowW
                cell = @grid.cells[(mouse_y / @grid.cellSizeY).to_i * (@grid.columns + 1) + (mouse_x / @grid.cellSizeX).to_i]
                
                if !cell.path
                    cell.wall = button_down?(Gosu::MsLeft) ? true : false
                end
            end
        end
    end

    def update
        events()
        
        if @simulate
            @grid.BFS(@start, @end)
        end
    end
end

colors = Colors.new
window = Game.new({"default": colors.white, "wall": colors.black, "visited": colors.red, "visiting": colors.yellow, "path": colors.green})
window.show()
