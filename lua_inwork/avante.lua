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
  build = function()
    if vim.fn.has("win32") == 1 then
      return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    else
      return "make"
    end
  end,
  event = "VeryLazy",
  version = false,
  opts = function()
    local google_api_key = read_api_key_from_file(google_api_key_file_path)

    if not google_api_key then
        vim.notify("Avante: Google API key not loaded. Check ~/.config/nvim/google-ai.token", vim.log.levels.WARN)
    end

    return {
      provider = "google_gemini", -- This should be the name of your custom provider
      providers = {
        -- Define your custom Google Gemini provider here
        google_gemini = {
          -- !!! IMPORTANT: This is the missing piece for a custom provider !!!
          -- You need to tell Avante how to construct the HTTP request.
          parse_curl_args = function(config, request_body)
            -- 'config' will contain the 'google_gemini' table (endpoint, model, etc.)
            -- 'request_body' will contain 'extra_request_body' from your config, plus Avante's own additions

            -- Google Gemini's API expects the API key as a query parameter or in headers.
            -- It's typically recommended in headers for security.
            -- Let's try it as a query parameter first as it's often simpler for curl.
            -- The endpoint needs to include the model in the path for Gemini's generateContent
            -- Example: https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=YOUR_API_KEY

            local endpoint = config.endpoint .. "/models/" .. config.model .. ":generateContent?key=" .. config.api_key
            local headers = {
                "Content-Type: application/json",
            }

            -- Google's Gemini API often expects a specific 'contents' structure.
            -- Your 'request_body' will contain things like 'temperature', 'maxOutputTokens'
            -- from 'extra_request_body' and the actual prompt from Avante.
            -- You need to map Avante's internal request format to Google's.
            -- This part is crucial and depends on Avante's `request_body` structure.
            -- For simplicity, let's assume Avante sends the prompt in a 'prompt' field
            -- and you want to format it for Gemini's 'contents' array.

            local google_payload = {
                contents = {
                    {
                        parts = {
                            { text = request_body.prompt or "" } -- Assuming Avante passes the prompt as 'request_body.prompt'
                        }
                    }
                },
                generationConfig = {
                    temperature = request_body.temperature or config.extra_request_body.temperature,
                    maxOutputTokens = request_body.maxOutputTokens or config.extra_request_body.maxOutputTokens,
                    -- add other generation parameters here if needed
                }
                -- safetySettings might also be needed for Gemini, depending on your use case
            }

            -- Convert the payload to a JSON string
            local json_payload = vim.fn.json_encode(google_payload)

            return {
              "-X", "POST",
              endpoint,
              unpack(headers),
              "--data-binary", json_payload
            }
          end,
          -- Configuration for your Google Gemini API
          endpoint = "https://generativelanguage.googleapis.com/v1beta",
          api_key = google_api_key,
          model = "gemini-pro", -- Use a specific Gemini model
          timeout = 30000,
          extra_request_body = {
            temperature = 0.75,
            maxOutputTokens = 2048,
          },
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
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}

