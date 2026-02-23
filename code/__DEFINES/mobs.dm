/*ALL MOB-RELATED DEFINES THAT DON'T BELONG IN ANOTHER FILE GO HERE*/

//Misc mob defines

//Ready states at roundstart for /mob/dead/new_player/authenticated
#define PLAYER_NOT_READY 0
#define PLAYER_READY_TO_PLAY 1
#define PLAYER_READY_TO_OBSERVE 2

/// Dynamic list indexes
#define CURRENT_LIVING_PLAYERS "living_players_list"
#define CURRENT_LIVING_ANTAGS "living_antags_list"
#define CURRENT_DEAD_PLAYERS "dead_players_list"
#define CURRENT_OBSERVERS "current_observers_list"

//movement intent defines for the m_intent var
#define MOVE_INTENT_WALK "walk"
#define MOVE_INTENT_RUN  "run"

// Bleed rates
// See blood.dm for calculations
#define BLEED_RATE_MINOR 2.4 		/// Point at which bleeding is considered minor and will eventually self-heal
#define BLEED_HEAL_RATE_MINOR 0.02 	/// How quickly minor bleeds will stop bleeding (0.05/sec)
#define MAX_BLEED_RATE 3			/// Mobs can get more bleed than this, but won't actually bleed faster than this value

// Bleed damage values
#define BLEED_TINY 0.1
#define BLEED_SCRATCH 0.8
#define BLEED_SURFACE 1.5			// 560 > 506 blood in 75 seconds
#define BLEED_CUT 2.3				// 560 > 442 blood in 115 seconds
#define BLEED_DEEP_WOUND 2.4		// Crit in 285 seconds, Death in 356 seconds
#define BLEED_CRITICAL 3.6			// Crit in 190 seconds, Death in 238 seconds

#define BLEED_RATE_MULTIPLIER 1				/// How quickly do we bleed out? A value of 1 means that if we have a bleed rate of 10, then we lose 5 blood per second.
#define BLEED_RATE_MULTIPLIER_NO_HEART 0.4 	/// If we have no heart, then we will bleed slower. This multiplies by our bleeding rate if that is the case.

//Blood levels
#define BLOOD_VOLUME_MAXIMUM		2000
#define BLOOD_VOLUME_SLIME_SPLIT	1120
#define BLOOD_VOLUME_NORMAL			560
#define BLOOD_VOLUME_SAFE			475
#define BLOOD_VOLUME_OKAY			336
#define BLOOD_VOLUME_BAD			224
#define BLOOD_VOLUME_SURVIVE		122

#define AMOUNT_TO_BLEED_INTENSITY(x) ((x) ** 0.3333)

/// How efficiently humans regenerate blood.
#define BLOOD_REGEN_FACTOR 0.25

//Sizes of mobs, used by mob/living/var/mob_size
#define MOB_SIZE_TINY 0
#define MOB_SIZE_SMALL 1
#define MOB_SIZE_HUMAN 2
#define MOB_SIZE_LARGE 3

//Ventcrawling defines
#define VENTCRAWLER_NONE   0
#define VENTCRAWLER_NUDE   1
#define VENTCRAWLER_ALWAYS 2

//Bloodcrawling defines
#define BLOODCRAWL 1
#define BLOODCRAWL_EAT 2

// Mob bio-type flags
/// The mob is organic, can heal from medical sutures.
#define MOB_ORGANIC (1 << 0)
/// The mob isn't organic. For example, golems and IPCs.
#define MOB_INORGANIC (1 << 1)
/// The mob is a synthetic lifeform, like station borgs.
#define MOB_ROBOTIC (1 << 2)
/// The mob is an shambling undead corpse. Or a halloween species. Pick your poison.
#define MOB_UNDEAD (1 << 3)
/// The mob is a human-sized human-like human-creature.
#define MOB_HUMANOID (1 << 4)
/// The mob is a bug/insect/arachnid/some other kind of scuttly thing.
#define MOB_BUG (1 << 5)
/// The mob is a wild animal. Domestication may apply.
#define MOB_BEAST (1 << 6)
/// The mob is some kind of a creature that should be exempt from certain **fun** interactions for balance reasons, i.e. megafauna
#define MOB_SPECIAL (1 << 7)
/// The mob is some kind of a scaly reptile creature
#define MOB_REPTILE (1 << 8)
/// The mob is a spooky phantasm or an evil ghast of such nature.
#define MOB_SPIRIT (1 << 9)

#define DEFAULT_BODYPART_ICON_ORGANIC 'icons/mob/human/bodyparts_greyscale.dmi'
#define DEFAULT_BODYPART_ICON_ROBOTIC 'icons/mob/augmentation/augments.dmi'

#define MONKEY_BODYPART "monkey"
#define TERATOMA_BODYPART "teratoma"
#define ALIEN_BODYPART "alien"
#define LARVA_BODYPART "larva"

//Bodytype defines for how things can be worn, surgery, and other misc things.
///The limb is organic.
#define BODYTYPE_ORGANIC (1<<0)
///The limb is robotic.
#define BODYTYPE_ROBOTIC (1<<1)
///The limb fits the human mold. This is not meant to be literal, if the sprite "fits" on a human, it is "humanoid", regardless of origin.
#define BODYTYPE_HUMANOID (1<<2)
///The limb is digitigrade.
#define BODYTYPE_DIGITIGRADE (1<<3)
///The limb fits the monkey mold.
#define BODYTYPE_MONKEY (1<<4)
///The limb is snouted.
//#define BODYTYPE_SNOUTED (1<<5)
///A placeholder bodytype for xeno larva, so their limbs cannot be attached to anything.
#define BODYTYPE_LARVA_PLACEHOLDER (1<<6)
///The limb is from a xenomorph.
#define BODYTYPE_ALIEN (1<<7)

//Species gib types
#define GIB_TYPE_HUMAN "human"
#define GIB_TYPE_ROBOTIC "robotic"

#define DIGITIGRADE_NEVER 0
#define DIGITIGRADE_OPTIONAL 1
#define DIGITIGRADE_FORCED 2

///Digitigrade's prefs, used in features for legs if you're meant to be a Digitigrade.
#define DIGITIGRADE_LEGS "Digitigrade Legs"

// Health/damage defines
#define MAX_LIVING_HEALTH 100

//Reagent Metabolization flags, defines the type of reagents that affect this mob
#define PROCESS_ORGANIC 1		//Only processes reagents with "ORGANIC" or "ORGANIC | SYNTHETIC"
#define PROCESS_SYNTHETIC 2		//Only processes reagents with "SYNTHETIC" or "ORGANIC | SYNTHETIC"

// Reagent type flags, defines the types of mobs this reagent will affect
#define ORGANIC 1
#define SYNTHETIC 2

/*see __DEFINES/inventory.dm for bodypart bitflag defines*/

//for determining which type of heartbeat sound is playing
///Heartbeat is beating fast for hard crit
#define BEAT_FAST 1
///Heartbeat is beating slow for soft crit
#define BEAT_SLOW 2
///Heartbeat is gone... He's dead Jim :(
#define BEAT_NONE 0

// Health/damage defines for carbon mobs
#define HUMAN_MAX_OXYLOSS 3
#define HUMAN_CRIT_MAX_OXYLOSS (SSMOBS_DT/3)

#define STAMINA_CRIT_TIME (5 SECONDS)	//Time before regen starts when in stam crit
#define STAMINA_REGEN_BLOCK_TIME (2 SECONDS) //Time before regen starts when hit with stam damage

#define HEAT_DAMAGE_LEVEL_1 1 //Amount of damage applied when your body temperature just passes the 360.15k safety point
#define HEAT_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when your body temperature passes the 400K point
#define HEAT_DAMAGE_LEVEL_3 4 //Amount of damage applied when your body temperature passes the 460K point and you are on fire

#define COLD_DAMAGE_LEVEL_1 0.25 //Amount of damage applied when your body temperature just passes the 260.15k safety point
#define COLD_DAMAGE_LEVEL_2 0.75 //Amount of damage applied when your body temperature passes the 200K point
#define COLD_DAMAGE_LEVEL_3 1.5 //Amount of damage applied when your body temperature passes the 120K point

//Note that gas heat damage is only applied once every FOUR ticks.
#define HEAT_GAS_DAMAGE_LEVEL_1 2 //! Amount of damage applied when the current breath's temperature just passes the 360.15k safety point
#define HEAT_GAS_DAMAGE_LEVEL_2 4 //! Amount of damage applied when the current breath's temperature passes the 400K point
#define HEAT_GAS_DAMAGE_LEVEL_3 8 //! Amount of damage applied when the current breath's temperature passes the 1000K point

#define COLD_GAS_DAMAGE_LEVEL_1 0.5 //! Amount of damage applied when the current breath's temperature just passes the 260.15k safety point
#define COLD_GAS_DAMAGE_LEVEL_2 1.5 //! Amount of damage applied when the current breath's temperature passes the 200K point
#define COLD_GAS_DAMAGE_LEVEL_3 3 //! Amount of damage applied when the current breath's temperature passes the 120K point

//Brain Damage defines
#define BRAIN_DAMAGE_MILD 20
#define BRAIN_DAMAGE_SEVERE 100
#define BRAIN_DAMAGE_DEATH 200

#define BRAIN_TRAUMA_MILD /datum/brain_trauma/mild
#define BRAIN_TRAUMA_SEVERE /datum/brain_trauma/severe
#define BRAIN_TRAUMA_SPECIAL /datum/brain_trauma/special
#define BRAIN_TRAUMA_MAGIC /datum/brain_trauma/magic

#define TRAUMA_RESILIENCE_BASIC 1      //! Curable with chems
#define TRAUMA_RESILIENCE_SURGERY 2    //! Curable with brain recalibration
#define TRAUMA_RESILIENCE_LOBOTOMY 3   //! Curable with lobotomy
#define TRAUMA_RESILIENCE_MAGIC 4      //! Curable only with magic
#define TRAUMA_RESILIENCE_ABSOLUTE 5   //! This is here to stay

GLOBAL_LIST_INIT(available_random_trauma_list, list(
	"spiders" = 5,
	"space" = 2,
	"security" = 5,
	"clowns" = 5,
	"greytide" = 5,
	"lizards" = 5,
	"skeletons" = 5,
	"snakes" = 5,
	"robots" = 4,
	"doctors" = 4,
	"authority" = 5,
	"the supernatural" = 5,
	"aliens" = 5,
	"strangers" = 5,
	"birds" = 5,
	"falling" = 5,
	"anime" = 5
))

/// This trauma cannot be cured through "special" means, such as nanites or viruses.
#define TRAUMA_SPECIAL_CURE_PROOF	(1<<0)
/// This trauma transfers on cloning.
#define TRAUMA_CLONEABLE			(1<<1)
/// This trauma CANNOT be obtained randomly.
#define TRAUMA_NOT_RANDOM			(1<<2)
/// Default trauma flags.
#define TRAUMA_DEFAULT_FLAGS		(TRAUMA_CLONEABLE)

//Limit of traumas for each resilience tier
#define TRAUMA_LIMIT_BASIC 3
#define TRAUMA_LIMIT_SURGERY 2
#define TRAUMA_LIMIT_LOBOTOMY 3
#define TRAUMA_LIMIT_MAGIC 3
#define TRAUMA_LIMIT_ABSOLUTE INFINITY

#define BRAIN_DAMAGE_INTEGRITY_MULTIPLIER 0.5

//wing defines
#define WINGS_COSMETIC 0 //Absolutely fucking useless
#define WINGS_FLIGHTLESS 1 //can't generate lift, will only fly in 0-G, while atmos is present
#define WINGS_FLYING 2 //can generate lift and fly if atmos is present
#define WINGS_MAGIC 3 //can fly regardless of atmos

//Health hud screws for carbon mobs
#define SCREWYHUD_NONE 0
#define SCREWYHUD_CRIT 1
#define SCREWYHUD_DEAD 2
#define SCREWYHUD_HEALTHY 3

//Moods levels for humans
#define MOOD_LEVEL_HAPPY4 15
#define MOOD_LEVEL_HAPPY3 10
#define MOOD_LEVEL_HAPPY2 6
#define MOOD_LEVEL_HAPPY1 2
#define MOOD_LEVEL_NEUTRAL 0
#define MOOD_LEVEL_SAD1 -3
#define MOOD_LEVEL_SAD2 -7
#define MOOD_LEVEL_SAD3 -15
#define MOOD_LEVEL_SAD4 -20

//Sanity levels for humans
#define SANITY_MAXIMUM 150
#define SANITY_GREAT 125
#define SANITY_NEUTRAL 100
#define SANITY_DISTURBED 75
#define SANITY_UNSTABLE 50
#define SANITY_CRAZY 25
#define SANITY_INSANE 0

//Nutrition levels for humans
#define NUTRITION_LEVEL_FAT 600
#define NUTRITION_LEVEL_FULL 550
#define NUTRITION_LEVEL_WELL_FED 450
#define NUTRITION_LEVEL_FED 350
#define NUTRITION_LEVEL_HUNGRY 250
#define NUTRITION_LEVEL_STARVING 150

#define NUTRITION_LEVEL_START_MIN 250
#define NUTRITION_LEVEL_START_MAX 400

//Disgust levels for humans
#define DISGUST_LEVEL_MAXEDOUT 150
#define DISGUST_LEVEL_DISGUSTED 75
#define DISGUST_LEVEL_VERYGROSS 50
#define DISGUST_LEVEL_GROSS 25

//Used as an upper limit for species that continuously gain nutriment
#define NUTRITION_LEVEL_ALMOST_FULL 535

//Base nutrition value used for newly initialized slimes
#define SLIME_DEFAULT_NUTRITION 700

//Slime evolution threshold. Controls how fast slimes can split/grow
#define SLIME_EVOLUTION_THRESHOLD 10

//Slime extract crossing. Controls how many extracts is required to feed to a slime to core-cross.
#define SLIME_EXTRACT_CROSSING_REQUIRED 10

//Slime commands defines
#define SLIME_FRIENDSHIP_FOLLOW 			3 //! Min friendship to order it to follow
#define SLIME_FRIENDSHIP_STOPEAT 			5 //! Min friendship to order it to stop eating someone
#define SLIME_FRIENDSHIP_STOPEAT_NOANGRY	7 //! Min friendship to order it to stop eating someone without it losing friendship
#define SLIME_FRIENDSHIP_STOPCHASE			4 //! Min friendship to order it to stop chasing someone (their target)
#define SLIME_FRIENDSHIP_STOPCHASE_NOANGRY	6 //! Min friendship to order it to stop chasing someone (their target) without it losing friendship
#define SLIME_FRIENDSHIP_STAY				3 //! Min friendship to order it to stay
#define SLIME_FRIENDSHIP_ATTACK				8 //! Min friendship to order it to attack

//Slime transformative extract effects
#define SLIME_EFFECT_DEFAULT		(1<<0)
#define SLIME_EFFECT_GREY			(1<<1)
#define SLIME_EFFECT_ORANGE			(1<<2)
#define SLIME_EFFECT_PURPLE			(1<<3)
#define SLIME_EFFECT_BLUE			(1<<4)
#define SLIME_EFFECT_METAL			(1<<5)
#define SLIME_EFFECT_YELLOW			(1<<6)
#define SLIME_EFFECT_DARK_PURPLE	(1<<7)
#define SLIME_EFFECT_DARK_BLUE		(1<<8)
#define SLIME_EFFECT_SILVER			(1<<9)
#define SLIME_EFFECT_BLUESPACE		(1<<10)
#define SLIME_EFFECT_SEPIA			(1<<11)
#define SLIME_EFFECT_CERULEAN		(1<<12)
#define SLIME_EFFECT_PYRITE			(1<<13)
#define SLIME_EFFECT_RED			(1<<14)
#define SLIME_EFFECT_GREEN			(1<<15)
#define SLIME_EFFECT_PINK			(1<<16)
#define SLIME_EFFECT_GOLD			(1<<17)
#define SLIME_EFFECT_OIL			(1<<18)
#define SLIME_EFFECT_BLACK			(1<<19)
#define SLIME_EFFECT_LIGHT_PINK		(1<<20)
#define SLIME_EFFECT_ADAMANTINE		(1<<21)
#define SLIME_EFFECT_RAINBOW		(1<<22)

//Sentience types, to prevent things like sentience potions from giving bosses sentience
#define SENTIENCE_ORGANIC 1
#define SENTIENCE_ARTIFICIAL 2
#define SENTIENCE_OTHER 3
#define SENTIENCE_MINEBOT 4
#define SENTIENCE_BOSS 5

//Mob AI Status
#define POWER_RESTORATION_OFF 0
#define POWER_RESTORATION_START 1
#define POWER_RESTORATION_SEARCH_APC 2
#define POWER_RESTORATION_APC_FOUND 3

//Hostile simple animals
//If you add a new status, be sure to add a list for it to the simple_animals global in _globalvars/lists/mobs.dm
#define AI_ON 1
#define AI_IDLE 2
#define AI_OFF 3
#define AI_Z_OFF 4

/// An AI hint which tells the AI what it should break.
/// Note that mobs being able to break walls and r-walls is determined by their attack force.
#define ENVIRONMENT_SMASH_NONE			0
#define ENVIRONMENT_SMASH_STRUCTURES	(1<<0) 	//crates, lockers, ect
#define ENVIRONMENT_SMASH_WALLS			(1<<1)  //walls
#define ENVIRONMENT_SMASH_RWALLS		(1<<2)	//rwalls

#define NO_SLIP_WHEN_WALKING	(1<<0)
#define SLIDE					(1<<1)
#define GALOSHES_DONT_HELP		(1<<2)
#define SLIDE_ICE				(1<<3)
#define SLIP_WHEN_CRAWLING		(1<<4) //clown planet ruin
#define NO_SLIP_ON_CATWALK      (1<<5)

///Flags used by the flags parameter of electrocute act.
///Makes it so that the shock doesn't take gloves into account.
#define SHOCK_NOGLOVES (1 << 0)
///Used when the shock is from a tesla bolt.
#define SHOCK_TESLA (1 << 1)
///Used when an illusion shocks something. Makes the shock deal stamina damage and not trigger certain secondary effects.
#define SHOCK_ILLUSION (1 << 2)
///The shock doesn't stun.
#define SHOCK_NOSTUN (1 << 3)
/// No default message is sent from the shock
#define SHOCK_SUPPRESS_MESSAGE (1 << 4)

#define INCORPOREAL_MOVE_BASIC 1
#define INCORPOREAL_MOVE_SHADOW 2 //!  leaves a trail of shadows
#define INCORPOREAL_MOVE_JAUNT 3 //! is blocked by holy water/salt
#define INCORPOREAL_MOVE_EMINENCE 4 //! same as jaunt, but lets eminence pass clockwalls

//Secbot and ED209 judgment criteria bitflag values
#define JUDGE_EMAGGED		(1<<0)
#define JUDGE_IDCHECK		(1<<1)
#define JUDGE_WEAPONCHECK	(1<<2)
#define JUDGE_RECORDCHECK	(1<<3)
//ED209's ignore monkeys
#define JUDGE_IGNOREMONKEYS	(1<<4)

#define SHADOW_SPECIES_LIGHT_THRESHOLD 0.25
// Offsets defines

#define OFFSET_UNIFORM "uniform"
#define OFFSET_ID "id"
#define OFFSET_GLOVES "gloves"
#define OFFSET_GLASSES "glasses"
#define OFFSET_EARS "ears"
#define OFFSET_SHOES "shoes"
#define OFFSET_S_STORE "s_store"
#define OFFSET_FACEMASK "mask"
#define OFFSET_HEAD "head"
#define OFFSET_FACE "face"
#define OFFSET_BELT "belt"
#define OFFSET_BACK "back"
#define OFFSET_SUIT "suit"
#define OFFSET_NECK "neck"
#define OFFSET_LEFT_HAND "l_hand"
#define OFFSET_RIGHT_HAND "r_hand"

//MINOR TWEAKS/MISC
#define AGE_MIN				18	//! youngest a character can be
#define AGE_MAX				85	//! oldest a character can be
#define WIZARD_AGE_MIN		30	//! youngest a wizard can be
#define APPRENTICE_AGE_MIN	29	//! youngest an apprentice can be
#define SHOES_SLOWDOWN		0	//! How much shoes slow you down by default. Negative values speed you up
#define POCKET_STRIP_DELAY	(4 SECONDS)	//! time taken to search somebody's pockets
#define DOOR_CRUSH_DAMAGE	15	//! the amount of damage that airlocks deal when they crush you

#define HUNGER_FACTOR 0.05 //factor at which mob nutrition decreases
#define REAGENTS_METABOLISM 0.2 //How many units of reagent are consumed per second, by default.

// Eye protection
// THese values are additive to determine your overall flash protection.
#define FLASH_PROTECTION_SENSITIVE -1
#define FLASH_PROTECTION_NONE 0
#define FLASH_PROTECTION_FLASH 1
#define FLASH_PROTECTION_WELDER 2
#define FLASH_PROTECTION_WELDER_SENSITIVE 3
#define FLASH_PROTECTION_WELDER_HYPER_SENSITIVE 4

// Roundstart trait system

//The maximum amount of positive quirks one character can have at roundstart, and I hope whoever originally named this simply MAX_QUIRKS stubs their toe
#define MAX_POSITIVE_QUIRKS 3

// AI Toggles
#define AI_CAMERA_LUMINOSITY	5
#define AI_VOX //! Comment out if you don't want VOX to be enabled and have players download the voice sounds.

// /obj/item/bodypart on_mob_life() retval flag
#define BODYPART_LIFE_UPDATE_HEALTH (1<<0)

#define MAX_REVIVE_FIRE_DAMAGE 180
#define MAX_REVIVE_BRUTE_DAMAGE 180

#define GRAB_PIXEL_SHIFT_PASSIVE 6
#define GRAB_PIXEL_SHIFT_AGGRESSIVE 12
#define GRAB_PIXEL_SHIFT_NECK 16

#define PULL_PRONE_SLOWDOWN 1.5
#define HUMAN_CARRY_SLOWDOWN 0.35

#define SLEEP_CHECK_DEATH(X) sleep(X); if(QDELETED(src) || stat == DEAD) return;

#define DOING_INTERACTION(user, interaction_key) (LAZYACCESS(user.do_afters, interaction_key))
#define DOING_INTERACTION_LIMIT(user, interaction_key, max_interaction_count) ((LAZYACCESS(user.do_afters, interaction_key) || 0) >= max_interaction_count)
#define DOING_INTERACTION_WITH_TARGET(user, target) (LAZYACCESS(user.do_afters, target))
#define DOING_INTERACTION_WITH_TARGET_LIMIT(user, target, max_interaction_count) ((LAZYACCESS(user.do_afters, target) || 0) >= max_interaction_count)

// recent examine defines
/// How long it takes for an examined atom to be removed from recent_examines. Should be the max of the below time windows
#define RECENT_EXAMINE_MAX_WINDOW (2 SECONDS)
/// If you examine the same atom twice in this timeframe, we call examine_more() instead of examine()
#define EXAMINE_MORE_WINDOW (1 SECONDS)

#define SILENCE_RANGED_MESSAGE (1<<0)

// Mob Playability Set By Admin Or Ghosting
#define SENTIENCE_SKIP 0
#define SENTIENCE_RETAIN 1	//a player ghosting out of the mob will make the mob playable for others, if it was already playable
#define SENTIENCE_FORCE 2		//the mob will be made playable by force when a player is forcefully ejected from a mob (by admin, for example)
#define SENTIENCE_ERASE 3

//Flavor Text When Entering A Playable Mob
#define FLAVOR_TEXT_EVIL "evil"	//mob antag
#define FLAVOR_TEXT_GOOD "good"	//ie do not cause evil
#define FLAVOR_TEXT_NONE "none"
#define FLAVOR_TEXT_GOAL_ANTAG "blob"	//is antag, but should work towards its goals

//Saves a proc call, life is suffering. If who has no targets_from var, we assume it's just who
#define GET_TARGETS_FROM(who) (who.targets_from ? who.get_targets_from() : who)

///Define for spawning megafauna instead of a mob for cave gen
#define SPAWN_MEGAFAUNA "bluh bluh huge boss"

///How much a mob's sprite should be moved when they're lying down
#define PIXEL_Y_OFFSET_LYING -6

///Squash flags. For squashable element

///Whether or not the squashing requires the squashed mob to be lying down
#define SQUASHED_SHOULD_BE_DOWN (1<<0)
///Whether or not to gib when the squashed mob is moved over
#define SQUASHED_SHOULD_BE_GIBBED (1<<0)


/*
 * Defines for "AI emotions", allowing the AI to expression emotions
 * with status displays via emotes.
 */

#define AI_EMOTION_VERY_HAPPY "Very Happy"
#define AI_EMOTION_HAPPY "Happy"
#define AI_EMOTION_NEUTRAL "Neutral"
#define AI_EMOTION_UNSURE "Unsure"
#define AI_EMOTION_CONFUSED "Confused"
#define AI_EMOTION_SAD "Sad"
#define AI_EMOTION_BSOD "BSOD"
#define AI_EMOTION_BLANK "Blank"
#define AI_EMOTION_PROBLEMS "Problems?"
#define AI_EMOTION_AWESOME "Awesome"
#define AI_EMOTION_FACEPALM "Facepalm"
#define AI_EMOTION_THINKING "Thinking"
#define AI_EMOTION_FRIEND_COMPUTER "Friend Computer"
#define AI_EMOTION_DORFY "Dorfy"
#define AI_EMOTION_BLUE_GLOW "Blue Glow"
#define AI_EMOTION_RED_GLOW "Red Glow"

//Generic body sizes
#define BODY_SIZE_NORMAL 0
#define BODY_SIZE_SHORT 1
#define BODY_SIZE_TALL -1

/// Throw modes, defines whether or not to turn off throw mode after
#define THROW_MODE_DISABLED 0
#define THROW_MODE_TOGGLE 1
#define THROW_MODE_HOLD 2

#define MOB_OVERLAY_LAYER_ABSOLUTE(_mob_layer, _overlay_layer) (_mob_layer - (_overlay_layer) * ((MOB_MAX_CLOTHING_LAYER - MOB_LAYER) / TOTAL_LAYERS))

/// Converts the layer into a float layer that is within the bounds of the defined maximum mob clothing layer
/// The bigger the input layer, the deeper it will be (mutations layer is at the bottom, so has a float layer of FLOAT_LAYER - 0.1).
#define CALCULATE_MOB_OVERLAY_LAYER(_layer) (FLOAT_LAYER - (_layer) * ((MOB_MAX_CLOTHING_LAYER - MOB_LAYER) / TOTAL_LAYERS))

// Mob Overlays Indexes
/// KEEP THIS UP-TO-DATE OR SHIT WILL BREAK ;_;
#define TOTAL_LAYERS 29
/// Mutations layer - Tk headglows, cold resistance glow, etc
#define MUTATIONS_LAYER 29
/// Certain mutantrace features (tail when looking south) that must appear behind the body parts
#define BODY_BEHIND_LAYER 28
/// Initially "AUGMENTS", this was repurposed to be a catch-all bodyparts flag
#define BODYPARTS_LAYER 27
/// certain mutantrace features (snout, body markings) that must appear above the body parts
#define BODY_ADJ_LAYER 26
/// underwear, undershirts, socks, eyes, lips(makeup)
#define BODY_LAYER 25
/// mutations that should appear above body, body_adj and bodyparts layer (e.g. laser eyes)
#define FRONT_MUTATIONS_LAYER 24
/// damage indicators (cuts and burns)
#define DAMAGE_LAYER 23
/// Jumpsuit clothing layer
#define UNIFORM_LAYER 22
/// lmao at the idiot who put both ids and hands on the same layer
#define ID_LAYER 21
/// Hands body part layer (or is this for the arm? not sure...)
#define HANDS_PART_LAYER 20
/// Gloves layer
#define GLOVES_LAYER 19
/// Shoes layer
#define SHOES_LAYER 18
/// Ears layer (Spessmen have ears? Wow)
#define EARS_LAYER 17
/// Suit layer (armor, coats, etc.)
#define SUIT_LAYER 16
/// Glasses layer
#define GLASSES_LAYER 15
/// Belt layer
#define BELT_LAYER 14 //Possible make this an overlay of somethign required to wear a belt?
/// Suit storage layer (tucking a gun or baton underneath your armor)
#define SUIT_STORE_LAYER 13
///  Neck layer (for wearing ties and bedsheets)
#define NECK_LAYER 12
/// Back layer (for backpacks and equipment on your back)
#define BACK_LAYER 11
/// Hair layer (mess with the fro and you got to go!)
#define HAIR_LAYER 10		//! TODO: make part of head layer?
/// Facemask layer (gas masks, breath masks, etc.)
#define FACEMASK_LAYER 9
/// Head layer (hats, helmets, etc.)
#define HEAD_LAYER 8
/// Handcuff layer (when your hands are cuffed)
#define HANDCUFF_LAYER 7
/// Legcuff layer (when your feet are cuffed)
#define LEGCUFF_LAYER 6
/// Hands layer (for the actual hand, not the arm... I think?)
#define HANDS_LAYER 5
/// Body front layer. Usually used for mutant bodyparts that need to be in front of stuff (e.g. cat ears)
#define BODY_FRONT_LAYER 4
/// Blood cult ascended halo layer, because there's currently no better solution for adding/removing
#define HALO_LAYER 3
/// Typing layer for the typing indicator
#define TYPING_LAYER 2
/// The highest most layer for mob overlays
#define HIGHEST_LAYER 1

//Mob Overlay Index Shortcuts for alternate_worn_layer, layers
//Because I *KNOW* somebody will think layer+1 means "above"
//IT DOESN'T OK, IT MEANS "UNDER"
/// The layer underneath the suit
#define UNDER_SUIT_LAYER (SUIT_LAYER+1)
/// The layer underneath the head (for hats)
#define UNDER_HEAD_LAYER (HEAD_LAYER+1)

//AND -1 MEANS "ABOVE", OK?, OK!?!
/// The layer above shoes
#define ABOVE_SHOES_LAYER (SHOES_LAYER-1)
/// The layer above mutant body parts
#define ABOVE_BODY_FRONT_LAYER (BODY_FRONT_LAYER-1)

//used by canUseTopic()
/// If silicons need to be next to the atom to use this
#define BE_CLOSE TRUE
/// If other mobs (monkeys, aliens, etc) can use this
#define NO_DEXTERITY TRUE // I had to change 20+ files because some non-dnd-playing fuckchumbis can't spell "dexterity"
// If telekinesis you can use it from a distance
#define NO_TK TRUE

/// The default mob sprite size (used for shrinking or enlarging the mob sprite to regular size)
#define RESIZE_DEFAULT_SIZE 1

/// Get the client from the var
#define CLIENT_FROM_VAR(I) (ismob(I) ? I:client : (istype(I, /client) ? I : (istype(I, /datum/mind) ? I:current?:client : null)))

/// The mob will vomit a green color
#define VOMIT_TOXIC 1
/// The mob will vomit a purple color
#define VOMIT_PURPLE 2
/// The mob will vomit up nanites
#define VOMIT_NANITE 3


/// Messages when (something) lays an egg
#define EGG_LAYING_MESSAGES list("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")

/// How far away you can be to make eye contact with someone while examining
#define EYE_CONTACT_RANGE 5

/// Returns whether or not the given mob can succumb
#define CAN_SUCCUMB(target) (HAS_TRAIT(target, TRAIT_CRITICAL_CONDITION) && !HAS_TRAIT(target, TRAIT_NODEATH))

/// Possible value of [/atom/movable/buckle_lying]. If set to a different (positive-or-zero) value than this, the buckling thing will force a lying angle on the buckled.
#define NO_BUCKLE_LYING -1

// Body position defines.
/// Mob is standing up, usually associated with lying_angle value of 0.
#define STANDING_UP 0
/// Mob is lying down, usually associated with lying_angle values of 90 or 270.
#define LYING_DOWN 1

// Flags for fully_heal().

/// Special flag that means this heal is an admin heal and goes above and beyond
/// Note, this includes things like removing suicide status and handcuffs / legcuffs, use with slight caution.
#define HEAL_ADMIN (1<<0)
/// Heals all brute damage.
#define HEAL_BRUTE (1<<1)
/// Heals all burn damage.
#define HEAL_BURN (1<<2)
/// Heals all toxin damage, slime people included.
#define HEAL_TOX (1<<3)
/// Heals all oxyloss.
#define HEAL_OXY (1<<4)
/// Heals all cellular damage.
#define HEAL_CLONE (1<<5)
/// Heals all stamina damage.
#define HEAL_STAM (1<<6)
/// Restore all limbs to their initial state.
#define HEAL_LIMBS (1<<7)
/// Heals all organs from failing. If done as a part of an admin heal, will instead restore all organs to their initial state.
#define HEAL_ORGANS (1<<8)
/// A "super" heal organs, this refreshes all organs entirely, deleting old and replacing them with new.
#define HEAL_REFRESH_ORGANS (1<<9)
/// Removes all brain traumas, not including permanent ones.
#define HEAL_TRAUMAS (1<<10)
/// Removes all reagents present.
#define HEAL_ALL_REAGENTS (1<<11)
/// Removes all non-positive diseases.
#define HEAL_NEGATIVE_DISEASES (1<<12)
/// Restores body temperature back to nominal.
#define HEAL_TEMP (1<<13)
/// Restores blood levels to normal.
#define HEAL_BLOOD (1<<14)
/// Removes all non-positive mutations (neutral included).
#define HEAL_NEGATIVE_MUTATIONS (1<<15)
/// Removes status effects with this flag set that also have remove_on_fullheal = TRUE.
#define HEAL_STATUS (1<<16)
/// Same as above, removes all CC related status effects with this flag set that also have remove_on_fullheal = TRUE.
#define HEAL_CC_STATUS (1<<17)
/// Deletes any restraints on the mob (handcuffs / legcuffs)
#define HEAL_RESTRAINTS (1<<18)

/// Combination flag to only heal the main damage types.
#define HEAL_DAMAGE (HEAL_BRUTE|HEAL_BURN|HEAL_TOX|HEAL_OXY|HEAL_CLONE|HEAL_STAM)
/// Combination flag to only heal things messed up things about the mob's body itself.
#define HEAL_BODY (HEAL_LIMBS|HEAL_ORGANS|HEAL_REFRESH_ORGANS|HEAL_TRAUMAS|HEAL_BLOOD|HEAL_TEMP)
/// Combination flag to heal negative things affecting the mob.
#define HEAL_AFFLICTIONS (HEAL_NEGATIVE_DISEASES|HEAL_NEGATIVE_MUTATIONS|HEAL_ALL_REAGENTS|HEAL_STATUS|HEAL_CC_STATUS)

/// Full heal that isn't admin forced
#define HEAL_ALL ~(HEAL_ADMIN|HEAL_RESTRAINTS)
/// Heals everything and is as strong as / is an admin heal
#define ADMIN_HEAL_ALL ALL

/// Default minimum body temperature mobs can exist in before taking damage
#define NPC_DEFAULT_MIN_TEMP 250
/// Default maximum body temperature mobs can exist in before taking damage
#define NPC_DEFAULT_MAX_TEMP 350

/// Distance which you can see someone's ID card
/// Short enough that you can inspect over tables (bartender checking age)
#define ID_EXAMINE_DISTANCE 3
