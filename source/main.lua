import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/animation"

import "pdkeyboardwrapper"
import "pdkeyboardt9"

-- Localizing commonly used globals
local pd <const> = playdate
local gfx <const> = playdate.graphics

MonoCarlo = gfx.font.new("fonts/MonoCarlo")

local kbs = {{name = "Default", kb = nil}, {name = "9KeyIsh", kb = pdKeyboardT9}}
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
    MonoCarlo:drawText("Keyboard: ".. kbs[kbi].name, 10, 20)
    MonoCarlo:drawText("Text: " .. (playdate.keyboard.text or ""), 10, 40)

end

pdKeyboardWrapper.Initialize()
pdKeyboardT9.keyFont = MonoCarlo
