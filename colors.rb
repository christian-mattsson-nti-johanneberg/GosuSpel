class Colors
    attr_reader :black, :gray, :white, :aqua, :red, :green, :blue, :yellow, :cyan

    def initialize()
        @black = 0xff_000000
        @gray = 0xff_808080
        @white = 0xff_ffffff
        @aqua = 0xff_00ffff
        #@red = 0xff_ff0000
        @green = 0xff_00ff00
        @blue = 0xff_0000ff
        @yellow = Gosu::Color.new(150, 255, 255, 0)
        @cyan = 0xff_00ffff
        @red = Gosu::Color.new(20, 255, 0, 0)
    end
end
