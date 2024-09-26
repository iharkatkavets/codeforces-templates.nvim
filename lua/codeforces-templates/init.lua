local M = {}

M._templates = {
	cpp = "templates/solution.cpp",
	python = "templates/solution.py",
	go = "templates/solution.go",
	swift = "templates/solution.swift",
}

M._test_commands = {
	cpp = { "sh", "-c", "g++ -std=c++11 solution.cpp -o solution && ./solution < input.txt" },
	go = { "go", "run", "solution.go && ./solution < input.txt" },
}

M.setup = function(opts)
	opts = opts or {}
	print("CodeForces plugin loaded!")
end

local get_plugin_base_path = function()
	local source = debug.getinfo(1, "S").source:sub(2) -- Get the script's source and remove the "@" character
	return source:match("(.*/)")
end

local get_file_name = function(basename, extension)
	local filename = basename .. "." .. extension
	local bfrnr = vim.fn.bufnr(filename)
	if bfrnr == -1 then
		return filename
	end

	local i = 1
	filename = basename .. i .. "." .. extension
	bfrnr = vim.fn.bufnr(filename)
	while bfrnr ~= -1 do
		i = i + 1
		filename = basename .. i .. "." .. extension
		bfrnr = vim.fn.bufnr(filename)
	end
	return filename
end

M.create_source_buffer = function(lang)
	local filename = get_file_name("solution", lang)
	local bufnr = vim.fn.bufadd(filename)
	vim.fn.bufload(bufnr)

	local template_file = M._templates[lang]

	local base_path = get_plugin_base_path()
	local full_path = base_path .. template_file
	local fh = io.open(full_path, "r")
	if not fh then
		print("Couldn't open template file")
		return
	end

	for line in fh:lines() do
		local line_count = vim.api.nvim_buf_line_count(bufnr)
		if line_count == 1 and vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)[1] == "" then
			vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { line })
		else
			vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { line })
		end
	end

	vim.api.nvim_buf_set_name(bufnr, filename)
	vim.api.nvim_set_option_value("buflisted", true, { buf = bufnr })
	vim.api.nvim_set_current_buf(bufnr)
	vim.cmd("write")

	fh:close()
end

M.create_input_buffer = function()
	local filename = get_file_name("input", "txt")
	local bufnr = vim.fn.bufadd(filename)
	vim.fn.bufload(bufnr)
	vim.api.nvim_buf_set_name(bufnr, filename)
	vim.api.nvim_set_option_value("buflisted", true, { buf = bufnr })
	vim.api.nvim_set_current_buf(bufnr)
	vim.cmd("write")
end

M.create_template = function(lang)
	M.create_input_buffer()
	M.create_source_buffer(lang)
end

M.run_tests = function(lang)
	local command = M._test_commands[lang]
	if not command then
		print("No test command for " .. lang)
		return
	end
	local output = vim.fn.system(command)
	print("Result\n" .. output)
	if vim.v.shell_error ~= 0 then
		print("Command failed with error code: " .. vim.v.shell_error)
	else
		print("Command output:\n" .. output)
	end
end

vim.api.nvim_create_user_command("CFCreateTemplate", function(opts)
	M.create_template(opts.args)
end, {
	nargs = 1,
	complete = function(ArgLead, CmdLine, CursorPos)
		return { "python", "cpp", "go" }
	end,
})

vim.api.nvim_create_user_command("CFTest", function(opts)
	M.run_tests(opts.args)
end, {
	nargs = 1,
	complete = function(ArgLead, CmdLine, CursorPos)
		return { "python", "cpp", "go" }
	end,
})

return M
