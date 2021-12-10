//Cleaning tool strength
// 1 is also a valid cleaning strength but completely unused so left undefined
#define CLEAN_WEAK 			2
/// Acceptable tools
#define CLEAN_MEDIUM		3
/// Industrial strength
#define CLEAN_STRONG		4
/// Cleaning strong enough your granny would be proud
#define CLEAN_IMPRESSIVE	5
/// Cleans things spotless down to the atomic structure
#define CLEAN_GOD			6
/// Never cleaned
#define CLEAN_NEVER 7

//How strong things have to be to wipe forensic evidence...
#define CLEAN_STRENGTH_FINGERPRINTS CLEAN_IMPRESSIVE
#define CLEAN_STRENGTH_BLOOD CLEAN_WEAK
#define CLEAN_STRENGTH_FIBERS CLEAN_IMPRESSIVE

// Different kinds of things that can be cleaned.
// Use these when overriding the wash proc or registering for the clean signals to check if your thing should be cleaned
/// Cleans blood off of the cleanable atom.
#define CLEAN_TYPE_BLOOD		(1 << 0)
/// Cleans runes off of the cleanable atom.
#define CLEAN_TYPE_RUNES		(1 << 1)
/// Cleans fingerprints off of the cleanable atom.
#define CLEAN_TYPE_FINGERPRINTS	(1 << 2)
/// Cleans fibres off of the cleanable atom.
#define CLEAN_TYPE_FIBERS		(1 << 3)
/// Cleans radiation off of the cleanable atom.
#define CLEAN_TYPE_RADIATION	(1 << 4)
/// Cleans diseases off of the cleanable atom.
#define CLEAN_TYPE_DISEASE		(1 << 5)
/// Special type, add this flag to make some cleaning processes non-instant. Currently only used for showers when removing radiation.
#define CLEAN_TYPE_WEAK			(1 << 6)
/// Cleans paint off of the cleanable atom.
#define CLEAN_TYPE_PAINT		(1 << 7)
/// Cleans acid off of the cleanable atom.
#define CLEAN_TYPE_ACID			(1 << 8)

// Different cleaning methods.
// Use these when calling the wash proc for your cleaning apparatus
#define CLEAN_WASH (CLEAN_TYPE_BLOOD | CLEAN_TYPE_RUNES | CLEAN_TYPE_DISEASE | CLEAN_TYPE_ACID)
#define CLEAN_SCRUB (CLEAN_WASH | CLEAN_TYPE_FINGERPRINTS | CLEAN_TYPE_FIBERS | CLEAN_TYPE_PAINT)
#define CLEAN_RAD CLEAN_TYPE_RADIATION
#define CLEAN_ALL (ALL & ~CLEAN_TYPE_WEAK)
