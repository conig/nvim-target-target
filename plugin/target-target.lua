-- plugin/target-target.lua

-- Set up an autocommand to detect when a _targets.R file or top-level _target_pipelines entry is saved
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = {
        "_targets.[rR]",
        "*_target_pipelines/*",
    },
    callback = function()
        require("target_target.manifest").update_manifest()
    end,
})
