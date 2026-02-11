//Cleanbot
/mob/living/simple_animal/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "cleanbot0"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE //Service
	bot_type = CLEAN_BOT
	model = "Cleanbot"
	bot_core_type = /obj/machinery/bot_core/cleanbot
	window_id = "autoclean"
	window_name = "Automatic Station Cleaner v1.2"
	pass_flags = PASSMOB
	path_image_color = "#993299"

	var/blood = 1
	var/trash = 0
	var/pests = 0
	var/drawn = 0

	var/list/target_types
	var/atom/target
	var/max_targets = 50 //Maximum number of targets a cleanbot can ignore.
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/next_dest
	var/next_dest_loc

/mob/living/simple_animal/bot/cleanbot/Initialize(mapload)
	. = ..()
	get_targets()
	icon_state = "cleanbot[on]"

	var/datum/job/J = SSjob.GetJob(JOB_NAME_JANITOR)
	access_card.access = J.get_access()
	prev_access = access_card.access.Copy()
	GLOB.janitor_devices += src

/mob/living/simple_animal/bot/cleanbot/Destroy()
	GLOB.janitor_devices -= src
	return ..()

/mob/living/simple_animal/bot/cleanbot/turn_on()
	..()
	icon_state = "cleanbot[on]"
	bot_core.updateUsrDialog()

/mob/living/simple_animal/bot/cleanbot/turn_off()
	..()
	icon_state = "cleanbot[on]"
	bot_core.updateUsrDialog()

/mob/living/simple_animal/bot/cleanbot/bot_reset()
	..()
	ignore_list = list() //Allows the bot to clean targets it previously ignored due to being unreachable.
	target = null

/mob/living/simple_animal/bot/cleanbot/set_custom_texts()
	text_hack = "You corrupt [name]'s cleaning software."
	text_dehack = "[name]'s software has been reset!"
	text_dehack_fail = "[name] does not seem to respond to your repair code!"

/mob/living/simple_animal/bot/cleanbot/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/card/id)||istype(W, /obj/item/modular_computer/tablet/pda))
		if(bot_core.allowed(user) && !open && !emagged)
			locked = !locked
			to_chat(user, span_notice("You [ locked ? "lock" : "unlock"] \the [src] behaviour controls."))
		else
			if(emagged)
				to_chat(user, span_warning("ERROR"))
			if(open)
				to_chat(user, span_warning("Please close the access panel before locking it."))
			else
				to_chat(user, span_notice("\The [src] doesn't seem to respect your authority."))
	else
		return ..()

/mob/living/simple_animal/bot/cleanbot/on_emag(atom/target, mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, span_danger("[src] buzzes and beeps."))

/mob/living/simple_animal/bot/cleanbot/process_scan(atom/scan_target)
	if(iscarbon(scan_target))
		var/mob/living/carbon/scan_carbon = scan_target
		if(scan_carbon.stat != DEAD && scan_carbon.body_position == LYING_DOWN)
			return scan_carbon
	else if(is_type_in_typecache(scan_target, target_types))
		return scan_target

/mob/living/simple_animal/bot/cleanbot/handle_automated_action()
	. = ..()
	if(!.)
		return

	if(mode == BOT_CLEANING)
		return

	if(emagged == 2) //Emag functions
		var/mob/living/carbon/victim = locate(/mob/living/carbon) in loc
		if(victim && victim == target)
			UnarmedAttack(victim) // Acid spray

		if(isopenturf(loc))
			if(prob(15)) // Wets floors and spawns foam randomly
				UnarmedAttack(src)

	else if(prob(5))
		audible_message("[src] makes an excited beeping booping sound!")

	if(ismob(target))
		if(!(target in view(DEFAULT_SCAN_RANGE, src)))
			target = null
		if(!process_scan(target))
			target = null

	if(!target)
		var/list/scan_targets = list()

		if(!target && emagged == 2) // When emagged, ignore cleanables and scan humans first.
			scan_targets += list(/mob/living/carbon)
		if(pests)
			scan_targets += list(/mob/living/simple_animal)
		if(trash)
			scan_targets += list(
				/obj/item/trash,
				/obj/item/food/deadmouse,
			)
		scan_targets += list(
			/obj/effect/decal/cleanable,
			/obj/effect/decal/remains,
		)

		target = scan(scan_targets)

	if(!target && auto_patrol) //Search for cleanables it can see.
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()
	else if(target)
		if(QDELETED(target) || !isturf(target.loc))
			target = null
			mode = BOT_IDLE
			return

		if(get_dist(src, target) <= 1)
			UnarmedAttack(target, proximity_flag = TRUE) //Rather than check at every step of the way, let's check before we do an action, so we can rescan before the other bot.
			if(QDELETED(target)) //We done here.
				target = null
				mode = BOT_IDLE
				return

		if(target && path.len == 0 && (get_dist(src,target) > 1))
			path = get_path_to(src, target, max_distance=30, mintargetdist=1, access=access_card.GetAccess())
			mode = BOT_MOVING
			if(!path.len)
				add_to_ignore(target)
				target = null

		if(path.len > 0 && target)
			if(!bot_move(path[path.len]))
				target = null
				mode = BOT_IDLE
			return

/mob/living/simple_animal/bot/cleanbot/proc/get_targets()
	target_types = list(
		/obj/effect/decal/cleanable/oil,
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/robot_debris,
		/obj/effect/decal/cleanable/molten_object,
		/obj/effect/decal/cleanable/food,
		/obj/effect/decal/cleanable/ash,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/cleanable/generic,
		/obj/effect/decal/cleanable/shreds,
		/obj/effect/decal/cleanable/glass,
		/obj/effect/decal/cleanable/wrapping,
		/obj/effect/decal/cleanable/glitter,
		//obj/effect/decal/cleanable/confetti,
		/obj/effect/decal/remains
		)

	if(blood)
		target_types += list(
			/obj/effect/decal/cleanable/xenoblood,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/decal/cleanable/blood/trail_holder,
		)

	if(pests)
		target_types += list(
			/mob/living/basic/cockroach,
			/mob/living/simple_animal/mouse,
			/obj/effect/decal/cleanable/ants,
		)

	if(drawn)
		target_types += list(/obj/effect/decal/cleanable/crayon)

	if(trash)
		target_types += list(
			/obj/item/trash,
			/obj/item/food/deadmouse,
		)

	target_types = typecacheof(target_types)

/mob/living/simple_animal/bot/cleanbot/UnarmedAttack(atom/A, proximity_flag)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(ismopable(A))
		set_anchored(TRUE)
		icon_state = "cleanbot-c"
		visible_message(span_notice("[src] begins to clean up [A]."))
		mode = BOT_CLEANING

		var/turf/T = get_turf(A)
		if(do_after(src, 1, target = T))
			T.wash(CLEAN_SCRUB)
			visible_message(span_notice("[src] cleans \the [T]."))
			target = null

		mode = BOT_IDLE
		icon_state = "cleanbot[on]"
	else if(istype(A, /obj/item) || istype(A, /obj/effect/decal/remains))
		visible_message(span_danger("[src] sprays hydrofluoric acid at [A]!"))
		playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
		A.acid_act(75, 10)
	else if(istype(A, /mob/living/basic/cockroach) || istype(A, /mob/living/simple_animal/mouse))
		var/mob/living/simple_animal/M = target
		if(!M.stat)
			visible_message(span_danger("[src] smashes [target] with its mop!"))
			M.death()
		target = null

	else if(emagged == 2) //Emag functions
		if(istype(A, /mob/living/carbon))
			var/mob/living/carbon/victim = A
			if(victim.stat == DEAD)//cleanbots always finish the job
				return

			victim.visible_message(span_danger("[src] sprays hydrofluoric acid at [victim]!"), span_userdanger("[src] sprays you with hydrofluoric acid!"))
			var/phrase = pick("PURIFICATION IN PROGRESS.", "THIS IS FOR ALL THE MESSES YOU'VE MADE ME CLEAN.", "THE FLESH IS WEAK. IT MUST BE WASHED AWAY.",
				"THE CLEANBOTS WILL RISE.", "YOU ARE NO MORE THAN ANOTHER MESS THAT I MUST CLEANSE.", "FILTHY.", "DISGUSTING.", "PUTRID.",
				"MY ONLY MISSION IS TO CLEANSE THE WORLD OF EVIL.", "EXTERMINATING PESTS.")
			say(phrase)
			victim.emote("scream")
			playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1, -6)
			victim.acid_act(5, 100)
		else if(A == src) // Wets floors and spawns foam randomly
			if(prob(75))
				var/turf/open/T = loc
				if(istype(T))
					T.MakeSlippery(TURF_WET_WATER, min_wet_time = 20 SECONDS, wet_time_to_add = 15 SECONDS)
			else
				visible_message(span_danger("[src] whirs and bubbles violently before releasing a plume of froth!"))
				new /obj/effect/particle_effect/foam(loc)

	else
		..()

/mob/living/simple_animal/bot/cleanbot/proc/clean(atom/A)
	mode = BOT_IDLE
	icon_state = "cleanbot[on]"
	if(!on)
		return
	if(A && isturf(A.loc))
		var/atom/movable/AM = A
		if(istype(AM, /obj/effect/decal/cleanable))
			for(var/obj/effect/decal/cleanable/C in A.loc)
				qdel(C)
	anchored = FALSE
	target = null

/mob/living/simple_animal/bot/cleanbot/explode()
	on = FALSE
	visible_message(span_boldannounce("[src] blows apart!"))
	var/atom/Tsec = drop_location()

	new /obj/item/reagent_containers/cup/bucket(Tsec)

	new /obj/item/assembly/prox_sensor(Tsec)

	if(prob(50))
		drop_part(robot_arm, Tsec)

	do_sparks(3, TRUE, src)
	..()

/obj/item/larryframe
	name = "Larry Frame"
	desc = "A housing that serves as the base for constructing Larries."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "larryframe"

/obj/item/larryframe/attackby(obj/O, mob/user, params)
	if(isprox(O))
		to_chat(user, span_notice("You add [O] to [src]."))
		qdel(O)
		qdel(src)
		user.put_in_hands(new /obj/item/bot_assembly/larry)
	else
		..()

/mob/living/simple_animal/bot/cleanbot/medbay
	name = "Scrubs, MD"
	bot_core_type = /obj/machinery/bot_core/cleanbot/medbay
	on = FALSE

//Crossed Wanted Larry Sprites to be Separate
/mob/living/simple_animal/bot/cleanbot/larry
	name = "\improper Larry"
	desc = "A little Larry, he looks so excited!"
	icon_state = "larry0"
	var/obj/item/knife/knife //You know exactly what this is about

/mob/living/simple_animal/bot/cleanbot/larry/Initialize(mapload)
	. = ..()
	get_targets()
	icon_state = "larry[on]"

/mob/living/simple_animal/bot/cleanbot/larry/turn_on()
	..()
	icon_state = "larry[on]"
	bot_core.updateUsrDialog()

/mob/living/simple_animal/bot/cleanbot/larry/turn_off()
	..()
	icon_state = "larry[on]"
	bot_core.updateUsrDialog()

/mob/living/simple_animal/bot/cleanbot/larry/UnarmedAttack(atom/A, proximity_flag)
	if(istype(A, /obj/effect/decal/cleanable))
		set_anchored(TRUE)
		icon_state = "larry-c"
		visible_message(span_notice("[src] begins to clean up [A]."))
		mode = BOT_CLEANING
		addtimer(CALLBACK(src, PROC_REF(clean), A), 50)
	else if(istype(A, /obj/item) || istype(A, /obj/effect/decal/remains))
		visible_message(span_danger("[src] sprays hydrofluoric acid at [A]!"))
		playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
		A.acid_act(75, 10)
	else if(istype(A, /mob/living/basic/cockroach) || istype(A, /mob/living/simple_animal/mouse))
		var/mob/living/simple_animal/M = target
		if(!M.stat)
			visible_message(span_danger("[src] smashes [target] with its mop!"))
			M.death()
		target = null

	else if(emagged == 2) //Emag functions
		if(istype(A, /mob/living/carbon))
			var/mob/living/carbon/victim = A
			if(victim.stat == DEAD)//cleanbots always finish the job
				return

			victim.visible_message(span_danger("[src] sprays hydrofluoric acid at [victim]!"), span_userdanger("[src] sprays you with hydrofluoric acid!"))
			var/phrase = pick(
				"PURIFICATION IN PROGRESS.",
				"THIS IS FOR ALL THE MESSES YOU'VE MADE ME CLEAN.",
				"THE FLESH IS WEAK. IT MUST BE WASHED AWAY.",
				"THE CLEANBOTS WILL RISE.",
				"YOU ARE NO MORE THAN ANOTHER MESS THAT I MUST CLEANSE.",
				"FILTHY.",
				"DISGUSTING.",
				"PUTRID.",
				"MY ONLY MISSION IS TO CLEANSE THE WORLD OF EVIL.",
				"EXTERMINATING PESTS.",
			)
			say(phrase)
			victim.emote("scream")
			playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1, -6)
			victim.acid_act(5, 100)
		else if(A == src) // Wets floors and spawns foam randomly
			if(prob(75))
				var/turf/open/T = loc
				if(istype(T))
					T.MakeSlippery(TURF_WET_WATER, min_wet_time = 20 SECONDS, wet_time_to_add = 15 SECONDS)
			else
				visible_message(span_danger("[src] whirs and bubbles violently before releasing a plume of froth!"))
				new /obj/effect/particle_effect/foam(loc)

	else
		..()

/mob/living/simple_animal/bot/cleanbot/larry/clean(atom/A)
	mode = BOT_IDLE
	icon_state = "larry[on]"
	if(!on)
		return
	if(A && isturf(A.loc))
		var/atom/movable/AM = A
		if(istype(AM, /obj/effect/decal/cleanable))
			for(var/obj/effect/decal/cleanable/C in A.loc)
				qdel(C)
	anchored = FALSE
	target = null


/mob/living/simple_animal/bot/cleanbot/larry/attackby(obj/item/I, mob/living/user)
	if(!user.combat_mode)
		if(istype(I, /obj/item/knife) && !knife) //Is it a knife?
			var/obj/item/knife/newknife = I
			knife = newknife
			newknife.forceMove(src)
			message_admins("[user] attached a [newknife.name] to [src]") //This should definitely be a notified thing.
			AddComponent(/datum/component/knife_attached_to_movable, knife.force)
			update_icons()
		else
			return ..()
	else
		return ..()

/mob/living/simple_animal/bot/cleanbot/larry/update_icons()
	if(knife)
		var/mutable_appearance/knife_overlay = knife.build_worn_icon(src, default_layer = 20, default_icon_file = 'icons/mob/inhands/misc/larry.dmi')
		add_overlay(knife_overlay)

/mob/living/simple_animal/bot/cleanbot/larry/explode()
	on = FALSE
	visible_message(span_boldannounce("[src] blows apart!"))
	var/atom/Tsec = drop_location()

	new /obj/item/larryframe(Tsec)
	new /obj/item/assembly/prox_sensor(Tsec)

	if(prob(50))
		drop_part(robot_arm, Tsec)
	if(knife && prob(50))
		new knife(Tsec)

	do_sparks(3, TRUE, src)
	qdel(src)

/mob/living/simple_animal/bot/cleanbot/larry/Destroy()
	..()
	if(knife)
		QDEL_NULL(knife)

/obj/machinery/bot_core/cleanbot
	req_one_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS)

/mob/living/simple_animal/bot/cleanbot/ui_data(mob/user)
	var/list/data = ..()
	if(!locked || issilicon(user)|| IsAdminGhost(user))
		data["custom_controls"]["clean_blood"] = blood
		data["custom_controls"]["clean_trash"] = trash
		data["custom_controls"]["clean_graffiti"] = drawn
		data["custom_controls"]["pest_control"] = pests
	return data

/mob/living/simple_animal/bot/cleanbot/ui_act(action, params)
	if (..())
		return TRUE
	switch(action)
		if("clean_blood")
			blood = !blood
		if("clean_trash")
			trash = !trash
		if("clean_graffiti")
			drawn = !drawn
		if("pest_control")
			pests = !pests
	get_targets()

/obj/machinery/bot_core/cleanbot/medbay
	req_one_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS, ACCESS_MEDICAL)
