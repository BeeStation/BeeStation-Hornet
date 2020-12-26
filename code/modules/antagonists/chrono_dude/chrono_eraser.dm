/*
	- CHRONO ERASER -
	
	CONTENTS
		The Backpack (and some code to protect it)
		The Gun
		Chrono Beam	(holds people in place, vaporizes people with TA antag datum)
		Chrono Field (a structure that holds people in place)
*/



#define CHRONO_BEAM_RANGE 3
#define CHRONO_FRAME_COUNT 22
/obj/item/chrono_eraser
	name = "Timestream Eradication Device"
	desc = "The result of outlawed time-bluespace research, this device is capable of wiping a being from the timestream. They never are, they never were, they never will be."
	icon = 'icons/obj/chronos.dmi'
	icon_state = "chronobackpack"
	item_state = "backpack"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	actions_types = list(/datum/action/item_action/equip_unequip_TED_Gun)
	var/obj/item/gun/energy/chrono_gun/PA = null
	var/protected = FALSE

/obj/item/chrono_eraser/proc/protection_check(mob/user)
	if (protected && !user.mind?.has_antag_datum(/datum/antagonist/tca))
		return FALSE
	return TRUE

/obj/item/chrono_eraser/equipped(mob/living/user, slot)
	..()
	if (!protection_check(user))
		to_chat(user, "<span class='warning'>As you try to equipt it, the [src] shines blue for a second, then teleports away!</span>")
		qdel(src)

/obj/item/chrono_eraser/dropped()
	..()
	if(PA)
		qdel(PA)

/obj/item/chrono_eraser/Destroy()
	dropped()
	return ..()

/obj/item/chrono_eraser/ui_action_click(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.back == src)
			if(PA)
				qdel(PA)
			else
				PA = new(src)
				user.put_in_hands(PA)

/obj/item/chrono_eraser/item_action_slot_check(slot, mob/user)
	if(slot == SLOT_BACK)
		return 1

/obj/item/gun/energy/chrono_gun
	name = "T.E.D. Projection Apparatus"
	desc = "It's as if they never existed in the first place."
	icon = 'icons/obj/chronos.dmi'
	icon_state = "chronogun"
	item_state = "chronogun"
	w_class = WEIGHT_CLASS_NORMAL
	item_flags = DROPDEL
	ammo_type = list(/obj/item/ammo_casing/energy/chrono_beam,/obj/item/ammo_casing/energy/electrode/spec)
	can_charge = FALSE
	fire_delay = 50
	var/obj/item/chrono_eraser/TED = null
	var/turf/startpos = null

/obj/item/gun/energy/chrono_gun/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHRONO_GUN_TRAIT)
	if(istype(loc, /obj/item/chrono_eraser))
		TED = loc
	else //admin must have spawned it
		TED = new(src.loc)
		return INITIALIZE_HINT_QDEL

/obj/item/gun/energy/chrono_gun/update_icon()
	return

/obj/item/gun/energy/chrono_gun/Destroy()
	if(TED)
		TED.PA = null
		TED = null
	return ..()

/obj/item/projectile/energy/chrono_beam
	name = "eradicate"
	icon_state = "chronobolt"
	range = CHRONO_BEAM_RANGE
	nodamage = TRUE
	var/obj/item/gun/energy/chrono_gun/gun = null

/obj/item/projectile/energy/chrono_beam/Initialize()
	. = ..()
	var/obj/item/ammo_casing/energy/chrono_beam/C = loc
	if(istype(C))
		gun = C.gun

/obj/item/projectile/energy/chrono_beam/on_hit(atom/target)
	if(target && gun && isliving(target))
		var/mob/living/PT = target
		if (PT.mind?.has_antag_datum(/datum/antagonist/ta))
			PT.dust()
		else
			new /obj/structure/chrono_field(target.loc, target, gun)


/obj/item/ammo_casing/energy/chrono_beam
	name = "eradication beam"
	projectile_type = /obj/item/projectile/energy/chrono_beam
	icon_state = "chronobolt"
	e_cost = 0
	var/obj/item/gun/energy/chrono_gun/gun

/obj/item/ammo_casing/energy/chrono_beam/Initialize()
	if(istype(loc))
		gun = loc
	. = ..()

/obj/structure/chrono_field
	name = "eradication field"
	desc = "An aura of time-bluespace energy."
	icon = 'icons/effects/effects.dmi'
	icon_state = "chronofield"
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	move_resist = INFINITY
	interaction_flags_atom = NONE
	var/mob/living/captured = null
	var/tickstokill = 15
	var/mutable_appearance/mob_underlay
	var/preloaded = 0
	var/RPpos = null

/obj/structure/chrono_field/Initialize(mapload, mob/living/target, obj/item/gun/energy/chrono_gun/G)
	if(target && isliving(target) && G)
		target.forceMove(src)
		captured = target
		var/icon/mob_snapshot = getFlatIcon(target)
		var/icon/cached_icon = new()

		for(var/i=1, i<=CHRONO_FRAME_COUNT, i++)
			var/icon/removing_frame = icon('icons/obj/chronos.dmi', "erasing", SOUTH, i)
			var/icon/mob_icon = icon(mob_snapshot)
			mob_icon.Blend(removing_frame, ICON_MULTIPLY)
			cached_icon.Insert(mob_icon, "frame[i]")

		mob_underlay = mutable_appearance(cached_icon, "frame1")
		update_icon()

		desc = initial(desc) + "<br><span class='info'>It appears to contain [target.name].</span>"
	START_PROCESSING(SSobj, src)
	return ..()

/obj/structure/chrono_field/update_icon()
	var/ttk_frame = 1 - (tickstokill / initial(tickstokill))
	ttk_frame = CLAMP(CEILING(ttk_frame * CHRONO_FRAME_COUNT, 1), 1, CHRONO_FRAME_COUNT)
	if(ttk_frame != RPpos)
		RPpos = ttk_frame
		mob_underlay.icon_state = "frame[RPpos]"
		underlays = list() //hack: BYOND refuses to update the underlay to match the icon_state otherwise
		underlays += mob_underlay

/obj/structure/chrono_field/process()
	if(captured)
		if(tickstokill > initial(tickstokill))
			for(var/atom/movable/AM in contents)
				AM.forceMove(drop_location())
			qdel(src)
		else
			captured.Unconscious(80)
			if(captured.loc != src)
				captured.forceMove(src)
			update_icon()
			tickstokill++
	else
		qdel(src)

/obj/structure/chrono_field/assume_air()
	return 0

/obj/structure/chrono_field/return_air() //we always have nominal air and temperature
	var/datum/gas_mixture/GM = new
	GM.set_moles(/datum/gas/oxygen, MOLES_O2STANDARD)
	GM.set_moles(/datum/gas/nitrogen, MOLES_N2STANDARD)
	GM.set_temperature(T20C)
	return GM

/obj/structure/chrono_field/singularity_act()
	return

/obj/structure/chrono_field/singularity_pull()
	return

/obj/structure/chrono_field/ex_act()
	return

/obj/structure/chrono_field/blob_act(obj/structure/blob/B)
	return


#undef CHRONO_BEAM_RANGE
#undef CHRONO_FRAME_COUNT
