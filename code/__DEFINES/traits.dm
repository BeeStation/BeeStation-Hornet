#define SIGNAL_ADDTRAIT(trait_ref) "addtrait [trait_ref]"
#define SIGNAL_REMOVETRAIT(trait_ref) "removetrait [trait_ref]"

// trait accessor defines
#define ADD_TRAIT(target, trait, source) \
	do { \
		var/list/_L; \
		if (!target.status_traits) { \
			target.status_traits = list(); \
			_L = target.status_traits; \
			_L[trait] = list(source); \
			SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait), trait); \
		} else { \
			_L = target.status_traits; \
			if (_L[trait]) { \
				_L[trait] |= list(source); \
			} else { \
				_L[trait] = list(source); \
				SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait), trait); \
			} \
		} \
	} while (0)
#define REMOVE_TRAIT(target, trait, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L && _L[trait]) { \
			for (var/_T in _L[trait]) { \
				if ((!_S && (_T != ROUNDSTART_TRAIT)) || (_T in _S)) { \
					_L[trait] -= _T \
				} \
			};\
			if (!length(_L[trait])) { \
				_L -= trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(trait), trait); \
			}; \
			if (!length(_L)) { \
				target.status_traits = null \
			}; \
		} \
	} while (0)
#define REMOVE_TRAIT_NOT_FROM(target, trait, sources) \
	do { \
		var/list/_traits_list = target.status_traits; \
		var/list/_sources_list; \
		if (sources && !islist(sources)) { \
			_sources_list = list(sources); \
		} else { \
			_sources_list = sources\
		}; \
		if (_traits_list && _traits_list[trait]) { \
			for (var/_trait_source in _traits_list[trait]) { \
				if (!(_trait_source in _sources_list)) { \
					_traits_list[trait] -= _trait_source \
				} \
			};\
			if (!length(_traits_list[trait])) { \
				_traits_list -= trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(trait), trait); \
			}; \
			if (!length(_traits_list)) { \
				target.status_traits = null \
			}; \
		} \
	} while (0)
#define REMOVE_TRAITS_NOT_IN(target, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S = sources; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] &= _S;\
				if (!length(_L[_T])) { \
					_L -= _T; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_T), _T); \
					}; \
				};\
			if (!length(_L)) { \
				target.status_traits = null\
			};\
		}\
	} while (0)
#define REMOVE_TRAITS_IN(target, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S = sources; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] -= _S;\
				if (!length(_L[_T])) { \
					_L -= _T; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_T)); \
					}; \
				};\
			if (!length(_L)) { \
				target.status_traits = null\
			};\
		}\
	} while (0)

#define HAS_TRAIT(target, trait) (target.status_traits ? (target.status_traits[trait] ? TRUE : FALSE) : FALSE)
#define HAS_TRAIT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (source in target.status_traits[trait]) : FALSE) : FALSE)
#define HAS_TRAIT_FROM_ONLY(target, trait, source) (\
	target.status_traits ?\
		(target.status_traits[trait] ?\
			((source in target.status_traits[trait]) && (length(target.status_traits) == 1))\
			: FALSE)\
		: FALSE)
#define HAS_TRAIT_NOT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (length(target.status_traits[trait] - source) > 0) : FALSE) : FALSE)

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
/* All to replace update_mobility with traits
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
*/
#define TRAIT_INCAPACITATED "incapacitated"

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
#define TRAIT_ANTIMAGIC			"anti_magic"
#define TRAIT_HOLY				"holy"
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
#define TRAIT_UNSTABLE			"unstable"
#define TRAIT_XENO_IMMUNE		"xeno_immune" //prevents facehuggers implanting races that wouldn't be able to host an egg
#define TRAIT_NECROPOLIS_INFECTED "necropolis-infection"
#define TRAIT_BEEFRIEND 		"beefriend"
#define TRAIT_MEDICAL_HUD		"med_hud"
#define TRAIT_SECURITY_HUD		"sec_hud"
#define TRAIT_MEDIBOTCOMINGTHROUGH "medbot" //Is a medbot healing you
#define TRAIT_PASSTABLE			"passtable"
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

// You can stare into the abyss, but it does not stare back.
// You're immune to the hallucination effect of the supermatter, either
// through force of will, or equipment.
#define TRAIT_MADNESS_IMMUNE "supermatter_madness_immune"

//non-mob traits
#define TRAIT_PARALYSIS			"paralysis" //Used for limb-based paralysis, where replacing the limb will fix it

#define TRAIT_HEARING_SENSITIVE "hearing_sensitive"

// item traits
#define TRAIT_NODROP            "nodrop"
#define TRAIT_NO_STORAGE_INSERT	"no_storage_insert" //cannot be inserted in a storage.
#define TRAIT_SPRAYPAINTED		"spraypainted"
#define TRAIT_T_RAY_VISIBLE     "t-ray-visible" // Visible on t-ray scanners if the atom/var/level == 1
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
/// Buckling yourself to objects with this trait won't immobilize you
#define TRAIT_NO_IMMOBILIZE "no_immobilize"

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
/// Trait for customizable reagent holder
//#define TRAIT_CUSTOMIZABLE_REAGENT_HOLDER "customizable_reagent_holder"
/// Trait for allowing an item that isn't food into the customizable reagent holder
//#define TRAIT_ODD_CUSTOMIZABLE_FOOD_INGREDIENT "odd_customizable_food_ingredient"

///Trait applied to turfs when an atmos holosign is placed on them. It will stop firedoors from closing.
#define TRAIT_FIREDOOR_STOP "firedoor_stop"

/// this object has been frozen
#define TRAIT_FROZEN "frozen"

// common trait sources
#define TRAIT_GENERIC "generic"
#define GENERIC_ITEM_TRAIT "generic_item"
#define UNCONSCIOUS_TRAIT "unconscious"
#define EYE_DAMAGE "eye_damage"
#define GENETIC_MUTATION "genetic"
#define OBESITY "obesity"
#define MAGIC_TRAIT "magic"
#define TRAUMA_TRAIT "trauma"
#define DISEASE_TRAIT "disease"
#define SPECIES_TRAIT "species"
#define ORGAN_TRAIT "organ"
#define ROUNDSTART_TRAIT "roundstart" //cannot be removed without admin intervention
#define JOB_TRAIT "job"
#define CYBORG_ITEM_TRAIT "cyborg-item"
#define ADMIN_TRAIT "admin" // (B)admins only.
#define CHANGELING_TRAIT "changeling"
#define CULT_TRAIT "cult"
#define CURSED_ITEM_TRAIT "cursed-item" // The item is magically cursed
#define ABSTRACT_ITEM_TRAIT "abstract-item"
#define STATUS_EFFECT_TRAIT "status-effect"
#define CLOTHING_TRAIT "clothing"
#define CLOTHING_FEET_TRAIT "feet"
#define VEHICLE_TRAIT "vehicle" // inherited from riding vehicles
#define INNATE_TRAIT "innate"
#define CRIT_HEALTH_TRAIT "crit_health"
#define OXYLOSS_TRAIT "oxyloss"
//trait associated to being buckled
#define BUCKLED_TRAIT "buckled"
//trait associated to being held in a chokehold
#define CHOKEHOLD_TRAIT "chokehold"
//trait associated to resting
#define RESTING_TRAIT "resting"
#define GLASSES_TRAIT "glasses"
#define CURSE_TRAIT "eldritch"
#define STATION_TRAIT "station-trait"
#define TRAIT_RUSTY "rust_trait"

// unique trait sources, still defines
#define CLONING_POD_TRAIT "cloning-pod"
#define STATUE_MUTE "statue"
#define CHANGELING_DRAIN "drain"
#define MAGIC_BLIND "magic_blind"
#define HIGHLANDER "highlander"
#define TRAIT_HULK "hulk"
#define STASIS_MUTE "stasis"
#define GENETICS_SPELL "genetics_spell"
#define EYES_COVERED "eyes_covered"
#define CULT_EYES "cult_eyes"
#define TRAIT_SANTA "santa"
#define SCRYING_ORB "scrying-orb"
#define ABDUCTOR_ANTAGONIST "abductor-antagonist"
#define NUKEOP_TRAIT "nuke-op"
#define DEATHSQUAD_TRAIT "deathsquad"
#define MEGAFAUNA_TRAIT "megafauna"
#define CLOWN_NUKE_TRAIT "clown-nuke"
#define STICKY_MOUSTACHE_TRAIT "sticky-moustache"
#define CHAINSAW_FRENZY_TRAIT "chainsaw-frenzy"
#define CHRONO_GUN_TRAIT "chrono-gun"
#define REVERSE_BEAR_TRAP_TRAIT "reverse-bear-trap"
#define CURSED_MASK_TRAIT "cursed-mask"
#define HIS_GRACE_TRAIT "his-grace"
#define HAND_REPLACEMENT_TRAIT "magic-hand"
#define HOT_POTATO_TRAIT "hot-potato"
#define SABRE_SUICIDE_TRAIT "sabre-suicide"
#define ABDUCTOR_VEST_TRAIT "abductor-vest"
#define CAPTURE_THE_FLAG_TRAIT "capture-the-flag"
#define EYE_OF_GOD_TRAIT "eye-of-god"
#define SHAMEBRERO_TRAIT "shamebrero"
#define JAUNT_TRAIT "jaunt"
#define CHRONOSUIT_TRAIT "chronosuit"
#define LOCKED_HELMET_TRAIT "locked-helmet"
#define NINJA_SUIT_TRAIT "ninja-suit"
#define ANTI_DROP_IMPLANT_TRAIT "anti-drop-implant"
#define HIVEMIND_TRAIT "hivemind-trait"
#define VR_ZONE_TRAIT "vr_zone_trait"
#define GLUED_ITEM_TRAIT "glued-item"
#define LEGION_CORE_TRAIT "legion_core_trait"
#define MIRROR_TRAIT "mirror_trait"
#define CRAYON_TRAIT "crayon_trait"
#define HOLYWATER_TRAIT "holywater"
#define VANGUARD_TRAIT "vanguard"
#define STARGAZER_TRAIT "stargazer"
#define HOLOPARASITE_CLOAK_TRAIT	"holopara_cloak_trait"
#define HOLOPARASITE_SCOUT_TRAIT	"holopara_scout_trait"
#define HOLOPARASITE_STAT_TRAIT		"holopara_stat_trait"
#define PARRY_TRAIT	"parry_trait"
#define ELEMENT_TRAIT(source) "element_trait_[source]"
#define LIGHTPINK_TRAIT "lightpinktrait"
#define BATTLE_ROYALE_TRAIT "battleroyale_trait"
#define MADE_UNCLONEABLE "made-uncloneable"
#define TRAIT_JAWS_OF_LIFE "jaws-of-life"
#define STICKY_NODROP "sticky-nodrop" //sticky nodrop sounds like a good soundcloud rapper's name
//#define SKILLCHIP_TRAIT "skillchip"
#define PULLED_WHILE_SOFTCRIT_TRAIT "pulled-while-softcrit"
#define LOCKED_BORG_TRAIT "locked-borg"
#define TRAIT_PRESERVE_UI_WITHOUT_CLIENT "preserve_ui_without_client" //this mob should never close ui even if it doesn't have a client
#define EXPERIMENTAL_SURGERY_TRAIT "experimental_surgery"
#define NINJA_KIDNAPPED_TRAIT "ninja_kidnapped"

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
