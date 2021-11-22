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
    attr_accessor :visited, :visiting, :path

    def initialize(row, column, sizeX, sizeY, colors, visited=false, visiting=false, path=false)
        @row, @column = row, column
        @sizeX, @sizeY = sizeX, sizeY
        @colors = colors

        @visited = visited
        @visiting = visiting
        @path = path
    end

    def draw()
        if @path
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:path], false)
            draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, 0xffffffff, true)                
        elsif @visited
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

    attr_reader :width, :height, :rows, :columns, :cells, :cellSizeX, :cellSizeY, :color

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

    def get_adjacent(grid, cell)
        row, col = cell.row, cell.column

        possible = []

        [-1, 1].each do |r|
            if row + r <= @rows && row + r >= 0
                possible.append(grid.cells[(row + r) * (grid.columns + 1) + col])
            end
        end

        [-1, 1].each do |c|
            if col + c <= @columns && col + c >= 0
                possible.append(grid.cells[row * (grid.columns + 1) + col + c])
            end
        end

        [-1, 1].each do |r|
            [-1, 1].each do |c|
                if col + c <= @columns && col + c >= 0 && row + r <= @rows && row + r >= 0
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

            while not queue.empty? do
                currentPath = queue.pop
                currentCell = currentPath[-1]

                if currentCell.visited
                    next
                elsif currentCell == endCell
                    currentPath.each do |cell|
                        cell.path = true
                    end

                    break
                end
                currentCell.visited = true
                get_adjacent(self, currentCell).each do |cell|
                    cell.visiting = true
                    queue << currentPath + [cell]
                    sleep(0.01)
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
                    sleep(0.01)
                end
            end

        end
    end

    def draw
        @cells.each do |cell|
            cell.draw
        end
    end

    def reset
        @cells.each do |cell|
            cell.visited = false
            cell.visiting = false
        end
    end
end


class Game < Gosu::Window

    def initialize(colors=nil)
        @windowW, @windowH = [600, 600]
        
        if colors == nil
            c = Colors.new
            colors = {"default": colors.black, "visited": colors.red, "visiting": colors.yellow}
        end
        
        @grid = Grid.new(@windowW, @windowH, 20, 20, cellCollors=colors)

        @end = @grid.cells[rand(0...@grid.rows) * (@grid.columns + 1) + rand(0..@grid.columns)]
        @start = @grid.cells[rand(0...@grid.rows) * (@grid.columns + 1) + rand(0..@grid.columns)]
        @start.path = true
        @end.path = true

        super @windowW, @windowH
        self.caption = "Game"

        @grid.BFS(@start, @end)
    end
    
    def event_loop

    end

    def draw
        # @font.draw_text("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
        @grid.draw()
    end

    def update
    end
end

colors = Colors.new
window = Game.new({"default": colors.black, "visited": colors.red, "visiting": colors.yellow, "path": colors.green})
window.show()
