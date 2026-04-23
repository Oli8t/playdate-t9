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
pdKeyboardT9 = {
    pdUpdate = nil,
    text = "",
    state = keyboardState.kHidden,
    activeAnim = nil,
    keyFont = gfx.font.new("/System/Fonts/Roobert-11-Medium"),
    previewFont = gfx.font.new("/System/Fonts/Roobert-20-Medium"),

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
            [11] = { " " }
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
            [11] = { " " }
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
            [11] = { "0", "`" }
        },
    },
    mode = 1,
    keyW = 0,
    keyH = 0,
    padding = 1,

    currentInput = { button = nil, presses = 0, char = nil },
    update_current_char = function(self)
        if self.currentInput.button and self.currentInput.presses > 0 then
            local chars = self.keyMappings[self.mode][self.currentInput.button]
            self.currentInput.char = chars[(self.currentInput.presses - 1) % #chars + 1]
        end
    end,

    commit_character = function(self)
        if self.currentInput.button and self.currentInput.presses > 0 then
            local chars = self.keyMappings[self.mode][self.currentInput.button]
            local char = chars[(self.currentInput.presses - 1) % #chars + 1]
            self.text = self.text .. char
            self.textChangedCallback()
        end
        self.currentInput = { button = nil, presses = 0, char = nil }
    end,
    shiftAccumulated = 0,
    closeTimer = nil,
    isCancel = false,

    onCloseTimer = function()
        pdKeyboardT9.hide()
        pdKeyboardT9.keyboardWillHideCallback(pdKeyboardT9.isCancel == false)
    end,

    inputHandlers = {
        AButtonUp = function()
            pdKeyboardT9:commit_character()
            if pdKeyboardT9.closeTimer then pdKeyboardT9.closeTimer:remove() end
        end,
        BButtonUp = function()
            pdKeyboardT9:commit_character()
            pdKeyboardT9.deleteAccumulated = 0
            if pdKeyboardT9.closeTimer then pdKeyboardT9.closeTimer:remove() end
        end,
        AButtonDown = function()
            pdKeyboardT9:commit_character()
            if playdate.buttonIsPressed(playdate.kButtonB) then
                pdKeyboardT9.closeTimer = playdate.timer.new(1000, pdKeyboardT9.onCloseTimer)
                pdKeyboardT9.isCancel = false
            end
        end,
        BButtonDown = function()
            pdKeyboardT9:commit_character()
            if playdate.buttonIsPressed(playdate.kButtonA) then
                pdKeyboardT9.closeTimer = playdate.timer.new(1000, pdKeyboardT9.onCloseTimer)
                pdKeyboardT9.isCancel = true
            end
        end,
        leftButtonDown = function()
            local button = (playdate.buttonIsPressed(playdate.kButtonA) and 5) or
                (playdate.buttonIsPressed(playdate.kButtonB) and 10) or 4
            if button == 10 then
                pdKeyboardT9.mode += 1
                if pdKeyboardT9.mode > #pdKeyboardT9.keyMappings then
                    pdKeyboardT9.mode = 1
                end
                return
            end
            if pdKeyboardT9.currentInput.button ~= button then
                if pdKeyboardT9.currentInput.button then
                    pdKeyboardT9:commit_character()
                end
                pdKeyboardT9.currentInput = { button = button, presses = 0 }
            end
            pdKeyboardT9.currentInput.presses += 1
            pdKeyboardT9:update_current_char()
        end,
        rightButtonDown = function()
            local button = (playdate.buttonIsPressed(playdate.kButtonB) and 5) or
                (playdate.buttonIsPressed(playdate.kButtonA) and 11) or 6
            if pdKeyboardT9.currentInput.button ~= button then
                if pdKeyboardT9.currentInput.button then
                    pdKeyboardT9:commit_character()
                end
                pdKeyboardT9.currentInput = { button = button, presses = 0 }
            end
            pdKeyboardT9.currentInput.presses += 1
            pdKeyboardT9:update_current_char()
        end,
        upButtonDown = function()
            local button = (playdate.buttonIsPressed(playdate.kButtonB) and 1) or
                (playdate.buttonIsPressed(playdate.kButtonA) and 3) or 2
            if pdKeyboardT9.currentInput.button ~= button then
                if pdKeyboardT9.currentInput.button then
                    pdKeyboardT9:commit_character()
                end
                pdKeyboardT9.currentInput = { button = button, presses = 0 }
            end
            pdKeyboardT9.currentInput.presses += 1
            pdKeyboardT9:update_current_char()
        end,
        downButtonDown = function()
            local button = (playdate.buttonIsPressed(playdate.kButtonB) and 7) or
                (playdate.buttonIsPressed(playdate.kButtonA) and 9) or 8
            if pdKeyboardT9.currentInput.button ~= button then
                if pdKeyboardT9.currentInput.button then
                    pdKeyboardT9:commit_character()
                end
                pdKeyboardT9.currentInput = { button = button, presses = 0 }
            end
            pdKeyboardT9.currentInput.presses += 1
            pdKeyboardT9:update_current_char()
        end,
        cranked = function(change, acceleratedChange)
            pdKeyboardT9.shiftAccumulated += change
            if math.abs(pdKeyboardT9.shiftAccumulated) > 45 then
                pdKeyboardT9.shiftAccumulated = 0
                if pdKeyboardT9.currentInput.button then
                    pdKeyboardT9.currentInput = { button = nil, presses = 0, char = nil }
                else
                    pdKeyboardT9.text = pdKeyboardT9.text:sub(0, -2)
                    pdKeyboardT9.textChangedCallback()
                end
            end
        end,
    }
}

function pdKeyboardT9.Initialize()
    for _, chars in pairs(pdKeyboardT9.keyMappings[pdKeyboardT9.mode]) do
        pdKeyboardT9.keyW = math.max(pdKeyboardT9.keyW, pdKeyboardT9.keyFont:getTextWidth(table.concat(chars)))
    end
    pdKeyboardT9.keyW += (2 * pdKeyboardT9.padding)
    pdKeyboardT9.keyH = pdKeyboardT9.keyFont:getHeight() + (2 * pdKeyboardT9.padding) + gfx.getSystemFont():getHeight()
end

function pdKeyboardT9.show(text)
    if pdKeyboardT9.keyW == 0 then
        pdKeyboardT9.Initialize()
    end
    pdKeyboardT9.text = text
    if keyboardState.HiddenOrHiding(pdKeyboardT9.state) then
        pdKeyboardT9.pdUpdate = playdate.update
        playdate.update = pdKeyboardT9.update
        pdKeyboardT9.state = keyboardState.kAnimatingIn
        pdKeyboardT9.activeAnim = gfx.animator.new(200, 400, 222)
    end
end

function pdKeyboardT9.hide()
    if keyboardState.HiddenOrHiding(pdKeyboardT9.state) == false then
        pdKeyboardT9.state = keyboardState.kAnimatingOut
        pdKeyboardT9.activeAnim = gfx.animator.new(200, 222, 400)
    end
end

function pdKeyboardT9.left()
    return pdKeyboardT9.activeAnim and pdKeyboardT9.activeAnim:currentValue() or 400
end

function pdKeyboardT9.width()
    return pdKeyboardT9.activeAnim and (400 - pdKeyboardT9.activeAnim:currentValue()) or 0
end

function pdKeyboardT9.isVisible()
    return pdKeyboardT9.state ~= keyboardState.kHidden
end

function pdKeyboardT9.update()
    pdKeyboardT9.pdUpdate()

    if keyboardState.HiddenOrHiding(pdKeyboardT9.state) and pdKeyboardT9.activeAnim:ended() then
        pdKeyboardT9.state = keyboardState.kHidden
        playdate.update = pdKeyboardT9.pdUpdate
        playdate.inputHandlers.pop()
        pdKeyboardT9.keyboardDidHideCallback()
        pdKeyboardT9.text = ""
    end

    if pdKeyboardT9.state == keyboardState.kAnimatingIn and pdKeyboardT9.activeAnim:ended() then
        playdate.inputHandlers.push(pdKeyboardT9.inputHandlers, true)
        pdKeyboardT9.state = keyboardState.kShowing
        pdKeyboardT9.keyboardDidShowCallback()
    end

    if pdKeyboardT9.activeAnim and pdKeyboardT9.activeAnim:ended() == false then
        pdKeyboardT9.keyboardAnimatingCallback()
    end

    pdKeyboardT9.render()
end

function pdKeyboardT9.render()
    if pdKeyboardT9.keyFont then
        gfx.setFont(pdKeyboardT9.keyFont)
    end

    local w = pdKeyboardT9.keyW
    local h = pdKeyboardT9.keyH
    local totalW = w * 3
    local lx = (pdKeyboardT9.activeAnim and pdKeyboardT9.activeAnim:currentValue()) or 400
    local px = lx + (400 - lx) / 2 - totalW / 2
    local py = h*2
    local dir = (playdate.buttonIsPressed(playdate.kButtonA) and 3) or
    (playdate.buttonIsPressed(playdate.kButtonB) and 1) or 2
    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(3)
    gfx.drawLine(lx, 0, lx, 240)
    for y = 1, 3 do
        for x = 1, 3 do
            local sel = false
            if y == 2 then
                sel = (dir == 2 and x ~= dir) or (dir ~= 2 and x == 2)
            else
                sel = x == dir
            end
            gfx.setColor(sel and gfx.kColorWhite or gfx.kColorBlack)
            gfx.fillRect(px + w * (x-1), py + h * (y - 1), w, h)
            local chars = pdKeyboardT9.keyMappings[pdKeyboardT9.mode][x + 3 * (y - 1)]
            local str = ""
            for c = 1, #chars do
                str = str .. chars[c]
            end
            gfx.setImageDrawMode(gfx.kDrawModeNXOR)
            gfx.drawText(str, pdKeyboardT9.padding + px + w * (x -1), pdKeyboardT9.padding + py + h * (y - 1))
            if sel then
                gfx.getSystemFont():drawText((y==1 and "⬆️") or (y==3 and "⬇️") or (dir==3 and "⬅️") or (dir==1 and "➡️") or (x==1 and "⬅️") or "➡️", pdKeyboardT9.padding + px + w * (x -1), pdKeyboardT9.padding + py + h * (y) -gfx.getSystemFont():getHeight())
            end
        end
    end
    py -= 3
    gfx.setColor(dir == 1 and gfx.kColorWhite or gfx.kColorBlack)
    gfx.fillRect(px, py-h, w, h)
    gfx.getSystemFont():drawText("Ⓑ", px, py-h-gfx.getSystemFont():getHeight())
    gfx.drawText("Aa1", pdKeyboardT9.padding + px, pdKeyboardT9.padding + py-h )
    if dir == 1 then
        gfx.getSystemFont():drawText("⬅️", pdKeyboardT9.padding + px, pdKeyboardT9.padding + py - gfx.getSystemFont():getHeight())
    end

    gfx.setColor(dir == 3 and gfx.kColorWhite or gfx.kColorBlack)
    gfx.fillRect(px + w * 2, py - h, w, h)
    local space_case = pdKeyboardT9.keyMappings[pdKeyboardT9.mode][11]
    local str = ""
    for c = 1, #space_case do
        str = str .. (space_case[c] == " " and "(sp)" or space_case[c])
    end
    gfx.getSystemFont():drawText("Ⓐ", px + w*3 - gfx.getSystemFont():getTextWidth("Ⓐ"), py-h-gfx.getSystemFont():getHeight())
    gfx.drawText(str, pdKeyboardT9.padding + px + w * 3 - gfx.getFont():getTextWidth(str), pdKeyboardT9.padding + py - h)
    if dir == 3 then
        gfx.getSystemFont():drawText("➡️", pdKeyboardT9.padding + px + w*2, pdKeyboardT9.padding + py - gfx.getSystemFont():getHeight())
    end

    local width = gfx.getSystemFont():getTextWidth("🎣") + gfx.getFont():getTextWidth(": DEL")
    gfx.getSystemFont():drawText("🎣", lx + (400-lx)/2 - width/2, 240-gfx.getSystemFont():getHeight())
    gfx.drawText(": DEL", lx + (400-lx)/2 - width/2 + gfx.getSystemFont():getTextWidth("🎣"), 240-gfx.getSystemFont():getHeight())

    if pdKeyboardT9.currentInput.char then
        if pdKeyboardT9.previewFont then
            gfx.setFont(pdKeyboardT9.previewFont)
        end
        gfx.drawTextAligned(pdKeyboardT9.currentInput.char, px + 3*w/2 - gfx.getFont():getTextWidth(pdKeyboardT9.currentInput.char)/2, 40, gfx.kAlignCenter)
    end
end
