/obj/structure/chair
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon = 'icons/obj/beds_chairs/chairs.dmi'
	icon_state = "chair"
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 0 //you sit in a chair, not lay
	resistance_flags = NONE
	max_integrity = 250
	integrity_failure = 0.1
	custom_materials = list(/datum/material/iron = 2000)
	move_resist = MOVE_FORCE_WEAK
	layer = OBJ_LAYER
	var/buildstacktype = /obj/item/stack/sheet/iron
	var/buildstackamount = 1
	var/item_chair = /obj/item/chair // if null it can't be picked up
	/// Used to handle rotation properly, should only be 1, 4, or 8
	var/possible_dirs = 4
	var/colorable = FALSE

/obj/structure/chair/examine(mob/user)
	. = ..()
	. += span_notice("It's held together by a couple of <b>bolts</b>.")
	if(!has_buckled_mobs())
		. += span_notice("Drag your sprite to sit in it.")

/obj/structure/chair/Initialize(mapload)
	. = ..()
	MakeRotate()

///This proc adds the rotate component, overwrite this if you for some reason want to change some specific args.
/obj/structure/chair/proc/MakeRotate()
	AddComponent(/datum/component/simple_rotation, ROTATION_IGNORE_ANCHORED|ROTATION_GHOSTS_ALLOWED)

/obj/structure/chair/Destroy()
	SSjob.latejoin_trackers -= src	//These may be here due to the arrivals shuttle
	return ..()

/obj/structure/chair/deconstruct(disassembled)
	// If we have materials, and don't have the NOCONSTRUCT flag
	if(!(flags_1 & NODECONSTRUCT_1))
		if(buildstacktype)
			new buildstacktype(loc,buildstackamount)
		else
			for(var/i in custom_materials)
				var/datum/material/M = i
				new M.sheet_type(loc, FLOOR(custom_materials[M] / MINERAL_MATERIAL_AMOUNT, 1))
	..()

/obj/structure/chair/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/chair/narsie_act()
	var/obj/structure/chair/wood/W = new/obj/structure/chair/wood(get_turf(src))
	W.setDir(dir)
	qdel(src)

/obj/structure/chair/ratvar_act()
	var/obj/structure/chair/fancy/brass/B = new(get_turf(src))
	B.setDir(dir)
	qdel(src)

/obj/structure/chair/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/structure/chair/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/assembly/shock_kit))
		if(!user.temporarilyRemoveItemFromInventory(W))
			return
		var/obj/item/assembly/shock_kit/SK = W
		var/obj/structure/chair/e_chair/E = new /obj/structure/chair/e_chair(src.loc)
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		E.setDir(dir)
		E.part = SK
		SK.forceMove(E)
		SK.master = E
		qdel(src)
	else
		return ..()

/obj/structure/chair/wrench_act_secondary(mob/living/user, obj/item/weapon)
	if(flags_1&NODECONSTRUCT_1)
		return TRUE
	..()
	weapon.play_tool_sound(src)
	deconstruct(disassembled = TRUE)
	return TRUE

/obj/structure/chair/attack_tk(mob/user)
	if(!anchored || has_buckled_mobs() || !isturf(user.loc))
		return ..()
	setDir(turn(dir,-90))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/structure/chair/proc/handle_rotation(direction)
	handle_layer()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(direction)

/obj/structure/chair/proc/handle_layer()
	if(has_buckled_mobs() && dir == NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER

/obj/structure/chair/post_buckle_mob(mob/living/M)
	. = ..()
	handle_layer()

/obj/structure/chair/post_unbuckle_mob()
	. = ..()
	handle_layer()

/obj/structure/chair/setDir(newdir)
	..()
	handle_rotation(newdir)

// Chair types

/obj/structure/chair/old
	name = "strange chair"
	desc = "You sit in this. Either by will or force. Looks VERY uncomfortable."
	icon_state = "chairold"
	item_chair = null

/obj/structure/chair/mime
	name = "invisible chair"
	desc = "The mime needs to sit down and shut up."
	anchored = FALSE
	icon_state = null
	buildstacktype = null
	item_chair = null
	flags_1 = NODECONSTRUCT_1

/obj/structure/chair/mime/post_buckle_mob(mob/living/M)
	M.pixel_y += 5

/obj/structure/chair/mime/post_unbuckle_mob(mob/living/M)
	M.pixel_y -= 5

///Material chair
/obj/structure/chair/greyscale
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	item_chair = /obj/item/chair/greyscale
	buildstacktype = null //Custom mats handle this

/obj/structure/chair/wood
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstacktype = /obj/item/stack/sheet/wood
	buildstackamount = 3
	item_chair = /obj/item/chair/wood

/obj/structure/chair/wood/narsie_act()
	return

/obj/structure/chair/wood/normal //Kept for map compatibility

/obj/structure/chair/wood/wings
	icon_state = "wooden_chair_wings"
	item_chair = /obj/item/chair/wood/wings

/obj/structure/chair/fancy //base for any chair with armrests
	name = "fancy chair"
	desc = "It gives you the feel of importance by just having armrests."
	icon_state = "chair_fancy"
	item_chair = /obj/item/chair/fancy
	var/mutable_appearance/armrest

/obj/structure/chair/fancy/proc/GetArmrest()
	return mutable_appearance(initial(icon), "[icon_state]_armrest", ABOVE_MOB_LAYER)

/obj/structure/chair/fancy/Destroy()
	QDEL_NULL(armrest)
	return ..()

/obj/structure/chair/fancy/post_buckle_mob(mob/living/M)
	. = ..()
	update_armrest()

/obj/structure/chair/fancy/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

/obj/structure/chair/fancy/post_unbuckle_mob()
	. = ..()
	update_armrest()

/obj/structure/chair/fancy/attackby(obj/item/I, mob/living/user)
	. = ..()
	if(!colorable)
		return
	if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = I
		var/new_color = C.paint_color
		var/list/hsl = rgb2hsl(hex2num(copytext(new_color, 2, 4)), hex2num(copytext(new_color, 4, 6)), hex2num(copytext(new_color, 6, 8)))
		hsl[3] = max(hsl[3], 0.4)
		var/list/rgb = hsl2rgb(arglist(hsl))
		color = "#[num2hex(rgb[1], 2)][num2hex(rgb[2], 2)][num2hex(rgb[3], 2)]"
	if(color)
		cut_overlay(armrest)
		armrest = GetArmrest()
		update_armrest()

/obj/structure/chair/fancy/Initialize(mapload)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/chair/fancy/comfy
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfychair"
	color = rgb(141,70,0) //gotta keep the legacy color!
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstackamount = 2
	item_chair = null
	colorable = TRUE

/obj/structure/chair/fancy/corp
	color = null
	name = "corporate chair"
	desc = "It looks professional."
	icon_state = "comfychair_corp"
	buildstackamount = 1
	item_chair = null

/obj/structure/chair/fancy/shuttle
	name = "shuttle seat"
	desc = "A comfortable, secure seat. It has a more sturdy looking buckling system for smoother flights."
	icon_state = "shuttle_chair"
	buildstackamount = 1
	item_chair = null

/obj/structure/chair/fancy/plastic
	name = "plastic chair"
	desc = "If you want it, then you'll have to take it."
	icon_state = "plastic_chair"
	anchored = FALSE
	resistance_flags = FLAMMABLE
	max_integrity = 150
	custom_materials = list(/datum/material/plastic = 2000)
	buildstacktype = /obj/item/stack/sheet/plastic
	buildstackamount = 1
	item_chair = /obj/item/chair/plastic

/obj/structure/chair/fancy/plastic/post_buckle_mob(mob/living/M) //you do not want to see an angry spaceman speeding while holding dearly onto it
	. = ..()
	anchored = TRUE
	if(iscarbon(M))
		INVOKE_ASYNC(src, PROC_REF(snap_check), M)

/obj/structure/chair/fancy/plastic/post_unbuckle_mob()
	. = ..()
	handle_layer()
	anchored = FALSE

/obj/structure/chair/fancy/plastic/proc/snap_check(mob/living/M)
	if (M.nutrition >= NUTRITION_LEVEL_FAT) //you are so fat
		to_chat(M, span_warning("The chair begins to pop and crack, you're too heavy!"))
		if(do_after(M, 6 SECONDS, progress = FALSE))
			M.visible_message(span_notice("The plastic chair snaps under [M]'s weight!"))
			qdel(src)

/obj/structure/chair/fancy/brass
	name = "brass chair"
	desc = "A spinny chair made of brass. It looks uncomfortable."
	icon_state = "brass_chair"
	max_integrity = 150
	buildstacktype = /obj/item/stack/sheet/brass
	buildstackamount = 1
	item_chair = null
	var/turns = 0

/obj/structure/chair/fancy/brass/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/structure/chair/fancy/brass/process()
	setDir(turn(dir,-90))
	playsound(src, 'sound/effects/servostep.ogg', 50, FALSE)
	turns++
	if(turns >= 8)
		STOP_PROCESSING(SSfastprocess, src)

/obj/structure/chair/fancy/brass/relaymove(mob/user, direction)
	if(!direction)
		return FALSE
	if(direction == dir)
		return
	setDir(direction)
	playsound(src, 'sound/effects/servostep.ogg', 50, FALSE)
	return FALSE

/obj/structure/chair/fancy/brass/ratvar_act()
	return

/obj/structure/chair/fancy/brass/AltClick(mob/living/user)
	turns = 0
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	if(!(datum_flags & DF_ISPROCESSING))
		user.visible_message(span_notice("[user] spins [src] around, and Ratvarian technology keeps it spinning FOREVER."), \
		span_notice("Automated spinny chairs. The pinnacle of Ratvarian technology."))
		START_PROCESSING(SSfastprocess, src)
	else
		user.visible_message(span_notice("[user] stops [src]'s uncontrollable spinning."), \
		span_notice("You grab [src] and stop its wild spinning."))
		STOP_PROCESSING(SSfastprocess, src)

/obj/structure/chair/fancy/brass/bronze
	name = "bronze chair"
	desc = "A spinny chair made of bronze. It has little cogs for wheels!"
	anchored = FALSE
	icon_state = "brass_chair"
	buildstacktype = /obj/item/stack/sheet/bronze
	buildstackamount = 1
	item_chair = null

/obj/structure/chair/fancy/brass/bronze/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/machines/clockcult/integration_cog_install.ogg', 50, TRUE)

/obj/structure/chair/office
	name = "office chair"
	desc = "The propulsion of any lazy office worker, it has wheels."
	anchored = FALSE
	buildstackamount = 5
	item_chair = null
	icon_state = "officechair_dark"

/obj/structure/chair/office/relaymove(mob/user, direction)
	if(!direction)
		return FALSE
	if(direction == dir)
		return
	setDir(direction)
	return FALSE

/obj/structure/chair/office/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, 1)

/obj/structure/chair/office/light
	icon_state = "officechair_white"

/obj/structure/chair/foldable
	icon_state = "chair_foldable"
	name = "folding chair"
	desc = "No matter how much you squirm, it'll still be uncomfortable."
	max_integrity = 50
	buildstackamount = 2
	item_chair = /obj/item/chair/foldable
	anchored = FALSE

/obj/structure/chair/foldable/post_buckle_mob(mob/living/Mob)
	Mob.pixel_y += 2
	anchored = TRUE

/obj/structure/chair/foldable/post_unbuckle_mob(mob/living/Mob)
	Mob.pixel_y -= 2
	anchored = FALSE

//Stool

/obj/structure/chair/stool
	name = "stool"
	desc = "Apply butt."
	icon_state = "stool"
	can_buckle = 0
	buildstackamount = 1
	item_chair = /obj/item/chair/stool

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/chair/stool, 0)

/obj/structure/chair/stool/narsie_act()
	return

/obj/structure/chair/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!item_chair || has_buckled_mobs() || src.flags_1 & NODECONSTRUCT_1)
			return
		if(!usr.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
			return
		usr.visible_message(span_notice("[usr] grabs \the [src.name]."), span_notice("You grab \the [src.name]."))
		var/obj/item/C = new item_chair(loc)
		C.set_custom_materials(custom_materials)
		TransferComponents(C)
		usr.put_in_hands(C)
		qdel(src)

/obj/structure/chair/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	return ..()

/obj/structure/chair/stool/bar
	name = "bar stool"
	desc = "The apex of the bar experience."
	icon_state = "bar"
	item_chair = /obj/item/chair/stool/bar

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/chair/stool/bar, 0)

/obj/structure/chair/stool/bamboo
	name = "bamboo stool"
	desc = "A makeshift bamboo stool with a rustic look."
	icon_state = "bamboo_stool"
	resistance_flags = FLAMMABLE
	max_integrity = 60
	buildstacktype = /obj/item/stack/sheet/bamboo
	buildstackamount = 2
	item_chair = /obj/item/chair/stool/bamboo
