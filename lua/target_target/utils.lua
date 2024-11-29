-- lua/target_target/utils.lua

local Path = require("plenary.path")

local M = {}

-- Function to get the data directory specific to the current project
function M.get_data_dir()
    local project_dir = vim.fn.getcwd()
    local data_dir = vim.fn.stdpath("data") .. "/target_target/" .. vim.fn.sha256(project_dir)
    local path = Path:new(data_dir)
    if not path:exists() then
        path:mkdir({ parents = true })
    end
    return data_dir
end

return M

