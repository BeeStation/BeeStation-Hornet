// This file contains all of the "static" define strings that tie to a trait.
// WARNING: The sections here actually matter in this file as it's tested by CI. Please do not toy with the sections."


// BEGIN TRAIT DEFINES

/*
Remember to update _globalvars/traits.dm if you're adding/removing/renaming traits.
*/

// mob traits for temporary carbon states/status_effects. // TODO: Systematically dismember update_mobility and replace all its checks and updates with these traits, or offload to stat

/// Forces the user to stay unconscious. This shouldn't be used in a check outside of code related to stat and update_stat, or when its being intentionally applied from a specific source
#define TRAIT_KNOCKEDOUT "knockedout"
/// Prevents voluntary movement.
#define TRAIT_IMMOBILIZED "immobilized"
/// Prevents voluntary standing or staying up on its own.
#define TRAIT_FLOORED "floored"
/// Forces user to stay standing (ensures the unconscious/immobilized dont enter a lying position in cryopods)
#define TRAIT_FORCED_STANDING "forcedstanding"
/// Prevents usage of manipulation appendages (picking, holding or using items, manipulating storage).
#define TRAIT_HANDS_BLOCKED "handsblocked"
/// Inability to access UI hud elements. Turned into a trait from [MOBILITY_UI] to be able to track sources.
#define TRAIT_UI_BLOCKED "uiblocked"
/// Inability to pull things. Turned into a trait from [MOBILITY_PULL] to be able to track sources.
#define TRAIT_PULL_BLOCKED "pullblocked"
/// Abstract condition that prevents movement if being pulled and might be resisted against. Handcuffs and straight jackets, basically.
#define TRAIT_RESTRAINED "restrained"
#define TRAIT_INCAPACITATED "incapacitated"
//In some kind of critical condition. Is able to succumb.
#define TRAIT_CRITICAL_CONDITION "critical-condition"
// Grants them the ability to move even when without any limbs.
#define TRAIT_MOBILE "mobile"

//mob traits
#define TRAIT_BLIND "blind"
/// Mute. Can't talk.
#define TRAIT_MUTE "mute"
/// Emotemute. Can't... emote.
#define TRAIT_EMOTEMUTE "emotemute"
#define TRAIT_DEAF				"deaf"
#define TRAIT_NEARSIGHT			"nearsighted"
#define TRAIT_FAT				"fat"
#define TRAIT_HUSK				"husk"
#define TRAIT_BADDNA			"baddna"
#define TRAIT_CLUMSY			"clumsy"
#define TRAIT_DUMB				"dumb"
#define TRAIT_DISCOORDINATED	"discoordinated" //sets IsAdvancedToolUser to FALSE on humans and monkies
#define TRAIT_PACIFISM			"pacifism"
#define TRAIT_IGNORESLOWDOWN	"ignoreslow"
#define TRAIT_IGNOREDAMAGESLOWDOWN "ignoredamageslowdown"
#define TRAIT_DEATHCOMA			"deathcoma" //Causes death-like unconsciousness
#define TRAIT_REGEN_COMA		"regencoma"
#define TRAIT_FAKEDEATH			"fakedeath" //Makes the owner appear as dead to most forms of medical examination
#define TRAIT_DISFIGURED		"disfigured"
#define TRAIT_XENO_HOST			"xeno_host"	//Tracks whether we're gonna be a baby alien's mummy.
#define TRAIT_STUNIMMUNE		"stun_immunity"
#define TRAIT_STUNRESISTANCE    "stun_resistance"
#define TRAIT_CONFUSEIMMUNE		"confuse_immunity"
#define TRAIT_SLEEPIMMUNE		"sleep_immunity"
#define TRAIT_PUSHIMMUNE		"push_immunity"
#define TRAIT_SHOCKIMMUNE		"shock_immunity"
#define TRAIT_STABLEHEART		"stable_heart"
#define TRAIT_STABLELIVER		"stable_liver"
#define TRAIT_NOVOMIT			"no_vomit"
#define TRAIT_RESISTHEAT		"resist_heat"
#define TRAIT_RESISTHEATHANDS	"resist_heat_handsonly" //For when you want to be able to touch hot things, but still want fire to be an issue.
#define TRAIT_RESISTCOLD		"resist_cold"
#define TRAIT_RESISTHIGHPRESSURE	"resist_high_pressure"
#define TRAIT_RESISTLOWPRESSURE	"resist_low_pressure"
#define TRAIT_RADIMMUNE			"rad_immunity"
#define TRAIT_NORADDAMAGE		"no_rad_damage"
#define TRAIT_VIRUSIMMUNE		"virus_immunity"
#define TRAIT_PIERCEIMMUNE		"pierce_immunity"
#define TRAIT_NODISMEMBER		"dismember_immunity"
#define TRAIT_NOFIRE			"nonflammable"
#define TRAIT_NOGUNS			"no_guns"
#define TRAIT_NOHUNGER			"no_hunger"
#define TRAIT_NOMETABOLISM		"no_metabolism"
#define TRAIT_POWERHUNGRY		"power_hungry" //uses electricity instead of food
#define TRAIT_NOCLONELOSS		"no_cloneloss"
#define TRAIT_TOXIMMUNE			"toxin_immune"
#define TRAIT_EASYDISMEMBER		"easy_dismember"
#define TRAIT_LIMBATTACHMENT 	"limb_attach"
#define TRAIT_NOLIMBDISABLE		"no_limb_disable"
#define TRAIT_EASYLIMBDISABLE	"easy_limb_disable"
#define TRAIT_TOXINLOVER		"toxinlover"
#define TRAIT_NOHAIRLOSS		"no_hair_loss"
#define TRAIT_NOBREATH			"no_breath"
#define TRAIT_SEE_ANTIMAGIC		"see_anti_magic"
#define TRAIT_DEPRESSION		"depression"
#define TRAIT_JOLLY				"jolly"
#define TRAIT_NOCRITDAMAGE		"no_crit"
#define TRAIT_NOSLIPWATER		"noslip_water"
#define TRAIT_NOSLIPALL			"noslip_all"
#define TRAIT_NODEATH			"nodeath"
#define TRAIT_NOHARDCRIT		"nohardcrit"
#define TRAIT_NOSOFTCRIT		"nosoftcrit"
#define TRAIT_NOSTAMCRIT		"nostamcrit"
#define TRAIT_MINDSHIELD		"mindshield"
#define TRAIT_FAKE_MINDSHIELD	"fakemindshield"
#define TRAIT_DISSECTED			"dissected"
#define TRAIT_SIXTHSENSE		"sixth_sense" //I can hear dead people
#define TRAIT_FEARLESS			"fearless"
#define TRAIT_PARALYSIS_L_ARM	"para-l-arm" //These are used for brain-based paralysis, where replacing the limb won't fix it
#define TRAIT_PARALYSIS_R_ARM	"para-r-arm"
#define TRAIT_PARALYSIS_L_LEG	"para-l-leg"
#define TRAIT_PARALYSIS_R_LEG	"para-r-leg"
#define TRAIT_CANNOT_OPEN_PRESENTS "cannot-open-presents"
#define TRAIT_PRESENT_VISION    "present-vision"
#define TRAIT_DISK_VERIFIER     "disk-verifier"
#define TRAIT_MULTILINGUAL		"multilingual" //I know another language
#define TRAIT_LINGUIST			"linguist"
#define TRAIT_NOMOBSWAP         "no-mob-swap"
#define TRAIT_XRAY_VISION       "xray_vision"
#define TRAIT_THERMAL_VISION    "thermal_vision"
#define TRAIT_ABDUCTOR_TRAINING "abductor-training"
#define TRAIT_ABDUCTOR_SCIENTIST_TRAINING "abductor-scientist-training"
#define TRAIT_SURGEON           "surgeon" //Grants access to all surgeries
#define TRAIT_ABDUCTOR_SURGEON  "abductor-surgery-training" //Grants access to all surgeries except for certain blacklisted ones
#define	TRAIT_STRONG_GRABBER	"strong_grabber"
#define	TRAIT_CALCIUM_HEALER	"calcium_healer"
#define	TRAIT_MAGIC_CHOKE		"magic_choke"
#define TRAIT_SOOTHED_THROAT    "soothed-throat"
#define TRAIT_LAW_ENFORCEMENT_METABOLISM "law-enforcement-metabolism"
#define TRAIT_MEDICAL_METABOLISM "medical-metabolism"
#define TRAIT_ALWAYS_CLEAN      "always-clean"
#define TRAIT_BOOZE_SLIDER      "booze-slider"
#define TRAIT_QUICK_CARRY		"quick-carry"
#define TRAIT_QUICKER_CARRY		"quicker-carry"
#define TRAIT_UNINTELLIGIBLE_SPEECH "unintelligible-speech"
#define TRAIT_UNSTABLE "unstable"
#define TRAIT_OIL_FRIED "oil_fried"
#define TRAIT_XENO_IMMUNE "xeno_immune" //prevents facehuggers implanting races that wouldn't be able to host an egg
#define TRAIT_NECROPOLIS_INFECTED "necropolis-infection"
#define TRAIT_BEEFRIEND 		"beefriend"
#define TRAIT_PLANTHEALING		"planthealing"
#define TRAIT_MEDICAL_HUD		"med_hud"
#define TRAIT_SECURITY_HUD		"sec_hud"
#define TRAIT_DIAGNOSTIC_HUD "diag_hud"
#define TRAIT_MEDIBOTCOMINGTHROUGH "medbot" //Is a medbot healing you
#define TRAIT_PASSTABLE			"passtable"
#define TRAIT_BLUSHING 			"blushing"
#define TRAIT_CRYING			"crying"
#define TRAIT_NOBLOCK			"noblock"
#define TRAIT_NANITECOMPATIBLE	"nanitecompatible"
#define TRAIT_WARDED       		"curse_immune"
#define TRAIT_NONECRODISEASE	"nonecrodisease"
#define TRAIT_NICE_SHOT			"nice_shot" //hnnnnnnnggggg..... you're pretty good....
#define TRAIT_ALWAYS_STUBS      "always_stubs_toe" //you will always stub your toe on tables, even if you're wearing shoes
#define TRAIT_NAIVE				"naive" //All dead people will appear as sleeping.
#define TRAIT_DROPS_ITEMS_ON_DEATH "drops_items_on_death" //used for battle royale
#define TRAIT_DRINKSBLOOD		"drinks_blood"
#define TRAIT_MINDSWAPPED		"mindswapped"
#define TRAIT_SOMMELIER			"sommelier"  // shows different booze power flavor texts
#define TRAIT_BARMASTER			"bar_master" // always can identify reagents
#define TRAIT_HIVE_BURNT		 "hive-burnt"
#define TRAIT_MOTH_BURNT		"moth_burnt"
#define TRAIT_SPECIAL_TRAUMA_BOOST "special_trauma_boost" ///Increases chance of getting special traumas, makes them harder to cure
#define TRAIT_METALANGUAGE_KEY_ALLOWED "metalanguage_key_allowed" // you can use language key for metalanguage (,`) and but also you see lang icon
#define TRAIT_HYPERSPACED "hyperspaced" // Sanity trait to keep track of when we're in hyperspace and add the appropriate element if we werent
#define TRAIT_FREE_HYPERSPACE_MOVEMENT "free_hyperspace_movement" // Gives the movable free hyperspace movement without being pulled during shuttle transit
#define TRAIT_FAST_CUFF_REMOVAL "fast_cuff_removal" // Faster cuff removal
#define TRAIT_BLEED_HELD		"bleed_held" // For when a mob is holding their wounds, preventing them from bleeding further
#define TRAIT_NO_BLOOD			"no_blood" // Bleeding heals itself and bleeding is impossible
#define TRAIT_NO_BLEEDING		"no_bleed" // The user can acquire the bleeding status effect, but will no lose blood
#define TRAIT_BLOOD_COOLANT		"blood_coolant" // Replaces blood with coolant, meaning we overheat instead of losing air

// You can stare into the abyss, but it does not stare back.
// You're immune to the hallucination effect of the supermatter, either
// through force of will, or equipment.
#define TRAIT_MADNESS_IMMUNE "supermatter_madness_immune"

//non-mob traits
/// Used for limb-based paralysis, where replacing the limb will fix it.
#define TRAIT_PARALYSIS "paralysis"
/// Used for limbs.
#define TRAIT_DISABLED_BY_WOUND "disabled-by-wound"

/// Can use the nuclear device's UI, regardless of a lack of hands
#define TRAIT_CAN_USE_NUKE "can_use_nuke"

///Mob is being tracked on glob suit sensors list
#define TRACKED_SENSORS_TRAIT "tracked_sensors"
///Mob is tracked by suit sensors, and on glob suit sensors list
#define TRAIT_SUIT_SENSORS "suit_sensors"
///Mob is tracked by nanites, and on glob suit sensors list
#define TRAIT_NANITE_SENSORS "nanite_sensors"

/// Trait for psyphoza, flag for examine logic
#define TRAIT_PSYCHIC_SENSE "psychic_sense"

/**
 * Atom Traits
 */
///Used for managing KEEP_TOGETHER in [appearance_flags]
#define TRAIT_KEEP_TOGETHER "keep-together"
/// Buckling yourself to objects with this trait won't immobilize you
#define TRAIT_NO_IMMOBILIZE "no_immobilize"

//important_recursive_contents traits
/*
 * Used for movables that need to be updated, via COMSIG_ENTER_AREA and COMSIG_EXIT_AREA, when transitioning areas.
 * Use [/atom/movable/proc/become_area_sensitive(trait_source)] to properly enable it. How you remove it isn't as important.
 */
#define TRAIT_AREA_SENSITIVE "area-sensitive"
///every hearing sensitive atom has this trait
#define TRAIT_HEARING_SENSITIVE "hearing_sensitive"

/**
 * Item Traits
 */
#define TRAIT_NODROP            "nodrop"
#define TRAIT_NO_STORAGE_INSERT	"no_storage_insert" //cannot be inserted in a storage.
#define TRAIT_SPRAYPAINTED		"spraypainted"
#define TRAIT_T_RAY_VISIBLE     "t-ray-visible" // Visible on t-ray scanners if the atom/var/level == 1
/// If this item's been fried
#define TRAIT_FOOD_FRIED "food_fried"
#define TRAIT_NO_TELEPORT		"no-teleport" //you just can't
#define TRAIT_STARGAZED			"stargazed"	//Affected by a stargazer
#define TRAIT_DOOR_PRYER		"door-pryer"	//Item can be used on airlocks to pry them open (even when powered)
#define TRAIT_FISH_SAFE_STORAGE "fish_case" //Fish in this won't die
#define TRAIT_FISH_CASE_COMPATIBILE "fish_case_compatibile" //Stuff that can go inside fish cases
#define TRAIT_NEEDS_TWO_HANDS "needstwohands" // The items needs two hands to be carried

#define TRAIT_AI_BAGATTACK "bagattack" // This atom can ignore the "is on a turf" check for simple AI datum attacks, allowing them to attack from bags or lockers as long as any other conditions are met

/// Allows heretics to cast their spells.
#define TRAIT_ALLOW_HERETIC_CASTING "allow_heretic_casting"
/// Designates a heart as a living heart for a heretic.
#define TRAIT_LIVING_HEART "living_heart"
/// Prevents stripping this equipment
#define TRAIT_NO_STRIP "no_strip"

//quirk traits
#define TRAIT_ALCOHOL_TOLERANCE	"alcohol_tolerance"
#define TRAIT_AGEUSIA			"ageusia"
#define TRAIT_HEAVY_SLEEPER		"heavy_sleeper"
#define TRAIT_NIGHT_VISION		"night_vision"
#define TRAIT_LIGHT_STEP		"light_step"
#define TRAIT_SPIRITUAL			"spiritual"
#define TRAIT_VORACIOUS			"voracious"
#define TRAIT_SELF_AWARE		"self_aware"
#define TRAIT_FREERUNNING		"freerunning"
#define TRAIT_SKITTISH			"skittish"
#define TRAIT_POOR_AIM			"poor_aim"
#define TRAIT_PROSOPAGNOSIA		"prosopagnosia"
#define	TRAIT_NEET				"NEET"
#define TRAIT_DRUNK_HEALING		"drunk_healing"
#define TRAIT_TAGGER			"tagger"
#define TRAIT_PHOTOGRAPHER		"photographer"
#define TRAIT_MUSICIAN			"musician"
#define TRAIT_LIGHT_DRINKER		"light_drinker"
#define TRAIT_EMPATH			"empath"
#define TRAIT_FRIENDLY			"friendly"
#define TRAIT_GRABWEAKNESS		"grab_weakness"
#define TRAIT_BRAIN_TUMOR		"brain_tumor"
#define TRAIT_PROSKATER			"pro_skater"
#define TRAIT_PLUSHIELOVER		"plushie lover"

///Trait for dryable items
#define TRAIT_DRYABLE "trait_dryable"
///Trait for dried items
#define TRAIT_DRIED "trait_dried"
// Trait for customizable reagent holder
#define TRAIT_CUSTOMIZABLE_REAGENT_HOLDER "customizable_reagent_holder"
// Trait for allowing an item that isn't food into the customizable reagent holder
#define TRAIT_ODD_CUSTOMIZABLE_FOOD_INGREDIENT "odd_customizable_food_ingredient"

///Trait applied to turfs when an atmos holosign is placed on them. It will stop firedoors from closing.
#define TRAIT_FIREDOOR_STOP "firedoor_stop"

/// this object has been frozen
#define TRAIT_FROZEN "frozen"
///Turf trait for when a turf is transparent
#define TURF_Z_TRANSPARENT_TRAIT "turf_z_transparent"

///Traits given by station traits
#define STATION_TRAIT_BANANIUM_SHIPMENTS "station_trait_bananium_shipments"
#define STATION_TRAIT_CARP_INFESTATION "station_trait_carp_infestation"
#define STATION_TRAIT_PREMIUM_INTERNALS "station_trait_premium_internals"
#define STATION_TRAIT_LATE_ARRIVALS "station_trait_late_arrivals"
#define STATION_TRAIT_RANDOM_ARRIVALS "station_trait_random_arrivals"
#define STATION_TRAIT_HANGOVER "station_trait_hangover"
#define STATION_TRAIT_FILLED_MAINT "station_trait_filled_maint"
#define STATION_TRAIT_EMPTY_MAINT "station_trait_empty_maint"
#define STATION_TRAIT_PDA_GLITCHED "station_trait_pda_glitched"
#define STATION_TRAIT_DISTANT_SUPPLY_LINES "distant_supply_lines"
#define STATION_TRAIT_STRONG_SUPPLY_LINES "strong_supply_lines"
#define STATION_TRAIT_UNITED_BUDGET "united_budget"

/// Trait applied when the MMI component is added to an [/obj/item/integrated_circuit]
#define TRAIT_COMPONENT_MMI "component_mmi"

///Movement type traits for movables. See elements/movetype_handler.dm
#define TRAIT_MOVE_GROUND		"move_ground"
#define TRAIT_MOVE_FLYING		"move_flying"
#define TRAIT_MOVE_VENTCRAWLING	"move_ventcrawling"
#define TRAIT_MOVE_FLOATING		"move_floating"
#define TRAIT_MOVE_PHASING		"move_phasing"
/// Disables the floating animation. See above.
#define TRAIT_NO_FLOATING_ANIM		"no-floating-animation"

// END TRAIT DEFINES
