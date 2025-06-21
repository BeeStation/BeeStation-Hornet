//Defines for atom layers and planes
//KEEP THESE IN A NICE ACSCENDING ORDER, PLEASE


//KEEP THESE IN A NICE ACSCENDING ORDER, PLEASE

///cinematics are "below" the splash screen
#define CINEMATIC_LAYER -1

#define SPACE_LAYER 1.8
//#define TURF_LAYER 2 //For easy recordkeeping; this is a byond define
#define MID_TURF_LAYER 2.02
#define HIGH_TURF_LAYER 2.03

#define TURF_DECAL_LOWEST_LAYER 2.031
#define TURF_PLATING_DECAL_LAYER 2.031
#define TURF_DECAL_LAYER 2.039 //Makes turf decals appear in DM how they will look inworld.
#define TURF_DECAL_STRIPE_LAYER 2.0391
#define ABOVE_OPEN_TURF_LAYER 2.04
#define CLOSED_TURF_LAYER 2.05
#define BULLET_HOLE_LAYER 2.06
#define ABOVE_NORMAL_TURF_LAYER 2.08
#define LATTICE_LAYER 2.2
#define DISPOSAL_PIPE_LAYER 2.3
#define GAS_PIPE_HIDDEN_LAYER 2.35
#define WIRE_LAYER 2.4
#define WIRE_TERMINAL_LAYER 2.45
#define UNDER_CATWALK 2.454
#define NUCLEAR_REACTOR_LAYER 2.456 //Below atmospheric devices, above hidden pipes and catwalks.
#define CATWALK_LATTICE 2.455
#define GAS_SCRUBBER_LAYER 2.46
#define GAS_PIPE_VISIBLE_LAYER 2.47
#define GAS_FILTER_LAYER 2.48
#define GAS_PUMP_LAYER 2.49
#define PRESSURE_PLATE_LAYER 2.49
#define LOW_OBJ_LAYER 2.5
///catwalk overlay of /turf/open/floor/plating/catwalk_floor
#define CATWALK_LAYER 2.51
#define LOW_SIGIL_LAYER 2.52
#define SIGIL_LAYER 2.54
#define HIGH_PIPE_LAYER 2.55
#define HIGH_SIGIL_LAYER 2.56

#define BELOW_OPEN_DOOR_LAYER 2.6
#define BLASTDOOR_LAYER 2.65
#define OPEN_DOOR_LAYER 2.7
#define DOOR_HELPER_LAYER 2.71 //keep this above OPEN_DOOR_LAYER
#define PROJECTILE_HIT_THRESHOLD_LAYER 2.75 //projectiles won't hit objects at or below this layer if possible
#define TABLE_LAYER 2.8
#define BELOW_OBJ_LAYER 2.9
#define LOW_ITEM_LAYER 2.95
//#define OBJ_LAYER 3 //For easy recordkeeping; this is a byond define
#define CLOSED_BLASTDOOR_LAYER 3.05
#define CLOSED_DOOR_LAYER 3.1
#define CLOSED_FIREDOOR_LAYER 3.11
#define SHUTTER_LAYER 3.12 // HERE BE DRAGONS
#define ABOVE_OBJ_LAYER 3.2
#define ABOVE_WINDOW_LAYER 3.3
#define SIGN_LAYER 3.4
#define NOT_HIGH_OBJ_LAYER 3.5
#define HIGH_OBJ_LAYER 3.6

#define BELOW_MOB_LAYER 3.7
#define LYING_MOB_LAYER 3.8
//#define MOB_LAYER 4 //For easy recordkeeping; this is a byond define
#define MOB_MAX_CLOTHING_LAYER 4.1
#define MOB_SHIELD_LAYER 4.11
#define ABOVE_MOB_LAYER 4.2
#define WALL_OBJ_LAYER 4.35
#define EDGED_TURF_LAYER 4.4
#define ON_EDGED_TURF_LAYER 4.45
#define LARGE_MOB_LAYER 4.5
#define ABOVE_ALL_MOB_LAYER 4.6

#define METEOR_SHADOW_LAYER 4.69
#define METEOR_LAYER 4.7

#define SPACEVINE_LAYER 4.8
#define SPACEVINE_MOB_LAYER 4.9
//#define FLY_LAYER 5 //For easy recordkeeping; this is a byond define
#define GASFIRE_LAYER 5.05
#define MIMICKED_LIGHTING_LAYER 5.06
#define RIPPLE_LAYER 5.1

#define TEXT_EFFECT_UI_LAYER 5.90 // text effects shouldn't be displayed behind.
	// maybe it should be custom layer category like 'UI_LAYER 6'

///1000 is an unimportant number, it's just to normalize copied layers
#define RADIAL_LAYER 1000

#define RADIAL_BACKGROUND_LAYER 0
#define RADIAL_CONTENT_LAYER 1000

/**
 * Planes
 */

//NEVER HAVE ANYTHING BELOW THIS PLANE ADJUST IF YOU NEED MORE SPACE
#define LOWEST_EVER_PLANE -200

#define CLICKCATCHER_PLANE -99

#define PLANE_SPACE -95
#define PLANE_SPACE_PARALLAX -90

#define GRAVITY_PULSE_PLANE -89
#define GRAVITY_PULSE_RENDER_TARGET "*GRAVPULSE_RENDER_TARGET"

//---------- Z-MIMIC -------------
//#define ZMIMIC_MIN_PLANE -80
// ZMIMIC: -----------  -80 to -70
// Highest plane used by zmimic, occupies up to -ZMIMIC_MAX_DEPTH
#define ZMIMIC_MAX_PLANE -70
/// The maxiumum number of planes deep we'll go before we just dump everything on the same plane.
#define ZMIMIC_MAX_DEPTH 10

//---------- ABSTRACT LIGHTING -------------
// Layering order of these is not particularly meaningful.
// Important part is the seperation of the planes for control via plane_master
// We put these below the standard planes because if they are rendered without a plane-master (RenderIcon)
// then we want them to be as hidden as possible.

///This plane masks out lighting to create an "emissive" effect, ie for glowing lights in otherwise dark areas
#define EMISSIVE_PLANE -50
#define EMISSIVE_RENDER_TARGET "*EMISSIVE_PLANE"

/// The plane for managing the global starlight effect
#define STARLIGHT_PLANE -45

//---------- STANDARD -------------

#define FLOOR_PLANE -7
#define GAME_PLANE -4
#define GAME_PLANE_RENDER_TARGET "GAME_PLANE_RENDER_TARGET"

#define BLACKNESS_PLANE 0 //To keep from conflicts with SEE_BLACKNESS internals

#define AREA_PLANE 60
#define TEXT_EFFECT_PLANE 65
#define MASSIVE_OBJ_PLANE 70
#define GHOST_PLANE 80
#define POINT_PLANE 90

#define DATA_HUD_PLANE 15

//---------- LIGHTING -------------
///Normal 1 per turf dynamic lighting objects
#define LIGHTING_PLANE 100
#define LIGHTING_PLANE_ADDITIVE 101

///Lighting objects that are "free floating"
#define O_LIGHTING_VISUAL_PLANE 110
#define O_LIGHTING_VISUAL_LAYER 110
#define O_LIGHTING_VISUAL_RENDER_TARGET "O_LIGHT_VISUAL_PLANE"

///Things that should render ignoring lighting
#define ABOVE_LIGHTING_PLANE 120

///visibility + hiding of things outside of light source range
#define BYOND_LIGHTING_PLANE 130

///---------------- MISC -----------------------

///AI Camera Static
#define CAMERA_STATIC_PLANE 200

///Anything that wants to be part of the game plane, but also wants to draw above literally everything else
#define HIGH_GAME_PLANE 499

#define FULLSCREEN_PLANE 500

///Popup Chat Messages
#define RUNECHAT_PLANE 650
/// Plane for balloon text (text that fades up)
#define BALLOON_CHAT_PLANE 651

#define ATMOS_GROUP_PLANE 652
#define ATMOS_GROUP_LAYER 652

///--------------- FULLSCREEN IMAGES ------------
#define FLASH_LAYER 1
#define FULLSCREEN_LAYER 2
#define UI_DAMAGE_LAYER 3
#define BLIND_LAYER 4
#define CRIT_LAYER 5
#define CURSE_LAYER 6

///--------------- PSYCHIC & BLIND IMAGES ------------
//Plane for highlighting objects - most soul glimmers
#define PSYCHIC_PLANE 550
#define PSYCHIC_PLANE_RENDER_TARGET "*PSYCHIC_PLANE_RENDER_TARGET"
//Plane for not-highlighting objects - most hiding cult stuff
#define ANTI_PSYCHIC_PLANE 551
#define ANTI_PSYCHIC_PLANE_RENDER_TARGET "*ANTI_PSYCHIC_PLANE_RENDER_TARGET"
//Plane for blind stuff
#define BLIND_FEATURE_PLANE 552

//-------------------- Rendering ---------------------
#define RENDER_PLANE_GAME 990
#define RENDER_PLANE_NON_GAME 995
#define RENDER_PLANE_MASTER 999

//-------------------- HUD ---------------------
//HUD layer defines
#define HUD_PLANE 1000
#define HUD_LAYER 25
#define HUD_RENDER_TARGET "HUD_PLANE"
/// Layer for screentips
#define SCREENTIP_LAYER 26

#define ABOVE_HUD_PLANE 1100
#define ABOVE_HUD_RENDER_TARGET "ABOVE_HUD_PLANE"

///Plane of the "splash" icon used that shows on the lobby screen. Nothing should ever be above this.
#define SPLASHSCREEN_PLANE 9999

///Plane master controller keys
#define PLANE_MASTERS_GAME "plane_masters_game"
