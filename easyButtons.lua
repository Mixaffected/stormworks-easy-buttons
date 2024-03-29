local __buttons = {}

--- Use this function to create new buttons.
---@param x number The left upper coordinate in px.
---@param y number The left upper coordinate in px.
---@param width number The width of the button.
---@param height number The height of the button.
---@param text string The text of the button.
---@param horizontalTextAlign number -1: left; 0: center; 1: right.
---@param verticalTextAlign number -1: top; 0: center; 1: bottom.
---@param target function The function that should get executed if clicked or toggled.
---@param args table|nil Input a table with the parameters in right order. Example: {246, 900}.
---@param frameColor table = {255, 255, 255}; RGB or RGBA colors in a table.
---@param innerColor table | nil RGB or RGBA colors in a table.
---@param pressedColor table | nil RGB or RGBA colors in a table just for push button.
---@param activeColor table | nil RGB or RGBA colors in a table just for toggle button.
---@param textColor table = {255, 255, 255}; RGB or RGBA colors in a table.
---@param isToggle boolean | nil = false; If the button should be a push or a toggle button.
---@param tag string | nil If you want to identify this special button. Can also be used on more buttons to identify groups.
function newButton(x, y, width, height, text, target, args, frameColor, innerColor, pressedColor, activeColor, textColor,
                   isToggle, horizontalTextAlign, verticalTextAlign, tag)
    if x == nil or y == nil or width == nil or height == nil or text == nil or target == nil then
        return false
    end

    x = math.floor(x)
    y = math.floor(y)
    width = math.floor(width)
    height = math.floor(height)

    frameColor = frameColor or { 255, 255, 255 }
    textColor = textColor or { 255, 255, 255 }
    isToggle = isToggle or false
    horizontalTextAlign = horizontalTextAlign or 0
    verticalTextAlign = verticalTextAlign or 0

    local buttonNew = {
        ["tag"] = tag,
        ["x"] = x,
        ["y"] = y,
        ["width"] = width,
        ["height"] = height,
        ["text"] = text,
        ["isToggle"] = isToggle,
        ["horizontalAlign"] = horizontalTextAlign,
        ["verticalAlign"] = verticalTextAlign,
        ["target"] = target,
        ["args"] = args,
        ["frameColor"] = frameColor,
        ["innerColor"] = innerColor,
        ["pressedColor"] = pressedColor,
        ["activeColor"] = activeColor,
        ["textColor"] = textColor,
        ["isPressed"] = false,
        ["isHeld"] = false,
        ["isActive"] = false
    }

    __buttons[#__buttons + 1] = buttonNew
    return true
end

--- This function removes all buttons if nil as argument or all buttons with the tag you want.
---@param tag string | nil The id you want to delete leave empty if you want to delete all.
function removeButtons(tag)
    if tag == nil then
        __buttons = {}
    else
        for key = 1, #__buttons do
            local button = __buttons[key]
            if button["tag"] == tag then
                __buttons[key] = nil
            end
        end
    end
end

--- Put this in your onTick function. This calculates all presses and returns of each button.
---@param isPressed boolean If the screen was pressed.
---@param touchX number The x coordinate in px where the screen got pressed.
---@param touchY number The y coordinate in px where the screen got pressed.
---@param tag string|nil Update just the buttons with this id.
---@return boolean isPressOnBtn If the touch position is over at least one button.
---@return boolean isBtnActivated If the press activated at least one button.
function onTickButtons(isPressed, touchX, touchY, tag)
    local isPressOnBtn = false
    local isBtnActivated = false
    for key = 1, #__buttons do
        local button = __buttons[key]

        if tag ~= nil then
            if button["tag"] ~= tag then
                goto continueOnTick
            end
        end
        -- check if button is pressed
        local isBtnPressed = isPressed and
            isPointInRectangle(touchX, touchY, button["x"], button["y"], button["width"], button["height"])
        button["isPressed"] = isBtnPressed

        -- check if button pressed
        if isBtnPressed then
            -- just execute when button is freshly pushed
            if not button["isHeld"] then
                -- isActive true
                if button["isToggle"] then
                    button["isActive"] = not button["isActive"]
                else
                    button["isActive"] = true
                end
            end
            button["isHeld"] = true

            -- check if button released
        elseif not isBtnPressed and button["isHeld"] then
            button["isHeld"] = false
        end

        -- execute if active
        if button["isActive"] then
            if button["args"] ~= nil then
                button["target"](table.unpack(button["args"]))
            else
                button["target"]()
            end

            -- reset isActive when after one
            if not button["isToggle"] then
                button["isActive"] = false
            end

            isBtnActivated = true
        end

        if isBtnPressed then
            isPressOnBtn = true
        end

        ::continueOnTick::
    end
    return isPressOnBtn, isBtnActivated
end

--- Put this function in your onDraw function. This will draw all buttons on their specified places.
---@param tag string|nil Update just the buttons with this id.
function onDrawButtons(tag)
    for key = 1, #__buttons do
        local button = __buttons[key]

        if tag ~= nil then
            if button["tag"] ~= tag then
                goto continueOnDraw
            end
        end

        -- button background
        if button["innerColor"] ~= nil then
            -- toggle
            if button["isToggle"] and not button["isActive"] then
                screen.setColor(table.unpack(button["innerColor"]))
            elseif button["isToggle"] and button["isActive"] then
                if button["isActive"] and button["activeColor"] ~= nil and button["isToggle"] then
                    screen.setColor(table.unpack(button["activeColor"]))
                end
            end

            -- push
            if not button["isToggle"] and not button["isPressed"] then
                -- inactive
                screen.setColor(table.unpack(button["innerColor"]))
            elseif not button["isToggle"] and button["isPressed"] then
                -- check if pressed color exists and apply it
                if button["isPressed"] and button["pressedColor"] ~= nil then
                    screen.setColor(table.unpack(button["pressedColor"]))
                else
                    screen.setColor(table.unpack(button["innerColor"]))
                end
            end

            screen.drawRectF(button["x"], button["y"], button["width"], button["height"])
        end

        -- button frame
        screen.setColor(table.unpack(button["frameColor"]))
        screen.drawRect(button["x"], button["y"], button["width"], button["height"])

        -- button text
        screen.setColor(table.unpack(button["textColor"]))
        screen.drawTextBox(button["x"] + 1, button["y"] + 1, button["width"] + 1, button["height"], button["text"],
            button["horizontalAlign"], button["verticalAlign"])

        ::continueOnDraw::
    end
end

-- Return true if point is in rect when not return false
function isPointInRectangle(x, y, rectX, rectY, rectW, rectH)
    return x > rectX and y > rectY and x < rectX + rectW and y < rectY + rectH
end
