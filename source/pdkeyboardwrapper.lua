import "CoreLibs/keyboard"

local pdKeyboard = playdate.keyboard

local kbmt = {
    __index = function(t, key)
        if key == "text" then
            return pdKeyboardWrapper.activeKeyboard.text
        end
    end,
    __newindex = function(t, key, value)
        if key == "text" then
            pdKeyboardWrapper.activeKeyboard.text = value
        else
            rawset(t, key, value)
        end
    end
}

---@diagnostic disable-next-line: lowercase-global
pdKeyboardWrapper = setmetatable({
    activeKeyboard = pdKeyboard,
    pendingKeyboard = nil,
}, kbmt)

function pdKeyboardWrapper.AssignKeyboard(keyboard)
        if playdate.keyboard.isVisible() then
            print("[Error]: Attempted keyboard assignment while open")
            return
        end
        pdKeyboardWrapper.activeKeyboard = keyboard or pdKeyboard

        -- Actual keyboard callbacks will call these wrapper handlers; user can assign their callback logic to the wrapper callback
        pdKeyboardWrapper.activeKeyboard.keyboardDidShowCallback = pdKeyboardWrapper.OnKeyboardDidShow
        pdKeyboardWrapper.activeKeyboard.keyboardDidHideCallback = pdKeyboardWrapper.OnKeyboardDidHide
        pdKeyboardWrapper.activeKeyboard.keyboardWillHideCallback = pdKeyboardWrapper.OnKeyboardWillHide
        pdKeyboardWrapper.activeKeyboard.keyboardAnimatingCallback = pdKeyboardWrapper.OnKeyboardAnimating
        pdKeyboardWrapper.activeKeyboard.textChangedCallback = pdKeyboardWrapper.OnTextChanged

        -- meta table stuff to access the keyboard's text field through the wrapper

    end

function pdKeyboardWrapper.Initialize(keyboard)
    pdKeyboardWrapper.AssignKeyboard(keyboard)
    playdate.keyboard = pdKeyboardWrapper
end

function pdKeyboardWrapper.OnKeyboardDidShow()
    if pdKeyboardWrapper.keyboardDidShowCallback then
        pdKeyboardWrapper.keyboardDidShowCallback()
    end
end

function pdKeyboardWrapper.OnKeyboardDidHide()
    if pdKeyboardWrapper.keyboardDidHideCallback then
        pdKeyboardWrapper.keyboardDidHideCallback()
    end
end

function pdKeyboardWrapper.OnKeyboardWillHide()
    if pdKeyboardWrapper.keyboardWillHideCallback then
        pdKeyboardWrapper.keyboardWillHideCallback()
    end
end

function pdKeyboardWrapper.OnKeyboardAnimating()
    if pdKeyboardWrapper.keyboardAnimatingCallback then
        pdKeyboardWrapper.keyboardAnimatingCallback()
    end
end

function pdKeyboardWrapper.OnTextChanged()
    if pdKeyboardWrapper.textChangedCallback then
        pdKeyboardWrapper.textChangedCallback()
    end
end

-- Wrapper impls for the playdate keyboard interface
function pdKeyboardWrapper.show(text)
    pdKeyboardWrapper.activeKeyboard.show(text)
end

function pdKeyboardWrapper.hide()
    pdKeyboardWrapper.activeKeyboard.hide()
end

function pdKeyboardWrapper.left()
    return pdKeyboardWrapper.activeKeyboard.left()
end

function pdKeyboardWrapper.width()
    return pdKeyboardWrapper.activeKeyboard.width()
end

function pdKeyboardWrapper.isVisible()
    return pdKeyboardWrapper.activeKeyboard.isVisible()
end
