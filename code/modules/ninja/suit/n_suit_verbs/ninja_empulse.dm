/datum/action/item_action/ninjapulse
	name = "EM Burst (1kW)"
	desc = "Disable any nearby technology with an electro-magnetic pulse."
	button_icon_state = "emp"
	icon_icon = 'icons/hud/actions/actions_spells.dmi'
	cooldown_time = 30 SECONDS

/datum/action/item_action/ninjapulse/is_available()
	if (!..())
		return FALSE
	var/obj/item/clothing/suit/space/space_ninja/ninja = master
	return ninja.cell.charge >= 1000 && ninja.s_initialized

/datum/action/item_action/ninjapulse/on_activate(mob/user, atom/target)
	var/obj/item/clothing/suit/space/space_ninja/ninja = master
	if(ninja.consume_power(1000))
		var/mob/living/carbon/human/H = user
		playsound(H.loc, 'sound/effects/empulse.ogg', 60, 2)
		empulse(H, 4, 6) //Procs sure are nice. Slightly weaker than wizard's disable tch.
		start_cooldown()
	return ..()
