
#define DECISECONDS_IN_DAY 864000	//number of deciseconds in a day
#define MIDNIGHT_ROLLOVER		864000	//number of deciseconds in a day

#define JANUARY		1
#define FEBRUARY	2
#define MARCH		3
#define APRIL		4
#define MAY			5
#define JUNE		6
#define JULY		7
#define AUGUST		8
#define SEPTEMBER	9
#define OCTOBER		10
#define NOVEMBER	11
#define DECEMBER	12

//Select holiday names -- If you test for a holiday in the code, make the holiday's name a define and test for that instead
#define NEW_YEAR "New Year"
#define VALENTINES "Valentine's Day"
#define APRIL_FOOLS "April Fool's Day"
#define EASTER "Easter"
#define HALLOWEEN "Halloween"
#define CHRISTMAS "Christmas"
#define FESTIVE_SEASON "Festive Season"
#define GARBAGEDAY "Garbage Day"
#define MONKEYDAY "Monkey Day"

/*

Days of the week to make it easier to reference them.

When using time2text(), please use "DDD" to find the weekday. Refrain from using "Day"

*/

#define MONDAY "Mon"
#define TUESDAY "Tue"
#define WEDNESDAY "Wed"
#define THURSDAY "Thu"
#define FRIDAY "Fri"
#define SATURDAY "Sat"
#define SUNDAY "Sun"

#define MILLISECONDS *0.01

#define DECISECONDS *1 //the base unit all of these defines are scaled by, because byond uses that as a unit of measurement for some fucking reason

#define SECONDS *10

#define MINUTES SECONDS*60

#define HOURS MINUTES*60

#define TICKS *world.tick_lag

#define DS2TICKS(DS) ((DS)/world.tick_lag)

#define TICKS2DS(T) ((T) TICKS)

#define MS2DS(T) ((T) MILLISECONDS)

#define DS2MS(T) ((T) * 100)

/// Amount of years from the current year to offset in-universe
#define YEAR_OFFSET 540

