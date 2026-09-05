#define STAT_ENTRY_TIME 1
#define STAT_ENTRY_COUNT 2
#define STAT_ENTRY_LENGTH 2


#define STAT_START_STOPWATCH var/STAT_STOP_WATCH = TICK_USAGE
#define STAT_STOP_STOPWATCH var/STAT_TIME = TICK_USAGE_TO_MS(STAT_STOP_WATCH)
#define STAT_LOG_ENTRY(entrylist, entryname) \
	var/list/STAT_ENTRY = entrylist[entryname] || (entrylist[entryname] = new /list(STAT_ENTRY_LENGTH));\
	STAT_ENTRY[STAT_ENTRY_TIME] += STAT_TIME;\
	STAT_ENTRY[STAT_ENTRY_COUNT] += 1;



