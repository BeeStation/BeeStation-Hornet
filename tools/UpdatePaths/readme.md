IMPORTANT:
Please tie the script you are making to the associated PR on github and put it in the scripts folder when you are done. Naming convention is `PR#_shortdescription`, with content from other codebases being prefixed `codebase_PR#_shortdescription`.

Example:
- 1707_clothingunderrepath
- tg_55658_cornersfix.txt

# UpdatePaths

## How to Use:
Drag one of the scripts in the “Scripts” folder onto the .bat file “Update Paths” to open it with the `.bat` file (or use the Python script directly depending on your operating system). Let the script run to completion.

Use this tool before using MapMerge2 or opening the map in an map editor. This is because the map editor may discard any unknown paths not found in the byond environment (or what it builds after parsing `beestation.dme`).

## Scriptmaking:

This tool updates paths in the game to new paths. For instance:

If you have a path labeled `/obj/structure/door/airlock/science/closed/rd` and wanted it to be `/obj/structure/door/airlock/science/rd/closed`, this tool would update it for you! This is extremely helpful if you want to be nice to people who have to resolve merge conflicts from the PRs that you make updating these areas.

---

### How do I do it?
Simply create a `.txt` and type this on a line:

`/obj/structure/door/airlock/science/closed/rd : /obj/structure/door/airlock/science/rd/closed`

The path on the left is the old, the path on the right is the new. It is seperated by a ":"
If you want to make multiple path changes in one script, simply add more changes on new lines.

Putting `{@OLD}` is important since otherwise, UpdatePaths will automatically discard the old variables attached to the old path. Adding `{@OLD}` to the right-hand side will ensure that every single variable from the old path will be applied to the new path.

--

### On Variable Editing

If you do not want any variable edits to carry over, you can simply skip adding the `{@OLD}` tag (although this is not advisable under normal circumstances). There are also a bunch of neat features you can use with UpdatePaths variable filtering, such as ensuring all new paths get a certain variable edit, filtering old paths if they have a certain variable edit, or even splitting one path into multiple paths on a map. You can find out more about this by reading (**LINK THE __main__.py FILE WHEN YOU'RE DONE DUMBASS**).

If you get lost, look at other scripts for examples.
