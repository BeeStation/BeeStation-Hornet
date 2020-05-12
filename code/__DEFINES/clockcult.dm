#define CLOCKCULT_MIN_SERVANTS 4
#define CLOCKCULT_MAX_SERVANTS 8

#define CLOCKCULT_CREW_PER_CULT 12	//The amount of crew per each servant. 0-48: 4 | 49 - 60: 5 | 61 - 72:6 | 73 - 84: 7 | >85 : 8

//component id defines; sometimes these may not make sense in regards to their use in scripture but important ones are bright
#define BELLIGERENT_EYE "belligerent_eye" //! Use this for offensive and damaging scripture!
#define VANGUARD_COGWHEEL "vanguard_cogwheel" //! Use this for defensive and healing scripture!
#define GEIS_CAPACITOR "geis_capacitor" //! Use this for niche scripture!
#define REPLICANT_ALLOY "replicant_alloy"
#define HIEROPHANT_ANSIBLE "hierophant_ansible" //! Use this for construction-related scripture!

//Invokation speech types
#define INVOKATION_WHISPER 1
#define INVOKATION_SPOKEN 2
#define INVOKATION_SHOUT 3

#define DEFAULT_CLOCKSCRIPTS "6:-29,4:-2"

GLOBAL_LIST_EMPTY(servants_of_ratvar)	//List of minds in the cult

GLOBAL_VAR(clockcult_team)

GLOBAL_VAR(ratvar_arrival_tick)	//The world.time that Ratvar will arrive if the gateway is not disrupted

GLOBAL_VAR(celestial_gateway)	//The celestial gateway
GLOBAL_VAR_INIT(ratvar_risen, FALSE)	//Has ratvar risen?
GLOBAL_VAR_INIT(gateway_opening, FALSE)	//Is the gateway currently active?

//A useful list containing all scriptures with the index of the name.
//This should only be used for looking up scriptures
GLOBAL_LIST_EMPTY(clockcult_all_scriptures)

//scripture types
#define SCRIPTURE 0
#define DRIVER 1
#define APPLICATION 2
