return {
    name = "kevin",
    dir = vim.fn.stdpath("config") .. "/lua/plugins/kevin",
    config = function()
        local M = {}

        -- Configuration
        local config = {
            socket_path = '/tmp/kevin.sock',
            auto_open_files = true,
            debug = true,  -- Enable debug by default for testing
            enable_rag = true,
            auto_start_listener = true
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

        -- Search function using kevin's protocol
        function M.search_code(query)
            send_message("search", query, {})
            log("Searching for: " .. query)
        end

        -- Voice control is now automatic with focus/blur events
        -- No need for explicit start/stop functions

        -- Socket communication
        local function check_kevin_service()
            local uv = vim.loop
            local test_socket = uv.new_pipe(false)
            local is_available = false
            
            test_socket:connect(config.socket_path, function(err)
                if not err then
                    is_available = true
                    test_socket:close()
                end
            end)
            
            -- Give it a brief moment to test connection
            vim.wait(100, function() return is_available end)
            return is_available
        end

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
                    vim.schedule(function()
                        M.register_instance()
                        -- Voice starts automatically with focus event
                    end)
                end
            end)
            
            -- Handle incoming messages
            socket:read_start(function(err, data)
                if err then
                    log("Socket read error: " .. err)
                    return
                end
                
                if data then
                    vim.schedule(function()
                        M.handle_kevin_message(data)
                    end)
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
                else
                    log("Sent message: " .. msg_type .. " - " .. content)
                end
            end)
        end

        -- Core functionality
        function M.register_instance()
            local pid = vim.fn.getpid()
            local cwd = vim.fn.getcwd()
            
            -- Send initial focus event
            send_message("focus", "", {
                pid = pid,
                working_dir = cwd
            })
            
            log("Registered instance - PID: " .. pid .. ", CWD: " .. cwd)
        end

        function M.update_context()
            local buf = vim.api.nvim_get_current_buf()
            local file_path = vim.api.nvim_buf_get_name(buf)
            local cursor = vim.api.nvim_win_get_cursor(0)
            local doc_path = get_doc_path(file_path)
            
            -- Get language/filetype
            local filetype = vim.bo.filetype
            
            -- Get current function context (simple version - line based)
            local current_line = cursor[1]
            local lines = vim.api.nvim_buf_get_lines(buf, math.max(0, current_line - 10), current_line + 10, false)
            local context_snippet = table.concat(lines, '\n')
            
            -- Only get git info when explicitly needed (lazy)
            current_context = {
                file_path = file_path,
                file_content = get_buffer_content(),
                docs_path = doc_path,
                docs_content = read_file_if_exists(doc_path),
                cursor_line = cursor[1],
                cursor_col = cursor[2],
                working_dir = vim.fn.getcwd(),
                pid = vim.fn.getpid(),
                git_branch = nil,  -- Lazy load when needed
                git_status = nil,  -- Lazy load when needed
                filetype = filetype,
                context_snippet = context_snippet
            }
        end
        
        function M.get_git_info()
            -- Only call this when actually needed
            if not current_context.git_branch then
                current_context.git_branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub('\n', '')
                current_context.git_status = vim.fn.system("git status --porcelain 2>/dev/null"):gsub('\n', '\\n')
            end
            return current_context.git_branch, current_context.git_status
        end

        function M.handle_kevin_message(data)
            -- Split by newlines in case multiple messages are batched
            for line in data:gmatch("[^\n]+") do
                local ok, message = pcall(vim.json.decode, line)
                if not ok then
                    log("Failed to parse message: " .. line)
                    return
                end
                
                if message.type == "open_file" then
                    if message.metadata and message.metadata.file_path then
                        M.open_file(message.metadata.file_path)
                    end
                    
                elseif message.type == "search_result" then
                    -- Kevin found code
                    if message.metadata then
                        print("Found: " .. (message.metadata.file_path or "Unknown") .. ":" .. (message.metadata.cursor_line or "?"))
                        -- Could auto-open the file if desired
                    end
                    
                elseif message.type == "notification" then
                    -- Kevin notification
                    print("[Kevin] " .. message.content)
                    
                elseif message.type == "voice_status" then
                    -- Voice status update
                    log("Voice status: " .. message.content)
                    
                elseif message.type == "error" then
                    -- Error from kevin
                    print("[Kevin Error] " .. message.content)
                    
                elseif message.type == "goto_line" then
                    -- Navigate to specific line
                    vim.api.nvim_win_set_cursor(0, {message.metadata.line, 0})
                    
                elseif message.type == "search_text" then
                    -- Search for text in current buffer
                    vim.cmd("/" .. vim.fn.escape(message.content, '/\\'))
                    
                elseif message.type == "insert_text" then
                    -- Insert text at current cursor position
                    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                    vim.api.nvim_buf_set_text(0, row-1, col, row-1, col, {message.content})
                    
                elseif message.type == "request_context" then
                    -- Kevin is asking for current context
                    M.update_context()
                    send_message("context_response", current_context.context_snippet, {
                        file_path = current_context.file_path,
                        cursor_line = current_context.cursor_line,
                        cursor_col = current_context.cursor_col,
                        filetype = current_context.filetype
                    })
                    
                elseif message.type == "request_file" then
                    -- Kevin is asking for full file
                    M.update_context()
                    send_message("file_response", current_context.file_content, {
                        file_path = current_context.file_path,
                        filetype = current_context.filetype
                    })
                    
                elseif message.type == "request_git_info" then
                    -- Kevin needs git info
                    local git_branch, git_status = M.get_git_info()
                    send_message("git_info_response", "", {
                        git_branch = git_branch,
                        git_status = git_status,
                        working_dir = current_context.working_dir
                    })
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
            send_message("focus", "", {
                pid = vim.fn.getpid(),
                working_dir = vim.fn.getcwd()
            })
        end

        function M.send_focus_lost()
            send_message("blur", "", {
                pid = vim.fn.getpid()
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
            
            -- Check if Kevin service is running before setting up
            if not check_kevin_service() then
                vim.notify("Kevin service not running, plugin disabled", vim.log.levels.INFO)
                return
            end
            
            -- Connect to Kevin
            connect_kevin()
            
            -- RAG is now handled through kevin's socket interface
            
            -- Set up autocmds
            local group = vim.api.nvim_create_augroup("KevinVoice", { clear = true })
            
            -- Only track focus for kevin to know which nvim instance is active
            vim.api.nvim_create_autocmd("FocusGained", {
                group = group,
                callback = M.send_focus_gained
            })
            
            vim.api.nvim_create_autocmd("FocusLost", {
                group = group,
                callback = M.send_focus_lost
            })
            
            -- Clean up on exit
            vim.api.nvim_create_autocmd("VimLeavePre", {
                group = group,
                callback = function()
                    if socket then
                        socket:close()
                    end
                end
            })
            
            -- Create user commands
            vim.api.nvim_create_user_command("KevinDocs", M.create_docs, {
                desc = "Create/open documentation file for current buffer"
            })
            
            vim.api.nvim_create_user_command("KevinStatus", M.show_status, {
                desc = "Show Kevin plugin status"
            })
            
            vim.api.nvim_create_user_command("KevinSearch", function(opts)
                M.search_code(opts.args)
                -- Results will come back as search_result messages
            end, {
                nargs = 1,
                desc = "Search codebase using Kevin's RAG"
            })
            
            vim.api.nvim_create_user_command("KevinChat", function(opts)
                send_message("chat", opts.args, {})
                print("Sent to Kevin: " .. opts.args)
            end, {
                nargs = 1,
                desc = "Chat with Kevin"
            })
            
            vim.api.nvim_create_user_command("KevinExplain", function()
                M.update_context()
                send_message("explain", "What does this code do?", {
                    file_path = current_context.file_path,
                    cursor_line = current_context.cursor_line
                })
            end, {
                desc = "Ask Kevin to explain current code"
            })
            
            vim.api.nvim_create_user_command("KevinShow", function()
                -- Update context first
                M.update_context()
                -- Send context update
                send_message("context", "", {
                    pid = vim.fn.getpid(),
                    file_path = current_context.file_path,
                    cursor_line = current_context.cursor_line,
                    cursor_col = current_context.cursor_col
                })
                print("Shared current context with Kevin")
            end, {
                desc = "Share current context with Kevin"
            })
            
            
            log("Kevin Voice plugin initialized")
        end

        -- Initialize the plugin
        M.setup()
    end
}