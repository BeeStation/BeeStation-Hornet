/// Uncomment this to enable testing of Vampire features (such as vassalizing people with a mind instead of a client).
//#define VAMPIRE_TESTING
#if defined(VAMPIRE_TESTING) && defined(CIBUILDING)
	#error VAMPIRE_TESTING is enabled, disable this!
#endif

// Blood-level defines
/// Determines Vampire regeneration rate
#define BS_BLOOD_VOLUME_MAX_REGEN 700
/// Cost to torture someone halfway, in blood. Called twice for full cost
#define TORTURE_BLOOD_HALF_COST 8
/// Cost to convert someone after successful torture, in blood
#define TORTURE_CONVERSION_COST 50
/// Once blood is this low, will enter a Frenzy
#define FRENZY_THRESHOLD_ENTER 25
/// Once blood is this high, will exit the Frenzy. Intentionally high, we want to kill the person we feed off of
#define FRENZY_THRESHOLD_EXIT 250
/// How much blood drained from the vampire each lifetick
#define VAMPIRE_PASSIVE_BLOOD_DRAIN 0.1

// Vassal defines
/// If someone passes all checks and can be vassalized
#define VASSALIZATION_ALLOWED 0
/// If someone has to accept vassalization
#define VASSALIZATION_DISLOYAL 1
/// If someone is not allowed under any circimstances to become a Vassal
#define VASSALIZATION_BANNED 2

// Cooldown defines
// Used to prevent spamming vampires
/// Spam prevention for healing messages.
#define VAMPIRE_SPAM_HEALING 15 SECONDS
/// Spam prevention for Sol Masquerade messages.
#define VAMPIRE_SPAM_MASQUERADE 60 SECONDS

/// Spam prevention for Sol messages.
#define VAMPIRE_SPAM_SOL 30 SECONDS

// Clan defines
#define CLAN_CAITIFF "Caitiff"
#define CLAN_BRUJAH "Brujah Clan"
#define CLAN_TOREADOR "Toreador Clan"
#define CLAN_NOSFERATU "Nosferatu Clan"
#define CLAN_TREMERE "Tremere Clan"
#define CLAN_GANGREL "Gangrel Clan"
#define CLAN_VENTRUE "Ventrue Clan"
#define CLAN_MALKAVIAN "Malkavian Clan"
#define CLAN_TZIMISCE "Tzimisce Clan"
#define CLAN_HECATA "Hecata Clan"
#define CLAN_LASOMBRA "Lasombra Clan"

#define TREMERE_VASSAL "tremere_vassal"
#define FAVORITE_VASSAL "favorite_vassal"
#define DISCORDANT_VASSAL "discordant_vassal"

// Power defines
/// This Power can't be used in Torpor
#define BP_CANT_USE_IN_TORPOR (1<<0)
/// This Power can't be used in Frenzy.
#define BP_CANT_USE_IN_FRENZY (1<<1)
/// This Power can't be used with a stake in you
#define BP_CANT_USE_WHILE_STAKED (1<<2)
/// This Power can't be used while incapacitated
#define BP_CANT_USE_WHILE_INCAPACITATED (1<<3)
/// This Power can't be used while unconscious
#define BP_CANT_USE_WHILE_UNCONSCIOUS (1<<4)
/// This Power can't be used during Sol
#define BP_CANT_USE_DURING_SOL (1<<5)

/// This Power can be purchased by Vampires
#define VAMPIRE_CAN_BUY (1<<0)
/// This is a Default Power that all Vampires get.
#define VAMPIRE_DEFAULT_POWER (1<<1)
/// This Power can be purchased by Tremere Vampires
#define TREMERE_CAN_BUY (1<<2)
/// This Power can be purchased by Vassals
#define VASSAL_CAN_BUY (1<<3)
/// This Power is exclusive to Brujah vampires, who will gain them upon joining Brujah.
#define BRUJAH_DEFAULT_POWER (1<<4)

/// This Power is a Toggled Power
#define BP_AM_TOGGLE (1<<0)
/// This Power is a Single-Use Power
#define BP_AM_SINGLEUSE (1<<1)
/// This Power has a Static cooldown
#define BP_AM_STATIC_COOLDOWN (1<<2)
/// This Power doesn't cost bloot to run while unconscious
#define BP_AM_COSTLESS_UNCONSCIOUS (1<<3)
/// This Power has a cooldown that is more dynamic than a typical power
#define BP_AM_VERY_DYNAMIC_COOLDOWN (1<<4)

// Vampire Signals
/// Called when a Vampire breaks the Masquerade
#define COMSIG_VAMPIRE_BROKE_MASQUERADE "comsig_vampire_broke_masquerade"

// Sol signals & Defines
/// Sent every Sol tick
#define COMSIG_SOL_RISE_TICK "comsig_sol_rise_tick"
/// Sent 90 seconds before Sol begins
#define COMSIG_SOL_NEAR_START "comsig_sol_near_start"
/// Sent at the end of Sol
#define COMSIG_SOL_END "comsig_sol_end"
/// Sent 15 seconds before Sol ends
#define COMSIG_SOL_NEAR_END "comsig_sol_near_end"
/// Sent when a warning for Sol is meant to go out: (danger_level, vampire_warning_message, vassal_warning_message)
#define COMSIG_SOL_WARNING_GIVEN "comsig_sol_warning_given"

#define DANGER_LEVEL_FIRST_WARNING 1
#define DANGER_LEVEL_SECOND_WARNING 2
#define DANGER_LEVEL_THIRD_WARNING 3
#define DANGER_LEVEL_SOL_ROSE 4
#define DANGER_LEVEL_SOL_ENDED 5

// Clan defines
/// Drinks blood the normal Vampire way.
#define VAMPIRE_DRINK_NORMAL "vampire_drink_normal"
/// Drinks blood but is snobby, refusing to drink from mindless
#define VAMPIRE_DRINK_SNOBBY "vampire_drink_snobby"

// Traits
/// Falsifies Health analyzer blood levels
#define TRAIT_MASQUERADE "trait_masquerade"
/// Your body is literal room temperature. Does not make you immune to the temp
#define TRAIT_COLDBLOODED "trait_coldblooded"
/// For people in the middle of being staked
#define TRAIT_BEINGSTAKED "trait_beingstaked"

// Trait sources
/// Sour trait for all vampire traits
#define TRAIT_VAMPIRE "trait_vampire"
/// Source trait while Feeding
#define TRAIT_FEED "trait_feed"
/// Source trait during a Frenzy
#define TRAIT_FRENZY "trait_frenzy"
/// Source trait for vampires in torpor.
#define TRAIT_TORPOR "trait_torpor"
/// Source trait for vampire mesmerization.
#define TRAIT_MESMERIZED "trait_mesmerized"

// Macros
#define IS_CURATOR(mob) (mob?.mind?.assigned_role == JOB_NAME_CURATOR)
