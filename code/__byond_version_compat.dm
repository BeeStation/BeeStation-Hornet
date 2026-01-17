// This file contains defines allowing targeting byond versions newer than the supported

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 516
#define MIN_COMPILER_BUILD 1648
#if (DM_VERSION < MIN_COMPILER_VERSION || DM_BUILD < MIN_COMPILER_BUILD) && !defined(SPACEMAN_DMM) && !defined(OPENDREAM)
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error You need version 516.1648 or higher
#endif

// 516.1660 broke (x in vars), which breaks a lot of things.
#if (DM_VERSION == 516 && DM_BUILD == 1660)
#error This version of BYOND (516.1660) has a bug which prevents this codebase from loading properly. If possible, update your BYOND version. Otherwise, visit www.byond.com/download/build to download an older release.
#endif

//Update this whenever the byond version is stable so people stop updating to hilariously broken versions
#define MAX_COMPILER_VERSION 516
#define MAX_COMPILER_BUILD 1700
#if DM_VERSION > MAX_COMPILER_VERSION || DM_BUILD > MAX_COMPILER_BUILD
#warn WARNING: Your BYOND version is over the recommended version (516.1700)! Stability is not guaranteed.
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
