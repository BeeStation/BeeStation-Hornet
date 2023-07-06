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
	integrity_failure = 30
	dir = SOUTH
	var/buildstacktype = /obj/item/stack/sheet/iron
	var/buildstackamount = 2
	var/bolts = TRUE

/obj/structure/bed/examine(mob/user)
	. = ..()
	if(bolts)
		. += "<span class='notice'>It's held together by a couple of <b>bolts</b>.</span>"

/obj/structure/bed/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(buildstacktype)
			new buildstacktype(loc,buildstackamount)
	..()

/obj/structure/bed/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/bed/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH && !(flags_1&NODECONSTRUCT_1))
		W.play_tool_sound(src)
		deconstruct(TRUE)
	else
		return ..()

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
	var/foldabletype = /obj/item/roller

/obj/structure/bed/roller/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/roller/robo))
		var/obj/item/roller/robo/R = W
		if(R.loaded)
			to_chat(user, "<span class='warning'>You already have a roller bed docked!</span>")
			return

		if(has_buckled_mobs())
			if(buckled_mobs.len > 1)
				unbuckle_all_mobs()
				user.visible_message("<span class='notice'>[user] unbuckles all creatures from [src].</span>")
			else
				user_unbuckle_mob(buckled_mobs[1],user)
		else
			R.loaded = src
			forceMove(R)
			user.visible_message("[user] collects [src].", "<span class='notice'>You collect [src].</span>")
		return 1
	else
		return ..()

/obj/structure/bed/roller/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
			return 0
		if(has_buckled_mobs())
			return 0
		usr.visible_message("[usr] collapses \the [src.name].", "<span class='notice'>You collapse \the [src.name].</span>")
		var/obj/structure/bed/roller/B = new foldabletype(get_turf(src))
		usr.put_in_hands(B)
		qdel(src)

/obj/structure/bed/roller/post_buckle_mob(mob/living/M)
	set_density(TRUE)
	icon_state = "up"
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

/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/beds_chairs/rollerbed.dmi'
	icon_state = "folded"
	w_class = WEIGHT_CLASS_NORMAL // No more excuses, stop getting blood everywhere

/obj/item/roller/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/roller/robo))
		var/obj/item/roller/robo/R = I
		if(R.loaded)
			to_chat(user, "<span class='warning'>[R] already has a roller bed loaded!</span>")
			return
		user.visible_message("<span class='notice'>[user] loads [src].</span>", "<span class='notice'>You load [src] into [R].</span>")
		R.loaded = new/obj/structure/bed/roller(R)
		qdel(src) //"Load"
		return
	else
		return ..()

/obj/item/roller/attack_self(mob/user)
	deploy_roller(user, user.loc)

/obj/item/roller/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(isopenturf(target))
		deploy_roller(user, target)

/obj/item/roller/proc/deploy_roller(mob/user, atom/location)
	var/obj/structure/bed/roller/R = new /obj/structure/bed/roller(location)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/roller/robo //ROLLER ROBO DA!
	name = "roller bed dock"
	desc = "A collapsed roller bed that can be ejected for emergency use. Must be collected or replaced after use."
	var/obj/structure/bed/roller/loaded = null

/obj/item/roller/robo/Initialize(mapload)
	. = ..()
	loaded = new(src)

/obj/item/roller/robo/examine(mob/user)
	. = ..()
	. += "The dock is [loaded ? "loaded" : "empty"]."

/obj/item/roller/robo/deploy_roller(mob/user, atom/location)
	if(loaded)
		loaded.forceMove(location)
		user.visible_message("[user] deploys [loaded].", "<span class='notice'>You deploy [loaded].</span>")
		loaded = null
	else
		to_chat(user, "<span class='warning'>The dock is empty!</span>")

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
		. += "<span class='abductor'>Fairly sure we absolutely stole that technology.</span>"

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
		. += "<span class='abductor'>Fairly sure we absolutely stole that technology... Why did we steal this again?</span>"
