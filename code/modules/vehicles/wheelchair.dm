/obj/vehicle/ridden/wheelchair //ported from Hippiestation (by Jujumatic)
	name = "wheelchair"
	desc = "A chair with big wheels. It looks like you can move in this on your own."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "wheelchair"
	layer = OBJ_LAYER
	max_integrity = 100
	armor_type = /datum/armor/ridden_wheelchair
	canmove = TRUE
	density = FALSE		//Thought I couldn't fix this one easily, phew
	move_resist = MOVE_FORCE_WEAK
	// Run speed delay is multiplied with this for vehicle move delay.
	var/delay_multiplier = 6.7


/datum/armor/ridden_wheelchair
	melee = 10
	bullet = 10
	laser = 10
	bomb = 10
	fire = 20
	acid = 30

/obj/vehicle/ridden/wheelchair/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_IMMOBILIZE, INNATE_TRAIT) //the wheelchair doesnt immobilize us like a bed would

/obj/vehicle/ridden/wheelchair/add_riding_element()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/wheelchair/hand)

/obj/vehicle/ridden/wheelchair/atom_destruction(damage_flag)
	new /obj/item/stack/rods(drop_location(), 1)
	new /obj/item/stack/sheet/iron(drop_location(), 1)
	..()

/obj/vehicle/ridden/wheelchair/Destroy()
	if(has_buckled_mobs())
		var/mob/living/carbon/H = buckled_mobs[1]
		unbuckle_mob(H)
	return ..()

/obj/vehicle/ridden/wheelchair/Moved()
	. = ..()
	cut_overlays()
	playsound(src, 'sound/effects/roll.ogg', 75, 1)
	if(has_buckled_mobs())
		handle_rotation_overlayed()


/obj/vehicle/ridden/wheelchair/post_buckle_mob(mob/living/user)
	. = ..()
	handle_rotation_overlayed()

/obj/vehicle/ridden/wheelchair/post_unbuckle_mob()
	. = ..()
	cut_overlays()

/obj/vehicle/ridden/wheelchair/setDir(newdir)
	..()
	handle_rotation(newdir)

/obj/vehicle/ridden/wheelchair/wrench_act(mob/living/user, obj/item/I)	//Attackby should stop it attacking the wheelchair after moving away during decon
	to_chat(user, span_notice("You begin to detach the wheels..."))
	if(I.use_tool(src, user, 40, volume=50))
		to_chat(user, span_notice("You detach the wheels and deconstruct the chair."))
		new /obj/item/stack/rods(drop_location(), 6)
		new /obj/item/stack/sheet/iron(drop_location(), 4)
		qdel(src)
	return TRUE

/obj/vehicle/ridden/wheelchair/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/vehicle/ridden/wheelchair/proc/handle_rotation(direction)
	if(has_buckled_mobs())
		handle_rotation_overlayed()
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(direction)

/obj/vehicle/ridden/wheelchair/proc/handle_rotation_overlayed()
	cut_overlays()
	var/image/V = image(icon = icon, icon_state = "wheelchair_overlay", layer = FLY_LAYER, dir = src.dir)
	add_overlay(V)



/obj/vehicle/ridden/wheelchair/proc/can_be_rotated(mob/living/user)
	return TRUE

/obj/vehicle/ridden/wheelchair/proc/can_user_rotate(mob/living/user)
	var/mob/living/L = user
	if(istype(L))
		if(!user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
			return FALSE
	if(isobserver(user) && CONFIG_GET(flag/ghost_interaction))
		return TRUE
	return FALSE
