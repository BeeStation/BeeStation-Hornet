#define INTERDICTION_LENS_RANGE 3

/datum/clockcult/scripture/create_structure/interdiction
	name = "Interdiction Lens"
	desc = "Creates a device that will slow non servants in the area and damage mechanised exosuits."
	tip = "Construct interdiction lens to slow down a hostile assault."
	button_icon_state = "Interdiction Lens"
	power_cost = 500
	invokation_time = 80
	invokation_text = list("Oh great lord...", "...may your divinity block the outsiders.")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/interdiction_lens
	cogs_required = 4
	category = SPELLTYPE_STRUCTURES

/obj/structure/destructible/clockwork/gear_base/interdiction_lens
	name = "interdiction lens"
	desc = "A mesmerizing light that flashes to a rhythm that you just can't stop tapping to."
	clockwork_desc = "A small device which will slow down nearby attackers at a small power cost."
	default_icon_state = "interdiction_lens_inactive"
	anchored = TRUE
	break_message = "<span class='warning'>The interdiction lens breaks into multiple fragments, which gently float to the ground.</span>"
	max_integrity = 150
	obj_integrity = 150
	var/enabled = FALSE
	var/processing = FALSE
	var/datum/proximity_monitor/advanced/dampening_field
	var/obj/item/borg/projectile_dampen/internal_dampener

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/Initialize()
	internal_dampener = new
	. = ..()

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/Destroy()
	if(enabled)
		STOP_PROCESSING(SSobj, src)
	QDEL_NULL(dampening_field)
	QDEL_NULL(internal_dampener)
	. = ..()

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/attack_hand(mob/user)
	if(is_servant_of_ratvar(user))
		enabled = !enabled
		to_chat(user, "<span class='brass'>You toggle [src] [enabled?"on":"off"].</span>")
		if(enabled)
			if(check_power(5))
				repowered()
			else
				to_chat(user, "<span class='warning'>[src] does not have enough power!</span>")
		else
			depowered()
	else
		. = ..()

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/process()
	if(!anchored)
		enabled = FALSE
		STOP_PROCESSING(SSobj, src)
		icon_state = "interdiction_lens_unwrenched"
		return
	if(!update_power())
		return
	if(prob(5))
		new /obj/effect/temp_visual/steam_release(get_turf(src))
	for(var/mob/living/L in range(INTERDICTION_LENS_RANGE, src))
		if(!is_servant_of_ratvar(L))
			if(use_power(5))
				L.apply_status_effect(STATUS_EFFECT_INTERDICTION)
	for(var/obj/item/projectile/P in range(INTERDICTION_LENS_RANGE, src))
		if(isliving(P) || !is_servant_of_ratvar(P.firer))
			if(use_power(5))
				P.speed *= 2
				P.damage /= 1.4
				P.visible_message("<span class='warning'>[P] appears to slow in midair!</span>")
	for(var/obj/mecha/M in range(INTERDICTION_LENS_RANGE, src))
		if(use_power(5))
			M.use_power(1000)
			M.take_damage(25)
			do_sparks(4, TRUE, M)

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/repowered()
	if(enabled)
		if(!processing)
			START_PROCESSING(SSobj, src)
			processing = TRUE
		icon_state = "interdiction_lens_active"
		flick("interdiction_lens_recharged", src)
		if(istype(dampening_field))
			QDEL_NULL(dampening_field)
		dampening_field = make_field(/datum/proximity_monitor/advanced/peaceborg_dampener/clockwork, list("current_range" = INTERDICTION_LENS_RANGE, "host" = src, "projector" = internal_dampener))

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/depowered()
	if(processing)
		STOP_PROCESSING(SSobj, src)
		processing = FALSE
	icon_state = "interdiction_lens_inactive"
	flick("interdiction_lens_discharged", src)
	QDEL_NULL(dampening_field)

//Dampening field
/datum/proximity_monitor/advanced/peaceborg_dampener/clockwork
	name = "\improper Reality Distortion Field"

/datum/proximity_monitor/advanced/peaceborg_dampener/clockwork/capture_projectile(obj/item/projectile/P, track_projectile = TRUE)
	if(P in tracked)
		return
	if(ismob(P.firer) && is_servant_of_ratvar(P.firer))
		return
	projector.dampen_projectile(P, track_projectile)
	if(track_projectile)
		tracked += P
