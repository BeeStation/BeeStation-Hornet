/mob/living/simple_animal/eminence
	name = "the Eminence"
	desc = "A glowing ball of light."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "eminence"
	mob_biotypes = list(MOB_SPIRIT)
	incorporeal_move = INCORPOREAL_MOVE_EMINENCE
	invisibility = INVISIBILITY_SPIRIT
	health = INFINITY
	maxHealth = INFINITY
	plane = GHOST_PLANE
	healable = FALSE
	spacewalk = TRUE
	sight = SEE_SELF
	throwforce = 0

	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	unsuitable_atmos_damage = 0
	damage_coeff = list(BRUTE = 0, BURN = 0, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	status_flags = 0
	wander = FALSE
	density = FALSE
	movement_type = FLYING
	move_resist = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	speed = 1
	unique_name = FALSE
	hud_possible = list(ANTAG_HUD)
	hud_type = /datum/hud/revenant

	var/calculated_cogs = 0
	var/cogs = 0
	var/obj/item/radio/borg/eminence/internal_radio

	var/mob/living/selected_mob = null

	var/obj/effect/proc_holder/spell/targeted/eminence/reebe/spell_reebe
	var/obj/effect/proc_holder/spell/targeted/eminence/station/spell_station
	var/obj/effect/proc_holder/spell/targeted/eminence/servant_warp/spell_servant_warp
	var/obj/effect/proc_holder/spell/targeted/eminence/mass_recall/mass_recall
	var/obj/effect/proc_holder/spell/targeted/eminence/linked_abscond/linked_abscond
	var/obj/effect/proc_holder/spell/targeted/eminence/trigger_event/trigger_event

/mob/living/simple_animal/eminence/ClickOn(atom/A, params)
	. = ..()
	if(!.)
		A.eminence_act(src)

/mob/living/simple_animal/eminence/proc/cog_change()
	//Calculate cogs
	if(calculated_cogs != GLOB.installed_integration_cogs)
		var/difference = GLOB.installed_integration_cogs - calculated_cogs
		calculated_cogs += difference
		cogs += difference
		to_chat(src, "<span class='brass'>You have gained [difference] cogs!</span>")

//Cannot gib the eminence.
/mob/living/simple_animal/eminence/gib()
	return

/mob/living/simple_animal/eminence/UnarmedAttack(atom/A)
	return FALSE

/mob/living/simple_animal/eminence/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	return FALSE

/mob/living/simple_animal/eminence/rad_act(amount)
	return

/mob/living/simple_animal/eminence/Initialize(mapload)
	. = ..()
	GLOB.clockcult_eminence = src
	//Add spells
	spell_reebe = new
	AddSpell(spell_reebe)
	spell_station = new
	AddSpell(spell_station)
	spell_servant_warp = new
	AddSpell(spell_servant_warp)
	mass_recall = new
	AddSpell(mass_recall)
	linked_abscond = new
	AddSpell(linked_abscond)
	trigger_event = new
	AddSpell(trigger_event)
	//Wooooo, you are a ghost
	AddComponent(/datum/component/tracking_beacon, "ghost", null, null, TRUE, "#9e4d91", TRUE, TRUE, "#490066")
	internal_radio = new(src)
	cog_change()

/mob/living/simple_animal/eminence/Destroy()
	. = ..()
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(beacon)
		qdel(beacon)

/mob/living/simple_animal/eminence/Login()
	. = ..()
	var/datum/antagonist/servant_of_ratvar/S = add_servant_of_ratvar(src, silent=TRUE)
	S.prefix = CLOCKCULT_PREFIX_EMINENCE
	to_chat(src, "<span class='large_brass'>You are the Eminence!</span>")
	to_chat(src, "<span class='brass'>Click on objects to perform actions, different objects have different actions, try them out!</span>")
	to_chat(src, "<span class='brass'>Many of your spells require a target first. Click on a servant to select them!</span>")

/mob/living/simple_animal/eminence/say_verb(message as text)
	set name = "Say"
	set category = "IC"
	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return
	if(message)
		hierophant_message(message, src, span="<span class='large_brass'>", say=FALSE)

/mob/living/simple_animal/eminence/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced)
	return FALSE

/mob/living/simple_animal/eminence/Move(atom/newloc, direct)
	if(istype(get_area(newloc), /area/chapel))
		to_chat(usr, "<span class='warning'>You cannot move on to holy grounds!</span>")
		return
	. = ..()

/mob/living/simple_animal/eminence/bullet_act(obj/item/projectile/Proj)
	return BULLET_ACT_FORCE_PIERCE

/mob/living/simple_animal/eminence/proc/run_global_event(datum/round_event_control/E)
	E.preRunEvent()
	E.runEvent()
	SSevents.reschedule()

/mob/living/simple_animal/eminence/get_stat_tab_status()
	var/list/tab_data = ..()
	tab_data["Cogs Available"] = GENERATE_STAT_TEXT("[cogs] Cogs")
	return tab_data

/mob/living/simple_animal/eminence/update_health_hud()
	return

/mob/living/simple_animal/eminence/flash_act(intensity, override_blindness_check, affect_silicon, visual, type)
	return

//Eminence abilities

/obj/effect/proc_holder/spell/targeted/eminence
	invocation = "none"
	invocation_type = INVOCATION_NONE
	action_icon = 'icons/mob/actions/actions_clockcult.dmi'
	action_icon_state = "ratvarian_spear"
	action_background_icon_state = "bg_clock"
	clothes_req = FALSE
	charge_max = 0
	cooldown_min = 0
	range = -1
	include_user = TRUE
	var/cog_cost

/obj/effect/proc_holder/spell/targeted/eminence/can_cast(mob/user)
	. = ..()
	var/mob/living/simple_animal/eminence/eminence = user
	if(!istype(eminence))
		return FALSE
	if(eminence.cogs < cog_cost)
		return FALSE

/obj/effect/proc_holder/spell/targeted/eminence/proc/consume_cogs(mob/living/simple_animal/eminence/eminence)
	eminence.cogs -= cog_cost

//=====Warp to Reebe=====
/obj/effect/proc_holder/spell/targeted/eminence/reebe
	name = "Jump to Reebe"
	desc = "Teleport yourself to Reebe."
	action_icon_state = "Abscond"

/obj/effect/proc_holder/spell/targeted/eminence/reebe/cast(mob/living/user)
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.celestial_gateway
	if(G)
		user.abstract_move(get_turf(G))
		SEND_SOUND(user, sound('sound/magic/magic_missile.ogg'))
		flash_color(user, flash_color = "#AF0AAF", flash_time = 25)
	else
		to_chat(user, "<span class='warning'>There is no Ark!</span>")

//=====Warp to station=====
/obj/effect/proc_holder/spell/targeted/eminence/station
	name = "Jump to Station"
	desc = "Teleport yourself to the station."
	action_icon_state = "warp_down"

/obj/effect/proc_holder/spell/targeted/eminence/station/cast(mob/living/user)
	if(!is_station_level(user.z))
		user.abstract_move(get_turf(pick(GLOB.generic_event_spawns)))
		SEND_SOUND(user, sound('sound/magic/magic_missile.ogg'))
		flash_color(user, flash_color = "#AF0AAF", flash_time = 25)
	else
		to_chat(user, "<span class='warning'>You're already on the station!</span>")

//=====Teleport to servant=====
/obj/effect/proc_holder/spell/targeted/eminence/servant_warp
	name = "Jump to Servant"
	desc = "Teleport yourself to a specific servant."
	action_icon_state = "Spatial Warp"

/obj/effect/proc_holder/spell/targeted/eminence/servant_warp/cast(list/targets, mob/user)
	//Get a list of all servants
	var/datum/mind/choice = input(user, "Select servant", "Warp to...", null) in GLOB.all_servants_of_ratvar
	var/mob/living/M
	if(!choice)
		return
	M = choice.current
	if(!isliving(M))
		to_chat(user, "<span class='warning'>You cannot jump to them!</span>")
		return
	if(!is_servant_of_ratvar(M))
		to_chat(user, "<span class='warning'>They are no longer a servant of Rat'var!</span>")
		return
	var/turf/T = get_turf(M)
	if(SSmapping.level_trait(T.z, ZTRAIT_CENTCOM))
		to_chat(user, "<span class='warning'>They are out of your reach!</span>")
		return
	user.forceMove(get_turf(T))
	SEND_SOUND(user, sound('sound/magic/magic_missile.ogg'))
	flash_color(user, flash_color = "#AF0AAF", flash_time = 25)

//=====Mass Recall=====
/obj/effect/proc_holder/spell/targeted/eminence/mass_recall
	name = "Initiate Mass Recall"
	desc = "Initiates a mass recall, warping everyone to the Ark. Can only be used 1 time."
	action_icon_state = "Spatial Gateway"

/obj/effect/proc_holder/spell/targeted/eminence/mass_recall/cast(list/targets, mob/living/user)
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/C = GLOB.celestial_gateway
	if(!C)
		return
	C.begin_mass_recall()
	user.RemoveSpell(src)

//=====Linked Abscond=====
/obj/effect/proc_holder/spell/targeted/eminence/linked_abscond
	name = "Linked Abscond"
	desc = "Warps a target to Reebe if they are still for 7 seconds. Costs 1 cog."
	action_icon_state = "Linked Abscond"
	charge_max = 1800
	cog_cost = 1

/obj/effect/proc_holder/spell/targeted/eminence/linked_abscond/can_cast(mob/user)
	if(!..())
		return FALSE
	var/mob/living/simple_animal/eminence/E = user
	if(!istype(E))
		return FALSE
	if(E.selected_mob && is_servant_of_ratvar(E.selected_mob))
		return TRUE
	return FALSE

/obj/effect/proc_holder/spell/targeted/eminence/linked_abscond/cast(list/targets, mob/living/user)
	var/mob/living/simple_animal/eminence/E = user
	if(!istype(E))
		to_chat(E, "<span class='brass'>You are not the Eminence! (This is a bug)</span>")
		revert_cast(user)
		return FALSE
	if(!E.selected_mob || !is_servant_of_ratvar(E.selected_mob))
		E.selected_mob = null
		to_chat(user, "<span class='neovgre'>You need to select a valid target by clicking on them.</span>")
		revert_cast(user)
		return FALSE
	var/mob/living/L = E.selected_mob
	if(!istype(L))
		to_chat(E, "<span class='brass'>You cannot do that on this mob!</span>")
		revert_cast(user)
		return FALSE
	to_chat(E, "<span class='brass'>You begin recalling [L]...</span>")
	to_chat(L, "<span class='brass'>The Eminence is summoning you...</span>")
	L.visible_message("<span class='warning'>[L] flares briefly.</span>")
	if(do_after(E, 70, target=L))
		L.visible_message("<span class='warning'>[L] phases out of existence!</span>")
		var/turf/T = get_turf(pick(GLOB.servant_spawns))
		try_warp_servant(L, T, FALSE)
		consume_cogs(E)
		return TRUE
	else
		to_chat(E, "<span class='brass'>You fail to recall [L].</span>")
		revert_cast(user)
		return FALSE

//Trigger event
/obj/effect/proc_holder/spell/targeted/eminence/trigger_event
	name = "Manipulate Reality"
	desc = "Manipulate reality causing global events to occur. Costs 5 cogs"
	action_icon_state = "Geis"
	charge_max = 3000
	cog_cost = 5

/obj/effect/proc_holder/spell/targeted/eminence/trigger_event/cast(list/targets, mob/user)
	var/picked_event = input(user, "Pick an event to run", "Manipulate Reality", null) in list(
		"Anomaly",
		"Brand Intelligence",
		"Camera Failure",
		"Communications Blackout",
		"Disease Outbreak",
		"Electrical Storm",
		"False Alarm",
		"Grid Check",
		"Mass Hallucination",
		"Processor Overload"
	)
	if(!picked_event)
		revert_cast(user)
		return
	if(picked_event == "Anomaly")
		picked_event = pick("Anomaly: Energetic Flux", "Anomaly: Pyroclastic", "Anomaly: Gravitational", "Anomaly: Bluespace")
	//Reschedule events
	//Get the picked event
	for(var/datum/round_event_control/E in SSevents.control)
		if(E.name == picked_event)
			var/mob/living/simple_animal/eminence/eminence = user
			INVOKE_ASYNC(eminence, TYPE_PROC_REF(/mob/living/simple_animal/eminence, run_global_event), E)
			consume_cogs(user)
			return
	revert_cast(user)

//Internal Radio
/obj/item/radio/borg/eminence
	name = "eminence internal listener"
	desc = "if you can see this, call a coder"
	canhear_range = 0
	radio_silent = TRUE
	prison_radio = TRUE
	broadcasting = TRUE
