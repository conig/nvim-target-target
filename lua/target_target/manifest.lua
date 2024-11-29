-- lua/target_target/manifest.lua

local utils = require("target_target.utils")
local Path = require("plenary.path")
local data_dir = utils.get_data_dir()

local M = {}

-- Function to update the manifest by calling R code
function M.update_manifest()
    -- Command to run in R
    local r_command = [[Rscript -e 'targets::tar_manifest() |> jsonlite::toJSON()']]

    -- Run the R command and capture output
    local manifest_json = vim.fn.system(r_command)

    -- Handle errors
    if vim.v.shell_error ~= 0 then
        vim.notify("Error updating manifest: " .. manifest_json, vim.log.levels.ERROR)
        return
    end

    -- Save the manifest to a file in the data directory
    local manifest_path = Path:new(data_dir, "manifest.json")
    manifest_path:write(manifest_json, "w")
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

