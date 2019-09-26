GLOBAL_VAR_INIT(pocket_dim, 1)
/area/hippie/pocket_dimension
	name = "??? INVALID COORDINATES ???"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = STANDARD_GRAVITY
	noteleport = TRUE
	unique = FALSE
	requires_power = FALSE

/datum/guardian_ability/major/special/pocket
	name = "Pocket Dimension"
	desc = "The guardian can access a small pocket dimension, bringing it's owner with it as well."
	cost = 5
	spell_type = /obj/effect/proc_holder/spell/self/pocket_dim

/datum/guardian_ability/major/special/pocket/Apply()
	if(!LAZYLEN(guardian.pocket_dim))
		var/list/errorList = list()
		var/pocket_dim = SSmapping.LoadGroup(errorList, "Pocket Dimension [GLOB.pocket_dim]", "templates", "pocket_dimension.dmm", default_traits = list("Pocket Dimension" = TRUE, "Pocket Dimension [GLOB.pocket_dim]" = TRUE, ZTRAIT_BOMBCAP_MULTIPLIER = 0), silent = TRUE)
		if(errorList.len)	// reebe failed to load
			message_admins("A pocket dimension failed to load!")
			log_game("A pocket dimension failed to load!")
			return FALSE
		for(var/datum/parsed_map/PM in pocket_dim)
			PM.initTemplateBounds()
		guardian.pocket_dim = "Pocket Dimension [GLOB.pocket_dim]"
		GLOB.pocket_dim++
	. = ..()
	var/obj/effect/proc_holder/spell/self/pocket_dim/S = spell
	if(S && istype(S))
		S.guardian = guardian
		var/turf/T = get_turf(guardian)
		S.last_x = T.x
		S.last_y = T.y
		S.last_z = T.z


/obj/effect/proc_holder/spell/self/pocket_dim
	name = "Pocket Dimension"
	desc = "You and your master enter a special pocket dimension, where you are invincible and immortal."
	clothes_req = FALSE
	staff_req = FALSE
	human_req = FALSE
	charge_max = 30 SECONDS
	action_icon = 'icons/obj/objects.dmi'
	action_icon_state = "anom"
	var/last_x
	var/last_y
	var/last_z
	var/mob/living/simple_animal/hostile/guardian/guardian

/obj/effect/proc_holder/spell/self/pocket_dim/cast(list/targets, mob/living/user)
	if(!guardian || !istype(guardian))
		return
	var/mob/living/L = guardian.summoner
	if(!guardian.pocket_dim)
		to_chat("<span class='red bold'>ERROR: You do not have a pocket dimension generated! Report this bug on Github!</span>")
		return
	var/list/zs = SSmapping.levels_by_trait(guardian.pocket_dim)
	if(!LAZYLEN(zs))
		to_chat("<span class='red bold'>ERROR: You have a pocket dimension generated, but it doesn't exist? Report this bug on Github!</span>")
		return
	var/pocket = zs[1]
	var/pull_the_pulling_thing_too = TRUE
	if(isliving(L.pulling) && L.grab_state < GRAB_NECK)
		pull_the_pulling_thing_too = FALSE
	new /obj/effect/temp_visual/bluespace_fissure(get_turf(L))
	if(SSmapping.level_trait(L.z, "Pocket Dimension"))
		if(last_x && last_y && last_z)
			L.forceMove(get_turf(L))
			take_effects(L)
			L.x = last_x
			L.y = last_y
			L.z = last_z
			if(pull_the_pulling_thing_too && L.pulling)
				L.pulling.x = last_x
				L.pulling.y = last_y
				L.pulling.z = last_z
			L.visible_message("<span class='danger'>[L]'s body suddenly swirls into existence, [(pull_the_pulling_thing_too && L.pulling) ? "bringing [L.pulling] with it, " : ""]as if emerging from a vortex!</span>")
			charge_counter = 0
	else
		L.forceMove(get_turf(L))
		L.visible_message("<span class='danger'>[L]'s body swirls up and disappears, [(pull_the_pulling_thing_too && L.pulling) ? "pulling [L.pulling] in with it, " : ""]as if sucked into a vortex!</span>")
		last_x = L.x
		last_y = L.y
		last_z = L.z
		add_effects(L)
		L.x = 4
		L.y = 4
		L.z = pocket
		if(pull_the_pulling_thing_too && L.pulling)
			if(ishuman(L.pulling))
				var/mob/living/carbon/human/HP = L.pulling
			L.pulling.x = 4
			L.pulling.y = 4
			L.pulling.z = pocket
		charge_counter = charge_max

/obj/effect/proc_holder/spell/self/pocket_dim/proc/check_if_teleport(mob/living/L)
	var/list/zs = SSmapping.levels_by_trait(guardian.pocket_dim)
	if(!LAZYLEN(zs))
		return
	var/pocket = zs[1]
	if(L.z != pocket)
		take_effects(L)

/obj/effect/proc_holder/spell/self/pocket_dim/proc/add_effects(mob/living/L)
	L.status_flags |= GODMODE
	RegisterSignal(L, COMSIG_MOVABLE_MOVED, .proc/check_if_teleport)
	for(var/mob/living/simple_animal/hostile/guardian/G in L.hasparasites())
		G.Recall(TRUE)
		G.status_flags |= GODMODE

/obj/effect/proc_holder/spell/self/pocket_dim/proc/take_effects(mob/living/L)
	L.status_flags &= ~GODMODE
	UnregisterSignal(L, COMSIG_MOVABLE_MOVED)
	for(var/mob/living/simple_animal/hostile/guardian/G in L.hasparasites())
		G.Recall(TRUE)
		G.status_flags &= ~GODMODE
