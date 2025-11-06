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

function utils.select_up_down_patterns(up_pattern, down_pattern)
    local api = vim.api
    local bufnr = api.nvim_get_current_buf()
    local cursor = api.nvim_win_get_cursor(0)
    local start_line = cursor[1] - 1 -- Lua index starts at 0 for nvim_buf_get_lines
    local end_line = cursor[1] - 1

    -- Find the upper boundary line by searching backward for the up_pattern
    if not up_pattern == nil then
        for line_num = start_line, 0, -1 do
            local line = api.nvim_buf_get_lines(bufnr, line_num, line_num + 1, false)[1]
            if line and line:find(up_pattern) then
                start_line = line_num
                break
            end
        end
    end

    if not down_pattern == nil then
        -- Find the lower boundary line by searching forward for the down_pattern
        local line_count = api.nvim_buf_line_count(bufnr)
        for line_num = cursor[1] - 1, line_count - 1 do
            local line = api.nvim_buf_get_lines(bufnr, line_num, line_num + 1, false)[1]
            if line and line:find(down_pattern) then
                end_line = line_num
                break
            end
        end
    end

    -- Start visual line mode selection from start_line to end_line
    api.nvim_win_set_cursor(0, { start_line + 1, 0 }) -- Move cursor to start line
    vim.cmd('normal! V')                              -- Start linewise visual mode
    api.nvim_win_set_cursor(0, { end_line + 1, 0 })   -- Move cursor to end line (extend selection)
end

return utils
