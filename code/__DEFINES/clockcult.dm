#define CLOCKCULT_MIN_SERVANTS 4
#define CLOCKCULT_MAX_SERVANTS 8

#define CLOCKCULT_CREW_PER_CULT 12

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

//Invokation types
#define INVOKATION_INSTANT 0 //Instantly calls the invokation effect after casted
#define INVOKATION_ATTACK_CULTIST 1 //For being used on cultists
#define INVOKATION_ATTACK_NON_CULTIST 2 //Once invoked, click on a non cultist to trigger effect
