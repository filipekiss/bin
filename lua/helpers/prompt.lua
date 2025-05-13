local prompt = {

	clear = function()
		io.write("\27[1A\27[2K") -- Up one line, clear
		io.write("\27[2K\r") -- Clear current line just in case
	end,

	-- Prompt user for yes/no answer
	-- @param question string The question to ask
	-- @param default boolean The default answer if no answer is given - true for yes, false for no. Defaults to false
	-- @return boolean True if yes, false if no
	yes_no = function(question, default)
		local default_answer = default or false
		local yno_label = default_answer and "Y/n" or "y/N"
		while true do
			io.write(question .. " (" .. yno_label .. "):")
			local answer = io.read():lower() or (default_answer and "y" or "n")
			prompt.clear()
			if
				answer == "y"
				or answer == "yes"
				or default_answer and answer == ""
			then
				return true
			else
				return false
			end
		end
	end,

	-- Prompt user for free text input
	-- @param question string The question to ask
	-- @return string The user's answer
	text = function(question)
		io.write(question .. ": ")
		return io.read()
	end,
}

return prompt
