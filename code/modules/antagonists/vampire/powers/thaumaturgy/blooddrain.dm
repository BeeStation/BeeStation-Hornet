/obj/item/gun/magic/wand/drain
	name = "wand of drain vitality"
	desc = "This dark wand saps the very life force from your target, slowing them and eventually transferring their life essence to you. Requires you to remain within range to be effective."
	fire_sound = 'sound/magic/wandodeath.ogg'
	ammo_type = /obj/item/ammo_casing/magic/drain
	icon_state = "drainwand"
	item_state = "drainwand"
	var/datum/status_effect/life_drain/active_effect

/obj/item/gun/magic/wand/drain/pull_trigger(atom/target, mob/living/user, params, aimed)
	if(charges && active_effect)
		active_effect.end_drain()
	return ..()

/obj/item/gun/magic/wand/drain/dropped(mob/user)
	. = ..()
	if(active_effect)
		active_effect.end_drain()
