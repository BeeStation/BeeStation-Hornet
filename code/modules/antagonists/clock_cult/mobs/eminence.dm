/mob/living/simple_animal/eminence
	name = "the Eminence"
	desc = "A glowing ball of light."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "eminence"
	mob_biotypes = MOB_SPIRIT
	incorporeal_move = INCORPOREAL_MOVE_EMINENCE
	invisibility = INVISIBILITY_SPIRIT
	health = INFINITY
	maxHealth = INFINITY
	plane = GHOST_PLANE
	healable = FALSE
	sight = SEE_SELF
	throwforce = 0

	see_in_dark = NIGHTVISION_FOV_RANGE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	unsuitable_atmos_damage = 0
	damage_coeff = list(BRUTE = 0, BURN = 0, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	status_flags = 0
	wander = FALSE
	density = FALSE
	is_flying_animal = TRUE
	no_flying_animation = TRUE
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

	var/datum/action/spell/eminence/reebe/spell_reebe
	var/datum/action/spell/eminence/station/spell_station
	var/datum/action/spell/eminence/servant_warp/spell_servant_warp
	var/datum/action/spell/eminence/mass_recall/mass_recall
	var/datum/action/spell/eminence/linked_abscond/linked_abscond
	var/datum/action/spell/eminence/trigger_event/trigger_event

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
		to_chat(src, span_brass("You have gained [difference] cogs!"))

//Cannot gib the eminence.
/mob/living/simple_animal/eminence/gib()
	return

/mob/living/simple_animal/eminence/UnarmedAttack(atom/A, proximity_flag, modifiers)
	return FALSE

/mob/living/simple_animal/eminence/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	return FALSE

/mob/living/simple_animal/eminence/Initialize(mapload)
	. = ..()
	GLOB.clockcult_eminence = src
	//Add spells

	spell_reebe = new
	spell_reebe.Grant(src)
	spell_station = new
	spell_station.Grant(src)
	spell_servant_warp = new
	spell_servant_warp.Grant(src)
	mass_recall = new
	mass_recall.Grant(src)
	linked_abscond = new
	linked_abscond.Grant(src)
	trigger_event = new
	trigger_event.Grant(src)
	//Wooooo, you are a ghost
	AddComponent(/datum/component/tracking_beacon, "ghost", null, null, TRUE, "#9e4d91", TRUE, TRUE, "#490066")
	internal_radio = new(src)

	cogs = GLOB.installed_integration_cogs

	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)

/mob/living/simple_animal/eminence/Destroy()
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(beacon)
		qdel(beacon)
	. = ..()

/mob/living/simple_animal/eminence/Login()
	. = ..()
	if(!.)
		return
	if(!client)
		return

	var/datum/antagonist/servant_of_ratvar/S = add_servant_of_ratvar(src, silent=TRUE)
	S.prefix = CLOCKCULT_PREFIX_EMINENCE
	to_chat(src, span_largebrass("You are the Eminence!"))
	to_chat(src, span_brass("Click on objects to perform actions, different objects have different actions, try them out!"))
	to_chat(src, span_brass("Many of your spells require a target first. Click on a servant to select them!"))

/mob/living/simple_animal/eminence/say_verb(message as text)
	set name = "Say"
	set category = "IC"
	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return
	if(message)
		hierophant_message(message, src, span="<span class='large_brass'>", say=FALSE)

/mob/living/simple_animal/eminence/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced)
	return FALSE

/mob/living/simple_animal/eminence/Move(atom/newloc, direct)
	if(istype(get_area(newloc), /area/chapel))
		to_chat(usr, span_warning("You cannot move on to holy grounds!"))
		return
	. = ..()

/mob/living/simple_animal/eminence/bullet_act(obj/projectile/Proj)
	return BULLET_ACT_FORCE_PIERCE

/mob/living/simple_animal/eminence/proc/run_global_event(datum/round_event_control/E)
	E.preRunEvent()
	E.runEvent()
	SSevents.reschedule()

/mob/living/simple_animal/eminence/get_stat_tab_status()
	var/list/tab_data = ..()
	tab_data["Cogs Available"] = GENERATE_STAT_TEXT("[cogs] Cogs")
	return tab_data

/mob/living/simple_animal/eminence/med_hud_set_health()
	return

/mob/living/simple_animal/eminence/med_hud_set_status()
	return

/mob/living/simple_animal/eminence/update_health_hud()
	return

/mob/living/simple_animal/eminence/flash_act(intensity, override_blindness_check, affect_silicon, visual, type)
	return

//Internal Radio
/obj/item/radio/borg/eminence
	name = "eminence internal listener"
	desc = "if you can see this, call a coder"
	canhear_range = 0
	radio_noise = FALSE
	prison_radio = TRUE


/obj/item/radio/borg/eminence/Initialize(mapload)
	. = ..()
	set_broadcasting(TRUE)
