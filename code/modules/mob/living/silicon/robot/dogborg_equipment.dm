/*
DOG BORG EQUIPMENT HERE
SLEEPER CODE IS IN game/objects/items/devices/dogborg_sleeper.dm !
*/

/obj/item/dogborg/jaws
	name = "Dogborg jaws"
	desc = "The jaws of the debug errors oh god."
	icon = 'icons/mob/dogborg.dmi'
	flags_1 = CONDUCT_1
	force = 1
	throwforce = 0
	w_class = 3
	hitsound = 'sound/weapons/bite.ogg'
	sharpness = IS_SHARP

/obj/item/dogborg/jaws/big
	name = "combat jaws"
	desc = "The jaws of the law. Very sharp."
	icon_state = "jaws"
	force = 12
	attack_verb = list("chomped", "bit", "ripped", "mauled", "enforced")

/obj/item/dogborg/jaws/small
	name = "puppy jaws"
	desc = "Rubberized teeth designed to protect accidental harm. Sharp enough for specialized tasks however."
	icon_state = "smalljaws"
	force = 6
	attack_verb = list("nibbled", "bit", "gnawed", "chomped", "nommed")
	var/status = 0

/obj/item/dogborg/jaws/attack(atom/A, mob/living/silicon/robot/user)
	..()
	user.do_attack_animation(A, ATTACK_EFFECT_BITE)
	log_combat(user, A, "bit")

/obj/item/dogborg/jaws/small/attack_self(mob/user)
	var/mob/living/silicon/robot.R = user
	if(R.cell && R.cell.charge > 100)
		if(R.emagged && status == 0)
			name = "combat jaws"
			icon_state = "jaws"
			desc = "The jaws of the law."
			force = 12
			attack_verb = list("chomped", "bit", "ripped", "mauled", "enforced")
			status = 1
			to_chat(user, "<span class='notice'>Your jaws are now [status ? "Combat" : "Pup'd"].</span>")
		else
			name = "puppy jaws"
			icon_state = "smalljaws"
			desc = "The jaws of a small dog."
			force = 5
			attack_verb = list("nibbled", "bit", "gnawed", "chomped", "nommed")
			status = 0
			if(R.emagged)
				to_chat(user, "<span class='notice'>Your jaws are now [status ? "Combat" : "Pup'd"].</span>")
	update_icon()

//Boop

/obj/item/analyzer/nose
	name = "boop module"
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "nose"
	desc = "The BOOP module"
	flags_1 = CONDUCT_1
	force = 0
	throwforce = 0
	attack_verb = list("nuzzles", "pushes", "boops")
	w_class = 1

/obj/item/analyzer/nose/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	do_attack_animation(target, null, src)
	user.visible_message("<span class='notice'>[user] [pick(attack_verb)] \the [target.name] with their nose!</span>")

//Delivery
/obj/item/storage/bag/borgdelivery
	name = "fetching storage"
	desc = "Fetch the thing!"
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "dbag"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/bag/borgdelivery/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.max_combined_w_class = 5
	STR.max_items = 1
	STR.cant_hold = typecacheof(list(/obj/item/disk/nuclear, /obj/item/radio/intercom))



/obj/item/twohanded/shockpaddles/cyborg/hound
	name = "Paws of Life"
	desc = "MediHound specific shock paws."
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "defibpaddles0"
	item_state = "defibpaddles0"

