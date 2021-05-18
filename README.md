<!--alex disable blacklist color colors execute kill nuke sexy whitelist wtf-->

# bin

> My collection of small binary utilities

---

This repository was created from my [dotfiles][1] repository. I've collected
(and wrote some myself) along almost 10 years. If you know the author of some
uncredited bin, please, [let me know][issue] (or open a
[pull-request][pull-request]) and I'll update it accordingly. :)

> **Disclaimer**: I mainly use ZSH, so some scripts here might not work as well
> (or not work at all) in other shell like [bash][2] or [fish][3]. Feel free to
> open a [pull-request][pull-request] to make these scripts more portable.

## Install

Clone this somewhere in your system, for example `$HOME/.bin-filipekiss`

```sh
$ git clone https://github.com/filipekiss/bin ~/.bin-filipekiss
```

Then, edit your `PATH` variable to add the folder above to it. (If you have no
idea where that is, it's probably in a file called `.zshrc` or `.bashrc` that
sits in your home folder)

```
export PATH=$HOME/.bin-filipekiss:$PATH
```

Restart your terminal and the commands should be available.

## Commands

### \$

If you ever copied a command from the internet (like the `git clone` above) and
got an error saying `$: command not found`, this is the script for you. It
reminds you to stop copy pasting commands from the internet (because that's a
security issue, you know) but also runs the command so you don't get frustrated

---

### +x

Shortcut to `chmod +x`, to easily give execute permission to files

---

### \_\_debug

This is a small utility I wrote to help me debug some scripts (specially
completion scripts, since it's hard to output information). It's a very crude
logging mechanism.

#### Example

At the beginning of your script, call `__debug start`. You may pass an optional
file name where the messages will be written, for example
`__debug start myscript.log`. Be aware that the `myscript.log` file **will be
truncated**.

During your script, when you need to debug something, just call
`__debug "Debugging message"` and a message will be appended to the debug file,
with a time stamp.

You can use `__debug tail` to tail the latest debug file (or you can `tail -f`
the file directly)

---

### colortest

Print a color table showing all terminal colors supported.

#### Example

![image](https://user-images.githubusercontent.com/48519/57935022-3ec4f200-7897-11e9-94cf-dc09a515ac0f.png)

---

### dst

**USAGE:** `dst [TIMEZONE]`

Check daylight savings for a given timezone. Timezone must be in _tz database_
format. You can check the complete list
[here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

### extract

Use to extract compressed files: `extract archive.zip`.

**Supported extensions:** `*.tar.bz2`, `*.tar.gz`, `*.bz2`, `*.rar`, `*.gz`,
`*.tar`, `*.tbz2`, `*.tgz`, `*.zip`, `*.Z`, `*.7z`

---

> **A word about `git-` binaries**
>
> All utilities that are prefixed with `git-` can be used as git commands. so
> instead of using the command as `git-browse` you can `git browse` and have the
> same effect.

### git-ahead (git ahead)

**USAGE:** `git ahead`

Show which commits will be pushed to the current tracked branch.

#### Options

| Flags            | Description                            |
| :--------------- | :------------------------------------- |
| **--submodules** | Include submodules when checking       |
| **--force**      | Force fetching changes from the remote |

`git-ahead` accepts any argument you're able to pass to `git log`

---

### git-behind (git behind)

**USAGE:** `git behind`

Show which commits will be pulled from the current tracked branch.

#### Options

| Flags            | Description                            |
| :--------------- | :------------------------------------- |
| **--submodules** | Include submodules when checking       |
| **--force**      | Force fetching changes from the remote |

`git-behind` accepts any argument you're able to pass to `git log`

---

### git-browse (git browse)

**USAGE:** `git browse`

use this to open the current project in your browser. this will parse the
default remote (usually `origin`) to choose which url to open. if you have
multiple remotes, you can pass an options argument with the remote name, for
example `git browse gitlab`.

> If you have [`hub`][hub] installed, it already provides a `browse` command to
> git and it will take precedence over this.

---

### git-churn (git churn)

**USAGE:** `git churn`

Churn means "frequency of change". You'll get an output like this:

```sh
$ git churn
1 file1
22 file2
333 file3
```

This means that `file1` changed one time, `file2` changes 22 times, and `file3`
changes 333 times.

Show churn for whole repo: `$ git churn`

Show churn for specific directories: `$ git churn app lib`

Show churn for a time range: `$ git churn --since='1 month ago'`

`git-churn` accepts any argument you're able to pass to `git log`

---

### git-conflicts (git conflicts)

**USAGE:** `git conflicts`

Show all files that are in a conflicted state.

---

### git-credit (git credit)

**USAGE:** `git credit "Zach Holman" zach@example.com`

Use this to credit the previous commit to another author

---

### git-deinit (git deinit)

**USAGE:** `git deinit`

Remove all `git` related files. It's the opposite of `git init`.

**THIS COMMAND IS NOT REVERSIBLE. YOU WILL LOOSE ALL HISTORY.**

---

### git-delete-tags (git delete-tags)

**USAGE:** `git delete-tags`

Remove all tags locally and remotely. Requires **awk**

---

### git-delete-merged-branches (git delete-merged-branches)

**USAGE:** `git delete-merged-branches`

Check which branches are already merged into you main branch and delete them.

#### Options

| Flags                         | Description                                                                                                                                           |
| :---------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------- |
| **--remote**                  | Run against remote branches. Default is running on local                                                                                              |
| **--dry-run, -n**             | Don't actually delete anything. Useful for checking what would be deleted                                                                             |
| **--master-branch [master]**  | Use this to pass the name of the branch that act as a master, in case your repository uses a different name.                                          |
| **--origin [origin]**         | Set the name of the remote to run against. Defaults to origin                                                                                         |
| **--force**                   | Force deletion of branches. You shouldn't need this option, ever                                                                                      |
| **--whitelist [branch-name]** | If this option is given, only branches that match the given names we'll be deleted. It can be passed multiple times. \* wildcard is supported         |
| **--blacklist [branch-name]** | If this option is given, only branches that DO NOT match the given names we'll be deleted. It can be passed multiple times. \* wildcard is supported. |
| **--squashed**                | Also check for branches that were merged to master using the squash strategy                                                                          |
| **--squashed-only**           | Check only for branches that we're merged using the squash strategy                                                                                   |
| **--no-squash-warning**       | Suppress the output information when squashed branches are found but no `--squashed` option was passed                                                |

#### Arguments

| Argument        | Description                                                                                                                                                                    |
| :-------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **branch name** | The only argument this command accepts is the branch name to compare other branches against. Defaults to origin/master (or whatever remote you pass using the --origin option) |

---

### git-edit (git edit)

**USAGE:** `git edit [conflicts|commited|staged|edited]`

Use this to edit file in various states. Uses `$EDITOR` to decide which editor
to use

#### Usage

**`git edit conflicts`** <br> Open all files that are in a conflicted state

**`git edit commited`** <br> Open all files that were changed on the last commit

**`git edit staged`** <br> Open all files that are staged for commit since last
commit

**`git edit edited`** <br> Open all files that were edited but not staged since
last commit

---

### git-flush (git flush)

**USAGE:** `git flush`

Use this to reduce the size of your repository. It deletes all reflogs, stashes
and other stuff that may be bloating your repository.

_Requires `perl`_

---

### git-go (git go)

**USAGE:** `git-go [OPTION] [COMMAND]`

#### Options

| Flags | Description                                                    |
| ----- | -------------------------------------------------------------- |
| `-g`  | Perform command globally, not scoped to current git repository |

#### Commands

| Command             | Description                                                                                                                                                                                                                         |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **search "q"**      | Perform a search                                                                                                                                                                                                                    |
| **@user**           | Browse a user. Is you pass **@user/repository**, browse that repo instead                                                                                                                                                           |
| **explore**         | Explore GitHub                                                                                                                                                                                                                      |
| **my [SUBCOMMAND]** | Browse your personal items, where SUBCOMMAND is one of: <ul> <li>`dashboard`</li><li>`issues [assigned\|mentioned\|created]`</li><li>`notifications`</li><li>`profile`</li><li>`pulls`</li><li>`settings`</li><li>`stars`</li></ul> |

---

### git-health (git health)

**USAGE:** `git health [all|local|remote] --stale --markdown`

By default, git health will be run against local branches. You can pass local to
only check local branches and remote to only check remote branches and all to
check all branches.

The branches will be sorted by last activity, from the most recently active to
the least recent active. You can use a dash prefix to invert the order, so
`git health -all` will list all branches with the most stale branch on top and
the most recent active branch on the bottom

If you pass the `--stale` option, only stale branches will be listed. By
default, branches are considered stale if no commit was made to them in the past
3 months. You can pass a value to stale, so `--stale "15 days ago"` will list
branches with no commits in the last 15 days.

If you pass the `--markdown` option, the output will be a markdown table, so you
can do something like `git health --markdown > stale_branches.md` to easily have
a markdown file generated with the stale branches.

---

### git-ignore (git ignore)

**USAGE:** `git ignore [OPTIONS] [patterns]`

Add files to `.gitignore` or `.git/info/exclude`. If adding to
`.git/info/exclude`, the file will be ignored for the current clone only. This
is not commited.

#### Options

| Flags             | Description                                               |
| ----------------- | --------------------------------------------------------- |
| **--exclude, -e** | Use `.git/info/exclude` instead of adding to `.gitignore` |
| **--root, -R**    | Add to the `.gitignore` file in the root of the project.  |

---

### git-maxpack (git maxpack)

**USAGE:** `git maxpack`

Set git compression to the maximum level and repack the current repository

---

### git-nuke (git nuke)

**USAGE:** `git nuke an-old-branch`

Deletes a branch both locally and on the origin remote

---

### git-purge-file (git purge-file)

**USAGE:** `git purge-file file1 file2`

This will remove all paths from the current git repository and history. See
[this help article from GitHub](https://help.github.com/en/articles/removing-sensitive-data-from-a-repository)
for more info.

---

### gir-rel (git rel)

**USAGE:** `git-rel [<ref>]` Shows the relationship between the current branch
and <ref>. With no <ref>, the current branch's remote tracking branch is used.

Examples:

        $ git-rel
        15 ahead
        11 behind

        $ git-rel v1.1
        230 ahead

---

### git-rewrite-to-subfolder (git rewrite-to-subfolder)

**USAGE:** `git rewrite-to-subfolder`

This script rewrites your entire history, moving the current repository root
into a subdirectory. This can be useful if you want to merge a submodule into
its parent repository.

For example, your main repository might contain a submodule at the path
`src/lib/`, containing a file called `test.c`. If you would merge the submodule
into the parent repository without further modification, all the commits to
`test.c` will have the path `/test.c`, whereas the file now actually lives in
`src/lib/test.c`.

If you rewrite your history using this script, adding `src/lib/` to the path and
the merging into the parent repository, all paths will be correct.

**NOTE: This script might complete garble your repository, so PLEASE apply this
only to a clone of the repository where it does not matter if the repo is
destroyed.**

---

### git-shamend (git shamend)

**USAGE:** `git shamend [options] [<revision>]`

Amends your staged changes as a fixup (keeping the pre-existing commit message)
to the specified commit, or HEAD if no revision is specified.

##### Options:

| Flags         | Description                                 |
| :------------ | :------------------------------------------ |
| **-a, --all** | Commit unchanged files, same as git commit. |

---

### git-st (git st)

**USAGE:** `git st`

A better git status, that shows a short summary and the diff stat.

Taken from
[this reddit thread](https://www.reddit.com/r/git/comments/cfykfu/better_git_status/)

## ![git-st example screenshot](https://user-images.githubusercontent.com/48519/61865981-9c4b6f80-aed4-11e9-9337-6673e50b20b4.png)

### git-store (git store)

**USAGE:** `git store [description]` after `git add files-to-stash`

This script is based on
[this stackoverflow answer](https://stackoverflow.com/a/32951373). It basically
creates two stashes: One named "Stashed: <description>", which includes
everything. This is git default stash. A second one named "Stored:
<description>". This will include only the staged changes. By default, the first
stash created is deleted, leaving you only with the stash with the staged
changes. See the `store.preserve` option below for more info.

##### Settings

`store.preserve = [true|false]` <br> By default, `git-store` will not preserve
the unstaged changes. Since we use the double stash method, it will delete the
"bad" stash and keep only the "good" stash (the one with only the staged
changes). You can keep the "bad" stash by setting the `store.preserve` config to
true:

`git config [--global] store.preserve true`

---

### git-sync (git sync)

**USAGE:** `git sync [origin] [branch]`

Syncs the current branch with it's remote counterpart. Basically a shortcut to
`git pull --rebase && git push`

> If you have [`hub`][hub] installed, it already provides a `sync` command to
> git and it will take precedence over this.

---

### git-up (git up)

**USAGE:** `git-up`

Like `git-pull` but show a short and sexy log of changes

---

### git-what-the-hell-just-happened (git what-the-hell-just-happened)

**USAGE:** `git what-the-hell-just-happened [branch]`

Show what was changed between the last two commits (`HEAD` and `HEAD@{1}`).

---

### git-winner (git winner)

**USAGE:** `git winner [date] --detail`

Show who has the most commits (number of commits and number of commited lines)
after a given date. If `--detail` is passed, all messages for the commits
analyzed will be printed.

---

### git-wtf (git wtf)

**USAGE:** `git wtf [branch+] [options]`

`git-wtf` displays the state of your repository in a readable, easy-to-scan
format. It's useful for getting a summary of how a branch relates to a remote
server, and for wrangling many topic branches.

`git-wtf` can show you:

- How a branch relates to the remote repo, if it's a tracking branch.
- How a branch relates to integration branches, if it's a feature branch.
- How a branch relates to the feature branches, if it's an integration branch.

`git-wtf` is best used before a git push, or between a git fetch and a git
merge. Be sure to set color.ui to auto or yes for maximum viewing pleasure.

If [branch] is not specified, `git-wtf` will use the current branch. The
possible [options] are:

| Options               | Description                                                           |
| --------------------- | --------------------------------------------------------------------- |
| **-l, --long**        | include author info and date for each commit                          |
| **-a, --all**         | show all branches across all remote repos, not just those from origin |
| **-A, --all-commits** | show all commits, not just the first 5                                |
| **-s, --short**       | don't show commits                                                    |
| **-k, --key**         | show key                                                              |
| **-r, --relations**   | show relation to features / integration branches                      |
| **--dump-config**     | print out current configuration and exit                              |

`git-wtf` uses some heuristics to determine which branches are integration
branches, and which are feature branches. (Specifically, it assumes the
integration branches are named "master", "next" and "edge".) If it guesses
incorrectly, you will have to create a `.git-wtfrc` file.

To start building a configuration file, run `git-wtf --dump-config > .git-wtfrc`
and edit it. The config file is a YAML file that specifies the integration
branches, any branches to ignore, and the max number of commits to display when
`--all-commits` isn't used. `git-wtf` will look for a `.git-wtfrc` file starting
in the current directory, and recursively up to the root.

IMPORTANT NOTE: all local branches referenced in `.git-wtfrc` must be prefixed
with `heads/`, e.g. `heads/master`. Remote branches must be of the form
`remotes/<remote>/<branch>`.

---

### killport

**USAGE:** `killport [PORT]`

Kill all processes running on the specified port.

---

### macos-wifi

**USAGE:** `macos-wify [no-symbol]`

I used this to show the current wi-fi connection name in my TMUX status bar. If
you pass `no-symbol` as the argument, only the SSID of the connection will be
returned. Otherwise, the format `₩:<SSID>` wil be used

---

### network-status

**USAGE:** `network-status [options]`

![network-status demo](https://user-images.githubusercontent.com/48519/67092470-900f3f80-f1af-11e9-8e95-d9df1dc5ae85.gif)

An improved version of the `macos-wifi` binary. It works as a general tool to
test internet availability. If you are connected to a Wi-Fi network, a Wi-Fi
symbol and the network name will be displayed. If you're using a cabled
connection, a little ethernet cable will be used to display the network status.

_**The script works under Linux as well, but it won't show the network name.
Also note that, for the symbols to show properly, you need to use a font that
has been patched with [Nerd Font](https://www.nerdfonts.com)**_

#### Options

| Flags          | Description                                    |
| :------------- | :--------------------------------------------- |
| **--no-color** | Don't show colored output                      |
| **--tmux**     | Use TMUX formatting instead of terminal colors |

---

### test-drive

###### [original source](https://gist.github.com/hellricer/e514d9615d02838244d8de74d0ab18b3)

**USAGE:** `test-drive`

![test-drive demo](https://user-images.githubusercontent.com/48519/91456891-1393c580-e884-11ea-9c8b-eaab8f694aba.png)

Display the current terminal capabilities, including 24-bit color, left-to-right
chars, sixel images, emoji etc…

---

## Thanks

I'd like to thank everyone who posts their scripts online so people like me are
able to read and learn from them. This is a small way of giving back to the
community.

**filipekiss/bin** © 2019+, Filipe Kiss Released under the [MIT] License.<br>
Authored and maintained by Filipe Kiss.

> GitHub [@filipekiss](https://github.com/filipekiss) &nbsp;&middot;&nbsp;
> Twitter [@filipekiss](https://twitter.com/filipekiss)

[mit]: http://mit-license.org/
[1]: https://github.com/filipekiss/dotfiles
[2]: https://www.gnu.org/software/bash/
[3]: https://fishshell.com/
[issue]: https://github.com/filipekiss/bin/issues/new
[pull-request]: https://github.com/filipekiss/bin/compare
[hub]: https://hub.github.com/
