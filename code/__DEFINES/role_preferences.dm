

//Values for antag preferences, event roles, etc. unified here

//Hour requirements before players can choose to be specific jobs

#define MINUTES_REQUIRED_BASIC 120 			//For jobs that are easy to grief with, but not necessarily hard for new players
#define MINUTES_REQUIRED_INTERMEDIATE 600 	//For jobs that require a more detailed understanding of either the game in general, or a specific department.
#define MINUTES_REQUIRED_ADVANCED 900 		//For jobs that aren't command, but hold a similar level of importance to either their department or the round as a whole.
#define MINUTES_REQUIRED_COMMAND 1200 		//For command positions, to be weighed against the relevant department


// Banning snowflake - global antag ban. Does not include ghost roles that aren't antagonists or forced antagonists
#define BAN_ROLE_ALL_ANTAGONISTS			"All Antagonists"

//These are synced with the Database, if you change the values of the defines
//then you MUST update the database!
#define ROLE_TRAITOR			"Traitor"
#define ROLE_OPERATIVE			"Nuclear Operative"
#define ROLE_CHANGELING			"Changeling"
#define ROLE_WIZARD				"Wizard"
//#define ROLE_MALF				"Malf AI" // Currently under traitor datum, so we can't have this separate.
#define ROLE_INCURSION			"Incursion Team"
#define ROLE_EXCOMM				"Excommunicated Syndicate Agent"
#define ROLE_REV				"Revolutionary"
#define ROLE_REV_HEAD			"Head Revolutionary"
#define ROLE_ALIEN				"Xenomorph"
#define ROLE_CULTIST			"Cultist"
#define ROLE_SERVANT_OF_RATVAR	"Servant of Ratvar"
#define ROLE_HERETIC			"Heretic"
#define ROLE_BLOB				"Blob"
#define ROLE_NINJA				"Space Ninja"
#define ROLE_ABDUCTOR			"Abductor"
#define ROLE_REVENANT			"Revenant"
#define ROLE_DEVIL				"Devil"
#define ROLE_BROTHER			"Blood Brother"
#define ROLE_OVERTHROW			"Syndicate Mutineer"
#define ROLE_HIVE				"Hivemind Host"
#define ROLE_OBSESSED			"Obsessed"
#define ROLE_SPACE_DRAGON		"Space Dragon"
#define ROLE_INTERNAL_AFFAIRS	"Internal Affairs Agent"
#define ROLE_GANG				"Gangster"
#define ROLE_HOLOPARASITE		"Holoparasite"
#define ROLE_TERATOMA			"Teratoma"
#define ROLE_SPIDER				"Spider"
#define ROLE_SWARMER			"Swarmer"
#define ROLE_MORPH				"Morph"
#define ROLE_NIGHTMARE			"Nightmare"
#define ROLE_SPACE_PIRATE		"Space Pirate"
#define ROLE_FUGITIVE			"Fugitive"
#define ROLE_FUGITIVE_HUNTER	"Fugitive Hunter"
#define ROLE_SLAUGHTER_DEMON	"Slaughter Demon"
#define ROLE_CONTRACTOR_SUPPORT_UNIT "Contractor Support Unit"
#define ROLE_PYRO_SLIME			"Pyroclastic Anomaly Slime"
#define ROLE_MONKEY_HELMET		"Sentient Monkey"

/// Roles that are antagonists, roundstart or not, and have passes to do.. antagonistry
GLOBAL_LIST_INIT(antagonist_bannable_roles, list(
	ROLE_TRAITOR,
	ROLE_OPERATIVE,
	ROLE_CHANGELING,
	ROLE_WIZARD,
//	ROLE_MALF,
	ROLE_INCURSION,
	ROLE_EXCOMM,
	ROLE_REV,
	ROLE_REV_HEAD,
	ROLE_ALIEN,
	ROLE_CULTIST,
	ROLE_SERVANT_OF_RATVAR,
	ROLE_HERETIC,
	ROLE_BLOB,
	ROLE_NINJA,
	ROLE_ABDUCTOR,
	ROLE_REVENANT,
	ROLE_DEVIL,
	ROLE_BROTHER,
	ROLE_OVERTHROW,
	ROLE_HIVE,
	ROLE_OBSESSED,
	ROLE_SPACE_DRAGON,
	ROLE_INTERNAL_AFFAIRS,
	ROLE_GANG,
	ROLE_HOLOPARASITE,
	ROLE_TERATOMA,
	ROLE_SPIDER,
	ROLE_SWARMER,
	ROLE_MORPH,
	ROLE_NIGHTMARE,
	ROLE_SPACE_PIRATE,
	ROLE_FUGITIVE,
	ROLE_FUGITIVE_HUNTER,
	ROLE_SLAUGHTER_DEMON,
	ROLE_CONTRACTOR_SUPPORT_UNIT,
))

#define BAN_ROLE_FORCED_ANTAGONISTS			"Forced Antagonists"

#define ROLE_BRAINWASHED		"Brainwashed Victim"
#define ROLE_HYPNOTIZED			"Hypnotized Victim"
#define ROLE_HIVE_VESSEL		"Awakened Vessel"

/// Forced antagonist roles
GLOBAL_LIST_INIT(forced_bannable_roles, list(
	ROLE_BRAINWASHED,
	ROLE_HYPNOTIZED,
	ROLE_HIVE_VESSEL,
))

#define BAN_ROLE_ALL_GHOST	"Non-Antagonist Ghost Roles"

#define ROLE_PAI				"pAI"
#define ROLE_POSIBRAIN			"Posibrain"
#define ROLE_DRONE				"Drone"
#define ROLE_SENTIENCE			"Sentience Potion Spawn"
#define ROLE_EXPERIMENTAL_CLONE "Experimental Clone"
#define ROLE_LAVALAND_ELITE		"Lavaland Elite"
#define ROLE_SPECTRAL_BLADE		"Spectral Blade"
#define ROLE_ASHWALKER			"Ashwalker"
#define ROLE_LIFEBRINGER		"Lifebringer"
#define ROLE_FREE_GOLEM			"Free Golem"
#define ROLE_HERMIT				"Hermit"
#define ROLE_TRANSLOCATED_VET	"Translocated Vet"
#define ROLE_LAVALAND_ESCAPED_PRISONER	"Lavaland Escaped Prisoner"
#define ROLE_BEACH_BUM			"Beach Bum"
#define ROLE_HOTEL_STAFF		"Hotel Staff"
#define ROLE_LAVALAND_SYNDICATE	"Lavaland Syndicate"
#define ROLE_DEMONIC_FRIEND		"Demonic Friend"
#define ROLE_ANCIENT_CREW		"Ancient Crew"
#define ROLE_SKELETAL_REMAINS	"Skeletal Remains"
#define ROLE_SENTIENT_ANIMAL	"Sentient Animal"
#define ROLE_HOLY_SUMMONED		"Holy Summoned"
#define ROLE_SURVIVALIST		"Exploration Survivalist"
#define ROLE_EXPLORATION_VIP	"Exploration VIP"
#define ROLE_SENTIENT_XENOARTIFACT "Sentient Xenoartifiact"

/// Any ghost role that is not really an antagonist or doesn't antagonize (lavaland, sentience potion, etc)
GLOBAL_LIST_INIT(ghost_role_bannable_roles, list(
	ROLE_PAI,
	ROLE_POSIBRAIN,
	ROLE_DRONE,
	ROLE_SENTIENCE,
	ROLE_EXPERIMENTAL_CLONE,
	ROLE_LAVALAND_ELITE,
	ROLE_SPECTRAL_BLADE,
	ROLE_ASHWALKER,
	ROLE_LIFEBRINGER,
	ROLE_FREE_GOLEM,
	ROLE_HERMIT,
	ROLE_TRANSLOCATED_VET,
	ROLE_LAVALAND_ESCAPED_PRISONER,
	ROLE_BEACH_BUM,
	ROLE_HOTEL_STAFF,
	ROLE_LAVALAND_SYNDICATE,
	ROLE_DEMONIC_FRIEND,
	ROLE_ANCIENT_CREW,
	ROLE_SKELETAL_REMAINS,
	ROLE_SENTIENT_ANIMAL,
	ROLE_HOLY_SUMMONED,
))

#define ROLE_IMAGINARY_FRIEND	"Imaginary Friend"
#define ROLE_SPLIT_PERSONALITY	"Split Personality"
#define ROLE_MIND_TRANSFER		"Mind Transfer Potion"
#define ROLE_ERT				"Emergency Response Team"

/// Other roles that don't really fit any of the above, and probably shouldn't be banned with the others as a group
/// Little to no impact on anything
GLOBAL_LIST_INIT(other_bannable_roles, list(
	ROLE_IMAGINARY_FRIEND,
	ROLE_SPLIT_PERSONALITY,
	ROLE_MIND_TRANSFER,
	ROLE_ERT,
))

/// Do not ban this role. Oh my god. Please.
#define UNBANNABLE_ANTAGONIST "Unbannable"

/client/proc/role_preference_enabled(role_preference_key)
	if(!ispath(role_preference_key, /datum/role_preference))
		CRASH("Invalid role_preference_key [role_preference_key] passed to role_preference_enabled!")
	if(!src.prefs)
		return FALSE
	var/list/source = src.prefs.role_preferences
	var/datum/role_preference/pref = role_preference_key
	if(initial(pref.per_character))
		source = src.prefs.active_character.role_preferences_character
	var/role_preference_value = source["[role_preference_key]"]
	if(isnum(role_preference_value) && !role_preference_value) // explicitly disabled and not null
		return FALSE
	return TRUE

/// If the client given is fit for a given role based on the arguments passed
/// banning_key: ROLE_X used for this role - to check if the player is banned.
/// role_preference_key: The /datum/role_preference typepath to check if the player has the role enabled and would like to receive the poll.
/// poll_ignore_key: The POLL_IGNORE_X define for this role, used for temporarily disabling ghost polls for high volume roles.
/// req_hours: The amount of living hours required to receive this role.
/// feedback: if we should send a to_chat
/client/proc/should_include_for_role(banning_key = BAN_ROLE_ALL_ANTAGONISTS, role_preference_key = null, poll_ignore_key = null, req_hours = 0, feedback = FALSE)
	if(QDELETED(src) || (poll_ignore_key && GLOB.poll_ignore[poll_ignore_key] && (src.ckey in GLOB.poll_ignore[poll_ignore_key])))
		return FALSE
	if(role_preference_key)
		if(!ispath(role_preference_key, /datum/role_preference))
			CRASH("Invalid role_preference_key [role_preference_key] passed to should_include_for_role!")
		if(!src.role_preference_enabled(role_preference_key))
			return FALSE
	if(banning_key)
		if(is_banned_from(src.ckey, banning_key))
			if(feedback)
				to_chat(src, "<span class='warning'>You are banned from this role!</span>")
			return FALSE
	if(req_hours) //minimum living hour count
		if((src.get_exp_living(TRUE)/60) < req_hours)
			if(feedback)
				to_chat(src, "<span class='warning'>You do not have enough living hours to take this role ([req_hours]hrs required)!</span>")
			return FALSE
	return TRUE

/client/proc/can_take_ghost_spawner(banning_key = BAN_ROLE_ALL_ANTAGONISTS, use_cooldown = TRUE, is_ghost_role = FALSE, is_admin_spawned = FALSE)
	if(!istype(src))
		return FALSE
	if(is_ghost_role && !(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER) && !is_admin_spawned)
		to_chat(src, "<span class='warning'>An admin has temporarily disabled non-admin ghost roles!</span>")
		return FALSE
	if(!src.should_include_for_role(
		banning_key = banning_key,
		feedback = TRUE
	))
		return FALSE
	if(use_cooldown && src.next_ghost_role_tick > world.time)
		to_chat(src, "<span class='warning'>You have died recently, you must wait [(src.next_ghost_role_tick - world.time)/10] seconds until you can use a ghost spawner.</span>")
		return FALSE
	return TRUE

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEOVERFLOW 	1
#define BERANDOMJOB 	2
#define RETURNTOLOBBY 	3

#define ROLE_PREFERENCE_CATEGORY_ANAGONIST "Antagonists"
#define ROLE_PREFERENCE_CATEGORY_MIDROUND_LIVING "Midrounds (Living)"
#define ROLE_PREFERENCE_CATEGORY_MIDROUND_GHOST "Midrounds (Ghost Poll)"

GLOBAL_LIST_INIT(role_preference_entries, init_role_preference_entries())

/proc/init_role_preference_entries()
	var/list/output = list()
	for (var/datum/role_preference/preference_type as anything in subtypesof(/datum/role_preference))
		if (initial(preference_type.abstract_type) == preference_type)
			continue
		output[preference_type] = new preference_type
	return output
