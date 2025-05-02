/datum/clockcult/scripture/create_structure/prosperityprism
	name = "Prosperity Prism"
	desc = "Creates a prism that will remove a large amount of toxin damage and a small amount of other forms of damage from nearby servants. Requires power from a sigil of transmission."
	tip = "Create a prosperity prism to heal servants using sentinel's compromise without taking any damage."
	button_icon_state = "Prolonging Prism"
	power_cost = 300
	invokation_time = 8 SECONDS
	invokation_text = list("Your light shall heal the wounds beneath my skin.")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/prosperityprism
	cogs_required = 2

//Stargazer structure
/obj/structure/destructible/clockwork/gear_base/prosperityprism
	name = "prosperity prism"
	desc = "A prism that seems to somehow always have its gaze locked to you."
	clockwork_desc = "A prism that will heal nearby servants of toxin damage."
	icon_state = "prolonging_prism"
	anchored = TRUE
	break_message = span_warning("The prism falls apart, toxic liquid leaking out into the air.")
	max_integrity = 150
	minimum_power = 4
	var/powered = FALSE
	var/enabled = TRUE
	var/datum/reagents/holder

/obj/structure/destructible/clockwork/gear_base/prosperityprism/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	holder = new /datum/reagents(1000)
	holder.my_atom = src

/obj/structure/destructible/clockwork/gear_base/prosperityprism/Destroy()
	STOP_PROCESSING(SSobj, src)

	// Disperse the contained reagents
	if(LAZYLEN(holder.reagent_list))
		var/datum/effect_system/smoke_spread/chem/toxic_smoke = new
		var/turf = get_turf(src)

		toxic_smoke.attach(turf)
		toxic_smoke.set_up(holder, 3, turf, 0)
		toxic_smoke.start()
	QDEL_NULL(holder)
	. = ..()

/obj/structure/destructible/clockwork/gear_base/prosperityprism/update_icon_state()
	. = ..()
	icon_state = icon_state
	if(!anchored)
		icon_state += unwrenched_suffix
	else if(depowered || !powered)
		icon_state += "_inactive"

/obj/structure/destructible/clockwork/gear_base/prosperityprism/process(delta_time)
	if(!anchored)
		enabled = FALSE
		update_icon_state()
		return
	if(!enabled || depowered)
		if(powered)
			powered = FALSE
			update_icon_state()
		return
	if(!powered)
		powered = TRUE
		update_icon_state()

	for(var/mob/living/nearby in range(4, src))
		if(!IS_SERVANT_OF_RATVAR(nearby))
			continue
		if(!nearby.toxloss && !nearby.staminaloss && !nearby.bruteloss && !nearby.fireloss)
			continue

		if(use_power(2))
			// Heal the servant
			nearby.adjustToxLoss(-50 * delta_time, FALSE, TRUE)
			nearby.adjustStaminaLoss(-50 * delta_time)
			nearby.adjustBruteLoss(-10 * delta_time)
			nearby.adjustFireLoss(-10 * delta_time)

			new /obj/effect/temp_visual/heal(get_turf(nearby), "#45dd8a")

			// Store toxic reagents in the prism
			for(var/datum/reagent/reagent in nearby.reagents.reagent_list)
				if(istype(reagent, /datum/reagent/toxin))
					nearby.reagents.remove_reagent(reagent.type, 50 * delta_time)
					holder.add_reagent(reagent.type, 50 * delta_time)

/obj/structure/destructible/clockwork/gear_base/prosperityprism/attack_hand(mob/user, list/modifiers)
	if(!IS_SERVANT_OF_RATVAR(user))
		return ..()

	if(!anchored)
		balloon_alert(user, "not anchored!")
		return

	enabled = !enabled
	balloon_alert(user, "[enabled ? "enabled" : "disabled"]!")

