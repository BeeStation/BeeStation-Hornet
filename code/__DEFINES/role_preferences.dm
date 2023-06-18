

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
#define BAN_ROLE_TRAITOR			"Traitor"
#define BAN_ROLE_OPERATIVE			"Nuclear Operative"
#define BAN_ROLE_CHANGELING			"Changeling"
#define BAN_ROLE_WIZARD				"Wizard"
//#define BAN_ROLE_MALF				"Malf AI" // Currently under traitor datum, so we can't have this separate.
#define BAN_ROLE_INCURSION			"Incursion Team"
#define BAN_ROLE_EXCOMM				"Excommunicated Syndicate Agent"
#define BAN_ROLE_REV				"Revolutionary"
#define BAN_ROLE_REV_HEAD			"Head Revolutionary"
#define BAN_ROLE_ALIEN				"Xenomorph"
#define BAN_ROLE_CULTIST			"Cultist"
#define BAN_ROLE_SERVANT_OF_RATVAR	"Servant of Ratvar"
#define BAN_ROLE_HERETIC			"Heretic"
#define BAN_ROLE_BLOB				"Blob"
#define BAN_ROLE_NINJA				"Space Ninja"
#define BAN_ROLE_ABDUCTOR			"Abductor"
#define BAN_ROLE_REVENANT			"Revenant"
#define BAN_ROLE_DEVIL				"Devil"
#define BAN_ROLE_BROTHER			"Blood Brother"
#define BAN_ROLE_OVERTHROW			"Syndicate Mutineer"
#define BAN_ROLE_HIVE				"Hivemind Host"
#define BAN_ROLE_OBSESSED			"Obsessed"
#define BAN_ROLE_SPACE_DRAGON		"Space Dragon"
#define BAN_ROLE_INTERNAL_AFFAIRS	"Internal Affairs Agent"
#define BAN_ROLE_GANG				"Gangster"
#define BAN_ROLE_HOLOPARASITE		"Holoparasite"
#define BAN_ROLE_TERATOMA			"Teratoma"
#define BAN_ROLE_SPIDER				"Spider"
#define BAN_ROLE_SWARMER			"Swarmer"
#define BAN_ROLE_MORPH				"Morph"
#define BAN_ROLE_NIGHTMARE			"Nightmare"
#define BAN_ROLE_SPACE_PIRATE		"Space Pirate"
#define BAN_ROLE_FUGITIVE			"Fugitive"
#define BAN_ROLE_FUGITIVE_HUNTER	"Fugitive Hunter"
#define BAN_ROLE_SLAUGHTER_DEMON	"Slaughter Demon"
#define BAN_ROLE_CONTRACTOR_SUPPORT_UNIT "Contractor Support Unit"
#define BAN_ROLE_PYRO_SLIME			"Pyroclastic Anomaly Slime"

/// Roles that are antagonists, roundstart or not, and have passes to do.. antagonistry
GLOBAL_LIST_INIT(antagonist_bannable_roles, list(
	BAN_ROLE_TRAITOR,
	BAN_ROLE_OPERATIVE,
	BAN_ROLE_CHANGELING,
	BAN_ROLE_WIZARD,
//	BAN_ROLE_MALF,
	BAN_ROLE_INCURSION,
	BAN_ROLE_EXCOMM,
	BAN_ROLE_REV,
	BAN_ROLE_REV_HEAD,
	BAN_ROLE_ALIEN,
	BAN_ROLE_CULTIST,
	BAN_ROLE_SERVANT_OF_RATVAR,
	BAN_ROLE_HERETIC,
	BAN_ROLE_BLOB,
	BAN_ROLE_NINJA,
	BAN_ROLE_ABDUCTOR,
	BAN_ROLE_REVENANT,
	BAN_ROLE_DEVIL,
	BAN_ROLE_BROTHER,
	BAN_ROLE_OVERTHROW,
	BAN_ROLE_HIVE,
	BAN_ROLE_OBSESSED,
	BAN_ROLE_SPACE_DRAGON,
	BAN_ROLE_INTERNAL_AFFAIRS,
	BAN_ROLE_GANG,
	BAN_ROLE_HOLOPARASITE,
	BAN_ROLE_TERATOMA,
	BAN_ROLE_SPIDER,
	BAN_ROLE_SWARMER,
	BAN_ROLE_MORPH,
	BAN_ROLE_NIGHTMARE,
	BAN_ROLE_SPACE_PIRATE,
	BAN_ROLE_FUGITIVE,
	BAN_ROLE_FUGITIVE_HUNTER,
	BAN_ROLE_SLAUGHTER_DEMON,
	BAN_ROLE_CONTRACTOR_SUPPORT_UNIT,
))

#define BAN_ROLE_FORCED_ANTAGONISTS			"Forced Antagonists"

#define BAN_ROLE_BRAINWASHED		"Brainwashed Victim"
#define BAN_ROLE_HYPNOTIZED			"Hypnotized Victim"
#define BAN_ROLE_HIVE_VESSEL		"Awakened Vessel"

/// Forced antagonist roles
GLOBAL_LIST_INIT(forced_bannable_roles, list(
	BAN_ROLE_BRAINWASHED,
	BAN_ROLE_HYPNOTIZED,
	BAN_ROLE_HIVE_VESSEL,
))

#define BAN_ROLE_ALL_GHOST	"Non-Antagonist Ghost Roles"

#define BAN_ROLE_PAI				"pAI"
#define BAN_ROLE_POSIBRAIN			"Posibrain"
#define BAN_ROLE_DRONE				"Drone"
#define BAN_ROLE_SENTIENCE			"Sentience Potion Spawn"
#define BAN_ROLE_EXPERIMENTAL_CLONE "Experimental Clone"
#define BAN_ROLE_LAVALAND_ELITE		"Lavaland Elite"
#define BAN_ROLE_SPECTRAL_BLADE		"Spectral Blade"
#define BAN_ROLE_ASHWALKER			"Ashwalker"
#define BAN_ROLE_LIFEBRINGER		"Lifebringer"
#define BAN_ROLE_FREE_GOLEM			"Free Golem"
#define BAN_ROLE_HERMIT				"Hermit"
#define BAN_ROLE_TRANSLOCATED_VET	"Translocated Vet"
#define BAN_ROLE_LAVALAND_ESCAPED_PRISONER	"Lavaland Escaped Prisoner"
#define BAN_ROLE_BEACH_BUM			"Beach Bum"
#define BAN_ROLE_HOTEL_STAFF		"Hotel Staff"
#define BAN_ROLE_LAVALAND_SYNDICATE	"Lavaland Syndicate"
#define BAN_ROLE_DEMONIC_FRIEND		"Demonic Friend"
#define BAN_ROLE_ANCIENT_CREW		"Ancient Crew"
#define BAN_ROLE_SKELETAL_REMAINS	"Skeletal Remains"
#define BAN_ROLE_SENTIENT_ANIMAL	"Sentient Animal"
#define BAN_ROLE_HOLY_SUMMONED		"Holy Summoned"
#define BAN_ROLE_SURVIVALIST		"Exploration Survivalist"
#define BAN_ROLE_EXPLORATION_VIP	"Exploration VIP"
#define BAN_ROLE_SENTIENT_XENOARTIFACT "Sentient Xenoartifiact"

/// Any ghost role that is not really an antagonist or doesn't antagonize (lavaland, sentience potion, etc)
GLOBAL_LIST_INIT(ghost_role_bannable_roles, list(
	BAN_ROLE_PAI,
	BAN_ROLE_POSIBRAIN,
	BAN_ROLE_DRONE,
	BAN_ROLE_SENTIENCE,
	BAN_ROLE_EXPERIMENTAL_CLONE,
	BAN_ROLE_LAVALAND_ELITE,
	BAN_ROLE_SPECTRAL_BLADE,
	BAN_ROLE_ASHWALKER,
	BAN_ROLE_LIFEBRINGER,
	BAN_ROLE_FREE_GOLEM,
	BAN_ROLE_HERMIT,
	BAN_ROLE_TRANSLOCATED_VET,
	BAN_ROLE_LAVALAND_ESCAPED_PRISONER,
	BAN_ROLE_BEACH_BUM,
	BAN_ROLE_HOTEL_STAFF,
	BAN_ROLE_LAVALAND_SYNDICATE,
	BAN_ROLE_DEMONIC_FRIEND,
	BAN_ROLE_ANCIENT_CREW,
	BAN_ROLE_SKELETAL_REMAINS,
	BAN_ROLE_SENTIENT_ANIMAL,
	BAN_ROLE_HOLY_SUMMONED,
))

#define BAN_ROLE_IMAGINARY_FRIEND	"Imaginary Friend"
#define BAN_ROLE_SPLIT_PERSONALITY	"Split Personality"
#define BAN_ROLE_MIND_TRANSFER		"Mind Transfer Potion"
#define BAN_ROLE_ERT				"Emergency Response Team"

/// Other roles that don't really fit any of the above, and probably shouldn't be banned with the others as a group
/// Little to no impact on anything
GLOBAL_LIST_INIT(other_bannable_roles, list(
	BAN_ROLE_IMAGINARY_FRIEND,
	BAN_ROLE_SPLIT_PERSONALITY,
	BAN_ROLE_MIND_TRANSFER,
	BAN_ROLE_ERT,
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
/// banning_key: BAN_ROLE_X used for this role - to check if the player is banned.
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
		if(!role_preference_enabled(src, role_preference_key))
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
