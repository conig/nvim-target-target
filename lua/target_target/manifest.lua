-- lua/target_target/manifest.lua

-- lua/target_target/manifest.lua
local utils = require("target_target.utils")
local Path = require("plenary.path")
local Job = require("plenary.job")  -- Added plenary.job for asynchronous execution
local data_dir = utils.get_data_dir()

local M = {}

-- Function to update the manifest by calling R code asynchronously
function M.update_manifest()
    -- Command to run in R
    local r_command = 'targets::tar_manifest() |> jsonlite::toJSON()'
    -- Use plenary.job to run the R command asynchronously
    Job:new({
        command = 'Rscript',
        args = { '-e', r_command },
        on_exit = function(j, return_val)
            if return_val == 0 then
                local manifest_json = table.concat(j:result(), '\n')
                -- Save the manifest to a file in the data directory
                local manifest_path = Path:new(data_dir, "manifest.json")
                manifest_path:write(manifest_json, "w")
                -- Notify the user asynchronously
                vim.schedule(function()
                    vim.notify("Manifest updated successfully.", vim.log.levels.INFO)
                end)
            else
                local stderr = table.concat(j:stderr_result(), '\n')
                -- Notify the user of the error asynchronously
                vim.schedule(function()
                    vim.notify("Error updating manifest: " .. stderr, vim.log.levels.ERROR)
                end)
            end
        end,
    }):start()
end

-- Function to read the manifest
function M.read_manifest()
    local manifest_path = Path:new(data_dir, "manifest.json")
    if not manifest_path:exists() then
        return nil
    end
    local manifest_json = manifest_path:read()
    return vim.json.decode(manifest_json)
end

return M

