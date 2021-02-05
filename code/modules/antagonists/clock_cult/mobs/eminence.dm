/mob/living/simple_animal/eminence
	name = "eminence"
	desc = "An glowing ball of light."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "eminence"
	mob_biotypes = list(MOB_SPIRIT)
	incorporeal_move = INCORPOREAL_MOVE_JAUNT
	invisibility = INVISIBILITY_OBSERVER
	health = INFINITY
	maxHealth = INFINITY
	layer = GHOST_LAYER
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
	harm_intent_damage = 0
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

	var/mob/living/selected_mob = null

	var/obj/effect/proc_holder/spell/targeted/eminence/reebe/spell_reebe
	var/obj/effect/proc_holder/spell/targeted/eminence/station/spell_station
	var/obj/effect/proc_holder/spell/targeted/eminence/mass_recall/mass_recall
	var/obj/effect/proc_holder/spell/targeted/eminence/reagent_purge/reagent_purge
	var/obj/effect/proc_holder/spell/targeted/eminence/linked_asbcond/linked_abscond

/mob/living/simple_animal/eminence/ClickOn(atom/A, params)
	. = ..()
	if(!.)
		A.eminence_act(src)

/mob/living/simple_animal/eminence/Initialize()
	. = ..()
	GLOB.clockcult_eminence = src
	spell_reebe = new
	AddSpell(spell_reebe)
	spell_station = new
	AddSpell(spell_station)
	mass_recall = new
	AddSpell(mass_recall)
	reagent_purge = new
	AddSpell(reagent_purge)
	linked_abscond = new
	AddSpell(linked_abscond)

/mob/living/simple_animal/eminence/Login()
	. = ..()
	add_servant_of_ratvar(src, silent=TRUE)
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

//Eminence abilities

/obj/effect/proc_holder/spell/targeted/eminence
	invocation = "none"
	invocation_type = "none"
	action_icon = 'icons/mob/actions/actions_clockcult.dmi'
	action_icon_state = "ratvarian_spear"
	action_background_icon_state = "bg_clock"
	clothes_req = FALSE
	charge_max = 0
	cooldown_min = 0
	range = -1
	include_user = TRUE

//=====Warp to Reebe=====
/obj/effect/proc_holder/spell/targeted/eminence/reebe
	name = "Jump to Reebe"
	desc = "Teleport yourself to Reebe."
	action_icon_state = "Abscond"

/obj/effect/proc_holder/spell/targeted/eminence/reebe/cast(list/targets, mob/living/user)
	user.forceMove(get_turf(GLOB.celestial_gateway))

//=====Warp to station=====
/obj/effect/proc_holder/spell/targeted/eminence/station
	name = "Jump to Station"
	desc = "Teleport yourself to the station."
	action_icon_state = "warp_down"

/obj/effect/proc_holder/spell/targeted/eminence/station/cast(list/targets, mob/living/user)
	user.forceMove(SSmapping.get_station_center())

//=====Mass Recall=====
/obj/effect/proc_holder/spell/targeted/eminence/mass_recall
	name = "Initiate Mass Recall"
	desc = "Initiates a mass recall, warping everyone to the Ark."
	action_icon_state = "Spatial Gateway"

/obj/effect/proc_holder/spell/targeted/eminence/mass_recall/cast(list/targets, mob/living/user)
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/C = GLOB.celestial_gateway
	if(!C)
		return
	C.begin_mass_recall()
	user.RemoveSpell(src)

//=====Purge Reagents=====
/obj/effect/proc_holder/spell/targeted/eminence/reagent_purge
	name = "Purge Reagents"
	desc = "Purges all the reagents from a selected target. You must select a target by left clicking on them first."
	action_icon_state = "Mending Mantra"
	charge_max = 300

/obj/effect/proc_holder/spell/targeted/eminence/reagent_purge/can_cast(mob/user)
	if(!..())
		return FALSE
	var/mob/living/simple_animal/eminence/E = user
	if(!istype(E))
		return FALSE
	if(E.selected_mob && is_servant_of_ratvar(E.selected_mob))
		return TRUE
	return FALSE

/obj/effect/proc_holder/spell/targeted/eminence/reagent_purge/cast(list/targets, mob/living/user)
	var/mob/living/simple_animal/eminence/E = user
	if(!istype(E))
		revert_cast(user)
		return FALSE
	if(!E.selected_mob || !is_servant_of_ratvar(E.selected_mob))
		E.selected_mob = null
		to_chat(user, "<span class='neovgre'>You need to select a valid target by clicking on them.</span>")
		revert_cast(user)
		return FALSE
	var/mob/living/L = E.selected_mob
	if(!istype(L))
		revert_cast(user)
		return FALSE
	L.reagents?.clear_reagents()
	to_chat(user, "<span class='inathneq'>You clear the reagents from [L]!</span>")
	to_chat(L, "<span class='inathneq'>The Eminence has purified your blood!</span>")
	return TRUE

//=====Linked Abscond=====
/obj/effect/proc_holder/spell/targeted/eminence/linked_asbcond
	name = "Linked Abscond"
	desc = "Warps a target to Reebe if they are still for 7 seconds."
	action_icon_state = "Linked Abscond"
	charge_max = 4500

/obj/effect/proc_holder/spell/targeted/eminence/linked_asbcond/can_cast(mob/user)
	if(!..())
		return FALSE
	var/mob/living/simple_animal/eminence/E = user
	if(!istype(E))
		return FALSE
	if(E.selected_mob && is_servant_of_ratvar(E.selected_mob))
		return TRUE
	return FALSE

/obj/effect/proc_holder/spell/targeted/eminence/linked_asbcond/cast(list/targets, mob/living/user)
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
		L.visible_message("<span class='warning'>[L] phases out of existance!</span>")
		var/turf/T = get_turf(pick(GLOB.servant_spawns))
		try_warp_servant(L, T, FALSE)
		return TRUE
	else
		to_chat(E, "<span class='brass'>You fail to recall [L].</span>")
		revert_cast(user)
		return FALSE
