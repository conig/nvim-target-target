-- lua/target_target/acquire_target.lua

local manifest = require("target_target.manifest")
local utils = require("target_target.utils")
local Path = require("plenary.path")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local data_dir = utils.get_data_dir()

local M = {}

-- Function to pick a target and return its name via callback
function M.pick_target(callback)
  local manifest_data = manifest.read_manifest()
  if not manifest_data then
    vim.notify("Manifest not found. Please save your _targets.R file first.", vim.log.levels.WARN)
    return
  end

  -- Build a mapping from target names to commands
  local target_items = {}
  for _, target in ipairs(manifest_data) do
    table.insert(target_items, {
      name = target.name,
      command = target.command,
    })
  end

  -- Custom previewer to display the command associated with the selected target
  local previewer = previewers.new_buffer_previewer({
    define_preview = function(self, entry)
      local bufnr = self.state.bufnr
      -- Split the command on \n to handle newlines
      local lines = vim.split(entry.value.command, "\n")
      -- Set the buffer content to the command lines
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      -- Set syntax highlighting if needed
      vim.schedule(function()
        vim.bo[bufnr].filetype = "r"
      end)
    end,
  })

  pickers
    .new({}, {
      prompt_title = "Select Target",
      finder = finders.new_table({
        results = target_items,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = entry.name,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = previewer,
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if callback then
            callback(selection.value.name)
          end
        end)
        return true
      end,
    })
    :find()
end

-- Function to acquire target by saving the selected target name
function M.acquire_target()
  M.pick_target(function(name)
    M.save_active_name(name)
    vim.notify("Active target set to: " .. name)
  end)
end

-- Function to save the active target name
function M.save_active_name(name)
  local active_name_path = Path:new(data_dir, "active_target.txt")
  active_name_path:write(name, "w")
end

-- Function to get the active target name
function M.get_active_name()
  local active_name_path = Path:new(data_dir, "active_target.txt")
  if not active_name_path:exists() then
    return nil
  end
  local name = active_name_path:read()
  return name
end

return M
