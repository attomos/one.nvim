local M = {}

---@param highlights table<string, vim.api.keyset.highlight>
M.load = function(highlights)
    for group, highlight in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, highlight)
    end
end

M.bg = '#ffffff'
M.fg = '#000000'
M.day_brightness = 0.3

local uv = vim.uv or vim.loop

---@param c  string
local function rgb(c)
    c = string.lower(c)
    return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

local me = debug.getinfo(1, 'S').source:sub(2)
me = vim.fn.fnamemodify(me, ':h:h')

function M.mod(modname)
    if package.loaded[modname] then
        return package.loaded[modname]
    end
    local ret = loadfile(me .. '/' .. modname:gsub('%.', '/') .. '.lua')()
    package.loaded[modname] = ret
    return ret
end

---@param foreground string foreground color
---@param background string background color
---@param alpha number|string number between 0 and 1. 0 results in bg, 1 results in fg
function M.blend(foreground, alpha, background)
    alpha = type(alpha) == 'string' and (tonumber(alpha, 16) / 0xff) or alpha
    local bg = rgb(background)
    local fg = rgb(foreground)

    local blendChannel = function(i)
        local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
        return math.floor(math.min(math.max(0, ret), 255) + 0.5)
    end

    return string.format('#%02x%02x%02x', blendChannel(1), blendChannel(2), blendChannel(3))
end

function M.blend_bg(hex, amount, bg)
    return M.blend(hex, amount, bg or M.bg)
end

return M
