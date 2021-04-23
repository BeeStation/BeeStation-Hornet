/obj/item/pool
	icon = 'icons/obj/pool.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 0
	damtype = STAMINA
	w_class = WEIGHT_CLASS_BULKY
	block_sound = 'sound/weapons/tap.ogg'
	block_level = 1
	block_upgrade_walk = 0
	block_power = 0
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	attack_verb = list("wacked")

/obj/item/pool/Initialize()
	. = ..()
	//Pick a random color
	add_atom_colour(pick(COLOR_YELLOW, COLOR_LIME, COLOR_RED, COLOR_BLUE_LIGHT, COLOR_CYAN, COLOR_MAGENTA), FIXED_COLOUR_PRIORITY)

/obj/item/pool/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE, force_unwielded=0, force_wielded=5, \
				wieldsound='sound/weapons/tap.ogg', unwieldsound='sound/weapons/tap.ogg', block_power_wielded=20)

/obj/item/pool/rubber_ring
	name = "inflateable ring"
	desc = "An inflateable ring used for keeping people afloat. Throw at drowning people to save them."
	icon_state = "rubber_ring"

/obj/item/pool/rubber_ring/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		//Make sure they are in a pool
		if(!istype(get_turf(H), /turf/open/indestructible/sound/pool))
			return
		//Make sure they are alive and can pick it up
		if(H.stat)
			return
		//Try shove it in their inventory
		if(H.put_in_active_hand(src))
			visible_message("<span class='notice'>The [src] lands over [H]'s head!</span>")

/obj/item/pool/pool_noodle
	icon_state = "pool_noodle"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	name = "pool noodle"
	desc = "A long noodle made of foam. Helping those with fears of swimming swim since the 1980s."
	var/suiciding = FALSE

/obj/item/pool/pool_noodle/attack(mob/target, mob/living/carbon/human/user)
	. = ..()
	if(ISWIELDED(src) && prob(50))
		INVOKE_ASYNC(src, .proc/jedi_spin, user)

/obj/item/pool/pool_noodle/proc/jedi_spin(mob/living/user) //rip complex code, but this fucked up blocking
	user.emote("flip")

/obj/item/pool/pool_noodle/suicide_act(mob/user)
	if(suiciding)
		return SHAME
	suiciding = TRUE
	user.visible_message("<span class='notice'>[user] begins kicking their legs to stay afloat!</span>")
	var/mob/living/L = user
	if(istype(L))
		L.Immobilize(63)
	animate(user, time=20, pixel_y=18)
	sleep(20)
	animate(user, time=10, pixel_y=12)
	sleep(10)
	user.visible_message("<span class='notice'>[user] keeps swimming higher and higher!</span>")
	animate(user, time=10, pixel_y=22)
	sleep(10)
	animate(user, time=10, pixel_y=16)
	sleep(10)
	animate(user, time=15, pixel_y=32)
	sleep(15)
	user.visible_message("<span class='suicide'>[user] suddenly realised they aren't in the water and cannot float.</span>")
	animate(user, time=1, pixel_y=0)
	sleep(1)
	user.ghostize()
	user.gib()
	suiciding = FALSE
	return MANUAL_SUICIDE
