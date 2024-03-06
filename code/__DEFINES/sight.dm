#define INVISIBILITY_SYSTEM_ALL_TURFS 5

/// SUPER IMPORTANT NOTE:
/// * DO NOT EVER USE `invisibility = 0`. Everything must be INVISIBILITY_DEFAULT at default
#define INVISIBILITY_DEFAULT  30

#define SEE_INVISIBLE_NOLIGHT 35 // We don't want to see lights!
#define INVISIBILITY_LIGHTING 40
#define SEE_INVISIBLE_EVERYONE_DEFAULT 45 // We see lights!

#define INVISIBILITY_SPIRIT 60   // invisibility level for ghostly & spiritual mobs(Revenant, floor cluwne, etc) + ghost observers
#define SEE_INVISIBLE_SPIRIT 60  // You can see ghostly & spiritual presences

#define INVISIBILITY_OBSERVER 95  // Things that are only visible by ghosts (i.e. SM countdown)
#define SEE_INVISIBLE_OBSERVER 95 // only ghosts have this. Do not give this to anyone

#define INVISIBILITY_MAXIMUM 100 //! the maximum allowed for "real" objects
#define SEE_INVISIBLE_MAXIMUM 100

#define INVISIBILITY_ABSTRACT 101 //! only used for abstract objects (e.g. spacevine_controller), things that are not really there.

#define BORGMESON		(1<<0)
#define BORGTHERM		(1<<1)
#define BORGXRAY 		(1<<2)
#define BORGMATERIAL	(1<<3)

//for clothing visor toggles, these determine which vars to toggle
#define VISOR_FLASHPROTECT	(1<<0)
#define VISOR_TINT			(1<<1)
#define VISOR_VISIONFLAGS	(1<<2) //all following flags only matter for glasses
#define VISOR_DARKNESSVIEW	(1<<3)
#define VISOR_INVISVIEW		(1<<4)
