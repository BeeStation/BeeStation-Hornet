//==================================//
// !      Prosperity Prism     ! //
//==================================//
/datum/clockcult/scripture/create_structure/prosperityprism
	name = "Prosperity Prism"
	desc = "Creates a prism that will remove a large amount of toxin damage and a small amount of other forms of damage from nearby servants. Requires power from a sigil of transmission."
	tip = "Create a prosperity prism to heal servants using sentinel's compromise without taking any damage."
	button_icon_state = "Prolonging Prism"
	power_cost = 300
	invokation_time = 80
	invokation_text = list("Your light shall heal the wounds beneath my skin.")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/prosperityprism
	cogs_required = 2
	category = SPELLTYPE_STRUCTURES

//Stargazer structure
/obj/structure/destructible/clockwork/gear_base/prosperityprism
	name = "prosperity prism"
	desc = "A prism that seems to somehow always have its gaze locked to you."
	clockwork_desc = "A prism that will heal nearby servants of toxin damage."
	default_icon_state = "prolonging_prism"
	anchored = TRUE
	break_message = "<span class='warning'>The prism falls apart, toxic liquid leaking out into the air.</span>"
	max_integrity = 150
	obj_integrity = 150
	minimum_power = 4
	var/powered = FALSE
	var/toggled_on = TRUE
	var/datum/reagents/holder

/obj/structure/destructible/clockwork/gear_base/prosperityprism/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	holder = new /datum/reagents(1000)
	holder.my_atom = src

/obj/structure/destructible/clockwork/gear_base/prosperityprism/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(LAZYLEN(holder.reagent_list))
		var/datum/effect_system/smoke_spread/chem/S = new
		var/turf_location = get_turf(src)
		S.attach(turf_location)
		S.set_up(holder, 3, turf_location, 0)
		S.start()
	QDEL_NULL(holder)
	. = ..()

/obj/structure/destructible/clockwork/gear_base/prosperityprism/update_icon_state()
	. = ..()
	icon_state = default_icon_state
	if(!anchored)
		icon_state += unwrenched_suffix
	else if(depowered || !powered)
		icon_state += "_inactive"

/obj/structure/destructible/clockwork/gear_base/prosperityprism/process(delta_time)
	if(!anchored)
		toggled_on = FALSE
		update_icon_state()
		return
	if(!toggled_on || depowered)
		if(powered)
			powered = FALSE
			update_icon_state()
		return
	if(!powered)
		powered = TRUE
		update_icon_state()
	for(var/mob/living/L in range(4, src))
		if(!is_servant_of_ratvar(L))
			continue
		if(!L.toxloss && !L.staminaloss && !L.bruteloss && !L.fireloss)
			continue
		if(use_power(2))
			L.adjustToxLoss(-5*delta_time, FALSE, TRUE)
			L.adjustStaminaLoss(-5*delta_time)
			L.adjustBruteLoss(-1*delta_time)
			L.adjustFireLoss(-1*delta_time)
			new /obj/effect/temp_visual/heal(get_turf(L), "#45dd8a")
			for(var/datum/reagent/R in L.reagents.reagent_list)
				if(istype(R, /datum/reagent/toxin))
					L.reagents.remove_reagent(R.type, 5*delta_time)
					holder.add_reagent(R.type, 5*delta_time)

/obj/structure/destructible/clockwork/gear_base/prosperityprism/attack_hand(mob/user)
	if(is_servant_of_ratvar(user))
		if(!anchored)
			to_chat(user, "<span class='warning'>[src] needs to be fastened to the floor!</span>")
			return
		toggled_on = !toggled_on
		to_chat(user, "<span class='brass'>You flick the switch on [src], turning it [toggled_on?"on":"off"]!</span>")
	else
		. = ..()

