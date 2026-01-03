//#define TESTING				//By using the testing("message") proc you can create debug-feedback for people with this
								//uncommented, but not visible in the release version)

//#define DATUMVAR_DEBUGGING_MODE	//Enables the ability to cache datum vars and retrieve later for debugging which vars changed.

// Comment this out if you are debugging problems that might be obscured by custom error handling in world/Error
#ifdef DEBUG
#define USE_CUSTOM_ERROR_HANDLER
#endif

#ifdef TESTING
#define DATUMVAR_DEBUGGING_MODE

///Used to find the sources of harddels, quite laggy, don't be surpised if it freezes your client for a good while
//#define REFERENCE_TRACKING
#ifdef REFERENCE_TRACKING

///Used for doing dry runs of the reference finder, to test for feature completeness
///Slightly slower, higher in memory. Just not optimal
//#define REFERENCE_TRACKING_DEBUG

///Run a lookup on things hard deleting by default.
//#define GC_FAILURE_HARD_LOOKUP
#ifdef GC_FAILURE_HARD_LOOKUP
///Don't stop when searching, go till you're totally done
#define FIND_REF_NO_CHECK_TICK
#endif //ifdef GC_FAILURE_HARD_LOOKUP

#endif //ifdef REFERENCE_TRACKING

//#define VISUALIZE_ACTIVE_TURFS	//Highlights atmos active turfs in green
//#define TRACK_MAX_SHARE	//Allows max share tracking, for use in the atmos debugging ui
#endif //ifdef TESTING

/// Disables hub authentication. This must be done at compile time due to /client::authenticate being read-only
/// All connecting users will be forced to use external auth. If external auth is not enabled in the config, the connection is blindly trusted.
/// DO NOT ENABLE THIS FLAG ON PRODUCTION WITHOUT EXTERNAL AUTH SET UP
/// Toggle ENABLE_GUEST_EXTERNAL_AUTH to require external auth, otherwise CKEYs are blindly trusted!
/// This flag also forcibly enables guest connections, because every client has its key reassigned on login.
/// This flag also disables BYOND account age checks, BYOND Key change verification, and makes the config flag use_account_age_for_jobs useless.
//#define DISABLE_BYOND_AUTH

/// Enables BYOND TRACY, which allows profiling using Tracy.
/// The prof.dll/libprof.so must be built and placed in the repo folder.
/// https://github.com/mafemergency/byond-tracy
//#define USE_BYOND_TRACY

/////////////////////// ZMIMIC

///Enables Multi-Z lighting
/// Doesn't work and causes artifacts when lights are deleted
//#define ZMIMIC_LIGHT_BLEED

/// If this is uncommented, will profile mapload atom initializations
//#define PROFILE_MAPLOAD_INIT_ATOM
#ifdef PROFILE_MAPLOAD_INIT_ATOM
#warn PROFILE_MAPLOAD_INIT_ATOM creates very large profiles, do not leave this on!
#endif

//#define UNIT_TESTS			//If this is uncommented, we do a single run though of the game setup and tear down process with unit tests in between

/// If this is uncommented, we set up the ref tracker to be used in a live environment
/// And to log events to [log_dir]/harddels.log
//#define REFERENCE_DOING_IT_LIVE
#ifdef REFERENCE_DOING_IT_LIVE
// compile the backend
#define REFERENCE_TRACKING
// actually look for refs
#define GC_FAILURE_HARD_LOOKUP
#endif // REFERENCE_DOING_IT_LIVE

#ifdef REFERENCE_TRACKING_FAST
#define REFERENCE_TRACKING
#define REFERENCE_TRACKING_DEBUG
#endif

/// If this is uncommented, force our verb processing into just the 2% of a tick
/// We normally reserve for it
/// NEVER run this on live, it's for simulating highpop only
// #define VERB_STRESS_TEST

#ifdef VERB_STRESS_TEST
/// Uncomment this to force all verbs to run into overtime all of the time
/// Essentially negating the reserve 2%

// #define FORCE_VERB_OVERTIME
#warn Hey brother, you're running in LAG MODE.
#warn IF YOU PUT THIS ON LIVE I WILL FIND YOU AND MAKE YOU WISH YOU WERE NEVE-
#endif

// If defined, we will compile with FULL timer debug info, rather then a limited scope
// Be warned, this increases timer creation cost by 5x
// #define TIMER_DEBUG

/// If this is uncommented, Autowiki will generate edits and shut down the server.
/// Prefer the autowiki build target instead.
// #define AUTOWIKI

#ifndef PRELOAD_RSC	//set to:
#define PRELOAD_RSC	0 // 0 to allow using external resources or on-demand behaviour;
#endif				// 1 to use the default behaviour;
					// 2 for preloading absolutely everything;

//#define LOWMEMORYMODE
#ifdef LOWMEMORYMODE
	#warn WARNING: Compiling with LOWMEMORYMODE.
	#ifdef FORCE_MAP
	#warn WARNING: FORCE_MAP is already defined.
	#else
	#define FORCE_MAP "runtimestation"
	#endif
	#ifdef CIBUILDING
	#error LOWMEMORYMODE is enabled, disable this!
	#endif
#endif

#define SENDMAPS_PROFILE

//Additional code for the above flags.
#ifdef TESTING
#warn compiling in TESTING mode. testing() debug messages will be visible.

#ifdef CIBUILDING
#error TESTING is enabled, disable this!
#endif
#endif

#ifdef CIBUILDING
#define UNIT_TESTS
#endif

#ifdef CITESTING
#define TESTING
#endif

#if defined(UNIT_TESTS)
//Hard del testing defines
#define REFERENCE_TRACKING
#define REFERENCE_TRACKING_DEBUG
#define FIND_REF_NO_CHECK_TICK
#define GC_FAILURE_HARD_LOOKUP
//Test at full capacity, the extra cost doesn't matter
#define TIMER_DEBUG
#endif

#ifdef TGS
// TGS performs its own build of dm.exe, but includes a prepended TGS define.
#define CBT
#endif


#if defined(OPENDREAM) && !defined(CIBUILDING)
#warn You are building with OpenDream. Remember to build TGUI manually.
#warn You can do this by running tgui-build.cmd from the bin directory.
#elif !defined(CBT) && !defined(SPACEMAN_DMM) && !defined(FASTDMM) && !defined(CIBUILDING)
#warn Building with Dream Maker is no longer supported and will result in missing interface files.
#warn Switch to VSCode and when prompted install the recommended extensions, you can then either use the UI or press Ctrl+Shift+B to build the codebase.
#endif
