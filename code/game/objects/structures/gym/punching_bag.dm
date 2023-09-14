/obj/structure/punching_bag
	name = "punching bag"
	desc = "A punching bag. Can you get to speed level 4???"
	icon = 'icons/obj/fitness.dmi'
	icon_state = "punchingbag"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	var/static/list/hit_sounds = list(
		'sound/weapons/genhit1.ogg',
		'sound/weapons/genhit2.ogg',
		'sound/weapons/genhit3.ogg',
		'sound/weapons/punch1.ogg',
		'sound/weapons/punch2.ogg',
		'sound/weapons/punch3.ogg',
		'sound/weapons/punch4.ogg',
	)

/obj/structure/punching_bag/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	flick("[icon_state]-punch", src)
	playsound(loc, pick(hit_sounds), 25, TRUE, -1)
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "exercise", /datum/mood_event/exercise)
	user.apply_status_effect(STATUS_EFFECT_EXERCISED)

