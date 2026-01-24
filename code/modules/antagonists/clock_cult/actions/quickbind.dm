/datum/action/innate/clockcult
	button_icon = 'icons/hud/actions/actions_clockcult.dmi'
	button_icon_state = "Abscond"
	background_icon_state = "bg_clock"
	buttontooltipstyle = "brass"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS

/datum/action/innate/clockcult/quick_bind
	name = "Quick Bind"
	button_icon_state = "Abscond"
	desc = "A quick bound spell."

	/// The slab this action is bound to
	var/obj/item/clockwork/clockwork_slab/activation_slab
	/// The scripture to invoke
	var/datum/clockcult/scripture/scripture

/datum/action/innate/clockcult/quick_bind/New(datum/clockcult/scripture/new_scripture, obj/item/clockwork/clockwork_slab/slab)
	. = ..()
	scripture = new_scripture
	activation_slab = slab

/datum/action/innate/clockcult/quick_bind/Destroy()
	activation_slab = null
	Remove(owner)
	. = ..()

/datum/action/innate/clockcult/quick_bind/Grant(mob/living/user)
	name = scripture.name
	desc = scripture.tip
	button_icon_state = scripture.button_icon_state
	if(scripture.power_cost)
		desc += "<br>Draws <b>[scripture.power_cost]W</b> from the ark per use."
	. = ..()

/datum/action/innate/clockcult/quick_bind/Remove(mob/user)
	if(activation_slab.invoking_scripture == scripture)
		activation_slab.invoking_scripture = null
	. = ..()

/datum/action/innate/clockcult/quick_bind/is_available()
	if(!IS_SERVANT_OF_RATVAR(owner) || owner.incapacitated())
		return FALSE
	. = ..()

/datum/action/innate/clockcult/quick_bind/on_activate()
	if(!activation_slab?.invoking_scripture)
		scripture.try_to_invoke(owner)
