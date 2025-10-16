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
	var/obj/effect/decal/cleanable/target
	var/max_targets = 50 //Maximum number of targets a cleanbot can ignore.
	var/oldloc = null
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
	oldloc = null

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

/mob/living/simple_animal/bot/cleanbot/process_scan(atom/A)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(C.stat != DEAD && C.body_position == LYING_DOWN)
			return C
	else if(is_type_in_typecache(A, target_types))
		return A

/mob/living/simple_animal/bot/cleanbot/handle_automated_action()
	if(!..())
		return

	if(mode == BOT_CLEANING)
		return

	if(emagged == 2) //Emag functions
		if(isopenturf(loc))

			for(var/mob/living/carbon/victim in loc)
				if(victim != target)
					UnarmedAttack(victim) // Acid spray

			if(prob(15)) // Wets floors and spawns foam randomly
				UnarmedAttack(src)

	else if(prob(5))
		audible_message("[src] makes an excited beeping booping sound!")

	if(ismob(target))
		if(!(target in view(DEFAULT_SCAN_RANGE, src)))
			target = null
		if(!process_scan(target))
			target = null

	if(!target && emagged == 2) // When emagged, target humans who slipped on the water and melt their faces off
		target = scan(/mob/living/carbon)

	if(!target && pests) //Search for pests to exterminate first.
		target = scan(/mob/living/simple_animal)

	if(!target) //Search for decals then.
		target = scan(/obj/effect/decal/cleanable)

	if(!target) //Checks for remains
		target = scan(/obj/effect/decal/remains)

	if(!target && trash) //Then for trash.
		target = scan(/obj/item/trash)

	if(!target && auto_patrol) //Search for cleanables it can see.
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

	if(target)
		if(QDELETED(target) || !isturf(target.loc))
			target = null
			mode = BOT_IDLE
			return

		if(loc == get_turf(target))
			if(!(check_bot(target) && prob(50)))	//Target is not defined at the parent. 50% chance to still try and clean so we dont get stuck on the last blood drop.
				UnarmedAttack(target)	//Rather than check at every step of the way, let's check before we do an action, so we can rescan before the other bot.
				if(QDELETED(target)) //We done here.
					target = null
					mode = BOT_IDLE
					return
			else
				shuffle = TRUE	//Shuffle the list the next time we scan so we dont both go the same way.
			path = list()

		if(!path || path.len == 0) //No path, need a new one
			//Try to produce a path to the target, and ignore airlocks to which it has access.
			path = get_path_to(src, target, 30, id=access_card)
			if(!bot_move(target))
				add_to_ignore(target)
				target = null
				path = list()
				return
			mode = BOT_MOVING
		else if(!bot_move(target))
			target = null
			mode = BOT_IDLE
			return

	oldloc = loc

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
		/obj/effect/decal/remains
		)

	if(blood)
		target_types += /obj/effect/decal/cleanable/xenoblood
		target_types += /obj/effect/decal/cleanable/blood

	if(pests)
		target_types += /mob/living/basic/cockroach
		target_types += /mob/living/simple_animal/mouse

	if(drawn)
		target_types += /obj/effect/decal/cleanable/crayon

	if(trash)
		target_types += /obj/item/trash

	target_types = typecacheof(target_types)

/mob/living/simple_animal/bot/cleanbot/UnarmedAttack(atom/A)
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

/mob/living/simple_animal/bot/cleanbot/larry/UnarmedAttack(atom/A)
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
