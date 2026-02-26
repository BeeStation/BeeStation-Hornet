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
