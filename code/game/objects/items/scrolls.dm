/obj/item/teleportation_scroll
	name = "scroll of teleportation"
	desc = "A scroll for moving around."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	var/uses = 4 /// Number of uses the scroll gets.
	actions_types = list(/datum/action/cooldown/spell/teleport/area_teleport/wizard/scroll)
	w_class = WEIGHT_CLASS_SMALL
	item_state = "paper"
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE

/obj/item/teleportation_scroll/Initialize(mapload)
	. = ..()
	// In the future, this can be generalized into just "magic scrolls that give you a specific spell".
	var/datum/action/cooldown/spell/teleport/area_teleport/wizard/scroll/teleport = locate() in actions
	if(teleport)
		teleport.name = name
		teleport.icon_icon = icon
		teleport.button_icon_state = icon_state

/obj/item/teleportation_scroll/item_action_slot_check(slot, mob/user)
	return (slot == ITEM_SLOT_HANDS)

/obj/item/teleportation_scroll/apprentice
	name = "lesser scroll of teleportation"
	uses = 1



/obj/item/teleportation_scroll/attack_self(mob/user)
	. = ..()
	if(.)
		return

	if(!uses)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(human_user.incapacitated() || !human_user.is_holding(src))
		return
	var/datum/action/cooldown/spell/teleport/area_teleport/wizard/scroll/teleport = locate() in actions
	if(!teleport)
		to_chat(user, ("<span class='warning'>[src] seems to be a faulty teleportation scroll, and has no magic associated.</span>"))
		return
	if(!teleport.Activate(user))
		return
	if(--uses <= 0)
		to_chat(user, ("<span class='warning'>[src] runs out of uses and crumbles to dust!</span>"))
		qdel(src)
	return TRUE
/* stale merge upstream moment
	if(do_teleport(user, pick(L), channel = TELEPORT_CHANNEL_MAGIC, bypass_area_restriction = TRUE))
		smoke.start()
		uses--
	else
		to_chat(user, "The spell matrix was disrupted by something near the destination.")
*/
