import os
from fnmatch import fnmatch

#I know this script is complete shit, but it works and helps updating a lot of files.
#How to use:
#Update the path to your local location of your code
root = 'E:/Space Station 13/beestation_mapping/beestation/code'

def reformat(file_dir):
    f = open(file_dir, "r")
    text = f.read()
    new_text = text
    #Quick search for ui_interact
    if("/ui_interact" not in new_text):
        f.close()
        return
    #Make sure it hasn't been updated already
    if(", datum/ui_state/state = GLOB." not in new_text):
        f.close()
        print("LEAVING: ", file_dir)
        return
    print("UPDATING: ", file_dir)
    #===Update===
    #Find what the state was
    state_start_index = new_text.find(", datum/ui_state/state = GLOB.")
    dot_index = new_text.find(".", state_start_index)
    end_index = new_text.find("_state", dot_index)
    state_type = new_text[dot_index + 1: end_index]
    #Find index of ui_interact
    ui_interact_index = new_text.find("/ui_interact")
    #Find start of the line
    ui_interact_line_start = new_text.rfind("\n", 0, ui_interact_index)
    #get the type
    datum_typepath = new_text[ui_interact_line_start: ui_interact_index]
    #Insert the new state proc
    new_text = new_text[0: ui_interact_line_start] + "\n" + datum_typepath + "/ui_state(mob/user)\n\treturn GLOB." + state_type + "_state\n\n" + new_text[ui_interact_line_start + 1:]
    #Find index of ui_interact
    ui_interact_index = new_text.find("/ui_interact")
    #Find end of line
    eol_index = new_text.find(")", ui_interact_index)
    #Replace
    subs = new_text[ui_interact_index: eol_index]
    new_text = new_text[0 : int(ui_interact_index) : ] + "/ui_interact(mob/user, datum/tgui/ui" + new_text[int(eol_index) : :]
    #===================
    #try_update_ui updates
    tuui_index = new_text.find("SStgui.try_update_ui", ui_interact_index)
    tuui_eol_index = new_text.find(")", tuui_index)
    #Replace
    new_text = new_text[0: tuui_index] + "SStgui.try_update_ui(user, src, ui)" + new_text[tuui_eol_index + 1:]
    #===================
    #ui = new( updates
    new_ui_index = new_text.find("ui = new(", ui_interact_index)
    new_ui_eol_index = new_text.find(")", new_ui_index)
    #Get UI name (BIG ASSUMPTION THAT THE NAME IS FIRST STRING :) )
    string_start_index = new_text.find("\"", new_ui_index)
    string_end_index = new_text.find("\"", string_start_index + 1)
    ui_name = new_text[string_start_index : string_end_index]
    #Replace
    new_text = new_text[0: new_ui_index] + "ui = new(user, src, " + ui_name + "\")" + new_text[new_ui_eol_index + 1 : ]
    print(new_text)
    #===Done===
    f.close()
    f = open(file_dir, "w")
    f.write(new_text)
    f.close()

pattern = "*.dm"

for path, subdirs, files in os.walk(root):
    for name in files:
        if fnmatch(name, pattern):
            reformat(os.path.join(path, name))
