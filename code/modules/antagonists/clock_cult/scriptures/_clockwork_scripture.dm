/datum/clockcult/scripture
	var/name = ""
	var/desc = ""
	var/tip = ""
	var/power_cost = 0
	var/invokation_text
	var/button_icon_state = "telerune"

/datum/clockcult/scripture/proc/quick_bind(obj/item/clockwork/clockwork_slab/slab, position=1)
	if(slab.quick_bound_scriptures[position])
		//Unbind the scripture that is quickbound
		qdel(slab.quick_bound_scriptures[position])
	//Put the quickbound action onto the slab, the slab should grant when picked up
	var/datum/action/innate/clockcult/quick_bind/quickbound = new
	quickbound.scripture = src
	quickbound.activation_slab = slab
	slab.quick_bound_scriptures[position] = quickbound

/datum/action/innate/clockcult
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS

/datum/action/innate/clockcult/quick_bind
	name = "Quick Bind"
	button_icon_state = "telerune"
	desc = "A quick bound spell."
	var/obj/item/clockwork/clockwork_slab/activation_slab
	var/datum/clockcult/scripture/scripture

/datum/action/innate/clockcult/quick_bind/Grant(mob/living/M)
	if(power_cost)
		desc += "<br>Draws <b>[power_cost]W</b> from the ark per use."
	..()
	button.locked = TRUE
	button.ordered = FALSE

/datum/action/innate/clockcult/quick_bind/Remove(mob/M)
	if(activation_slab)
		activation_slab.quick_bound_scriptures -= src
	if(activation_slab.invoking_scripture == src)
		activation_slab.invoking_scripture = null
	..(M)

/datum/action/innate/clockcult/quick_bind/IsAvailable()
	if(!is_servant_of_ratvar(owner) || owner.incapacitated())
		return FALSE
	return ..()

/datum/action/innate/clockcult/quick_bind/Activate()
	if(!activation_slab)
		return
	if(!activation_slab.invoking_scripture)
		activation_slab.invoking_scripture = src
		to_chat(owner, "<span class='brass'>DEBUG: You invoke [name] using the [activation_slab.name].</span>")
	else
		to_chat(owner, "<span class='brass'>DEBUG: You fail to invoke [name].</span>")
