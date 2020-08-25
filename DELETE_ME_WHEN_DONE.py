import os
from fnmatch import fnmatch

def reformat(file_dir):
    f = open(file_dir, "r")
    text = f.read()
    new_text = text
    #Quick search for ui_interact
    if("ui_interact" not in new_text):
        f.close()
        return
    #Make sure it hasn't been updated already
    if(", datum/ui_state/state = GLOB." not in new_text):
        f.close()
        print("LEAVING: ", file_dir)
        return
    print("UPDATING: ", file_dir)
    print(new_text)
    f.close()
    f = open(file_dir, "w")
    f.write(new_text)
    f.close()

root = 'E:/Space Station 13/beestation_mapping/beestation/code'
pattern = "*.dm"

for path, subdirs, files in os.walk(root):
    for name in files:
        if fnmatch(name, pattern):
            reformat(os.path.join(path, name))
