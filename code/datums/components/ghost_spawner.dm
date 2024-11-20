
#define GHOST_SPAWNER_MURDERBONE "You are a smart, but primitive being. You kill either out of instinct, fear, or to protect your race. Protect yourself, your allies and survive no matter the cost."
#define GHOST_SPAWNER_NEUTRAL "Your story is yours and yours alone, you are a neutral being that exists to serve its own goals and desires. You may find allies along the way, or betray those in order to climb higher. Whatever you do, it should be done out of the desire to survive."
#define GHOST_SPAWNER_STATION "You are a creature of the station, help and protect your friends from danger!"
#define GHOST_SPAWNER_HOSTILE "The station operates as normal while injustice spreads across the world like a plague. Whatever your motive, your actions should be driven by it and it should push your story forward."
#define GHOST_SPAWNER_SLAVE "You exist to serve your master. Your master's goals are your goals and you pledge eternal servitude towards them."

#define GHOST_SPAWN_UNABLE 0
#define GHOST_SPAWN_CLIENT_LOCKED 1
#define GHOST_SPAWN_ABLE 2

/**
 * Attaching this component to an object will cause observers to be able to interact with
 * to spawn in as a provided mob.
 */

/datum/component/ghost_spawner
	/// What ban setting to use for the spawner
	var/ban_key
	/// If this is set, then upon activation the owner will be deleted
	/// and this will be spawned instead.
	var/spawned_type = null
	/// If you want to create the mob via a proc instead, then use this.
	/// Arguments: mob/user (person performing the action)
	/// Only executed if we are attached to a structure
	var/datum/callback/spawn_proc = null
	/// If a spawner is set to unique, then it will show up multiple times
	/// for each individual spawner on the ghost alert. Otherwise they will
	/// be grouped together and players will be distributed amongst the available
	/// mobs for that type (A unique alert will not appear if another exists at the
	/// same time, which prevents spamming)
	var/unique = FALSE
	/// If we are using a spawned type, should we delete the parent after spawning?
	var/remove_after_spawn = FALSE
	/// Flavour message to be shown upon spawn
	var/flavour_message = null
	/// If set, we will become bound to this mob upon spawning
	var/datum/mind/master = null
	/// If set
	/// Have we alerted already?
	var/_alerted = FALSE

/datum/component/ghost_spawner/Initialize(
		ban_key,
		unique = FALSE,
		spawned_type = null,
		datum/callback/spawn_proc = null,
		remove_after_spawn = TRUE,
		flavour_message = GHOST_SPAWNER_NEUTRAL,
		mob/living/master = null,
		)
	if (spawned_type && !ispath(spawned_type, /mob/living))
		stack_trace("Attempted to create a ghost spawner with an invalid spawned type, the spawned type must be a typepath derived from /mob/living.")
		return COMPONENT_INCOMPATIBLE
	src.ban_key = ban_key
	src.spawned_type = spawned_type
	src.unique = unique
	src.remove_after_spawn = remove_after_spawn
	src.master = master
	src.flavour_message = flavour_message
	src.spawn_proc = spawn_proc

/datum/component/ghost_spawner/RegisterWithParent()
	var/mob/living/parent_mob = parent
	raise_spawner_alert()
	// Handle the attack
	RegisterSignal(parent_mob, COMSIG_ATOM_ATTACK_GHOST, PROC_REF(on_ghost_interaction))
	RegisterSignal(parent_mob, COMSIG_LIVING_DEATH, PROC_REF(on_mob_death))
	RegisterSignal(parent_mob, COMSIG_MOB_GHOSTIZE, PROC_REF(on_mob_ghost))

/datum/component/ghost_spawner/UnregisterFromParent()
	var/mob/living/parent_mob = parent
	parent_mob.RemoveElement(/datum/element/point_of_interest)
	remove_from_spawner_menu()
	UnregisterSignal(parent_mob, COMSIG_ATOM_ATTACK_GHOST)

/datum/component/ghost_spawner/proc/remove_from_spawner_menu()
	_alerted = FALSE
	for(var/spawner in GLOB.mob_spawners)
		GLOB.mob_spawners[spawner] -= parent
		if(!length(GLOB.mob_spawners[spawner]))
			GLOB.mob_spawners -= spawner
	SSmobs.update_spawners()

/datum/component/ghost_spawner/proc/on_mob_ghost(datum/source, can_reenter_corpse, sentience_retention)
	SIGNAL_HANDLER
	if (sentience_retention == SENTIENCE_SKIP)
		return
	if (sentience_retention == SENTIENCE_ERASE)
		qdel(src)
		return
	raise_spawner_alert(TRUE)

/// When the mob dies, remove from the spawner menu but don't remove this
/// component.
/datum/component/ghost_spawner/proc/on_mob_death()
	SIGNAL_HANDLER
	remove_from_spawner_menu()

/datum/component/ghost_spawner/proc/raise_spawner_alert(ignore_key = FALSE)
	var/mob/living/parent_mob = parent
	// Don't showcase dead mobs that become controllable
	if (istype(parent_mob) && ((!ignore_key && parent_mob.key) || parent_mob.stat == DEAD))
		return
	if (_alerted)
		return
	_alerted = TRUE
	// Send out the notification
	notify_ghosts(
		"[parent_mob.name] can be controlled",
		enter_link="<a href=?src=[REF(src)];activate=1>(Click to play)</a>",
		source=parent_mob,
		action=NOTIFY_ATTACK,
		notification_key=unique ? "[REF(parent_mob)]_notify_action" : "[parent_mob.type]_notify_action"
		)
	// Add the spawner
	// Use the initial name if it has random numbers at the end of the name
	LAZYADD(GLOB.mob_spawners[get_source_name()], parent_mob)
	parent_mob.AddElement(/datum/element/point_of_interest)
	SSmobs.update_spawners()

/datum/component/ghost_spawner/proc/on_ghost_interaction(datum/source, mob/dead/observer/ghost, direct)
	SIGNAL_HANDLER
	// Check if we need to hand off to a group
	if (!unique && !direct)
		spawn_into_group(ghost)
	else
		// Spawn into the specific mob
		spawn_into_mob(ghost, parent)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/ghost_spawner/proc/spawn_into_group(mob/dead/observer/player)
	set waitfor = FALSE
	// Find an uninhabited mob from the group that we can spawn in
	var/list/mob_spawn_group = GLOB.mob_spawners[get_source_name()]
	if (!mob_spawn_group)
		return
	if (!player.client)
		return
	var/atom/closest_mob = null
	var/closest_distance = INFINITY
	// Order by the ones closest to the player
	for (var/atom/target in mob_spawn_group)
		var/distance = get_dist(target, player)
		if (distance > closest_distance)
			continue
		switch (can_become_role(player.client, target))
			if (GHOST_SPAWN_UNABLE)
				continue
			if (GHOST_SPAWN_CLIENT_LOCKED)
				return
		closest_mob = target
		closest_distance = distance
	if (!closest_mob)
		return
	// Will perform the role check again to safely handle sleeping code
	spawn_into_mob(player, closest_mob)

/datum/component/ghost_spawner/proc/spawn_into_mob(mob/dead/observer/player, atom/target)
	set waitfor = FALSE
	if (!player.client)
		return
	var/mob/living/parent_mob = target
	if (istype(parent_mob))
		if (can_become_role(player.client, parent_mob) != GHOST_SPAWN_ABLE)
			return
	else
		if (can_become_role(player.client, null) != GHOST_SPAWN_ABLE)
			return
	var/needs_sentience = FALSE
	// If the parent is not a mob, then delete it if necessary
	if (!istype(parent_mob))
		var/atom/parent_atom = parent
		if (spawn_proc)
			parent_mob = spawn_proc.Invoke(player)
			if (!parent_mob)
				return
			if (remove_after_spawn)
				qdel(parent)
		else
			parent_mob = new spawned_type(parent_atom.loc)
			if (remove_after_spawn)
				qdel(parent)
		needs_sentience = TRUE
	// Perform the spawning
	parent_mob.key = player.key
	log_game("[key_name(player)] took control of [parent_mob.name] ([parent_mob.type]) at [COORD(parent_mob)].")
	remove_from_spawner_menu()
	var/list/spawn_message = list()
	spawn_message += "<span class='big bold spawn_header'>You are [parent_mob.name]!</span>"
	// Setup master stuff
	if (!parent_mob.mind)
		parent_mob.mind_initialize()
	// Master overrides flavour text
	if (master)
		parent_mob.mind.enslave_mind_to_creator(master)
		log_game("[key_name(parent_mob)] had their master set to '[master.name]'")
		spawn_message += "Your master is [master.name], serve them. They may not be an antagonist, and you should not act like one unless otherwise told."
	else
		spawn_message += flavour_message
	spawn_message += "<font color='red'>Please do not use memories from previous lives!</font>"
	to_chat(parent_mob, "<span class='spawn_message'>[jointext(spawn_message, "<br />")]</span>")
	parent_mob.sentience_act()
	// Add the spawner to the sentience mob
	if (needs_sentience)
		parent_mob.AddComponent(/datum/component/ghost_spawner, ban_key, FALSE, flavour_message=flavour_message, master=master)

/datum/component/ghost_spawner/proc/can_become_role(client/user, atom/target)
	// This sleeps if the DB call isn't cached, so do it first
	if (!user.can_take_ghost_spawner(ban_key, TRUE, target && (target.flags_1 & ADMIN_SPAWNED_1)))
		return GHOST_SPAWN_CLIENT_LOCKED
	if (!SSticker.HasRoundStarted())
		return GHOST_SPAWN_CLIENT_LOCKED
	if (!user)
		return GHOST_SPAWN_UNABLE
	var/mob/living/living_target = target
	if (istype(living_target) && living_target.key)
		return GHOST_SPAWN_UNABLE
	return GHOST_SPAWN_ABLE

/datum/component/ghost_spawner/Topic(href, list/href_list)
	if (..())
		return TRUE
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			on_ghost_interaction(parent, ghost, FALSE)

/datum/component/ghost_spawner/proc/get_source_name()
	var/mob/living/parent_mob = parent
	if (!istype(parent_mob))
		. = "[parent_mob.name]"
	else
		. = (parent_mob.unique_name && !unique) ? initial(parent_mob.name) : parent_mob.name
	if (master)
		. += " (Master: [master.name])"
