/obj/item/singularityhammer
	name = "singularity hammer"
	desc = "The pinnacle of close combat technology, the hammer harnesses the power of a miniaturized singularity to deal crushing blows."
	icon_state = "singularity_hammer0"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	force = 5
	attack_weight = 3
	block_upgrade_walk = 1
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	armor = list(MELEE = 50,  BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 50, BIO = 0, RAD = 0, FIRE = 100, ACID = 100, STAMINA = 0)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	force_string = "LORD SINGULOTH HIMSELF"
	var/charged = 5

/obj/item/singularityhammer/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/singularityhammer/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_multiplier=4, icon_wielded="singularity_hammer1")

/obj/item/singularityhammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/singularityhammer/update_icon_state()
	icon_state = "mjollnir0"
	..()

/obj/item/singularityhammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/singularityhammer/process()
	if(charged < 5)
		charged++

/obj/item/singularityhammer/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "singularity_hammer0"

/obj/item/singularityhammer/proc/vortex(turf/pull, mob/wielder)
	for(var/atom/movable/A as mob|obj in orange(5,pull))
		if(A == wielder)
			continue
		if(A && !A.anchored && !ishuman(A))
			step_towards(A,pull)
			step_towards(A,pull)
			step_towards(A,pull)
		else if(ishuman(A))
			var/mob/living/carbon/human/H = A
			if(istype(H.shoes, /obj/item/clothing/shoes/magboots))
				var/obj/item/clothing/shoes/magboots/M = H.shoes
				if(M.magpulse)
					continue
			H.apply_effect(20, EFFECT_PARALYZE, 0)
			step_towards(H,pull)
			step_towards(H,pull)
			step_towards(H,pull)
	return

/obj/item/singularityhammer/afterattack(atom/A as mob|obj|turf|area, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(ISWIELDED(src))
		if(charged == 5)
			charged = 0
			if(istype(A, /mob/living/))
				var/mob/living/Z = A
				Z.take_bodypart_damage(20,0)
			playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			var/turf/target = get_turf(A)
			vortex(target,user)
