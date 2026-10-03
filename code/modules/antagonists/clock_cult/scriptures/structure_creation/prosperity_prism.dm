/datum/clockcult/scripture/create_structure/prosperityprism
	name = "Prosperity Prism"
	desc = "Creates a prism that will remove a large amount of toxin damage and a small amount of other forms of damage from nearby servants. Requires power from a sigil of transmission."
	tip = "Create a prosperity prism to heal servants using sentinel's compromise without taking any damage."
	invokation_text = list("Your light shall heal the wounds beneath my skin.")
	invokation_time = 8 SECONDS
	button_icon_state = "Prolonging Prism"
	power_cost = 300
	cogs_required = 2
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/prosperityprism
	category = SPELLTYPE_STRUCTURES

/obj/structure/destructible/clockwork/gear_base/prosperityprism
	name = "prosperity prism"
	desc = "A prism that seems to somehow always have its gaze locked to you."
	icon_state = "prolonging_prism"
	base_icon_state = "prolonging_prism"
	anchored = TRUE
	max_integrity = 150
	minimum_power = 4
	depowered = FALSE
	clockwork_desc = span_brass("A prism that will heal nearby servants of toxin damage.")
	break_message = span_warning("The prism falls apart, toxic liquid leaking out into the air.")
	var/powered = FALSE
	var/enabled = TRUE
	var/datum/reagents/holder

/obj/structure/destructible/clockwork/gear_base/prosperityprism/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	holder = new(1000)
	holder.my_atom = src

/obj/structure/destructible/clockwork/gear_base/prosperityprism/Destroy()
	STOP_PROCESSING(SSobj, src)

	// Disperse the contained reagents
	if(length(holder?.reagent_list))
		var/datum/effect_system/smoke_spread/chem/toxic_smoke = new()
		var/turf = get_turf(src)

		toxic_smoke.attach(turf)
		toxic_smoke.set_up(holder, 3, turf, 0)
		toxic_smoke.start()
	if(holder)
		QDEL_NULL(holder)

	return ..()

/obj/structure/destructible/clockwork/gear_base/prosperityprism/update_icon_state()
	. = ..()
	if(!anchored)
		icon_state += "[base_icon_state]_unwrenched"
	else if(depowered || !powered)
		icon_state = "[base_icon_state]_inactive"

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
		if(!nearby.toxloss && !nearby.stamina.loss && !nearby.bruteloss && !nearby.fireloss)
			continue

		if(use_power(2))
			// Heal the servant
			nearby.adjustToxLoss(-50 * delta_time, FALSE, TRUE)
			nearby.stamina.adjust(50 * delta_time)
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
	update_appearance(UPDATE_ICON)
