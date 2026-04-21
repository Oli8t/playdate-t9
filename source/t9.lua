local gfx <const> = playdate.graphics

SmallFont = gfx.font.new("fonts/robkohr-mono-5x8")

TextInput = {
    precursorText = "",
    postcursorText = "",
    --     1  2  3
    -- 10  4  5  6  11
    --     7  8  9
    t9Mapping = {
        [1] = { ".", "!", "?", "," },
        [2] = { "A", "B", "C" },
        [3] = { "D", "E", "F" },
        [4] = { "G", "H", "I" },
        [5] = { "J", "K", "L" },
        [6] = { "M", "N", "O" },
        [7] = { "P", "Q", "R", "S" },
        [8] = { "T", "U", "V" },
        [9] = { "W", "X", "Y", "Z" },
        [10] = { "\n" },
        [11] = { " " }
    },
    currentInput = { button = nil, presses = 0, char = nil },
    update_current_char = function(self)
        if self.currentInput.button and self.currentInput.presses > 0 then
            local chars = self.t9Mapping[self.currentInput.button]
            self.currentInput.char = chars[(self.currentInput.presses - 1) % #chars + 1]
        end
    end,

    commit_character = function(self)
        if self.currentInput.button and self.currentInput.presses > 0 then
            local chars = self.t9Mapping[self.currentInput.button]
            local char = chars[(self.currentInput.presses - 1) % #chars + 1]
            self.precursorText = self.precursorText .. char
        end
        self.currentInput = { button = nil, presses = 0, char = nil }
    end,
    shiftAccumulated = 0,
}

function RenderHintBoxes()
    local w = 26
    local h = 12
    local px = playdate.display.getWidth()/2 - w*5/2
    local py = playdate.display.getHeight() - h*3
    local dir = (playdate.buttonIsPressed(playdate.kButtonA) and 3) or (playdate.buttonIsPressed(playdate.kButtonB) and 1) or 2
    for y=1,3 do
        for x=1,3 do
            local sel = false
            if y==2 then
                sel = (dir == 2 and x ~= dir) or (dir ~= 2 and x == 2)
            else
                sel = x==dir
            end
            gfx.setColor(sel and gfx.kColorWhite or gfx.kColorBlack)
            gfx.fillRect(px + w*x, py + h*(y-1), w, h)
            local chars = TextInput.t9Mapping[x+3*(y-1)]
            local str = ""
            for c=1,#chars do
                str = str .. chars[c]
            end
            gfx.setImageDrawMode(gfx.kDrawModeNXOR)
            SmallFont:drawText(str, px + 2+w*x, py + 2+h*(y-1))
        end
    end
    gfx.setColor(dir==1 and gfx.kColorWhite or gfx.kColorBlack)
    gfx.fillRect(px, py+h, w, h)
    SmallFont:drawText("line", px,py + h)
    gfx.setColor(dir==3 and gfx.kColorWhite or gfx.kColorBlack)
    gfx.fillRect(2+px+w*4, 2+py+h, w, h)
    SmallFont:drawText("spce", 2+px+w*4,2+py+h)
end

T9InputHandlers = {
    AButtonUp = function()
        TextInput:commit_character()
    end,
    BButtonUp = function()
        TextInput:commit_character()
        TextInput.deleteAccumulated = 0
    end,
    leftButtonDown = function()
        local button = (playdate.buttonIsPressed(playdate.kButtonA) and 5) or
        (playdate.buttonIsPressed(playdate.kButtonB) and 10) or 4
        if TextInput.currentInput.button ~= button then
            if TextInput.currentInput.button then
                TextInput:commit_character()
            end
            TextInput.currentInput = { button = button, presses = 0 }
        end
        TextInput.currentInput.presses += 1
        TextInput:update_current_char()
    end,
    rightButtonDown = function()
        local button = (playdate.buttonIsPressed(playdate.kButtonB) and 5) or
        (playdate.buttonIsPressed(playdate.kButtonA) and 11) or 6
        if TextInput.currentInput.button ~= button then
            if TextInput.currentInput.button then
                TextInput:commit_character()
            end
            TextInput.currentInput = { button = button, presses = 0 }
        end
        TextInput.currentInput.presses += 1
        TextInput:update_current_char()
    end,
    upButtonDown = function()
        local button = (playdate.buttonIsPressed(playdate.kButtonB) and 1) or
            (playdate.buttonIsPressed(playdate.kButtonA) and 3) or 2
        if TextInput.currentInput.button ~= button then
            if TextInput.currentInput.button then
                TextInput:commit_character()
            end
            TextInput.currentInput = { button = button, presses = 0 }
        end
        TextInput.currentInput.presses += 1
        TextInput:update_current_char()
    end,
    downButtonDown = function()
        local button = (playdate.buttonIsPressed(playdate.kButtonB) and 7) or
            (playdate.buttonIsPressed(playdate.kButtonA) and 9) or 8
        if TextInput.currentInput.button ~= button then
            if TextInput.currentInput.button then
                TextInput:commit_character()
            end
            TextInput.currentInput = { button = button, presses = 0 }
        end
        TextInput.currentInput.presses += 1
        TextInput:update_current_char()
    end,
    cranked = function(change, acceleratedChange)
        TextInput.shiftAccumulated += change
        if TextInput.shiftAccumulated > 45 then
            TextInput.shiftAccumulated = 0
            TextInput:commit_character()
            TextInput.precursorText = TextInput.precursorText .. TextInput.postcursorText:sub(0, 1)
            TextInput.postcursorText = TextInput.postcursorText:sub(2)
        end
        if TextInput.shiftAccumulated < -45 then
            TextInput.shiftAccumulated = 0
            if playdate.buttonIsPressed(playdate.kButtonB) then
                if TextInput.currentInput.button then
                    TextInput.currentInput = { button = nil, presses = 0, char = nil }
                else
                    TextInput.precursorText = TextInput.precursorText:sub(0, -2)
                end
            else
                TextInput.postcursorText = TextInput.precursorText:sub(-1) .. TextInput.postcursorText
                TextInput.precursorText = TextInput.precursorText:sub(1, -2)
            end
        end
    end,
}
