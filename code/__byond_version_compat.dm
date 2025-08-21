// This file contains defines allowing targeting byond versions newer than the supported

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 515
#define MIN_COMPILER_BUILD 1642
#if (DM_VERSION < MIN_COMPILER_VERSION || DM_BUILD < MIN_COMPILER_BUILD) && !defined(SPACEMAN_DMM) && !defined(OPENDREAM)
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error You need version 515.1642 or higher
#endif

// Unable to compile this version thanks to mutable appearance changes
#if (DM_VERSION == 515 && DM_BUILD == 1643)
#error This specific version of BYOND (515.1643) cannot compile this project.
#error If 515.1643 IS NOT the latest version of BYOND, then you should simply update as normal.
#error But if 515.1643 IS the latest version of BYOND, i.e. you can't update, then you MUST visit www.byond.com/download/build and downgrade to 515.1642.
#endif

#if (DM_VERSION == 516 && DM_BUILD == 1660)
#error This version of Byond includes a breaking bug to how vars are accessed which causes a large amount of errors during initialization and prevents var-edit from functioning.
#error Please update your Byond version at https://secure.byond.com/download
#endif

/savefile/byond_version = MIN_COMPILER_VERSION

/// Call by name proc reference, checks if the proc exists on this type or as a global proc
#define PROC_REF(X) (nameof(.proc/##X))
/// Call by name verb references, checks if the proc exists on this type or as a global verb
#define VERB_REF(X) (nameof(.verb/##X))
/// Call by name proc reference, checks if the proc exists on given type or as a global proc
#define TYPE_PROC_REF(TYPE, X) (nameof(##TYPE.proc/##X))
/// Call by name verb reference, checks if the verb exists on given type or as a global verb
#define TYPE_VERB_REF(TYPE, X) (nameof(##TYPE.verb/##X))
/// Call by name proc reference, checks if the proc is existing global proc
#define GLOBAL_PROC_REF(X) (/proc/##X)
