-- Below is a small example program where you can move a circle
-- around with the crank. You can delete everything in this file,
-- but make sure to add back in a playdate.update function since
-- one is required for every Playdate game!
-- =============================================================

-- Importing libraries used for drawCircleAtPoint and crankIndicator
import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/animation"

import "t9"

-- Localizing commonly used globals
local pd <const> = playdate
local gfx <const> = playdate.graphics

pd.inputHandlers.push(T9InputHandlers)

local font = gfx.font.new("fonts/MonoCarlo")

local scale = 2
playdate.display.setScale(scale)
local padding = 6/scale
local right = playdate.display.getWidth() - padding
local bottom = playdate.display.getHeight() - padding

gfx.setImageDrawMode(gfx.kDrawModeInverted)
local cursorBlink = gfx.animation.blinker.new(200, 200, true)
cursorBlink:start()

-- playdate.update function is required in every project!
function playdate.update()
    -- Clear screen
    gfx.clear(gfx.kColorBlack)
    gfx.animation.blinker.updateAll()
    -- Draw text
    local preW, preH = gfx.getTextSizeForMaxWidth(TextInput.precursorText, right-padding)
    local postW, postH = gfx.getTextSizeForMaxWidth(TextInput.postcursorText, right-padding)

    if preH > bottom then
        gfx.setDrawOffset(0, -font:getHeight() * math.ceil((preH-bottom)/font:getHeight()))
    else
        gfx.setDrawOffset(0,0)
    end

    gfx.setFont(font)
    local cursorchar = '|'
    if TextInput.currentInput.char and cursorBlink.on then
        cursorchar = TextInput.currentInput.char
    end
    gfx.drawTextInRect(TextInput.precursorText .. cursorchar .. TextInput.postcursorText, padding, padding, right, preH+postH)

    RenderHintBoxes()
end

local function update_scale(inScale)
    scale = inScale
    playdate.display.setScale(scale)
    padding = math.max(1, 6/scale)
    right = playdate.display.getWidth() - padding
    bottom = playdate.display.getHeight() - padding
end

playdate.getSystemMenu():addOptionsMenuItem("Scale", {"1", "2", "4"}, tostring(scale), function(opt)
    update_scale(opt)
end)