// Stuff that is relatively "core" and is used in other defines/helpers

/**
 * The game's world.icon_size. \
 * Ideally divisible by 16. \
 * Ideally a number, but it
 * can be a string ("32x32"), so more exotic coders
 * will be sad if you use this in math.
 */
#define ICON_SIZE_ALL 32
/// The X/Width dimension of ICON_SIZE. This will more than likely be the bigger axis.
#define ICON_SIZE_X 32
/// The Y/Height dimension of ICON_SIZE. This will more than likely be the smaller axis.
#define ICON_SIZE_Y 32

//Returns the hex value of a decimal number
//len == length of returned string
#define num2hex(X, len) num2text(X, len, 16)

//Returns an integer given a hex input, supports negative values "-ff"
//skips preceding invalid characters
#define hex2num(X) text2num(X, 16)

// Refs contain a type id within their string that can be used to identify byond types.
// Custom types that we define don't get a unique id, but this is useful for identifying
// types that don't normally have a way to run istype() on them.
#define TYPEID(thing) copytext(REF(thing), 4, 6)

/// Takes a datum as input, returns its ref string
#define text_ref(datum) ref(datum)


/// Change the value of the arg(of the desired order) into the new_value.
/// This will change every arg value of subtype procs even if it's called from the most parent type of a proc.
/// This is helpful when you need to call a parent proc first, but you need to change arg value for each subtype proc.
/// * arg_number : the order number of proc argument you want to change.
/// * new_value : The value you want to assign to the target arg (arg_number)
#define revise_proc_arg_value(arg_number, new_value)\
var/callee/callee_chain = callee; \
do{\
	callee_chain.args[arg_number] = new_value;\
	callee_chain = callee_chain.caller;\
}while(callee.name == callee_chain.name); // This means: while(proc_name_foo == proc_name_foo)
