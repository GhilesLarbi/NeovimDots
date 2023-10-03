local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
	vim.notify("bufferline doesn't exist", vim.log.levels.INFO)
	return
end

-- help bufferline-configuratoin
require("bufferline").setup()

