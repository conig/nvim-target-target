-- plugin/target-target.lua

-- Set up an autocommand to detect when a _targets.R file is saved
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "_targets.R",
    callback = function()
        require("target_target.manifest").update_manifest()
    end,
})
