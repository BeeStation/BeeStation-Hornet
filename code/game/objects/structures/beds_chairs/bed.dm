/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * 		Beds
 *		Roller beds
 */

/*
 * Beds
 */
/obj/structure/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon_state = "bed"
	icon = 'icons/obj/beds_chairs/beds.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 90
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 0.35
	dir = SOUTH
	var/buildstacktype = /obj/item/stack/sheet/iron
	var/buildstackamount = 2
	var/bolts = TRUE

// dir check for buckle_lying state
/obj/structure/bed/Initialize(mapload)
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(dir_changed))
	dir_changed(new_dir = dir)
	. = ..()

/obj/structure/bed/Destroy()
	UnregisterSignal(src, COMSIG_ATOM_DIR_CHANGE)
	return ..()

/obj/structure/bed/examine(mob/user)
	. = ..()
	if(bolts)
		. += span_notice("It's held together by a couple of <b>bolts</b>.")

/obj/structure/bed/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(buildstacktype)
			new buildstacktype(loc,buildstackamount)
	..()

/obj/structure/bed/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/bed/wrench_act_secondary(mob/living/user, obj/item/weapon)
	if(flags_1&NODECONSTRUCT_1)
		return TRUE
	..()
	weapon.play_tool_sound(src)
	deconstruct(disassembled = TRUE)
	return TRUE

/obj/structure/bed/proc/dir_changed(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	switch(new_dir)
		if(WEST, SOUTH)
			buckle_lying = 90
		if(EAST, NORTH)
			buckle_lying = 270

/*
 * Roller beds
 */
/obj/structure/bed/roller
	name = "roller bed"
	icon = 'icons/obj/beds_chairs/rollerbed.dmi'
	icon_state = "down"
	anchored = FALSE
	resistance_flags = NONE
	move_resist = MOVE_FORCE_WEAK
	var/foldabletype = /obj/item/rollerbed

/obj/structure/bed/roller/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
			return FALSE
		if(has_buckled_mobs())
			return FALSE
		usr.visible_message("[usr] collapses \the [src.name].", span_notice("You collapse \the [src.name]."))
		var/obj/structure/bed/roller/B = new foldabletype(get_turf(src))
		usr.put_in_hands(B)
		qdel(src)

/obj/structure/bed/roller/post_buckle_mob(mob/living/M)
	set_density(TRUE)
	icon_state = "up"
	M.reset_pull_offsets(M, TRUE) //TEMPORARY, remove when update_mobilty is kill
	//Push them up from the normal lying position
	M.pixel_y = M.base_pixel_y

/obj/structure/bed/roller/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, 1)

/obj/structure/bed/roller/post_unbuckle_mob(mob/living/M)
	set_density(FALSE)
	icon_state = "down"
	//Set them back down to the normal lying position
	M.pixel_y = M.base_pixel_y + M.body_position_pixel_y_offset

//Dog bed

/obj/structure/bed/dogbed
	name = "dog bed"
	icon_state = "dogbed"
	desc = "A comfy-looking dog bed. You can even strap your pet in, in case the gravity turns off."
	anchored = FALSE
	buildstacktype = /obj/item/stack/sheet/wood
	buildstackamount = 10
	var/owned = FALSE

/obj/structure/bed/dogbed/ian
	desc = "Ian's bed! Looks comfy."
	name = "Ian's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/cayenne
	desc = "Seems kind of... fishy."
	name = "Cayenne's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/renault
	desc = "Renault's bed! Looks comfy. A foxy person needs a foxy pet."
	name = "Renault's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/runtime
	desc = "A comfy-looking cat bed. You can even strap your pet in, in case the gravity turns off."
	name = "Runtime's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/vector
	desc = "Vector's bed! Wait... Do hamsters normally have beds...?"
	name = "Vector's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/walter
	desc = "Walter's bed! It reeks of testosterone and motor oil."
	name = "Walter's bed"
	anchored = TRUE

///Used to set the owner of a dogbed, returns FALSE if called on an owned bed or an invalid one, TRUE if the possesion succeeds
/obj/structure/bed/dogbed/proc/update_owner(mob/living/M)
	if(owned || type != /obj/structure/bed/dogbed) //Only marked beds work, this is hacky but I'm a hacky man
		return FALSE //Failed
	owned = TRUE
	name = "[M]'s bed"
	desc = "[M]'s bed! Looks comfy."
	return TRUE //Let any callers know that this bed is ours now

/obj/structure/bed/dogbed/buckle_mob(mob/living/M, force, check_loc)
	. = ..()
	update_owner(M)

/obj/structure/bed/alien
	name = "resting contraption"
	desc = "This looks similar to a normal bed from Earth. Could aliens be stealing <b>our technology</b>?"
	icon_state = "abed"

/obj/structure/bed/alien/examine(mob/user)
	. = ..()
	if(isabductor(user))
		. += span_abductor("Fairly sure we absolutely stole that technology.")

//unfortunateley no sickness mechanics on them... yet
/obj/structure/bed/maint
	name = "dirty mattress"
	desc = "An old grubby mattress. You try to not think about what could be the cause of those stains."
	icon_state = "dirty_mattress"

//Double Beds, for luxurious sleeping, i.e. the captain and maybe heads - if people use this for ERP, send them to skyrat, or worse, acacia
/obj/structure/bed/double
	name = "double bed"
	desc = "A luxurious double bed, for those too important for small dreams."
	icon_state = "bed_double"
	buildstackamount = 4
	max_buckled_mobs = 2
	///The mob who buckled to this bed second, to avoid other mobs getting pixel-shifted before they unbuckles.
	var/mob/living/goldilocks

/obj/structure/bed/double/post_buckle_mob(mob/living/M)
	M.reset_pull_offsets(M, TRUE) //TEMPORARY, remove when update_mobilty is kill
	if(buckled_mobs.len > 1 && !goldilocks) //Push the second buckled mob a bit higher from the normal lying position, also, if someone can figure out the same thing for plushes, i'll be really glad to know how to
		M.pixel_y = M.base_pixel_y + 6
		goldilocks = M
		RegisterSignal(goldilocks, COMSIG_PARENT_QDELETING, PROC_REF(goldilocks_deleted))

/obj/structure/bed/double/post_unbuckle_mob(mob/living/M)
	M.pixel_y = base_pixel_y + M.body_position_pixel_y_offset
	if(M == goldilocks)
		UnregisterSignal(goldilocks, COMSIG_PARENT_QDELETING)
		goldilocks = null

//Called when the signal is raised, removes the reference
//preventing the hard delete.
/obj/structure/bed/double/proc/goldilocks_deleted(datum/source, force)
	UnregisterSignal(goldilocks, COMSIG_PARENT_QDELETING)
	goldilocks = null

/obj/structure/bed/double/maint
	name = "double dirty mattress"
	desc = "An old grubby king sized mattress. You really try to not think about what could be the cause of those stains."
	icon_state = "dirty_mattress_double"

/obj/structure/bed/double/alien
	name = "double resting contraption"
	desc = "This looks similar to a normal double bed from Earth. Could aliens be stealing <b>our technology</b>?"
	icon_state = "abed_double"

/obj/structure/bed/double/alien/examine(mob/user)
	. = ..()
	if(isabductor(user))
		. += span_abductor("Fairly sure we absolutely stole that technology... Why did we steal this again?")
