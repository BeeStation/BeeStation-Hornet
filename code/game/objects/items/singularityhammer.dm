/obj/item/singularityhammer
	name = "singularity hammer"
	desc = "The pinnacle of close combat technology, the hammer harnesses the power of a miniaturized singularity to deal crushing blows."
	icon_state = "singularity_hammer0"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	worn_icon_state = "singularity_hammer"
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	force = 5
	attack_weight = 3

	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ISWEAPON
	armor_type = /datum/armor/item_singularityhammer
	resistance_flags = FIRE_PROOF | ACID_PROOF
	force_string = "LORD SINGULOTH HIMSELF"
	var/charged = 5


/datum/armor/item_singularityhammer
	melee = 50
	bullet = 50
	laser = 50
	bomb = 50
	fire = 100
	acid = 100

/obj/item/singularityhammer/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
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
		if(isliving(A))
			var/mob/living/vortexed_mob = A
			if(vortexed_mob.mob_negates_gravity())
				continue
			else
				vortexed_mob.Paralyze(2 SECONDS)
		if(!A.anchored && !isobserver(A))
			step_towards(A,pull)
			step_towards(A,pull)
			step_towards(A,pull)

/obj/item/singularityhammer/afterattack(atom/A as mob|obj|turf|area, mob/living/user, proximity)
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
