local utils = {}

function utils.open_selection()
    vim.cmd('normal! <E>')

    local function trim(s)
        return s:match("^%s*(.-)%s*$") or ""
    end
    -- Get the start and end positions of the visual selection
    local function region_to_text(region)
        local text = ''
        local maxcol = vim.v.maxcol
        for line, cols in vim.spairs(region) do
            local endcol = cols[2] == maxcol and -1 or cols[2]
            local chunk = vim.api.nvim_buf_get_text(0, line, cols[1], line, endcol, {})[1]
            text = ('%s%s '):format(text, chunk)
        end
        return trim(text)
    end

    local r = vim.region(0, "'<", "'>", vim.fn.visualmode(), true)

    local open_object = region_to_text(r);

    if open_object ~= "" then
        -- os.execute("xdg-open " .. vim.fn.shellescape(url))  -- For Linux
        os.execute("open " .. vim.fn.shellescape(open_object) .. " 2>/dev/null") -- For macOS
        -- os.execute("start " .. vim.fn.shellescape(url))  -- For Windows
    else
        print("Empty selection")
    end
end

return utils
