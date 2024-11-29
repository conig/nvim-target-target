-- lua/target_target/manifest.lua

local utils = require("target_target.utils")
local Path = require("plenary.path")
local Job = require("plenary.job")
local data_dir = utils.get_data_dir()

local M = {}

function M.update_manifest()
	-- Updated R command
	local r_command = 'targets::tar_manifest(fields = c("name", "command")) |> jsonlite::toJSON(auto_unbox = TRUE)'

	-- Use plenary.job to run the R command asynchronously
	Job:new({
		command = "Rscript",
		args = { "-e", r_command },
		on_exit = function(j, return_val)
			if return_val == 0 then
				local manifest_json = table.concat(j:result(), "\n")
				-- Save the manifest to a file in the data directory
				local manifest_path = Path:new(data_dir, "manifest.json")
				manifest_path:write(manifest_json, "w")
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
