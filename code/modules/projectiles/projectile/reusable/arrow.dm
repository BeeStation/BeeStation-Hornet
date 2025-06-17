/obj/projectile/bullet/reusable/arrow
	name = "formless Arrow"
	desc = "Woosh!"
	icon_state = "arrow"
	damage = 10
	armour_penetration = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	//passed on from the ammo_type when processed, so that it can be passed back to the ammo_type when dropped
	var/arrow_state = "unfinished"
	var/burning

/obj/projectile/bullet/reusable/arrow/on_hit(atom/target, blocked = FALSE)
	//check if embedding and reagent logic
	var/obj/item/ammo_casing/caseless/arrow/obj_arrow = convert_proj_to_obj()

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/bodypart/B = C.get_bodypart(def_zone)
		if(obj_arrow.tryEmbed(B))
			if(reagents) //if we embed successfully, inject all of our reagents
				reagents.handle_reactions(C, INJECT, reagents.total_volume)
				reagents.trans_to(C, reagents.total_volume)
		if(burning)
			var/mob/living/carbon/M = target
			M.adjust_fire_stacks(2)
			M.IgniteMob()

	if(reagents?.total_volume)//In case we didn't inject, reagents will splash out here
		reagents.handle_reactions(target, TOUCH, reagents.total_volume)  /// this was 	reagents.reaction(target, TOUCH, reagents.total_volume)
		visible_message("<span class='notice'>[src] spills its contents all over [target].</span>")

	if (isanimal(target)) //Arrows are very effective against simplemobs
		damage *= 2

	//standard projectile behavior takes over now
	. = ..()

//Re-creates the ammo_type when needed for embedding or dropping
/obj/projectile/bullet/reusable/arrow/proc/convert_proj_to_obj()
	dropped = TRUE
	var/obj/item/ammo_casing/caseless/arrow/dropped_arrow = new ammo_type
	dropped_arrow.forceMove(loc)
	dropped_arrow.update_arrow_state(dropped_arrow.check_break(arrow_state)) //Update the dropped arrow type by breaking it if necessary, also resets reagents
	return dropped_arrow

//override this proc entirely, we handle it unique to other reusables
/obj/projectile/bullet/reusable/arrow/handle_drop()
	if(dropped)
		return
	convert_proj_to_obj()

/obj/projectile/bullet/reusable/arrow/wood
	name = "wooden arrow"
	icon_state = "arrow_wood"
	damage = 9.5 //19 when finished
	bleed_force = 0
	armour_penetration = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/wood
	hitsound = 'sound/effects/hit_punch.ogg'

/obj/projectile/bullet/reusable/arrow/bamboo
	name = "bamboo arrow"
	damage = 8.5 //17 when finished
	speed = 0.7
	bleed_force = 0
	armour_penetration = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bamboo
	hitsound = 'sound/effects/hit_punch.ogg'

/obj/projectile/bullet/reusable/arrow/bone
	name = "bone arrow"
	damage = 10 //20 when finished without bonus
	bleed_force = 0
	armour_penetration = 10
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone
	hitsound = 'sound/effects/hit_punch.ogg'

/obj/projectile/bullet/reusable/arrow/plastitanium
	name = "plastitanium arrow"
	damage = 10 //20 when finished without bonus
	speed = 0.9
	bleed_force = 0
	armour_penetration = 20
	ammo_type = /obj/item/ammo_casing/caseless/arrow/plastitanium
	hitsound = 'sound/effects/hit_punch.ogg'

/obj/projectile/bullet/reusable/arrow/bronze
	name = "Bronze arrow"
	desc = "Bronze tipped arrow"
	damage = 20
	armour_penetration = 10
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bronze

