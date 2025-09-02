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
