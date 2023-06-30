//// COOLDOWN SYSTEMS
/*
 * We have 2 cooldown systems: timer cooldowns (divided between stoppable and regular) and world.time cooldowns.
 *
 * When to use each?
 *
 * * Adding a commonly-checked cooldown, like on a subsystem to check for processing
 * * * Use the world.time ones, as they are cheaper.
 *
 * * Adding a rarely-used one for special situations, such as giving an uncommon item a cooldown on a target.
 * * * Timer cooldown, as adding a new variable on each mob to track the cooldown of said uncommon item is going too far.
 *
 * * Triggering events at the end of a cooldown.
 * * * Timer cooldown, registering to its signal.
 *
 * * Being able to check how long left for the cooldown to end.
 * * * Either world.time or stoppable timer cooldowns, depending on the other factors. Regular timer cooldowns do not support this.
 *
 * * Being able to stop the timer before it ends.
 * * * Either world.time or stoppable timer cooldowns, depending on the other factors. Regular timer cooldowns do not support this.
*/


/*
 * Cooldown system based on an datum-level associative lazylist using timers.
*/

//INDEXES
#define COOLDOWN_BORG_SELF_REPAIR	"borg_self_repair"
#define COOLDOWN_LARRYKNIFE			"larry_knife"


//TIMER COOLDOWN MACROS

#define COMSIG_CD_STOP(cd_name) "cooldown_[cd_name]"
#define COMSIG_CD_RESET(cd_name) "cd_reset_[cd_name]"

#define TIMER_COOLDOWN_START(cd_source, cd_name, cd_time) LAZYSET(cd_source.cooldowns, cd_name, addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(end_cooldown), cd_source, cd_name), cd_time))

#define TIMER_COOLDOWN_CHECK(cd_source, cd_name) LAZYACCESS(cd_source.cooldowns, cd_name)

#define TIMER_COOLDOWN_END(cd_source, cd_name) LAZYREMOVE(cd_source.cooldowns, cd_name)

/*
 * Stoppable timer cooldowns.
 * Use indexes the same as the regular tiemr cooldowns.
 * They make use of the TIMER_COOLDOWN_CHECK() and TIMER_COOLDOWN_END() macros the same, just not the TIMER_COOLDOWN_START() one.
 * A bit more expensive than the regular timers, but can be reset before they end and the time left can be checked.
*/

#define S_TIMER_COOLDOWN_START(cd_source, cd_name, cd_time) LAZYSET(cd_source.cooldowns, cd_name, addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(end_cooldown), cd_source, cd_name), cd_time, TIMER_STOPPABLE))

#define S_TIMER_COOLDOWN_RESET(cd_source, cd_name) reset_cooldown(cd_source, cd_name)

#define S_TIMER_COOLDOWN_TIMELEFT(cd_source, cd_name) (timeleft(TIMER_COOLDOWN_CHECK(cd_source, cd_name)))


/*
 * Cooldown system based on storing world.time on a variable, plus the cooldown time.
 * Better performance over timer cooldowns, lower control. Same functionality.
*/

#define COOLDOWN_DECLARE(cd_name) var/##cd_name = 0

#define COOLDOWN_STATIC_DECLARE(cd_name) var/static/##cd_name = 0

#define COOLDOWN_START(cd_source, cd_name, cd_time) (cd_source.cd_name = world.time + (cd_time))

//Returns true if the cooldown has run its course, false otherwise
#define COOLDOWN_FINISHED(cd_source, cd_name) (cd_source.cd_name < world.time)

#define COOLDOWN_RESET(cd_source, cd_name) cd_source.cd_name = 0

#define COOLDOWN_TIMELEFT(cd_source, cd_name) (max(0, cd_source.cd_name - world.time))



// when a timer should track targets individually
// this is useful when an item should individually trigger cooldown time per mob
#define COOLDOWN_LIST_DECLARE(cd_name) var/list/##cd_name = list()

#define COOLDOWN_STATIC_LIST_DECLARE(cd_name) var/static/list/##cd_name = list()

/// IMPORTANT: "cd_target_index" should be individual because it's assoc key
#define COOLDOWN_LIST_START(cd_source, cd_name, cd_target_index, cd_time) (cd_source.cd_name[cd_target_index] = world.time + (cd_time))

#define COOLDOWN_LIST_FINISHED(cd_source, cd_name, cd_target_index) (cd_source.cd_name[cd_target_index] < world.time)

#define COOLDOWN_LIST_RESET(cd_source, cd_name, cd_target_index) cd_source.cd_name[cd_target_index] = 0

#define COOLDOWN_LIST_TIMELEFT(cd_source, cd_name, cd_target_index) (max(0, cd_source.cd_name[cd_target_index] - world.time))

/// use to change existing cooldown
#define COOLDOWN_LIST_ADJUST_TIME(cd_source, cd_name, cd_target_index, cd_time) (cd_source.cd_name[cd_target_index] = cd_source.cd_name[cd_target_index] - (cd_time))
