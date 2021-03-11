local Rects = {};
Rects.__index = Rects;

function Rect(x, y, w, h)
    if (x == nil or type(x) ~= "number") then x = 0; end
    if (y == nil or type(y) ~= "number") then y = 0; end
    if (w == nil or type(w) ~= "number") then w = 0; end
    if (h == nil or type(h) ~= "number") then h = 0; end

    x = x or 0;
    y = y or 0;
    w = w or 0;
    h = h or 0;

    return setmetatable({ x = x, y = y, w = w, h = h }, Rects);
end

function Rects:pointInside(vec)
    if (vec.x >= self.x and vec.x <= self.x + self.w and vec.y >= self.y and vec.y <= self.y + self.h) then 
        return true; 
    else 
        return false; 
    end
end

local windows = {{ name = "watermark", rect = Rect(1660, 10, 250, 20), sizable = false }};
local mouseHandler = { controlX = 0, controlY = 0, controlSelected = false, controlSelectedIndex = 0 };
local controls = { gui.add_checkbox("Enabled", true), gui.add_checkbox("Override HUD", true), gui.add_dropdown_multi("HUD Features", "Watermark", "Keybinds", "Weapons", "Health", "Spectator's List", "Scoreboard", "Bomb Timer", "Hitlist"), gui.add_colorpicker("Header Color", color.new(200, 103, 245, 255)) };
local locationControls = {};
local locationControlsVisible = true;

local localPlayer;
local scrSize = engine.screen_size();
local mouseVec = keys.get_mouse();

for i = 1, #windows do
    if (not windows[i][6]) then
        table.insert(locationControls, {gui.add_spacer(windows[i].name, 15), gui.add_slider(windows[i].name .. " X Axis", 0, scrSize.x, windows[i].rect.x), gui.add_slider(windows[i].name .. " Y Axis", 0, scrSize.y, windows[i].rect.y)});
    else
        table.insert(locationControls, {gui.add_spacer(windows[i].name, 15), gui.add_slider(windows[i].name .. " X Axis", 0, scrSize.x, windows[i].rect.x), gui.add_slider(windows[i].name .. " Y Axis", 0, scrSize.y, windows[i].rect.y), gui.add_slider(windows[i].name .. " Width", windows[i].minWidth, windows[i].maxWidth, windows[i].rect.w)});
    end
end

function handleWindows(windowName)
    if (#windows ~= 0) then
        for i = 1, #windows do
            if (windowName ~= nil) then -- Handle window lookups.
                if (windows[i].name == windowName) then
                    return i;
                end
            end
        end
    end

    -- Handle window movement
    if (keys.key_down(0x01)) then
        if (keys.key_pressed(0x01)) then
            if (#windows ~= 0) then
                for i = 1, #windows do
                    if (windows[i].rect:pointInside(mouseVec)) then
                        if (not mouseHandler.controlSelected) then
                            mouseHandler.controlX = mouseVec.x - windows[i].rect.x;
                            mouseHandler.controlY = mouseVec.y - windows[i].rect.y;
                            mouseHandler.controlSelected = true;
                            mouseHandler.controlSelectedIndex = i;
                        end
                    end
                end
            end
        else
            if (mouseHandler.controlSelected) then
                if (mouseVec.y - mouseHandler.controlY >= 0 and mouseVec.y - mouseHandler.controlY <= scrSize.y - windows[mouseHandler.controlSelectedIndex].rect.h) then
                    windows[mouseHandler.controlSelectedIndex].rect.y = mouseVec.y - mouseHandler.controlY;
                end

                if (mouseVec.x - mouseHandler.controlX >= 0 and mouseVec.x - mouseHandler.controlX <= scrSize.x - windows[mouseHandler.controlSelectedIndex].rect.w) then
                    windows[mouseHandler.controlSelectedIndex].rect.x = mouseVec.x - mouseHandler.controlX;
                end
            end
        end
    else
        if (mouseHandler.controlSelected) then
            locationControls[mouseHandler.controlSelectedIndex][2]:set_value(windows[mouseHandler.controlSelectedIndex].rect.x);
            locationControls[mouseHandler.controlSelectedIndex][3]:set_value(windows[mouseHandler.controlSelectedIndex].rect.y);
        end

        mouseHandler.controlSelected = false;
        mouseHandler.controlSelectedIndex = 0;
    end
end

local function stringContains(str1, str2)
    if (str1 ~= nil and str2 ~= nil) then
        if (string.find(str1:lower(), str2:lower())) then
            return true;
        else
            return false;
        end
    end
end

function drawWindow(windowName)
    if (windowName ~= nil) then
        local index = handleWindows(windowName);

        renderer.filled_rect(windows[index].rect.x, windows[index].rect.y, windows[index].rect.w, 2, controls[4]:get_value());
        renderer.filled_rect(windows[index].rect.x, windows[index].rect.y + 2, windows[index].rect.w, windows[index].rect.h - 2, color.new(20, 20, 20, 150));
        return index;
    end

    return 0;
end

function drawWatermark()
    local index = drawWindow("watermark");
end

function on_render()
    -- Handlers
    scrSize = engine.screen_size();
    mouseVec = keys.get_mouse();
    handleWindows();

    if (controls[1]:get_value()) then
        if (stringContains(controls[3]:get_value(), "Watermark")) then drawWatermark(); end
    end
end
