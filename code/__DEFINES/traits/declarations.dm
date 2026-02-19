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
// Only permits the ability to whisper
#define TRAIT_WHISPER_ONLY "whisper_only"

//mob traits
///Potential unlocked with wizard staff (they have every mutation activated)
#define TRAIT_POTENTIAL_UNLOCKED "potential_unlocked"
#define TRAIT_BLIND "blind"
/// Mute. Can't talk.
#define TRAIT_MUTE "mute"
/// Emotemute. Can't... emote.
#define TRAIT_EMOTEMUTE "emotemute"
#define TRAIT_DEAF "deaf"
#define TRAIT_NEARSIGHT "nearsighted"
#define TRAIT_FAT "fat"
#define TRAIT_HUSK "husk"
#define TRAIT_BADDNA "baddna"
#define TRAIT_CLUMSY "clumsy"
//means that you can't use weapons with normal trigger guards.
#define TRAIT_CHUNKYFINGERS "chunkyfingers"
#define TRAIT_FINGERPRINT_PASSTHROUGH "fingerprint_passthrough"
#define TRAIT_DUMB "dumb"
/// Whether a mob is dexterous enough to use machines and certain items or not.
#define TRAIT_ADVANCEDTOOLUSER "advancedtooluser"
// Antagonizes the above.
#define TRAIT_DISCOORDINATED_TOOL_USER "discoordinated_tool_user"
#define TRAIT_PACIFISM "pacifism"
#define TRAIT_IGNORESLOWDOWN "ignoreslow"
#define TRAIT_IGNOREDAMAGESLOWDOWN "ignoredamageslowdown"
/// Causes death-like unconsciousness
#define TRAIT_DEATHCOMA "deathcoma"
#define TRAIT_FAKEDEATH "fakedeath" //Makes the owner appear as dead to most forms of medical examination
#define TRAIT_DISFIGURED		"disfigured"
#define TRAIT_XENO_HOST			"xeno_host"	//Tracks whether we're gonna be a baby alien's mummy.
#define TRAIT_STUNIMMUNE		"stun_immunity"
#define TRAIT_STUNRESISTANCE    "stun_resistance"
#define TRAIT_SLEEPIMMUNE		"sleep_immunity"
#define TRAIT_PUSHIMMUNE		"push_immunity"
#define TRAIT_SHOCKIMMUNE		"shock_immunity"
#define TRAIT_HOLY				"holy"
#define TRAIT_ANTIMAGIC			"antimagic" //Unharmable
/// This mob recently blocked magic with some form of antimagic
#define TRAIT_RECENTLY_BLOCKED_MAGIC "recently_blocked_magic"
/// This allows a person who has antimagic to cast spells without getting blocked
#define TRAIT_ANTIMAGIC_NO_SELFBLOCK "anti_magic_no_selfblock"
#define TRAIT_STABLEHEART		"stable_heart"
#define TRAIT_STABLELIVER		"stable_liver"
#define TRAIT_NOVOMIT			"no_vomit"
#define TRAIT_RESISTHEAT		"resist_heat"
#define TRAIT_RESISTHEATHANDS	"resist_heat_handsonly" //For when you want to be able to touch hot things, but still want fire to be an issue.
#define TRAIT_RESISTCOLD		"resist_cold"
#define TRAIT_RESISTHIGHPRESSURE	"resist_high_pressure"
#define TRAIT_RESISTLOWPRESSURE	"resist_low_pressure"
#define TRAIT_LOWPRESSURELEAKING "low_pressure_leaking" //Don't take conventional damage at low pressure, instead you start to leak fluids
#define TRAIT_BOMBIMMUNE "bomb_immunity"
#define TRAIT_RADIMMUNE "rad_immunity"
#define TRAIT_GENELESS "geneless"
#define TRAIT_RADHEALER "rad_healer"
#define TRAIT_VIRUSIMMUNE		"virus_immunity"
#define TRAIT_PIERCEIMMUNE		"pierce_immunity"
#define TRAIT_NODISMEMBER "dismember_immunity"
#define TRAIT_NOFIRE "nonflammable"
#define TRAIT_NOFIRE_SPREAD "no_fire_spreading"
/// Mobs that have this trait cannot be extinguished
#define TRAIT_NO_EXTINGUISH "no_extinguish"
/// Are we expected to fight antags?
#define TRAIT_SECURITY "security_member"
/// Prevents plasmamen from self-igniting
#define TRAIT_NOSELFIGNITION "no_selfignition"
#define TRAIT_NOGUNS			"no_guns"
///This carbon doesn't get hungry
#define TRAIT_NOHUNGER "no_hunger"
///This carbon doesn't bleed
#define TRAIT_NOBLOOD "noblood"
/// Carbons with this trait can't have their DNA copied by diseases nor changelings
#define TRAIT_NO_DNA_COPY "no_dna_copy"
// This race can't become a vampire, changeling antagonist or be copied by a changeling.
#define TRAIT_NOT_TRANSMORPHIC "not_transmorphic"
#define TRAIT_NOMETABOLISM		"no_metabolism"
#define TRAIT_POWERHUNGRY		"power_hungry" //uses electricity instead of food
#define TRAIT_NOCLONELOSS		"no_cloneloss"
#define TRAIT_TOXIMMUNE			"toxin_immune"
#define TRAIT_EASYDISMEMBER		"easy_dismember"
#define TRAIT_LIMBATTACHMENT 	"limb_attach"
#define TRAIT_NOLIMBDISABLE		"no_limb_disable"
#define TRAIT_EASYLIMBDISABLE	"easy_limb_disable"
/// Mob recovers from addictions at an accelerated rate
#define TRAIT_ADDICTIONRESILIENT "addiction_resilient"
#define TRAIT_TOXINLOVER		"toxinlover"
#define TRAIT_NOHAIRLOSS		"no_hair_loss"
/// reduces the use time of syringes, pills, patches and medigels but only when using on someone
#define TRAIT_FASTMED "fast_med_use"
#define TRAIT_NOBREATH			"no_breath"
#define TRAIT_SEE_ANTIMAGIC		"see_anti_magic"
#define TRAIT_NOCRITDAMAGE		"no_crit"
#define TRAIT_NOSLIPWATER		"noslip_water"
/// Stops all slipping and sliding from ocurring
#define TRAIT_NOSLIPALL "noslip_all"
//Inherent trait preventing effects of stasis on a mob
#define TRAIT_NOSTASIS "no_stasis"
#define TRAIT_MARTIAL_ARTS_IMMUNE "martial_arts_immune" // nobody can use martial arts on this mob
/// this mob takes reduced damage from falling
#define TRAIT_LIGHT_LANDING "lightlanding"
/// Items with this trait will not have their worn icon overlayed.
#define TRAIT_NO_WORN_ICON "no_worn_icon"
/// Items with this trait will not appear when examined.
#define TRAIT_EXAMINE_SKIP "examine_skip"
/// Gives you the Shifty Eyes quirk, rarely making people who examine you think you examined them back even when you didn't
#define TRAIT_SHIFTY_EYES "shifty_eyes"

/// Unlinks gliding from movement speed, meaning that there will be a delay between movements rather than a single move movement between tiles
#define TRAIT_NO_GLIDE "no_glide"

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
#define TRAIT_NOMOBSWAP "no-mob-swap"
/// Gives us turf, mob and object vision through walls
#define TRAIT_XRAY_VISION "xray_vision"
/// Gives us mob vision through walls and slight night vision
#define TRAIT_THERMAL_VISION "thermal_vision"
/// Gives us turf vision through walls and slight night vision
#define TRAIT_MESON_VISION "meson_vision"
/// Gives us Night vision
#define TRAIT_TRUE_NIGHT_VISION "true_night_vision"
/// Lets us scan reagents
#define TRAIT_REAGENT_SCANNER "reagent_scanner"
#define TRAIT_ABDUCTOR_TRAINING "abductor-training"
#define TRAIT_ABDUCTOR_SCIENTIST_TRAINING "abductor-scientist-training"
#define TRAIT_SURGEON           "surgeon" //Grants access to all surgeries
#define TRAIT_ABDUCTOR_SURGEON  "abductor-surgery-training" //Grants access to all surgeries except for certain blacklisted ones
#define	TRAIT_STRONG_GRABBER	"strong_grabber"
#define	TRAIT_MAGIC_CHOKE		"magic_choke"
#define TRAIT_SOOTHED_THROAT    "soothed-throat"
#define TRAIT_LAW_ENFORCEMENT_METABOLISM "law-enforcement-metabolism"
#define TRAIT_MEDICAL_METABOLISM "medical-metabolism"
#define TRAIT_BOOZE_SLIDER      "booze-slider"
/// We place people into a fireman carry quicker than standard
#define TRAIT_QUICK_CARRY "quick-carry"
/// We place people into a fireman carry especially quickly compared to quick_carry
#define TRAIT_QUICKER_CARRY "quicker-carry"
#define TRAIT_QUICK_BUILD "quick-build"
#define TRAIT_UNINTELLIGIBLE_SPEECH "unintelligible-speech"
#define TRAIT_UNSTABLE "unstable"
#define TRAIT_OIL_FRIED "oil_fried"
#define TRAIT_XENO_IMMUNE "xeno_immune" //prevents facehuggers implanting races that wouldn't be able to host an egg
#define TRAIT_NECROPOLIS_INFECTED "necropolis-infection"
#define TRAIT_BEEFRIEND 		"beefriend"
#define TRAIT_MEDICAL_HUD "med_hud"
#define TRAIT_SECURITY_HUD "sec_hud"
/// for something granting you a diagnostic hud
#define TRAIT_DIAGNOSTIC_HUD "diag_hud"
#define TRAIT_PASSTABLE			"passtable"
#define TRAIT_BLUSHING 			"blushing"
#define TRAIT_CRYING			"crying"
#define TRAIT_NOBLOCK			"noblock"
#define TRAIT_NANITECOMPATIBLE	"nanitecompatible"
#define TRAIT_NICE_SHOT "nice_shot" //hnnnnnnnggggg..... you're pretty good....
/// Prevents hallucinations from the hallucination brain trauma (RDS)
#define TRAIT_HALLUCINATION_SUPPRESSED "hallucination_suppressed"
#define TRAIT_ALWAYS_STUBS "always_stubs_toe" //you will always stub your toe on tables, even if you're wearing shoes
#define TRAIT_NAIVE "naive" //All dead people will appear as sleeping.
#define TRAIT_PRIMITIVE "primitive"
#define TRAIT_SPACEWALK "spacewalk"
#define TRAIT_DROPS_ITEMS_ON_DEATH "drops_items_on_death" //used for battle royale
#define TRAIT_DRINKSBLOOD "drinks_blood"
#define TRAIT_SOMMELIER			"sommelier"  // shows different booze power flavor texts
#define TRAIT_BARMASTER			"bar_master" // always can identify reagents
#define TRAIT_MOTH_BURNT		"moth_burnt"
/// From anti-convulsant medication against seizures.
#define TRAIT_ANTICONVULSANT "anticonvulsant"
#define TRAIT_BLOODSHOT_EYES "bloodshot_eyes"
/// Addictions don't tick down, basically they're permanently addicted
#define TRAIT_HOPELESSLY_ADDICTED "hopelessly_addicted"
#define TRAIT_SPECIAL_TRAUMA_BOOST "special_trauma_boost" ///Increases chance of getting special traumas, makes them harder to cure
#define TRAIT_METALANGUAGE_KEY_ALLOWED "metalanguage_key_allowed" // you can use language key for metalanguage (,`) and but also you see lang icon
#define TRAIT_HYPERSPACED "hyperspaced" // Sanity trait to keep track of when we're in hyperspace and add the appropriate element if we werent
#define TRAIT_FREE_HYPERSPACE_MOVEMENT "free_hyperspace_movement" // Gives the movable free hyperspace movement without being pulled during shuttle transit
#define TRAIT_FAST_CUFF_REMOVAL "fast_cuff_removal" // Faster cuff removal
#define TRAIT_BLEED_HELD		"bleed_held" // For when a mob is holding their wounds, preventing them from bleeding further
#define TRAIT_NO_BLOOD			"no_blood" // Bleeding heals itself and bleeding is impossible
#define TRAIT_NO_BLEEDING		"no_bleed" // The user can acquire the bleeding status effect, but will no lose blood
#define TRAIT_BLOOD_COOLANT		"blood_coolant" // Replaces blood with coolant, meaning we overheat instead of losing air
#define TRAIT_NO_BUMP_SLAM		"no_bump_slam"	// Disables the ability to slam into walls
/// Trait given by being a hulk
#define TRAIT_HULK "hulk"
/// Trait that stores the skin colour of a mob
#define TRAIT_OVERRIDE_SKIN_COLOUR "skin_colour"
#define TRAIT_STEALTH_PICKPOCKET "stealth_pickpocket" // The user can take something off of someone via the strip menu without sending a message.
/// Trait that prevents you from being moved when pulled.
#define TRAIT_NO_MOVE_PULL "no_move_pull"
#define TRAIT_SILENT_FOOTSTEPS "silent_footsteps" //makes your footsteps completely silent
/// If applied to a mob, nearby dogs will have a small chance to nonharmfully harass said mob
#define TRAIT_HATED_BY_DOGS "hated_by_dogs"
#define TRAIT_BALLMER_SCIENTIST "ballmer_scientist"

/// This mob has no soul
#define TRAIT_NO_SOUL "no_soul"
/// Whether we're sneaking, from the alien sneak ability.
/// Maybe worth generalizing into a general "is sneaky" / "is stealth" trait in the future.
#define TRAIT_ALIEN_SNEAK "sneaking_alien"
/// The mob has an active mime vow of silence, and thus is unable to speak and has other mime things going on
#define TRAIT_MIMING "miming"
/// This mob is phased out of reality from magic, either a jaunt or rod form
#define TRAIT_MAGICALLY_PHASED "magically_phased"
#define TRAIT_GIANT				"giant"
#define TRAIT_DWARF				"dwarf"
#define TRAIT_OFF_BALANCE_TACKLER "off_balance_tackler" // Applies tackling defense bonus to any mob that has it
#define TRAIT_NO_STAGGER "no_stagger" // Prevents staggering.
/// Allows the species to equip items that normally require a jumpsuit without having one equipped. Used by golems.
#define TRAIT_NO_JUMPSUIT "no_jumpsuit"

/// Apply this to make a mob not dense, and remove it when you want it to no longer make them undense, other sorces of undesity will still apply. Always define a unique source when adding a new instance of this!
#define TRAIT_UNDENSE "undense"
/// Makes the mob immune to damage and several other ailments.
#define TRAIT_GODMODE "godmode"

// You can stare into the abyss, but it does not stare back.
// You're immune to the hallucination effect of the supermatter, either
// through force of will, or equipment.
#define TRAIT_MADNESS_IMMUNE "supermatter_madness_immune"
// You can stare into the abyss, and it turns pink.
// Being close enough to the supermatter makes it heal at higher temperatures and emit less heat.
#define TRAIT_SUPERMATTER_SOOTHER "supermatter_soother"

//non-mob traits
/// Used for limb-based paralysis, where replacing the limb will fix it.
#define TRAIT_PARALYSIS "paralysis"
/// This object has been slathered with a speed potion
#define TRAIT_SPEED_POTIONED "speed_potioned"

/// Can use the nuclear device's UI, regardless of a lack of hands
#define TRAIT_CAN_USE_NUKE "can_use_nuke"

/// Whether or not orbiting is blocked or not
#define TRAIT_ORBITING_FORBIDDEN "orbiting_forbidden"

///Mob is being tracked on glob suit sensors list
#define TRAIT_TRACKED_SENSORS "tracked_sensors"
///Mob is tracked by suit sensors, and on glob suit sensors list
#define TRAIT_SUIT_SENSORS "suit_sensors"
///Mob is tracked by nanites, and on glob suit sensors list
#define TRAIT_NANITE_SENSORS "nanite_sensors"

/// Trait for psyphoza, flag for examine logic
#define TRAIT_PSYCHIC_SENSE "psychic_sense"

/// Trait which means whatever has this is dancing by a dance machine
#define TRAIT_DISCO_DANCER "disco_dancer"

/**
 * Atom Traits
 */
///Used for managing KEEP_TOGETHER in [appearance_flags]
#define TRAIT_KEEP_TOGETHER "keep-together"
/// Properly wielded two handed item
#define TRAIT_WIELDED "wielded"
/// Buckling yourself to objects with this trait won't immobilize you
#define TRAIT_NO_IMMOBILIZE "no_immobilize"
/// A transforming item that is actively extended / transformed
#define TRAIT_TRANSFORM_ACTIVE "active_transform"

//important_recursive_contents traits
/*
 * Used for movables that need to be updated, via COMSIG_ENTER_AREA and COMSIG_EXIT_AREA, when transitioning areas.
 * Use [/atom/movable/proc/become_area_sensitive(trait_source)] to properly enable it. How you remove it isn't as important.
 */
#define TRAIT_AREA_SENSITIVE "area-sensitive"
///every hearing sensitive atom has this trait
#define TRAIT_HEARING_SENSITIVE "hearing_sensitive"
///every object that is currently the active storage of some client mob has this trait
#define TRAIT_ACTIVE_STORAGE "active_storage"

/// Climbable trait, given and taken by the climbable element when added or removed. Exists to be easily checked via HAS_TRAIT().
#define TRAIT_CLIMBABLE "trait_climbable"

/**
 * Item Traits
 */
#define TRAIT_NODROP            "nodrop"
#define TRAIT_NO_STORAGE_INSERT	"no_storage_insert" //cannot be inserted in a storage.
#define TRAIT_SPRAYPAINTED		"spraypainted"
#define TRAIT_T_RAY_VISIBLE     "t-ray-visible" // Visible on t-ray scanners if the atom/var/level == 1
/// If this item's been fried
#define TRAIT_FOOD_FRIED "food_fried"
/// If this item's been made by a chef instead of spawned by the map or admins
#define TRAIT_FOOD_CHEF_MADE "food_made_by_chef"
#define TRAIT_NO_TELEPORT		"no-teleport" //you just can't
#define TRAIT_STARGAZED			"stargazed"	//Affected by a stargazer
#define TRAIT_DOOR_PRYER		"door-pryer"	//Item can be used on airlocks to pry them open (even when powered)
#define TRAIT_FISH_SAFE_STORAGE "fish_case" //Fish in this won't die
#define TRAIT_FISH_CASE_COMPATIBILE "fish_case_compatibile" //Stuff that can go inside fish cases
#define TRAIT_NEEDS_TWO_HANDS "needstwohands" // The items needs two hands to be carried
#define TRAIT_AI_BAGATTACK "bagattack" // This atom can ignore the "is on a turf" check for simple AI datum attacks, allowing them to attack from bags or lockers as long as any other conditions are met
#define TRAIT_ARTIFACT_IGNORE "artifact_ignore" //This item is compltely ignored by artifacts, this is different to anti-artifact
#define TRAIT_IGNORE_EXPORT_SCAN "ignore_export_scan" //The export scanner can't scan this item

/// Allows heretics to cast their spells.
#define TRAIT_ALLOW_HERETIC_CASTING "allow_heretic_casting"
/// Designates a heart as a living heart for a heretic.
#define TRAIT_LIVING_HEART "living_heart"
/// Prevents stripping this equipment
#define TRAIT_NO_STRIP "no_strip"
/// Disallows this item from being pricetagged with a barcode
#define TRAIT_NO_BARCODES "no_barcode"

//quirk traits
#define TRAIT_ALCOHOL_TOLERANCE	"alcohol_tolerance"
#define TRAIT_AGEUSIA			"ageusia"
#define TRAIT_HEAVY_SLEEPER		"heavy_sleeper"
#define TRAIT_NIGHT_VISION_WEAK		"night_vision_trait"
#define TRAIT_LIGHT_STEP		"light_step"
#define TRAIT_SPIRITUAL			"spiritual"
#define TRAIT_VORACIOUS			"voracious"
#define TRAIT_SELF_AWARE		"self_aware"
#define TRAIT_FREERUNNING		"freerunning"
#define TRAIT_SKITTISH			"skittish"
#define TRAIT_POOR_AIM			"poor_aim"
#define TRAIT_TAGGER			"tagger"
#define TRAIT_PHOTOGRAPHER		"photographer"
#define TRAIT_LIGHT_DRINKER		"light_drinker"
#define TRAIT_EMPATH			"empath"
#define TRAIT_FRIENDLY			"friendly"
#define TRAIT_GRABWEAKNESS		"grab_weakness"
#define TRAIT_BRAIN_TUMOR		"brain_tumor"
#define TRAIT_PROSKATER			"pro_skater"
#define TRAIT_COMPUTER_WHIZ		"computer_whiz"

///Trait for dryable items
#define TRAIT_DRYABLE "trait_dryable"
///Trait for dried items
#define TRAIT_DRIED "trait_dried"
// Trait for customizable reagent holder
#define TRAIT_CUSTOMIZABLE_REAGENT_HOLDER "customizable_reagent_holder"
// Trait for allowing an item that isn't food into the customizable reagent holder
#define TRAIT_ODD_CUSTOMIZABLE_FOOD_INGREDIENT "odd_customizable_food_ingredient"

/* Traits for ventcrawling.
 * Both give access to ventcrawling, but *_NUDE requires the user to be
 * wearing no clothes and holding no items. If both present, *_ALWAYS
 * takes precedence.
 */
#define TRAIT_VENTCRAWLER_ALWAYS "ventcrawler_always"
#define TRAIT_VENTCRAWLER_NUDE "ventcrawler_nude"

///Trait applied to turfs when an atmos holosign is placed on them. It will stop firedoors from closing.
#define TRAIT_FIREDOOR_STOP "firedoor_stop"

/// this object has been frozen
#define TRAIT_FROZEN "frozen"

/// Makes a character be better/worse at tackling depending on their wing's status
#define TRAIT_TACKLING_WINGED_ATTACKER "tacking_winged_attacker"

/// Makes a character be frail and more likely to roll bad results if they hit a wall
#define TRAIT_TACKLING_FRAIL_ATTACKER "tackling_frail_attacker"

/// Makes a character be better/worse at defending against tackling depending on their tail's status
#define TRAIT_TACKLING_TAILED_DEFENDER "tackling_tailed_defender"

/// Is runechat for this atom/movable currently disabled, regardless of prefs or anything?
#define TRAIT_RUNECHAT_HIDDEN "runechat_hidden"

/// Trait given to a mob that is currently thinking (giving off the "thinking" icon), used in an IC context
#define TRAIT_THINKING_IN_CHARACTER "currently_thinking_IC"

/// This mob can strip other mobs.
#define TRAIT_CAN_STRIP "can_strip"

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
#define STATION_TRAIT_BIRTHDAY "station_trait_birthday"
#define STATION_TRAIT_BOTS_GLITCHED "station_trait_bot_glitch"
#define STATION_TRAIT_MACHINES_GLITCHED "station_trait_machine_glitch"
#define STATION_TRAIT_UNIQUE_AI "station_trait_unique_ai"

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

/// Weather immunities, also protect mobs inside them.
#define TRAIT_LAVA_IMMUNE "lava_immune" //Used by lava turfs and The Floor Is Lava.
#define TRAIT_ACIDSTORM_IMMUNE "acidstorm_immune"
#define TRAIT_ASHSTORM_IMMUNE "ashstorm_immune"
#define TRAIT_SNOWSTORM_IMMUNE "snowstorm_immune"
#define TRAIT_RADSTORM_IMMUNE "radstorm_immune"
#define TRAIT_WEATHER_IMMUNE "weather_immune" //Immune to ALL weather effects.

/// For unit testing, all do_afters set on this mob complete instantly and do not sleep
#define TRAIT_INSTANT_DO_AFTER "TRAIT_INSTANT_DO_AFTER"

/// The person with this trait always appears as 'unknown'.
#define TRAIT_UNKNOWN "unknown"

/// We are ignoring gravity
#define TRAIT_IGNORING_GRAVITY "ignores_gravity"
/// We have some form of forced gravity acting on us
#define TRAIT_FORCED_GRAVITY "forced_gravity"
#define TRAIT_NEGATES_GRAVITY "negates_gravity"
#define TRAIT_NIGHT_VISION "night_vision"

/// Oozelings with this trait will not lose limbs from low blood/nutrition.
#define TRAIT_OOZELING_NO_CANNIBALIZE "oozeling_no_cannibalize"

/// For the detective aurafarming ability
#define TRAIT_NOIR "noir"

/// Prevents items from being speed potion-ed, but allows their speed to be altered in other ways
#define TRAIT_NO_SPEED_POTION "no_speed_potion"

/// Are we immune to specifically tesla / SM shocks?
#define TRAIT_TESLA_SHOCKIMMUNE "tesla_shock_immunity"
/// Is this atom being actively shocked? Used to prevent repeated shocks.
#define TRAIT_BEING_SHOCKED "shocked"
/// Trait given to a dreaming carbon when they are currently doing dreaming stuff
#define TRAIT_DREAMING "currently_dreaming"

/// Stores typepaths, the typepath value read from this trait indicates that this item
/// is meant to look like the item with that path, which might affect how you show
/// this item to players (such as through armour readouts).
#define TRAIT_VALUE_MIMIC_PATH "mimic_path"

///without a human having this trait, they speak as if they have no tongue.
#define TRAIT_SPEAKS_CLEARLY "speaks_clearly"

/// Object is dangerous to mobs buckled to it
#define TRAIT_DANGEROUS_BUCKLE "dangerous_buckle"

// END TRAIT DEFINES
