//==================================//
// !      Stargazer     ! //
//==================================//
/datum/clockcult/scripture/create_structure/prosperityprism
	name = "Prosperity Prism"
	desc = "Creates a prism that will remove toxin damage from nearby servants."
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
	break_message = "<span class='warning'>The prism falls apart, toxic liquid leaking out.</span>"
	var/powered = FALSE
	var/toggled_on = TRUE

/obj/structure/destructible/clockwork/gear_base/prosperityprism/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/clockwork/gear_base/prosperityprism/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/destructible/clockwork/gear_base/prosperityprism/update_icon_state()
	. = ..()
	icon_state = default_icon_state
	if(!anchored)
		icon_state += unwrenched_suffix
	else if(!powered)
		icon_state += "_inactive"

/obj/structure/destructible/clockwork/gear_base/prosperityprism/process()
	if(GLOB.clockcult_power < 4 || !toggled_on)
		if(powered)
			powered = FALSE
			update_icon_state()
		return
	if(!powered)
		powered = TRUE
		update_icon_state()
	for(var/mob/living/L in range(4))
		if(!is_servant_of_ratvar(L))
			continue
		if(GLOB.clockcult_power < 4)
			return
		if(L.getToxLoss() > 0)
			L.adjustToxLoss(-10)
			GLOB.clockcult_power -= 4
			new /obj/effect/temp_visual/heal(get_turf(L), "#45dd8a")

/obj/structure/destructible/clockwork/gear_base/prosperityprism/attack_hand(mob/user)
	if(is_servant_of_ratvar(user))
		toggled_on = !toggled_on
		to_chat(user, "<span class='notice'>You flick the switch on [src]!</span>")
	else
		. = ..()

