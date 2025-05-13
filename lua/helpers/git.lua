local git = {
	--- Make a config key from a list of arguments
	--- @param  ... string|string[]
	--- @return string
	make_config_key = function(...)
		local args = { ... }
		-- if we have a single table argument, use it directly
		if type(args[1]) == "table" then
			---@diagnostic disable-next-line: param-type-mismatch
			return table.concat(args[1], ".")
		end
		-- otherwise concatenate all arguments with a .
		return table.concat(args, ".")
	end,

	make_prefixed_config_key_fn = function(prefix)
		return function(key)
			return git.make_config_key(prefix, key)
		end
	end,

	-- Execute git command and return output
	--- @param cmd string
	--- @param raw? boolean
	--- @return string
	exec = function(cmd, raw)
		local command = "git " .. cmd
		local handle = io.popen(command)
		if not handle then
			error("Failed to execute git command: " .. command)
		end
		local result = handle:read("*a")
		handle:close()
		return raw and result or result:gsub("[\r\n]+$", "")
	end,

	--- Just print the command to be executed
	dryrun = function(cmd, _)
		print("git " .. cmd)
	end,

	--- Get current branch name
	--- @return string
	current_branch = function()
		return git.exec("rev-parse --abbrev-ref HEAD")
	end,

	--- @param key string|string[]
	--- @param value string
	--- @param config_file? string
	--- @return nil
	set_config = function(key, value, config_file)
		local config_key = git.make_config_key(key)
		config_file = config_file and ("--file " .. config_file .. " ") or ""
		git.exec("config set " .. config_file .. config_key .. " " .. value)
	end,

	---
	--- @param key string|string[]
	--- @param config_file? string
	--- @return string|nil
	get_config = function(key, config_file)
		local config_key = git.make_config_key(key)
		config_file = config_file and ("--file " .. config_file .. " ") or ""
		local config_value =
			git.exec("config get " .. config_file .. config_key)
		if config_value ~= "" then
			return config_value
		else
			return nil
		end
	end,

	--- Set a branch metadata
	--- @param key string
	--- @param value string
	--- @param branch? string
	--- @return nil
	set_branch_metadata = function(key, value, branch)
		branch = branch or git.current_branch()
		local branch_key = { "branch", branch, key }
		git.set_config(branch_key, value)
	end,

	--- Get a branch metadata
	--- @param key string
	--- @param branch? string
	--- @return string|nil
	get_branch_metadata = function(key, branch)
		branch = branch or git.current_branch()
		local branch_key = { "branch", branch, key }
		return git.get_config(branch_key)
	end,

	--- Check if a branch exists
	--- @param branch string The branch name to check
	--- @return boolean True if the branch exists, false otherwise
	branch_exists = function(branch)
		local result = git.exec(("show-ref --branches %s"):format(branch), true)
		return result ~= ""
	end,

	--- Create a new branch
	--- @param branch string The branch name to create
	--- @param start_point? string The branch to start from
	--- @return nil
	create_branch = function(branch, start_point)
		start_point = start_point or "HEAD"
		git.exec(("checkout -b %s %s"):format(branch, start_point))
	end,
}

return git
