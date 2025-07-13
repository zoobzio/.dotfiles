local M = {}

-- Configuration
local config = {
    socket_path = '/tmp/kevin.sock',
    auto_open_files = true,
    debug = true  -- Enable debug by default for testing
}

-- State
local socket = nil
local connected = false
local current_context = {}

-- Utility functions
local function log(message)
    if config.debug then
        print("[Kevin] " .. message)
    end
end

local function get_doc_path(file_path)
    if file_path == "" then return "" end
    return "docs/" .. file_path .. ".md"
end

local function read_file_if_exists(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*all")
        file:close()
        return content
    end
    return ""
end

local function get_buffer_content()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    return table.concat(lines, '\n')
end

-- Socket communication
local function connect_kevin()
    local uv = vim.loop
    socket = uv.new_pipe(false)
    
    socket:connect(config.socket_path, function(err)
        if err then
            log("Failed to connect to Kevin: " .. err)
            connected = false
        else
            log("Connected to Kevin")
            connected = true
            M.register_instance()
            M.send_context()
        end
    end)
    
    -- Handle incoming messages
    socket:read_start(function(err, data)
        if err then
            log("Socket read error: " .. err)
            return
        end
        
        if data then
            M.handle_kevin_message(data)
        end
    end)
end

local function send_message(msg_type, content, metadata)
    if not connected or not socket then
        log("Not connected to Kevin")
        return
    end
    
    local message = {
        type = msg_type,
        content = content or "",
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        metadata = metadata or {}
    }
    
    local json_msg = vim.json.encode(message) .. '\n'
    socket:write(json_msg, function(err)
        if err then
            log("Failed to send message: " .. err)
        end
    end)
end

-- Core functionality
function M.register_instance()
    local pid = vim.fn.getpid()
    local cwd = vim.fn.getcwd()
    
    send_message("focus_gained", "", {
        pid = pid,
        working_dir = cwd
    })
    
    log("Registered instance - PID: " .. pid .. ", CWD: " .. cwd)
end

function M.send_context()
    if not connected then return end
    
    local buf = vim.api.nvim_get_current_buf()
    local file_path = vim.api.nvim_buf_get_name(buf)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local doc_path = get_doc_path(file_path)
    
    current_context = {
        file_path = file_path,
        file_content = get_buffer_content(),
        docs_path = doc_path,
        docs_content = read_file_if_exists(doc_path),
        cursor_line = cursor[1],
        cursor_col = cursor[2],
        working_dir = vim.fn.getcwd(),
        pid = vim.fn.getpid()
    }
    
    send_message("context_update", current_context.file_content, {
        pid = current_context.pid,
        working_dir = current_context.working_dir,
        file_path = file_path,
        docs_path = doc_path,
        docs_content = current_context.docs_content,
        cursor_line = current_context.cursor_line,
        cursor_col = current_context.cursor_col
    })
end

function M.handle_kevin_message(data)
    -- Split by newlines in case multiple messages are batched
    for line in data:gmatch("[^\n]+") do
        local ok, message = pcall(vim.json.decode, line)
        if not ok then
            log("Failed to parse message: " .. line)
            return
        end
        
        if message.type == "open_file" and message.metadata.file_path then
            M.open_file(message.metadata.file_path)
        end
    end
end

function M.open_file(file_path)
    if not config.auto_open_files then return end
    
    -- Check if file exists, create if it doesn't
    local file = io.open(file_path, "r")
    if not file then
        log("File doesn't exist yet: " .. file_path)
        return
    end
    file:close()
    
    -- Open in a split window
    vim.cmd("vsplit " .. vim.fn.fnameescape(file_path))
    log("Opened file: " .. file_path)
end

function M.send_focus_gained()
    send_message("focus_gained", "", {
        pid = vim.fn.getpid(),
        working_dir = vim.fn.getcwd()
    })
end

function M.send_focus_lost()
    send_message("focus_lost", "", {
        pid = vim.fn.getpid(),
        working_dir = vim.fn.getcwd()
    })
end

-- User commands
function M.create_docs()
    local file_path = vim.api.nvim_buf_get_name(0)
    if file_path == "" then
        print("No file in current buffer")
        return
    end
    
    local doc_path = get_doc_path(file_path)
    
    -- Create docs directory if it doesn't exist
    local doc_dir = vim.fn.fnamemodify(doc_path, ":h")
    vim.fn.mkdir(doc_dir, "p")
    
    -- Create or open the doc file
    vim.cmd("vsplit " .. vim.fn.fnameescape(doc_path))
    
    -- If new file, add a header
    if vim.fn.line('$') == 1 and vim.fn.getline(1) == '' then
        local header = {
            "# Documentation for " .. vim.fn.fnamemodify(file_path, ":t"),
            "",
            "## Overview",
            "",
            "## Functions",
            "",
            "## Notes",
            ""
        }
        vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
    end
end

function M.show_status()
    print("Kevin Voice Plugin Status:")
    print("  Connected: " .. (connected and "Yes" or "No"))
    print("  Socket: " .. config.socket_path)
    print("  Current file: " .. (current_context.file_path or "None"))
    print("  Docs file: " .. (current_context.docs_path or "None"))
end

-- Setup function
function M.setup(opts)
    opts = opts or {}
    config = vim.tbl_deep_extend("force", config, opts)
    
    -- Connect to Kevin
    connect_kevin()
    
    -- Set up autocmds
    local group = vim.api.nvim_create_augroup("KevinVoice", { clear = true })
    
    -- Send context on buffer changes
    vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, {
        group = group,
        callback = function()
            M.send_context()
        end
    })
    
    -- Send context on cursor movement (debounced)
    local timer = vim.loop.new_timer()
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = group,
        callback = function()
            timer:start(500, 0, vim.schedule_wrap(function()
                M.send_context()
            end))
        end
    })
    
    -- Handle focus events
    vim.api.nvim_create_autocmd("FocusGained", {
        group = group,
        callback = M.send_focus_gained
    })
    
    vim.api.nvim_create_autocmd("FocusLost", {
        group = group,
        callback = M.send_focus_lost
    })
    
    -- Create user commands
    vim.api.nvim_create_user_command("KevinDocs", M.create_docs, {
        desc = "Create/open documentation file for current buffer"
    })
    
    vim.api.nvim_create_user_command("KevinStatus", M.show_status, {
        desc = "Show Kevin plugin status"
    })
    
    log("Kevin Voice plugin initialized")
end

return M