GLOBAL_LIST_INIT(maintainers, world.file2list("[global.config.directory]/maintainers.txt"))

#define IS_MAINTAINER(ckey) (GLOB.patrons.Find(ckey))
