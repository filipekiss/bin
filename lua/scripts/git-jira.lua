-- git-jira
--------------------------------------------------------------------------------
-- Version
----------
-- 1.0.0
--
-- Author
---------
-- Filipe Kiss <hi@filipekiss.dev>
--
--------------------------------------------------------------------------------
--
-- Arguments
------------
--
-- [ticket]
-- The only argument this command accepts is the ticket number to associate with
-- the current branch. If you don't pass any argument, it will open the JIRA
-- ticket for the current branch if it is set, otherwise a message will be shown
--------------------------------------------------------------------------------
--
-- Options
-- -------
--
-- --guess-config
--   Try to guess the JIRA domain and prefix from the URL passed as argument.
--   This will print the guessed URL and ask for confirmation to update the
--   configuration file.
--
-- --config-file
--   The path to the configuration file to update. Defaults to .git/config
--   (current directory).
--
-- --set-jira-url
--   If the current branch has a JIRA URL associated, this option will update
--   the JIRA URL for the current branch by using the URL passed as argument.
--   You can use this option to update the JIRA URL for a branch that doesn't
--   have one. This is here as an escape hatch, as the idea is that the script
--   should infer the JIRA URL based on it's settings.
--
-- Configuration
----------------
-- You can configure this command by setting the following variables in your
-- .gitconfig file or using `git config` to set them:
--
-- git-jira.domain (default: <empty>)
--   The domain of your JIRA instance. This is mandatory.
--
-- git-jira.branch-format (default: %t)
--   The format to use when creating the JIRA ticket. Defaults to %t
--   Available variables:
--   - %p: prefix
--   - %s: ticket number
--   - %t: shortcut to %p-%s
--
--   Unknown variables will be outputted as is. Literal strings can be used as
--   well, for example - assuming your prefix is JIRA and your ticket number is
--   1234:
--   - default (%t) will output jira-1234
--   - feature/%t will output feature/jira-1234
--   - feature/%p-%s will output feature/jira-1234
--   - feature/%u-%t will output feature/%u-jira-1234
--
--   The prefix is always lowercased.
--
-- git-jira.prefix (default: <empty>)
--   The prefix to use when creating the JIRA ticket. This is mandatory.
--
-- You can use the --guess-config options have git-jira try to guess the correct
-- config form a JIRA ticket URL:
--
--   git jira --guess-config https://jira.atlassian.net/browse/PROJ-1234 should
--   configure the following options:
--
--   git-jira.domain = jira.atlassian.net
--   git-jira.prefix = PROJ
--
--   By default, git-jira will configure these options for the current
--   repository only. You can pass a `--config-file` options that is a file path
--   to configure the options using a different config file. For example, to set
--   these options globally:
--
--   git jira --guess-config https://jira.atlassian.net/browse/PROJ-1234 --config-file ~/.gitconfig
--
--------------------------------------------------------------------------------

local git_jira = {
	config = {
		jira_instance_domain = "git-jira.domain",
		jira_instance_prefix = "git-jira.prefix",
		jira_branch_format = "git-jira.branch-format",
		branch_jira_url_key = "jira-url",
		git_config_section = "git-jira",
	},
	defaults = {
		branch_format = "%t",
	},
}

function git_jira.guess_domain_and_prefix(maybe_jira_url)
	local guessed_jira_domain = maybe_jira_url:match("//([^/]+)")
	local guessed_jira_prefix = maybe_jira_url:match("//[^/]+/browse/([^-]+).*")
	local guessed_full_url = ("%%{dim}%s%%{reset}"):format(maybe_jira_url)
	if guessed_jira_domain and guessed_jira_prefix then
		guessed_full_url = "%{dim}"
			.. maybe_jira_url
				:gsub(
					guessed_jira_domain,
					"%%{reset}%%{blue}"
						.. guessed_jira_domain
						.. "%%{reset}%%{dim}"
				)
				:gsub(
					guessed_jira_prefix,
					"%%{reset}%%{magenta}"
						.. guessed_jira_prefix
						.. "%%{reset}%%{dim}"
				)
			.. "%{reset}"
	end
	return guessed_jira_domain, guessed_jira_prefix, guessed_full_url
end

function git_jira.guess_config(maybe_jira_url, config_file)
	local guessed_jira_domain, guessed_jira_prefix, formatted_url =
		git_jira.guess_domain_and_prefix(maybe_jira_url)
	if not guessed_jira_domain or not guessed_jira_prefix then
		print("Could not guess JIRA domain and/or prefix from URL")
		os.exit(1)
	end
	print("Guessing %{blue}domain%{reset} and %{magenta}prefix%{reset}:")
	print(("\n\r %s\n\r"):format(formatted_url))
	local current_domain =
		git.get_config(git_jira.config.jira_instance_domain, config_file)
	local current_prefix =
		git.get_config(git_jira.config.jira_instance_prefix, config_file)
	if
		current_domain == guessed_jira_domain
		and current_prefix == guessed_jira_prefix
	then
		print("Current configuration matches guessed configuration")
		os.exit(0)
	end
	local do_config_update = prompt.yes_no(
		colors("Update %{green}" .. config_file .. "%{reset}"),
		options["config-file"] == nil
	)
	if do_config_update then
		print("Updating config %{blue}" .. config_file)
		git.set_config(
			git_jira.config.jira_instance_domain,
			guessed_jira_domain:lower(),
			config_file
		)
		git.set_config(
			git_jira.config.jira_instance_prefix,
			guessed_jira_prefix:lower(),
			config_file
		)
	else
		print("Skipping configuration update")
	end
end

function git_jira.view_jira_metadata()
	local branch_jira_url =
		git.get_branch_metadata(git_jira.config.branch_jira_url_key)
	if branch_jira_url then
		print("Opening JIRA URL: %{green}" .. branch_jira_url .. "%{reset}")
		os.execute("open " .. branch_jira_url)
	else
		print(
			"No JIRA URL found for branch %{red}"
				.. git.current_branch()
				.. "%{reset}"
		)
	end
end

function git_jira.create_jira_url(ticket_id)
	local domain = git.get_config(git_jira.config.jira_instance_domain)
	local prefix = git.get_config(git_jira.config.jira_instance_prefix)
	if not domain or not prefix then
		print("Could not find JIRA domain or prefix")
		os.exit(1)
	end
	return ("https://%s/browse/%s-%s"):format(domain, prefix:upper(), ticket_id)
end

function git_jira.generate_branch_name(ticket_id)
	local branch_format = git.get_config(git_jira.config.jira_branch_format)
		or git_jira.defaults.branch_format
	branch_format = branch_format:gsub("%%t", "%%p-%%s")
	local prefix = git.get_config(git_jira.config.jira_instance_prefix)
	if not prefix then
		print("Could not find JIRA prefix")
		os.exit(1)
	end
	local branch_name = branch_format:gsub("%%p", prefix):gsub("%%s", ticket_id)
	return branch_name
end

function git_jira.print_formated(message, ...)
	print(message:format(...))
end

function git_jira.exit_with_message(message, ...)
	git_jira.print_formated(message, ...)
	os.exit(1)
end

function git_jira.exit_success(message, ...)
	git_jira.print_formated(message, ...)
	os.exit(0)
end

function git_jira.get_config_value(key, error_message)
	local value = git.get_config({ git_jira.config.git_config_section, key })
	if not value and error_message then
		git_jira.exit_with_message(error_message)
	end
	return value
end

function git_jira.update_config(key, value, config_file)
	git.set_config({
		git_jira.config.git_config_section,
		key,
	}, value:lower(), config_file)
end

function git_jira.handle_guess_config()
	if not options["guess-config"] or options["guess-config"] == "" then
		return false
	end

	local config_file = options["config-file"] or ".git/config"
	git_jira.guess_config(options["guess-config"], config_file)
	os.exit(0)
end

---@param branch_name? string @The name of the branch to guess the URL from, defaults to the current branch.
function git_jira.guess_url_from_branch_name(branch_name)
	branch_name = branch_name or git.current_branch()
	-- extract the ticket number from the branch name
	local ticket_id = branch_name:match("%d+")
	if ticket_id then
		return git_jira.create_jira_url(ticket_id)
	end
	return nil
end

function git_jira.handle_set_jira_url()
	if not options["set-jira-url"] then
		return false
	end

	if options["set-jira-url"] == "" or options["set-jira-url"] == true then
		local guessed_url = git_jira.guess_url_from_branch_name()
		if guessed_url then
			options["set-jira-url"] = guessed_url
		else
			git_jira.exit_with_message("JIRA URL cannot be empty")
		end
	end

	local current_url =
		git.get_branch_metadata(git_jira.config.branch_jira_url_key)
	if current_url == options["set-jira-url"] then
		git_jira.exit_success(
			"Current JIRA URL is already %%{green}%s%%{reset}",
			options["set-jira-url"]
		)
	end

	-- If it's just a ticket number, generate the full URL using configured options
	if
		type(options["set-jira-url"]) == "string"
		and options["set-jira-url"]:match("^[0-9]+$")
	then
		options["set-jira-url"] = git_jira.config.jira_instance_prefix
			.. "-"
			.. options["set-jira-url"]
	end

	git.set_branch_metadata(
		git_jira.config.branch_jira_url_key,
		options["set-jira-url"]
	)
	git_jira.print_formated(
		"Updated %%{blue}%s%%{reset} to %%{blue}%s%%{reset}",
		git.make_config_key(
			git_jira.config.git_config_section,
			git_jira.config.branch_jira_url_key
		),
		options["set-jira-url"]
	)
	os.exit(0)
end

function git_jira.handle_branch_creation(ticket_id)
	local branch_name = git_jira.generate_branch_name(ticket_id)
	if git.branch_exists(branch_name) then
		git_jira.print_formated(
			"Branch %%{blue}%s%%{reset} already exists",
			branch_name
		)
		-- check if it's checked out
		if git.current_branch() ~= branch_name then
			git_jira.print_formated(
				"Checking out branch %%{blue}%s%%{reset}",
				branch_name
			)
			git.exec("checkout " .. branch_name)
		end
		-- check if it has JIRA metadata
		local jira_url =
			git.get_branch_metadata(git_jira.config.branch_jira_url_key)
		if not jira_url then
			-- if not, ask the user if they want to set it
			local do_set_jira_url = prompt.yes_no(
				"Do you want to set the JIRA URL for this branch?",
				true
			)
			prompt.clear()
			if do_set_jira_url then
				jira_url = git_jira.create_jira_url(ticket_id)
				git_jira.print_formated(
					"Setting JIRA URL to %%{blue}%s%%{reset}",
					jira_url
				)
				prompt.clear()
				git.set_branch_metadata(
					git_jira.config.branch_jira_url_key,
					jira_url
				)
				git_jira.print_formated(
					"Set JIRA URL to %%{blue}%s%%{reset}",
					jira_url
				)
			else
				prompt.clear()
				git_jira.print_formated("Skipping JIRA URL update")
			end
		end
	else
		git.create_branch(branch_name)
		local jira_url = git_jira.create_jira_url(ticket_id)
		git_jira.print_formated(
			"Setting JIRA URL to %%{blue}%s%%{reset}",
			jira_url
		)
		prompt.clear()
		git.set_branch_metadata(git_jira.config.branch_jira_url_key, jira_url)
		git_jira.print_formated("Set JIRA URL to %%{blue}%s%%{reset}", jira_url)
	end
end

function git_jira.main()
	if git_jira.handle_guess_config() then
		return
	end
	if git_jira.handle_set_jira_url() then
		return
	end

	-- Check if we have ticket id
	local ticket_id = args[1]

	if ticket_id then
		git_jira.handle_branch_creation(ticket_id)
	else
		git_jira.view_jira_metadata()
	end
end

git_jira.main()
