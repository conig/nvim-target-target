-- lua/target_target/acquire_target.lua

local manifest = require("target_target.manifest")
local utils = require("target_target.utils")
local Path = require("plenary.path")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local data_dir = utils.get_data_dir()

local M = {}

-- Function to acquire target
function M.acquire_target()
    local manifest_data = manifest.read_manifest()
    if not manifest_data then
        vim.notify("Manifest not found. Please save your _targets.R file first.", vim.log.levels.WARN)
        return
    end

    local target_names = {}
    for _, target in ipairs(manifest_data) do
        table.insert(target_names, target.name)
    end

    pickers.new({}, {
        prompt_title = "Select Target",
        finder = finders.new_table {
            results = target_names,
        },
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                M.save_active_name(selection[1])
                vim.notify("Active target set to: " .. selection[1])
            end)
            return true
        end,
    }):find()
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

