//max channel is 1024. Only go lower from here, because byond tends to pick the first availiable channel to play sounds on
#define CHANNEL_LOBBYMUSIC		1024
#define CHANNEL_ADMIN			1023
#define CHANNEL_VOX				1022
#define CHANNEL_JUKEBOX			1021
#define CHANNEL_JUSTICAR_ARK	1020
#define CHANNEL_HEARTBEAT		1019 //sound channel for heartbeats
#define CHANNEL_AMBIENT_EFFECTS	1018
#define CHANNEL_AMBIENT_MUSIC	1017
#define CHANNEL_BUZZ			1017
#define CHANNEL_ELEVATOR_MUSIC	1016
#define CHANNEL_SOUNDTRACK		1015
#define CHANNEL_ANTAG_GREETING	1014

/// This is the lowest volume that can be used by playsound otherwise it gets ignored
/// Most sounds around 10 volume can barely be heard. Almost all sounds at 5 volume or below are inaudible
/// This is to prevent sound being spammed at really low volumes due to distance calculations
/// Recommend setting this to anywhere from 10-3 (or 0 to disable any sound minimum volume restrictions)
/// Ex. For a 70 volume sound, 17 tile range, 3 exponent, 2 falloff_distance:
/// Setting SOUND_AUDIBLE_VOLUME_MIN to 0 for the above will result in 17x17 radius (289 turfs)
/// Setting SOUND_AUDIBLE_VOLUME_MIN to 5 for the above will result in 14x14 radius (196 turfs)
/// Setting SOUND_AUDIBLE_VOLUME_MIN to 10 for the above will result in 11x11 radius (121 turfs)
#define SOUND_AUDIBLE_VOLUME_MIN 3

/* Calculates the max distance of a sound based on audible volume
 *
 * Note - you should NEVER pass in a volume that is lower than SOUND_AUDIBLE_VOLUME_MIN otherwise distance will be insanely large (like +250,000)
 *
 * Arguments:
 * * volume: The initial volume of the sound being played
 * * max_distance: The range of the sound in tiles (technically not real max distance since the furthest areas gets pruned due to SOUND_AUDIBLE_VOLUME_MIN)
 * * falloff_distance: Distance at which falloff begins. Sound is at peak volume (in regards to falloff) aslong as it is in this range.
 * * falloff_exponent: Rate of falloff for the audio. Higher means quicker drop to low volume. Should generally be over 1 to indicate a quick dive to 0 rather than a slow dive.
 * Returns: The max distance of a sound based on audible volume range
 */
#define CALCULATE_MAX_SOUND_AUDIBLE_DISTANCE(volume, max_distance, falloff_distance, falloff_exponent)\
	floor(((((-(max(max_distance - falloff_distance, 0) ** (1 / falloff_exponent)) / volume) * (SOUND_AUDIBLE_VOLUME_MIN - volume)) ** falloff_exponent) + falloff_distance))

/* Calculates the volume of a sound based on distance
 *
 * https://www.desmos.com/calculator/shjpmz3ck7
 *
 * Arguments:
 * * volume: The initial volume of the sound being played
 * * distance: How far away the sound is in tiles from the source
 * * falloff_distance: Distance at which falloff begins. Sound is at peak volume (in regards to falloff) aslong as it is in this range.
 * * falloff_exponent: Rate of falloff for the audio. Higher means quicker drop to low volume. Should generally be over 1 to indicate a quick dive to 0 rather than a slow dive.
 * Returns: The max distance of a sound based on audible volume range
 */
#define CALCULATE_SOUND_VOLUME(volume, distance, max_distance, falloff_distance, falloff_exponent)\
	((max(distance - falloff_distance, 0) ** (1 / falloff_exponent)) / ((max(max_distance, distance) - falloff_distance) ** (1 / falloff_exponent)) * volume)

///Default range of a sound.
#define SOUND_RANGE 17
#define MEDIUM_RANGE_SOUND_EXTRARANGE -5
///default extra range for sounds considered to be quieter
#define SHORT_RANGE_SOUND_EXTRARANGE -9
///The range deducted from sound range for things that are considered silent / sneaky
#define SILENCED_SOUND_EXTRARANGE -11
///Percentage of sound's range where no falloff is applied
#define SOUND_DEFAULT_FALLOFF_DISTANCE 1 //For a normal sound this would be 1 tile of no falloff
///The default exponent of sound falloff
#define SOUND_FALLOFF_EXPONENT 6

//THIS SHOULD ALWAYS BE THE LOWEST ONE!
//KEEP IT UPDATED

#define CHANNEL_HIGHEST_AVAILABLE 1014

#define MAX_INSTRUMENT_CHANNELS (128 * 6)

#define SOUND_MINIMUM_PRESSURE 10
#define FALLOFF_SOUNDS 1
#define INTERACTION_SOUND_RANGE_MODIFIER -3
#define EQUIP_SOUND_VOLUME 30
#define PICKUP_SOUND_VOLUME 40
#define DROP_SOUND_VOLUME 50
#define YEET_SOUND_VOLUME 90

#define AMBIENCE_GENERIC "generic"
#define AMBIENCE_HOLY "holy"
#define AMBIENCE_DANGER "danger"
#define AMBIENCE_RUINS "ruins"
#define AMBIENCE_ENGI "engi"
#define AMBIENCE_MINING "mining"
#define AMBIENCE_MEDICAL "med"
#define AMBIENCE_VIROLOGY "viro"
#define AMBIENCE_SPOOKY "spooky"
#define AMBIENCE_SPACE "space"
#define AMBIENCE_MAINT "maint"
#define AMBIENCE_AWAY "away"
#define AMBIENCE_REEBE "reebe"
#define AMBIENCE_CREEPY "creepy" //not to be confused with spooky
#define AMBIENCE_NONE "none"

//default byond sound environments
#define SOUND_ENVIRONMENT_NONE -1
#define SOUND_ENVIRONMENT_GENERIC 0
#define SOUND_ENVIRONMENT_PADDED_CELL 1
#define SOUND_ENVIRONMENT_ROOM 2
#define SOUND_ENVIRONMENT_BATHROOM 3
#define SOUND_ENVIRONMENT_LIVINGROOM 4
#define SOUND_ENVIRONMENT_STONEROOM 5
#define SOUND_ENVIRONMENT_AUDITORIUM 6
#define SOUND_ENVIRONMENT_CONCERT_HALL 7
#define SOUND_ENVIRONMENT_CAVE 8
#define SOUND_ENVIRONMENT_ARENA 9
#define SOUND_ENVIRONMENT_HANGAR 10
#define SOUND_ENVIRONMENT_CARPETED_HALLWAY 11
#define SOUND_ENVIRONMENT_HALLWAY 12
#define SOUND_ENVIRONMENT_STONE_CORRIDOR 13
#define SOUND_ENVIRONMENT_ALLEY 14
#define SOUND_ENVIRONMENT_FOREST 15
#define SOUND_ENVIRONMENT_CITY 16
#define SOUND_ENVIRONMENT_MOUNTAINS 17
#define SOUND_ENVIRONMENT_QUARRY 18
#define SOUND_ENVIRONMENT_PLAIN 19
#define SOUND_ENVIRONMENT_PARKING_LOT 20
#define SOUND_ENVIRONMENT_SEWER_PIPE 21
#define SOUND_ENVIRONMENT_UNDERWATER 22
#define SOUND_ENVIRONMENT_DRUGGED 23
#define SOUND_ENVIRONMENT_DIZZY 24
#define SOUND_ENVIRONMENT_PSYCHOTIC 25
//If we ever make custom ones add them here

//"sound areas": easy way of keeping different types of areas consistent.
#define SOUND_AREA_STANDARD_STATION SOUND_ENVIRONMENT_PARKING_LOT
#define SOUND_AREA_LARGE_ENCLOSED SOUND_ENVIRONMENT_QUARRY
#define SOUND_AREA_SMALL_ENCLOSED SOUND_ENVIRONMENT_BATHROOM
#define SOUND_AREA_TUNNEL_ENCLOSED SOUND_ENVIRONMENT_STONEROOM
#define SOUND_AREA_LARGE_SOFTFLOOR SOUND_ENVIRONMENT_CARPETED_HALLWAY
#define SOUND_AREA_MEDIUM_SOFTFLOOR SOUND_ENVIRONMENT_LIVINGROOM
#define SOUND_AREA_SMALL_SOFTFLOOR SOUND_ENVIRONMENT_ROOM
#define SOUND_AREA_ASTEROID SOUND_ENVIRONMENT_CAVE
#define SOUND_AREA_SPACE SOUND_ENVIRONMENT_UNDERWATER
#define SOUND_AREA_LAVALAND SOUND_ENVIRONMENT_MOUNTAINS
#define SOUND_AREA_WOODFLOOR SOUND_ENVIRONMENT_CITY

///Announcer audio keys
#define ANNOUNCER_AIMALF 			"announcer_aimalf"
#define ANNOUNCER_ALIENS			"announcer_aliens"
#define ANNOUNCER_ANIMES 			"announcer_animes"
#define ANNOUNCER_GRANOMALIES 		"announcer_granomalies"
#define ANNOUNCER_INTERCEPT 		"announcer_intercept"
#define ANNOUNCER_IONSTORM 			"announcer_ionstorm"
#define ANNOUNCER_METEORS			"announcer_meteors"
#define ANNOUNCER_OUTBREAK5			"announcer_outbreak5"
#define ANNOUNCER_OUTBREAK7			"announcer_outbreak7"
#define ANNOUNCER_POWEROFF			"announcer_poweroff"
#define ANNOUNCER_POWERON			"announcer_poweron"
#define ANNOUNCER_RADIATION			"announcer_radiation"
#define ANNOUNCER_SHUTTLECALLED		"announcer_shuttlecalled"
#define ANNOUNCER_SHUTTLEDOCK		"announcer_shuttledock"
#define ANNOUNCER_SHUTTLERECALLED	"announcer_shuttlerecalled"
#define ANNOUNCER_SPANOMALIES		"announcer_spanomalies"

#define SOUNDTRACK_PLAY_RESPECT 0
#define SOUNDTRACK_PLAY_ALL 1
#define SOUNDTRACK_PLAY_ONLYSTATION 2
