import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/animation"

import "pdkeyboardwrapper"
import "pdkeyboardt9"
import "pdkeyboard9simple"

-- Localizing commonly used globals
local pd <const> = playdate
local gfx <const> = playdate.graphics

TestFont = gfx.font.new("/System/Fonts/Roobert-11-Medium")

local kbs = {{name = "Default", kb = nil}, {name = "9KeySimple", kb = pdKeyboard9Simple}, {name = "9KeyIsh (Bad)", kb = pdKeyboardT9},}
local kbi = 1

local prekbInputHandlers = {
    AButtonDown = function()
        pd.keyboard.show("test text")
    end,
    leftButtonDown = function()
        kbi -= 1
        if kbi <= 0 then
            kbi = #kbs
        end
        pdKeyboardWrapper.AssignKeyboard(kbs[kbi].kb)
    end,
    rightButtonDown = function()
        kbi += 1
        if kbi > #kbs then
            kbi = 1
        end
        pdKeyboardWrapper.AssignKeyboard(kbs[kbi].kb)
    end
}

playdate.inputHandlers.push(prekbInputHandlers)

function playdate.update()
    playdate.timer.updateTimers()
    gfx.clear(gfx.kColorBlack)
    
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    TestFont:drawText("Keyboard: ".. kbs[kbi].name, 10, 20)
    TestFont:drawText("Text: " .. (playdate.keyboard.text or ""), 10, 80)

end

pdKeyboardWrapper.Initialize()
