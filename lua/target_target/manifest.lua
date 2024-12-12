-- lua/target_target/manifest.lua

local utils = require("target_target.utils")
local Path = require("plenary.path")
local Job = require("plenary.job")
local data_dir = utils.get_data_dir()

local M = {}

function M.update_manifest()
    -- Define the path where the manifest.json will be saved
    local manifest_path = Path:new(data_dir, "manifest.json"):absolute()

    -- Construct the R command to write JSON directly to the file
    local r_command = string.format([[
        library(targets)
        library(jsonlite)
        x <- tar_manifest(fields = c("name", "command"))
        jsonlite::toJSON(x, auto_unbox = TRUE) |> writeLines("%s")
    ]], manifest_path)

    -- Use plenary.job to run the R command asynchronously
    Job:new({
        command = "Rscript",
        args = { "--quiet", "-e", r_command },
        on_exit = function(j, return_val)
            if return_val == 0 then
                -- Notify the user asynchronously
                vim.schedule(function()
                    print("Manifest updated successfully.")
                end)
            else
                local stderr = table.concat(j:stderr_result(), "\n")
                -- Notify the user of the error asynchronously
                vim.schedule(function()
                    vim.notify("Error updating manifest: " .. stderr, vim.log.levels.ERROR)
                end)
            end
        end,
    }):start()
end

function M.read_manifest()
	local manifest_path = Path:new(data_dir, "manifest.json")
	if not manifest_path:exists() then
		return nil
	end
	local manifest_json = manifest_path:read()
	-- Decode the JSON, ensuring any errors are caught
	local ok, manifest_data = pcall(vim.json.decode, manifest_json)
	if not ok then
		vim.notify("Error parsing manifest JSON: " .. manifest_data, vim.log.levels.ERROR)
		return nil
	end
	return manifest_data
end

return M
