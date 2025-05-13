#!/usr/bin/env lua

-- launcher.lua - Auto-detect paths and load modules with argument parsing

-- Find script's real location (even through symlinks)
local function get_script_path()
	-- Get the caller's source info
	local info = debug.getinfo(2, "S")
	local source = info.source

	-- If it's a file, remove the "@" prefix
	if source:sub(1, 1) == "@" then
		source = source:sub(2)
	end

	-- Resolve symlinks using a more reliable method
	local handle = io.popen("cd \"$(dirname '" .. source .. "')\" && pwd")
	if not handle then
		error("Failed to get script path")
	end
	local dir_path = handle:read("*l")
	handle:close()

	return dir_path
end

-- Parse command line arguments
local function parse_args(args)
	local result = {
		args = {}, -- Positional arguments
		options = {}, -- Named options
	}

	local i = 1
	while i <= #args do
		local arg = args[i]

		-- Check if it's an option
		if arg:sub(1, 2) == "--" then
			local option = arg:sub(3)
			local name, value

			-- Check if it's --option=value format
			local eq_pos = option:find("=")
			if eq_pos then
				name = option:sub(1, eq_pos - 1)
				value = option:sub(eq_pos + 1)
			else
				-- It's a flag
				name = option

				-- Check if it's a negative flag (--no-option)
				if name:sub(1, 3) == "no-" then
					name = name:sub(4)
					value = false
				else
					-- Check if next argument exists and isn't an option
					if i + 1 <= #args and args[i + 1]:sub(1, 2) ~= "--" then
						value = args[i + 1]
						i = i + 1 -- Skip the next argument since we consumed it
					else
						-- It's a flag with no value, so set it to true
						value = true
					end
				end
			end

			result.options[name] = value
		else
			-- It's a positional argument
			table.insert(result.args, arg)
		end

		i = i + 1
	end

	return result
end

-- Get the real path of the script (handles symlinks)
local bin_dir = get_script_path()

-- Set modules directory
local modules_dir = bin_dir .. "/lua"

-- Setup module path to find modules
package.path = modules_dir .. "/?.lua;" .. package.path

-- Load common modules if they exist
local git_exists, git = pcall(require, "helpers.git")
if git_exists then
	_G.git = git
end

local ansicolors_exists, ansicolors = pcall(require, "helpers.ansicolors")
if ansicolors_exists then
	_G.colors = ansicolors
	local original_print = print
	-- Override print to use colors by default
	---@diagnostic disable-next-line: duplicate-set-field
	_G.print = function(...)
		return original_print(colors(...))
	end
end

local prompt_exists, prompt = pcall(require, "helpers.prompt")
if prompt_exists then
	_G.prompt = prompt
end

-- Get script name from arg[0]
local script_name = arg[0]:match("[^/]+$")

-- Path to the actual script based on name
local script_path = modules_dir .. "/scripts/" .. script_name .. ".lua"

-- Check if script exists
local f = io.open(script_path, "r")
if not f then
	print("Script not found: " .. script_path)
	os.exit(1)
end
f:close()

-- Parse the command line arguments
local parsed_args = parse_args(arg)

-- Create environment for the script with access to args
local script_env = setmetatable({
	-- Raw arguments
	arg = arg,

	-- Parsed arguments and options
	args = parsed_args.args,
	options = parsed_args.options,

	-- Legacy arg structure for backward compatibility
	argv = arg,
}, { __index = _G }) -- Fall back to global environment

-- Load the script
local chunk, load_error = loadfile(script_path)
if not chunk then
	print("Error loading " .. script_name .. ": " .. load_error)
	os.exit(1)
end

-- Set the environment and execute based on Lua version
if _VERSION == "Lua 5.1" then
	-- Lua 5.1 method
	setfenv(chunk, script_env)
	local success, err = pcall(chunk)
	if not success then
		print("Error executing " .. script_name .. ": " .. err)
		os.exit(1)
	end
else
	-- Lua 5.2+ method with environment
	-- First set up the environment
	local env = setmetatable(script_env, { __index = _G })

	-- Then load with that environment
	local success, err = xpcall(function()
		-- Use the debug library to set environment for 5.2+
		if setfenv then
			-- Lua 5.1 path
			setfenv(chunk, env)
			return chunk()
		else
			-- Lua 5.2+ path
			debug.setupvalue(chunk, 1, env)
			return chunk()
		end
	end, function(err)
		return debug.traceback(err)
	end)

	if not success then
		print("Error executing " .. script_name .. ":\n" .. err)
		os.exit(1)
	end
end
