/obj/item/grenade/exploration
	name = "breaching charges"
	desc = "Used by exploration crews to breach and demolish unknown places. Requires a nearby detonator to be triggered."
	icon_state = "plastic-explosive0"
	inhand_icon_state = "plastic-explosive"
	lefthand_file = 'icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/bombs_righthand.dmi'
	item_flags = NOBLUDGEON
	flags_1 = NONE
	w_class = WEIGHT_CLASS_SMALL
	var/atom/target = null
	var/mutable_appearance/plastic_overlay
	var/light_exp_range = 3
	var/heavy_range = 0
	var/devastation_range = 0
	var/list/attached_detonators = list()

/obj/item/grenade/exploration/Initialize(mapload)
	. = ..()
	plastic_overlay = mutable_appearance(icon, "[inhand_icon_state]2", HIGH_OBJ_LAYER)

/obj/item/grenade/exploration/Destroy()
	for(var/obj/item/exploration_detonator/detonator in attached_detonators)
		detonator.linked_explosives -= src
	attached_detonators = null
	. = ..()

/obj/item/grenade/exploration/attack_self(mob/user)
	return

/obj/item/grenade/exploration/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/exploration_detonator))
		var/obj/item/exploration_detonator/detonator = W
		detonator.linked_explosives |= src
		attached_detonators |= detonator
		to_chat(user, span_notice("You link [src] to [W]."))
		return
	. = ..()

/obj/item/grenade/exploration/afterattack(atom/movable/AM, mob/user, flag)
	. = ..()

	if(!length(attached_detonators))
		to_chat(user, span_notice("[src] needs to be linked to a detonator first!"))
		return

	if(!flag)
		return
	if(ismob(AM))
		return

	to_chat(user, span_notice("You start planting [src]."))

	if(do_after(user, 30, target = AM))
		if(!user.temporarilyRemoveItemFromInventory(src))
			return
		target = AM

		message_admins("[ADMIN_LOOKUPFLW(user)] planted [name] on [target.name] at [ADMIN_VERBOSEJMP(target)]")
		log_game("[key_name(user)] planted [name] on [target.name] at [AREACOORD(user)]")

		notify_ghosts(
			"[user] has planted \a [src] on [target]!",
			source = target,
			header = "Explosive Planted",
			notify_flags = NOTIFY_CATEGORY_NOFLASH,
		)

		moveToNullspace()	//Yep

		if(istype(AM, /obj/item)) //your crappy throwing star can't fly so good with a giant brick of c4 on it.
			var/obj/item/I = AM
			I.throw_speed = max(1, (I.throw_speed - 3))
			I.throw_range = max(1, (I.throw_range - 3))
			if(I.embedding)
				I.embedding["embed_chance"] = 0
				I.updateEmbedding()
		else if(istype(AM, /mob/living))
			plastic_overlay.layer = FLOAT_LAYER

		target.add_overlay(plastic_overlay)
		to_chat(user, span_notice("You plant the bomb."))

/obj/item/grenade/exploration/prime(mob/living/lanced_by)
	. = ..()
	if(!.)
		return
	var/turf/location
	if(target)
		if(!QDELETED(target))
			location = get_turf(target)
			target.cut_overlay(plastic_overlay)
			target.ex_act(EXPLODE_HEAVY, target)
	else
		location = get_turf(src)
	if(location)
		explosion(location, devastation_range, heavy_range, light_exp_range)
	if(isliving(target))
		var/mob/living/M = target
		M.gib()
	qdel(src)

/obj/item/exploration_detonator
	name = "detonator"
	desc = "A detonator that can be linked to explosives and then... you know, detonate them."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "detonator"
	w_class = WEIGHT_CLASS_SMALL
	var/range = 16
	var/list/linked_explosives = list()

/obj/item/exploration_detonator/Destroy()
	. = ..()
	for(var/obj/item/grenade/exploration/explosive in linked_explosives)
		explosive.attached_detonators -= src
	linked_explosives = null

/obj/item/exploration_detonator/attack_self(mob/user)
	. = ..()
	if(.)
		return
	var/turf/T = get_turf(user)
	if(is_station_level(T.z) && !(obj_flags & EMAGGED))
		to_chat(user, span_warning("STATION SAFETY ENABLED."))
		return
	var/explosives_trigged = 0
	for(var/obj/item/grenade/exploration/exploration in linked_explosives)
		// If the C4 hasn't been placed, don't blow it up
		if (!exploration.target)
			continue
		var/turf/T2 = get_turf(exploration.target)
		if(T2.get_virtual_z_level() == T.get_virtual_z_level() && get_dist(exploration.target, user) <= range)
			addtimer(CALLBACK(exploration, TYPE_PROC_REF(/obj/item/grenade/exploration, prime)), 10)
			explosives_trigged ++
	to_chat(user, span_notice("[explosives_trigged] explosives triggered."))

/obj/item/exploration_detonator/on_emag(mob/user)
	..()
	to_chat(user, span_warning("You override the safety controls of [src]. You can now trigger explosives on the station."))
