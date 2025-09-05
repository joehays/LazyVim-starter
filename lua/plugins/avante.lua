-- avante.lua ? NIPRgpt (OpenAI-style) + Ollama embeddings + MCP, with endpoint autodetect + safe quoting
return {
  {
    "ravitemer/mcphub.nvim",
    enabled = false, -- Add this line to disable the plugin
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("mcphub").setup({})
    end,
  },

  {
    "yetone/avante.nvim",
    enabled = false, -- Add this line to disable the plugin
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ravitemer/mcphub.nvim",
    },

    opts = function()
      --------------------------------------------------------------------------
      -- Smart detection for an embed endpoint the *RAG container* can reach
      --------------------------------------------------------------------------
      local function trim(s) return (s or ""):gsub("%s+$", "") end
      local function sh(cmd)
        local h = io.popen(cmd)
        if not h then return nil end
        local out = h:read("*a")
        h:close()
        return trim(out or "")
      end

      local endpoint = os.getenv("OLLAMA_OPENAI_ENDPOINT")
      if not endpoint or endpoint == "" then
        if sh("getent hosts host.containers.internal >/dev/null 2>&1; echo $?") == "0" then
          endpoint = "http://host.containers.internal:11434/v1"
        elseif sh("getent hosts host.docker.internal >/dev/null 2>&1; echo $?") == "0" then
          endpoint = "http://host.docker.internal:11434/v1"
        else
          local ip = sh([[ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}']])
          if ip == "" then ip = sh([[hostname -I 2>/dev/null | awk '{print $1}']]) end
          endpoint = (ip ~= "" and ("http://" .. ip .. ":11434/v1")) or "http://127.0.0.1:11434/v1"
        end
      end

      -- Ensure Avante sees a token var for the embedder (value doesn't matter for Ollama)
      local embed_api_key_env = "OLLAMA_API_KEY"
      if not os.getenv(embed_api_key_env) then
        embed_api_key_env = nil
      end

      --------------------------------------------------------------------------
      -- Providers
      --------------------------------------------------------------------------
      local provider = vim.env.AVANTE_PROVIDER or "openai" -- your NIPRgpt is OpenAI-compatible
      local COMMON = { timeout = 120000, temperature = 0, max_tokens = 8192 }

      local OPENAI = vim.tbl_deep_extend("force", COMMON, {
        endpoint = vim.env.OPENAI_API_BASE or "https://api.niprgpt.mil/v1",
        model    = vim.env.OPENAI_CHAT_MODEL or "Anthropic Sonnet 3.7",
        api_key  = "OPENAI_API_KEY",
      })

      local CLAUDE_SONNET_37_MODEL = vim.env.CLAUDE_SONNET_37_MODEL or "claude-3-7-sonnet-latest"
      local CLAUDE_SONNET_40_MODEL = vim.env.CLAUDE_SONNET_40_MODEL or "claude-4-0-sonnet-latest"
      local CLAUDE_BASE = { endpoint = vim.env.ANTHROPIC_API_BASE or "https://api.anthropic.com" }
      local CLAUDE_SONNET_37 = vim.tbl_deep_extend("force", COMMON, { endpoint = CLAUDE_BASE.endpoint, model = CLAUDE_SONNET_37_MODEL })
      local CLAUDE_SONNET_40 = vim.tbl_deep_extend("force", COMMON, { endpoint = CLAUDE_BASE.endpoint, model = CLAUDE_SONNET_40_MODEL })
      local claude_profile = (vim.env.AVANTE_CLAUDE_PROFILE == "sonnet40") and CLAUDE_SONNET_40 or CLAUDE_SONNET_37

      --------------------------------------------------------------------------
      -- RAG: NIPRgpt LLM + Ollama embeddings (auto-detected endpoint)
      --------------------------------------------------------------------------
      local RAG = {
        enabled    = true,
        host_mount = vim.loop.cwd(), -- current project only

        provider = (provider == "claude") and "claude" or "openai",
        endpoint = (provider == "claude") and CLAUDE_BASE.endpoint or OPENAI.endpoint,

        -- LLM that synthesizes the final answer using retrieved chunks
        llm = (provider == "claude")
          and { provider = "claude", endpoint = CLAUDE_BASE.endpoint, api_key = "ANTHROPIC_API_KEY", model = claude_profile.model, extra = nil }
          or  { provider = "openai", endpoint = OPENAI.endpoint,       api_key = "OPENAI_API_KEY",    model = OPENAI.model,          extra = nil },

        -- Embeddings via Ollama's OpenAI-compatible API
        embed = (function()
          local t = { provider = "openai", endpoint = endpoint, model = vim.env.OLLAMA_EMBED_MODEL or "bge-m3", extra = nil }
          if embed_api_key_env then t.api_key = embed_api_key_env else t.api_key_name = "cmd:printf local" end
          return t
        end)(),
      }

      -- Debug prints
      vim.schedule(function()
        pcall(vim.notify, "[Avante/RAG] embed endpoint = " .. (RAG.embed and (RAG.embed.endpoint or "nil") or "nil"))
        pcall(vim.notify, "[Avante/RAG] host_mount     = " .. (RAG.host_mount or "nil"))
        pcall(vim.notify, "[Avante/RAG] provider/endpoint (LLM) = " .. (RAG.provider or "?") .. " / " .. (RAG.endpoint or "?"))
        if vim.print then vim.print("[Avante/RAG] full config:", RAG) end
      end)

      return {
        provider = provider,
        use_project_instructions = true,
        openai = OPENAI,
        claude = claude_profile,
        rag_service = RAG,
        custom_tools = (function()
          local ok, ext = pcall(require, "mcphub.extensions.avante")
          return (ok and ext and ext.mcp_tool) and { ext.mcp_tool() } or {}
        end)(),
        system_prompt = (function()
          local ok, hub = pcall(require, "mcphub")
          if ok and hub and hub.get_hub_instance then
            local inst = hub.get_hub_instance()
            if inst and inst.get_active_servers_prompt then
              return inst:get_active_servers_prompt()
            end
          end
          return ""
        end)(),
      }
    end,

    -- IMPORTANT: do env + monkey-patch *after* plugin loads and *before* first launch
    config = function(_, opts)
      -- Make port/mount configurable (use your defaults)
      vim.env.AVANTE_RAG_PORT       = vim.env.AVANTE_RAG_PORT       or "30250"
      vim.env.AVANTE_RAG_HOST_MOUNT = vim.env.AVANTE_RAG_HOST_MOUNT or vim.loop.cwd()

      -- Setup Avante with the opts table above
      require("avante").setup(opts)

      --[[
      -- Monkey-patch the sidecar launcher so envs with spaces are quoted safely
      local ok, rag = pcall(require, "avante.rag_service")
      if ok and rag and rag.launch then
        local old_launch = rag.launch
        rag.launch = function(self, o)
          -- ensure RAG_LLM_MODEL is quoted so docker gets a single token
          if o and o.rag_service and o.rag_service.llm and o.rag_service.llm.model then
            local m = o.rag_service.llm.model
            if m and m ~= "" and not m:match('^".*"$') and not m:match("^'.*'$") then
              o.rag_service.llm.model = string.format("%q", m)
            end
          end
          return old_launch(self, o)
        end
      end

      ]]
      -- place inside the avante.nvim spec `config = function(_, opts)` AFTER require("avante").setup(opts)
      local ok, rag = pcall(require, "avante.rag_service")
      if ok and rag and rag.launch then
        local old = rag.launch
        rag.launch = function(self, o)
          o = vim.deepcopy(o or {})
          -- enforce env-driven port and host mount
          local port = tonumber(vim.env.AVANTE_RAG_PORT or "20250")
          o.__force_port = port
          o.__force_host_mount = vim.env.AVANTE_RAG_HOST_MOUNT
      
          -- ensure model is quoted
          if o.rag_service and o.rag_service.llm and o.rag_service.llm.model then
            local m = o.rag_service.llm.model
            if not m:match('^".*"$') and not m:match("^'.*'$") then
              o.rag_service.llm.model = string.format("%q", m)
            end
          end
      
          -- call original
          local id = old(self, o)
      
          -- if there is a built-in health wait, we can?t intercept easily;
          -- but many builds look at __force_port/__force_host_mount we passed through.
          return id
        end
      end
    end,
  },
}





--[[
-- Define the function to read the API key from a file OUTSIDE the plugin table
local function read_api_key_from_file(filename)
  local file = io.open(filename, "r")
  if file then
    local key = file:read("*all")
    file:close()
    return key and vim.trim(key)
  else
    vim.notify("Avante: Could not open API key file: " .. filename, vim.log.levels.ERROR)
    return nil
  end
end

-- Define the path to your API key file
local google_api_key_file_path = vim.fn.expand("~/dev/google-ai.token")

return {
  "yetone/avante.nvim",
  build = "make", -- Fixed: simplified build command
  event = "VeryLazy",
  version = false,
  opts = function()
    local google_api_key = read_api_key_from_file(google_api_key_file_path)

    if not google_api_key then
      vim.notify("Avante: Google API key not loaded. Check ~/.config/nvim/google-ai.token", vim.log.levels.WARN)
    end

    return {
      provider = "google_gemini",
      vendors = {
        google_gemini = {
          endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent",
          model = "gemini-pro",
          api_key_name = "GOOGLE_API_KEY",
          timeout = 30000,
          parse_curl_args = function(opts, code_opts)
            vim.notify("=== CUSTOM PROVIDER DEBUG ===", vim.log.levels.ERROR)
            vim.notify("code_opts: " .. vim.inspect(code_opts), vim.log.levels.ERROR)

            local url = opts.endpoint .. "?key=" .. google_api_key

            -- Extract message content from code_opts
            local prompt = "Hello, please help with this code."
            if code_opts and code_opts.messages and type(code_opts.messages) == "table" then
              for _, message in ipairs(code_opts.messages) do
                if message.role == "user" and message.content then
                  prompt = message.content
                  break
                end
              end
            end

            local data = {
              contents = {
                {
                  parts = {
                    { text = prompt },
                  },
                },
              },
              generationConfig = {
                temperature = 0.7,
                maxOutputTokens = 2048,
              },
            }

            local json_data = vim.json.encode(data)
            vim.notify("Final prompt: " .. prompt, vim.log.levels.ERROR)
            vim.notify("JSON: " .. json_data, vim.log.levels.ERROR)
            vim.notify("URL: " .. url, vim.log.levels.ERROR)

            return {
              url = url,
              headers = {
                ["Content-Type"] = "application/json",
              },
              body = json_data,
            }
          end,
          parse_response_data = function(data_stream, event_state, opts)
            vim.notify("=== RESPONSE DEBUG ===", vim.log.levels.ERROR)
            vim.notify("Raw response: " .. tostring(data_stream), vim.log.levels.ERROR)

            local ok, json = pcall(vim.json.decode, data_stream)
            if not ok then
              vim.notify("JSON decode failed: " .. tostring(json), vim.log.levels.ERROR)
              return nil
            end

            vim.notify("Parsed JSON: " .. vim.inspect(json), vim.log.levels.ERROR)

            if
              json.candidates
              and #json.candidates > 0
              and json.candidates[1].content
              and json.candidates[1].content.parts
              and #json.candidates[1].content.parts > 0
            then
              local text = json.candidates[1].content.parts[1].text or ""
              vim.notify("Extracted text: " .. text, vim.log.levels.ERROR)
              return text
            end

            vim.notify("No text found in response structure", vim.log.levels.ERROR)
            return nil
          end,
          is_disable_stream = function()
            return true
          end,
        },
      },
    }
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "echasnovski/mini.pick",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
    "ibhagwan/fzf-lua",
    "stevearc/dressing.nvim",
    "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      },
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
]]

-- -- Define the function to read the API key from a file OUTSIDE the plugin table
-- local function read_api_key_from_file(filename)
--   local file = io.open(filename, "r")
--   if file then
--     local key = file:read("*all")
--     file:close()
--     return key and vim.trim(key)
--   else
--     vim.notify("Avante: Could not open API key file: " .. filename, vim.log.levels.ERROR)
--     return nil
--   end
-- end
--
-- -- Define the path to your API key file
-- local google_api_key_file_path = vim.fn.expand("~/dev/google-ai.token")
--
-- return {
--   "yetone/avante.nvim",
--   build = function()
--     if vim.fn.has("win32") == 1 then
--       return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
--     else
--       return "make"
--     end
--   end,
--   event = "VeryLazy",
--   version = false,
--   opts = function()
--     local google_api_key = read_api_key_from_file(google_api_key_file_path)
--
--     if not google_api_key then
--       vim.notify("Avante: Google API key not loaded. Check ~/.config/nvim/google-ai.token", vim.log.levels.WARN)
--     end
--
--     return {
--       provider = "google_gemini", -- This should be the name of your custom provider
--       providers = {
--         -- Define your custom Google Gemini provider here
--         google_gemini = {
--           -- !!! IMPORTANT: This is the missing piece for a custom provider !!!
--           -- You need to tell Avante how to construct the HTTP request.
--           parse_curl_args = function(config, request_body)
--             -- 'config' will contain the 'google_gemini' table (endpoint, model, etc.)
--             -- 'request_body' will contain 'extra_request_body' from your config, plus Avante's own additions
--
--             -- Google Gemini's API expects the API key as a query parameter or in headers.
--             -- It's typically recommended in headers for security.
--             -- Let's try it as a query parameter first as it's often simpler for curl.
--             -- The endpoint needs to include the model in the path for Gemini's generateContent
--             -- Example: https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=YOUR_API_KEY
--
--             local endpoint = config.endpoint .. "/models/" .. config.model .. ":generateContent?key=" .. config.api_key
--             local headers = {
--               "Content-Type: application/json",
--             }
--
--             -- Google's Gemini API often expects a specific 'contents' structure.
--             -- Your 'request_body' will contain things like 'temperature', 'maxOutputTokens'
--             -- from 'extra_request_body' and the actual prompt from Avante.
--             -- You need to map Avante's internal request format to Google's.
--             -- This part is crucial and depends on Avante's `request_body` structure.
--             -- For simplicity, let's assume Avante sends the prompt in a 'prompt' field
--             -- and you want to format it for Gemini's 'contents' array.
--
--             local google_payload = {
--               contents = {
--                 {
--                   parts = {
--                     { text = request_body.prompt or "" }, -- Assuming Avante passes the prompt as 'request_body.prompt'
--                   },
--                 },
--               },
--               generationConfig = {
--                 temperature = request_body.temperature or config.extra_request_body.temperature,
--                 maxOutputTokens = request_body.maxOutputTokens or config.extra_request_body.maxOutputTokens,
--                 -- add other generation parameters here if needed
--               },
--               -- safetySettings might also be needed for Gemini, depending on your use case
--             }
--
--             -- Convert the payload to a JSON string
--             local json_payload = vim.fn.json_encode(google_payload)
--
--             return {
--               "-X",
--               "POST",
--               endpoint,
--               unpack(headers),
--               "--data-binary",
--               json_payload,
--             }
--           end,
--           -- Configuration for your Google Gemini API
--           endpoint = "https://generativelanguage.googleapis.com/v1beta",
--           api_key = google_api_key,
--           model = "gemini-pro", -- Use a specific Gemini model
--           timeout = 30000,
--           extra_request_body = {
--             temperature = 0.75,
--             maxOutputTokens = 2048,
--           },
--         },
--       },
--     }
--   end,
--   dependencies = {
--     "nvim-lua/plenary.nvim",
--     "MunifTanjim/nui.nvim",
--     "echasnovski/mini.pick",
--     "nvim-telescope/telescope.nvim",
--     "hrsh7th/nvim-cmp",
--     "ibhagwan/fzf-lua",
--     "stevearc/dressing.nvim",
--     "folke/snacks.nvim",
--     "nvim-tree/nvim-web-devicons",
--     {
--       "HakonHarnes/img-clip.nvim",
--       event = "VeryLazy",
--       opts = {
--         default = {
--           embed_image_as_base64 = false,
--           prompt_for_file_name = false,
--           drag_and_drop = {
--             insert_mode = true,
--           },
--           use_absolute_path = true,
--         },
--       },
--     },
--     {
--       "MeanderingProgrammer/render-markdown.nvim",
--       opts = {
--         file_types = { "markdown", "Avante" },
--       },
--       ft = { "markdown", "Avante" },
--     },
--   },
-- }
