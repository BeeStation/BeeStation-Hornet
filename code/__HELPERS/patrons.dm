GLOBAL_LIST_INIT(patrons, world.file2list("[global.config.directory]/patrons.txt"))

#define IS_PATRON(ckey) (GLOB.patrons.Find(ckey))
