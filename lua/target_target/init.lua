-- lua/target_target/init.lua

local M = {}

M.acquire_target = require("target_target.acquire_target").acquire_target
M.get_active_name = require("target_target.acquire_target").get_active_name
M.pick_target = require("target_target.acquire_target").pick_target

return M
