#define ASSERT_ABILITY_USABILITY		if(!owner.can_use_abilities) { to_chat(owner, span_warningbold("You can't do that right now!")); return FALSE; }
#define ASSERT_ABILITY_USABILITY_SILENT	if(!owner.can_use_abilities) { return FALSE; }

/// The multiplier to apply to the 'star factor' of scout holoparasite's sensory link if the summoner is "psychically attuned", like if they're a stargazer or something.
#define HOLOPARA_SCOUT_SPY_ATTUNED_MULTIPLIER	0.7
/// The maximum amount of surveillance snares a single holoparasite can have at a time.
#define HOLOPARA_MAX_SNARES						5
/// How close someone must be when examining a dextrous holoparasite to see what it has in its internal storage.
#define HOLOPARA_DEXTROUS_EXAMINE_DISTANCE		2
/// The maximum amount of characters a holoparasite's battlecry can be.
#define HOLOPARA_MAX_BATTLECRY_LENGTH			7

/// The base cooldown for holoparasite teleportation pad warps.
#define HOLOPARA_TELEPORT_BASE_COOLDOWN					1 MINUTES
/// The multiplier to apply to the teleportation cooldown whenever warping a non-living object to the beacon.
#define HOLOPARA_TELEPORT_NONLIVING_COOLDOWN_MULTIPLIER	0.45
/// The cooldown between deploying bluespace beacons.
#define HOLOPARA_TELEPORT_DEPLOY_COOLDOWN				5 MINUTES
/// How long a bluespace tear will remain after a holoparasite warps something.
#define HOLOPARA_TELEPORT_BLUESPACE_TEAR_TIME			2.5 MINUTES
/// How long to wait between telepathy target scans.
#define	HOLOPARA_TELEPATHY_SCAN_COOLDOWN				5 SECONDS
/// How long after a telepathic holoparasite communicates with a target they can respond for, if they can respond at all.
#define HOLOPARA_TELEPATHY_RESPONSE_TIME				3 MINUTES
/// How long the holoparasite must wait after uncloaking before it can cloak again.
#define HOLOPARA_SCOUT_CLOAK_COOLDOWN					20 SECONDS
/// The base length of the bomb arming cooldown - this will be divided by the range to get the actual cooldown.
#define HOLOPARA_BASE_ARM_COOLDOWN						2 MINUTES
/// The base length of the bomb detonation cooldown - this will be divided by the potential to get the actual cooldown.
#define HOLOPARA_BASE_DETONATE_COOLDOWN					3.5 MINUTES

/// How long the holoparasite must wait after manifesting/recalling before it can do so again.
#define HOLOPARASITE_MANIFEST_COOLDOWN					1.5 SECONDS
/// The cooldown time for manually resetting a holoparasite (when the conditions of the holoparasite's player being unavailable are NOT met)
#define HOLOPARA_MANUAL_RESET_COOLDOWN	5 MINUTES
/// How long a holoparasite's player must be AFK for before resets become free.
#define HOLOPARA_AFK_RESET_TIME			5 MINUTES

/// How far away someone can notice a holoparasite's summoner being damaged by recoil from.
#define HOLOPARA_SUMMONER_DAMAGE_VISION_RANGE	4

/// The maximum amount of brain damage that can occur from 'extra' recoil damage.
#define HOLOPARA_MAX_BRAIN_DAMAGE		(BRAIN_DAMAGE_SEVERE - 15)
/// The maximum blood volume that a healing holoparasite can heal up to.
#define HOLOPARA_MAX_BLOOD_VOLUME_HEAL	(BLOOD_VOLUME_SAFE + 15)

/// The cooldown between visible 'recoil' effects from holoparasite damage.
#define HOLOPARA_VISIBLE_RECOIL_COOLDOWN			1.5 SECONDS
/// Calculates how far the summoner blood will cough blood during recoil, based on how much damage they took
#define HOLOPARA_CALC_BLOOD_RECOIL_DISTANCE(damage) (damage >= (summoner.current.maxHealth * 0.2) ? clamp(round(amount / (summoner.current.maxHealth * 0.3), 1), 1, 3) : 1)
/// The chance of the mob screaming in pain from recoil damage.
#define HOLOPARA_RECOIL_SCREAM_PROB					10
/// How long a delayed holoparasite death takes.
#define HOLOPARA_DELAYED_DEATH_TIME					15 SECONDS

/// List key for the holoparasite theme message that displays when the builder is activated.
#define HOLOPARA_MESSAGE_USE			"use"
/// List key for the holoparasite theme message that displays when the builder has been used up.
#define HOLOPARA_MESSAGE_USED			"used"
/// List key for the holoparasite theme message that displays when the builder fails to select a candidate.
#define HOLOPARA_MESSAGE_FAILED			"failed"
/// List key for the holoparasite theme message that displays when the builder successuflly selects a candidate.
#define HOLOPARA_MESSAGE_SUCCESS		"success"
/// List key for the holoparasite theme message that displays when the builder refuses to activate for a changeling.
#define HOLOPARA_MESSAGE_LING_FAILED	"changeling failed"

/// List key for the icon state for a holoparasite theme.
#define HOLOPARA_THEME_ICON_STATE		"icon"
/// List key for the accent overlay for a holoparasite theme.
#define HOLOPARA_THEME_OVERLAY			"overlay"
/// List key for the bubble icon for a holoparasite theme.
#define HOLOPARA_THEME_BUBBLE_ICON		"bubble icon"
/// List key for the examine description for a holoparasite theme.
#define HOLOPARA_THEME_DESC				"description"
/// List key for the speak emote for a holoparasite theme.
#define HOLOPARA_THEME_SPEAK_EMOTE		"speak emote"
/// List key for the attack sound for a holoparasite theme.
#define HOLOPARA_THEME_ATTACK_SOUND		"attack sound"
/// List key for sprite recoloring for a holoparasite theme.
#define HOLOPARA_THEME_RECOLOR_SPRITE	"recolor entire sprite"
/// List key for whether the holoparasite uses an emissive overlay.
#define HOLOPARA_THEME_EMISSIVE			"emissive"

/// The total number of holoparasite-specific layers
#define HOLOPARA_TOTAL_LAYERS				1
/// The layer for the holoparasite's hands.
#define HOLOPARA_HANDS_LAYER				1
/// The maximum lightness (HSL) value for a holopara's accent color
#define HOLOPARA_MAX_ACCENT_LIGHTNESS		50

/// The extra range applied to the holoparasite manifestation sound effect
#define HOLOPARA_MANIFEST_SOUND_EXTRARANGE	SHORT_RANGE_SOUND_EXTRARANGE
/// The extra range applied to the holoparasite recall sound effect
#define HOLOPARA_RECALL_SOUND_EXTRARANGE	-5
