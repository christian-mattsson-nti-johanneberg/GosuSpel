require 'gosu'
require_relative 'colors'
require 'set'


def draw_rect(x, y, width, height, color, hollow=false, z=0)
    if hollow
        Gosu.draw_line(x, y, color, x + width, y, color)
        Gosu.draw_line(x + width, y, color, x + width, y + width, color)
        Gosu.draw_line(x + width, y + width, color, x, y + width, color)
        Gosu.draw_line(x, y + width, color, x, y, color)
    else
        Gosu.draw_rect(x, y, width, height, color, z, mode=:add)
    end
end


class Cell
    attr_reader :row, :column, :sizeX, :sizeY, :colors
    attr_accessor :visited, :visiting, :path, :wall, :visitedBy

    def initialize(row, column, sizeX, sizeY, colors, wall=false, visited=false, visiting=false, path=false)
        @row, @column = row, column
        @sizeX, @sizeY = sizeX, sizeY
        @colors = colors

        @visitedBy = Set.new()
        @visited = visited
        @visiting = visiting
        @path = path
        @wall = wall
    end

    def draw()
        @visitedBy.length.times do
            if @path
                draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:path], false)
                draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:border], true)
            elsif @visited
                draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:visited], false)
                draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:border], true)
            elsif @visiting
                draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:visiting], false)
                draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:border], true)
            elsif @wall
                draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:wall], false)
                draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:border], true)
            else
                draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:default], false)
                draw_rect(@column * @sizeX, @row * @sizeY, @sizeX, @sizeY, @colors[:border], true)
            end
        end
    end
end


class Grid

    attr_reader :width, :height, :rows, :columns, :cells, :cellSizeX, :cellSizeY

    def initialize(width, height, rows, columns, cellColors={"default": 0xff_ffffff, "visiting": 0xff_ffff00, "visited": 0xff_ff0000})
        @width, @height = width, height
        @rows, @columns = rows, columns
        @cellSizeX, @cellSizeY, = @width / @columns, @height / @rows
        @colors = cellColors

        @cells = []
        (0...@rows).each do |row|
            (0...@columns).each do |col|
                @cells.append(Cell.new(row, col, @cellSizeX, @cellSizeY, @colors, false, false))
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


class Pathfinder

    attr_reader :BFS, :DFS, :simulating
    attr_accessor :timeStep

    def initialize(timeStep)
        @timeStep = timeStep
        @simulating = false
    end

    def get_adjacent(grid, cell)
        row, col = cell.row, cell.column
        rows, columns = grid.rows, grid.columns

        possible = []

        [-1, 1].each do |r|
            if row + r < rows && row + r >= 0 && !grid.cells[(row + r) * grid.columns + col].wall
                possible.append(grid.cells[(row + r) * grid.columns + col])
            end
        end

        [-1, 1].each do |c|
            if col + c < columns && col + c >= 0 && !grid.cells[row * grid.columns + col + c].wall
                possible.append(grid.cells[row * grid.columns + col + c])
            end
        end

        [-1, 1].each do |r|
            [-1, 1].each do |c|
                if col + c < columns && col + c >= 0 && row + r < rows && row + r >= 0 && !grid.cells[(row + r) * grid.columns + col + c].wall
                    possible.append(grid.cells[(row + r) * grid.columns + col + c])
                end
            end
        end

        return possible
    end

    def BFS(grid, startCell, endCell)
        @simulating = true

        Thread.new do
            queue = Queue.new
            queue << [startCell]

            while !queue.empty? do
                currentPath = queue.pop
                currentCell = currentPath[-1]

                if currentCell.visitedBy.include?(self) || currentCell.wall
                    next
                elsif currentCell == endCell
                    currentPath.each { |cell| cell.path = true }
                    @simulating = false
                    break
                end

                currentCell.visited = true
                currentCell.visitedBy.add(self)
                get_adjacent(grid, currentCell).each do |cell|
                    cell.visiting = true
                    queue << currentPath + [cell]

                    sleep(@timeStep)
                end
            end
        end
    end

    def DFS(grid, startCell, endCell)
        @simulating = true
        Thread.new do
            stack = []
            stack << [startCell]

            while !stack.empty? do
                currentPath = stack.pop
                currentCell = currentPath[-1]

                if currentCell.visitedBy.include?(self) || currentCell.wall
                    next
                elsif currentCell == endCell
                    currentPath.each { |cell| cell.path = true }
                    @simulating = false
                    break
                end

                currentCell.visited = true
                currentCell.visitedBy.add(self)
                get_adjacent(grid, currentCell).each do |cell|
                    cell.visiting = true
                    stack << currentPath + [cell]

                    sleep(@timeStep)
                end
            end
        end
    end

end


class Game < Gosu::Window
=begin
TODO:
    - Fonvert state bools to state dict
    - Fix input events
=end

    def initialize(colors=nil, timeStep=0.001)
        @windowW, @windowH = [600, 600]
        
        if colors == nil
            c = Colors.new
            colors = {"default": colors.white, "wall": colors.black, "visited": colors.red, "visiting": colors.yellow, "path": colors.green}
        end
        
        @grid = Grid.new(@windowW, @windowH, 20, 20, colors)

        startCell = @grid.cells[rand(0...@grid.rows) * @grid.columns + rand(0...@grid.columns)]
        startCell.path = true
        @startCells = {startCell=>Pathfinder.new(timeStep)}

        @endCell = @grid.cells[rand(0...@grid.rows) * @grid.columns + rand(0...@grid.columns)]
        @endCell.path = true

        super @windowW, @windowH
        self.caption = "Game"

        @simulate = false
        @timeStep = timeStep
        @editingWalls = false
        @addWalls = true
    end

    def set_start_end(cell, start)
        if start
            if cell.path
                cell.path = false
                @startCells.delete(cell)
            else
                cell.path = true
                @startCells[cell] = Pathfinder.new(@timeStep)
            end
        else
            @endCell.path = false
            cell.path = true
            @endCell = cell
        end
    end

    def draw
        # @font.draw_text("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
        @grid.draw()
    end

    def events
        if button_down?(Gosu::KbSpace)
            @simulate = true
        end

        if button_down?(Gosu::MsLeft)
            if mouse_y >= 0 && mouse_y <= @windowH && mouse_x >= 0 && mouse_x <= @windowW
                cell = @grid.cells[(mouse_y / @grid.cellSizeY).to_i * @grid.columns + (mouse_x / @grid.cellSizeX).to_i]

                if button_down?(Gosu::KbLeftShift)
                    set_start_end(cell, true)
                elsif button_down?(Gosu::KbLeftControl)
                    if cell != @endCell
                        set_start_end(cell, false)
                    end
                else
                    if !@editingWalls
                        @editingWalls = true
                        @addWalls = !cell.wall  # If we start editing on a wall, we want to remove walls
                    end

                    if !cell.path && !cell.visited && !cell.visiting
                        cell.wall = @addWalls
                    end
                end
            end
        end

        if !button_down?(Gosu::MsLeft)
            @editingWalls = false
        end        
    end

    def update
        events()
        
        if @simulate
            @startCells.each do |startCell, pathfinder|
                if !pathfinder.simulating
                    pathfinder.BFS(@grid, startCell, @endCell)
                end
            end

            @simulate = false
        end
    end
end

colors = Colors.new
window = Game.new({"default": colors.white, "border": colors.black, "wall": colors.black, "visited": colors.red, "visiting": colors.yellow, "path": colors.green})
window.show()
