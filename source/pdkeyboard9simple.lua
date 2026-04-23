import "CoreLibs/animator"

local gfx <const> = playdate.graphics

local keyboardState = {
    kHidden = 1,
    kAnimatingOut = 2,
    kAnimatingIn = 3,
    kShowing = 4,
}

function keyboardState.HiddenOrHiding(state)
    return state <= keyboardState.kAnimatingOut
end

---@diagnostic disable-next-line: lowercase-global
pdKeyboard9Simple = {
    pdUpdate = nil,
    text = "",
    state = keyboardState.kHidden,
    activeAnim = nil,
    keyFont = gfx.font.new("/System/Fonts/Roobert-11-Medium"),
    previewFont = gfx.font.new("/System/Fonts/Roobert-20-Medium"),
    capBehavior = playdate.keyboard.kCapitalizationNormal,

    keyMappings = {
        {
            [1] = { ".", "!", "?", "," },
            [2] = { "A", "B", "C" },
            [3] = { "D", "E", "F" },
            [4] = { "G", "H", "I" },
            [5] = { "J", "K", "L" },
            [6] = { "M", "N", "O" },
            [7] = { "P", "Q", "R", "S" },
            [8] = { "T", "U", "V" },
            [9] = { "W", "X", "Y", "Z" },
            [10] = { "" },
            [11] = { " " },
            [12] = { "" },
        },
        {
            [1] = { ".", "!", "?", "," },
            [2] = { "a", "b", "c" },
            [3] = { "d", "e", "f" },
            [4] = { "g", "h", "i" },
            [5] = { "j", "k", "l" },
            [6] = { "m", "n", "o" },
            [7] = { "p", "q", "r", "s" },
            [8] = { "t", "u", "v" },
            [9] = { "w", "x", "y", "z" },
            [10] = { "" },
            [11] = { " " },
            [12] = { "" },
        },
        {
            [1] = { "1", "\\", "|", "/" },
            [2] = { "2", "@", "~", "_" },
            [3] = { "3", "#", "[", "]" },
            [4] = { "4", "$", "{", "}" },
            [5] = { "5", "%", "(", ")" },
            [6] = { "6", "^", "'", "\"" },
            [7] = { "7", "&", ":", ";" },
            [8] = { "8", "*", "+", "-" },
            [9] = { "9", "<", "=", ">" },
            [10] = { "" },
            [11] = { "0", "`" },
            [12] = { "" },
        },
    },
    mode = 1,
    keyW = 0,
    keyH = 0,
    padding = 1,
    x=2,
    y=2,

    pos2key = {
        ["1,1"] = 1,
        ["2,1"] = 2,
        ["3,1"] = 3,
        ["1,2"] = 4,
        ["2,2"] = 5,
        ["3,2"] = 6,
        ["1,3"] = 7,
        ["2,3"] = 8,
        ["3,3"] = 9,
        ["1,4"] = 10,
        ["2,4"] = 11,
        ["3,4"] = 12,
        ["3,5"] = 13,
    },

    currentInput = { button = nil, presses = 0, char = nil },
    update_current_char = function(self)
        if self.currentInput.button and self.currentInput.presses > 0 then
            local chars = self.keyMappings[self.mode][self.currentInput.button]
            self.currentInput.char = chars[(self.currentInput.presses - 1) % #chars + 1]
            if #chars == 1 then
                self:commit_character()
            end
        end
    end,

    commit_character = function(self)
        if self.currentInput.button and self.currentInput.presses > 0 then
            local chars = self.keyMappings[self.mode][self.currentInput.button]
            local char = chars[(self.currentInput.presses - 1) % #chars + 1]
            self.text = self.text .. char
            self.textChangedCallback()

            -- if self.capBehavior == playdate.keyboard.kCapitalizationNormal then
            --     if string.match(char, "%u") then
            --         self.mode = 2
            --     end
            -- end
            if self.capBehavior == playdate.keyboard.kCapitalizationWords then
                if string.match(char, " ") and self.mode == 2 then
                    self.mode = 1
                end
            end
            if self.capBehavior == playdate.keyboard.kCapitalizationSentences then
                if string.match(char, " ") and string.find(string.sub(self.text, -2, -2), "[.!?]") then
                    self.mode = 1
                end
            end
        end
        self.currentInput = { button = nil, presses = 0, char = nil }
    end,
    isCancel = false,

    inputHandlers = {
        AButtonDown = function()
            local button = pdKeyboard9Simple.pos2key[pdKeyboard9Simple.x..","..pdKeyboard9Simple.y]
            if pdKeyboard9Simple.currentInput.button ~= button then
                if pdKeyboard9Simple.currentInput.button then
                    pdKeyboard9Simple:commit_character()
                end
                pdKeyboard9Simple.currentInput = { button = button, presses = 0 }
            end
            if button == 10 then
                pdKeyboard9Simple.mode += 1
                if pdKeyboard9Simple.mode > #pdKeyboard9Simple.keyMappings then
                    pdKeyboard9Simple.mode = 1
                end
            else
                if button == 12 then
                    pdKeyboard9Simple.isCancel = false
                    pdKeyboard9Simple.hide()
                else
                    if button == 13 then
                        pdKeyboard9Simple.isCancel = true
                        pdKeyboard9Simple.hide()
                    else
                        pdKeyboard9Simple.currentInput.presses += 1
                        pdKeyboard9Simple:update_current_char()
                    end
                end
            end
        end,
        BButtonDown = function()
            if pdKeyboard9Simple.currentInput.button then
                pdKeyboard9Simple:commit_character()
            else
                pdKeyboard9Simple.text = pdKeyboard9Simple.text:sub(0, -2)
                pdKeyboard9Simple.textChangedCallback()
            end
        end,
        leftButtonDown = function()
            if pdKeyboard9Simple.pos2key[(pdKeyboard9Simple.x-1)..","..pdKeyboard9Simple.y] then
                pdKeyboard9Simple:commit_character()
                pdKeyboard9Simple.x -= 1
            end
        end,
        rightButtonDown = function()
            if pdKeyboard9Simple.pos2key[(pdKeyboard9Simple.x+1)..","..pdKeyboard9Simple.y] then
                pdKeyboard9Simple:commit_character()
                pdKeyboard9Simple.x += 1
            end
        end,
        upButtonDown = function()
            if pdKeyboard9Simple.pos2key[pdKeyboard9Simple.x..","..(pdKeyboard9Simple.y-1)] then
                pdKeyboard9Simple:commit_character()
                pdKeyboard9Simple.y -= 1
            end
        end,
        downButtonDown = function()
            if pdKeyboard9Simple.pos2key[pdKeyboard9Simple.x..","..(pdKeyboard9Simple.y+1)] then
                pdKeyboard9Simple:commit_character()
                pdKeyboard9Simple.y += 1
            end
        end,
    }
}

function pdKeyboard9Simple.Initialize()
    for _, chars in pairs(pdKeyboard9Simple.keyMappings[pdKeyboard9Simple.mode]) do
        pdKeyboard9Simple.keyW = math.max(pdKeyboard9Simple.keyW, pdKeyboard9Simple.keyFont:getTextWidth(table.concat(chars)))
    end
    pdKeyboard9Simple.keyW += (2 * pdKeyboard9Simple.padding)
    pdKeyboard9Simple.keyH = (2 * pdKeyboard9Simple.padding) + gfx.getSystemFont():getHeight()
end

function pdKeyboard9Simple.show(text)
    if pdKeyboard9Simple.keyW == 0 then
        pdKeyboard9Simple.Initialize()
    end
    pdKeyboard9Simple.x = 2
    pdKeyboard9Simple.y = 2
    pdKeyboard9Simple.mode = 1
    pdKeyboard9Simple.text = text
    if keyboardState.HiddenOrHiding(pdKeyboard9Simple.state) then
        pdKeyboard9Simple.pdUpdate = playdate.update
        playdate.update = pdKeyboard9Simple.update
        pdKeyboard9Simple.state = keyboardState.kAnimatingIn
        pdKeyboard9Simple.activeAnim = gfx.animator.new(200, 400, 222)
    end
end

function pdKeyboard9Simple.hide()
    if keyboardState.HiddenOrHiding(pdKeyboard9Simple.state) == false then
        pdKeyboard9Simple.state = keyboardState.kAnimatingOut
        pdKeyboard9Simple.activeAnim = gfx.animator.new(200, 222, 400)
        playdate.inputHandlers.pop()
    end
end

function pdKeyboard9Simple.left()
    return pdKeyboard9Simple.activeAnim and pdKeyboard9Simple.activeAnim:currentValue() or 400
end

function pdKeyboard9Simple.width()
    return pdKeyboard9Simple.activeAnim and (400 - pdKeyboard9Simple.activeAnim:currentValue()) or 0
end

function pdKeyboard9Simple.isVisible()
    return pdKeyboard9Simple.state ~= keyboardState.kHidden
end

function pdKeyboard9Simple.update()
    pdKeyboard9Simple.pdUpdate()

    if keyboardState.HiddenOrHiding(pdKeyboard9Simple.state) and pdKeyboard9Simple.activeAnim:ended() then
        pdKeyboard9Simple.state = keyboardState.kHidden
        playdate.update = pdKeyboard9Simple.pdUpdate
        pdKeyboard9Simple.keyboardDidHideCallback()
        pdKeyboard9Simple.text = ""
    end

    if pdKeyboard9Simple.state == keyboardState.kAnimatingIn and pdKeyboard9Simple.activeAnim:ended() then
        playdate.inputHandlers.push(pdKeyboard9Simple.inputHandlers, true)
        pdKeyboard9Simple.state = keyboardState.kShowing
        pdKeyboard9Simple.keyboardDidShowCallback()
    end

    if pdKeyboard9Simple.activeAnim and pdKeyboard9Simple.activeAnim:ended() == false then
        pdKeyboard9Simple.keyboardAnimatingCallback()
    end

    pdKeyboard9Simple.render()
end

function pdKeyboard9Simple.render()
    if pdKeyboard9Simple.keyFont then
        gfx.setFont(pdKeyboard9Simple.keyFont)
    end

    local w = pdKeyboard9Simple.keyW
    local h = pdKeyboard9Simple.keyH
    local totalW = w * 3
    local lx = (pdKeyboard9Simple.activeAnim and pdKeyboard9Simple.activeAnim:currentValue()) or 400
    local px = lx + (400 - lx) / 2 - totalW / 2
    local py = h*4
    local dir = (playdate.buttonIsPressed(playdate.kButtonA) and 3) or
    (playdate.buttonIsPressed(playdate.kButtonB) and 1) or 2
    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(3)
    gfx.drawLine(lx, 0, lx, 240)
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    for y = 1, 5 do
        for x = 1, 3 do
            local sel = x == pdKeyboard9Simple.x and y == pdKeyboard9Simple.y
            gfx.setColor(sel and gfx.kColorWhite or gfx.kColorBlack)
            gfx.fillRect(px + w * (x - 1), py + h * (y - 1), w, h)
            if y < 4 then
                local chars = pdKeyboard9Simple.keyMappings[pdKeyboard9Simple.mode][x + 3 * (y - 1)]
                local str = ""
                for c = 1, #chars do
                    str = str .. chars[c]
                end
                gfx.drawText(str, pdKeyboard9Simple.padding + px + w * (x - 1),
                    pdKeyboard9Simple.padding + py + h * (y - 1))
            else
                if y == 5 then
                    if x == 3 then
                        gfx.drawText("cancel", pdKeyboard9Simple.padding + px + w * (x - 1),
                            pdKeyboard9Simple.padding + py + h * (y - 1))
                    end
                else
                    if x == 1 then
                        gfx.drawText("Aa1", pdKeyboard9Simple.padding + px + w * (x - 1),
                            pdKeyboard9Simple.padding + py + h * (y - 1))
                    else
                        if x == 2 then
                            local space_case = pdKeyboard9Simple.keyMappings[pdKeyboard9Simple.mode][11]
                            local str = ""
                            for c = 1, #space_case do
                                str = str .. (space_case[c] == " " and "(sp)" or space_case[c])
                            end
                            gfx.drawText(str, pdKeyboard9Simple.padding + px + w * (x - 1),
                                pdKeyboard9Simple.padding + py + h * (y - 1))
                        else
                            gfx.drawText("OK", pdKeyboard9Simple.padding + px + w * (x - 1),
                                pdKeyboard9Simple.padding + py + h * (y - 1))
                        end
                    end
                end
            end
        end
    end

    local width = gfx.getSystemFont():getTextWidth("Ⓑ") + gfx.getFont():getTextWidth(": DEL")
    gfx.getSystemFont():drawText("Ⓑ", lx + (400-lx)/2 - width/2, 240-gfx.getSystemFont():getHeight())
    gfx.drawText(": DEL", lx + (400-lx)/2 - width/2 + gfx.getSystemFont():getTextWidth("🎣"), 240-gfx.getSystemFont():getHeight())

    if pdKeyboard9Simple.currentInput.char then
        if pdKeyboard9Simple.previewFont then
            gfx.setFont(pdKeyboard9Simple.previewFont)
        end
        gfx.drawTextAligned(pdKeyboard9Simple.currentInput.char, px + 3*w/2 - gfx.getFont():getTextWidth(pdKeyboard9Simple.currentInput.char)/2, 40, gfx.kAlignCenter)
    end
end
