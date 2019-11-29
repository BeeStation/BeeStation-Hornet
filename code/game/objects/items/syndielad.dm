#define POWEROFF "poweroff"
#define UPLINK "uplink"
#define PINPOINTER "pinpointer"
#define DETONATE "detonate"

/obj/item/clothing/gloves/syndielad
	name = "syndie-lad"
	desc = "A Syndie-Lad portable arm-mounted computer, generally used to assist with directives. It utilizes outdated technology, but it's extremely cheap and durable, ensuring its \
	continued production and relevancy."
	gender = MALE // Yes, this is an actual clothing var. Prevents examine from showing "they" despite the syndie-lad being a single item
	alternate_worn_icon = 'icons/obj/syndielad.dmi'
	icon = 'icons/obj/syndielad.dmi'
	icon_state = "syndilad"
	item_state = "syndilad-worn"
	strip_delay = 100
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	always_obscured = TRUE
	var/syndilad_on = FALSE
	var/syndilad_ready = TRUE // basically just prevents breaking the animations
	var/syndilad_pinactive = FALSE
	var/atom/movable/syndilad_target
	var/syndilad_minimum_range = 0
	var/syndilad_detonating = FALSE
	var/syndilad_bombmessage = "WAR NEVER CHANGES"
	var/mob/living/carbon/human/wearer = null
	var/bomb_armed = FALSE

/obj/item/clothing/gloves/syndielad/Initialize(mapload, owner, tc_amount = 0)
	. = ..()
	AddComponent(/datum/component/uplink, owner, FALSE, TRUE, null, tc_amount)
	GLOB.pinpointer_list += src

obj/item/clothing/gloves/syndielad/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	GLOB.pinpointer_list -= src
	syndilad_target = null
	return ..()

/obj/item/clothing/gloves/syndielad/attack_self(mob/living/user)
	if(syndilad_ready && syndilad_on)
		syndilad_menu(user)
	else
		toggle_power(user)


// Toggle Power


/obj/item/clothing/gloves/syndielad/proc/toggle_power(mob/living/user)
	if(syndilad_ready)
		playsound(src, 'sound/items/screwdriver2.ogg', 50, 1)
		if(!syndilad_on)
			syndilad_ready = FALSE
			to_chat(user, "<span class='notice'>You power on the Syndi-Lad.</span>")
			icon_state = "syndilad-turn-on"
			addtimer(20) // lets the animation play
			icon_state = "syndilad-on"
			syndilad_on = TRUE
			syndilad_ready = TRUE
		else
			to_chat(user, "<span class='notice'>You shut down the Syndi-Lad.</span>")
			syndilad_ready = FALSE
			icon_state = "syndilad-turn-off"
			addtimer(13)
			icon_state = "syndilad"
			syndilad_on = FALSE
			syndilad_ready = TRUE
		update_icon()


// Pinpointer stuff


/obj/item/clothing/gloves/syndielad/process()
	if(!syndilad_pinactive)
		return PROCESS_KILL
	scan_for_target()
	update_icon()
	..()
	for(var/obj/machinery/nuclearbomb/bomb in GLOB.nuke_list)
		if(bomb.timing)
			if(!bomb_armed)
				bomb_armed = TRUE
				playsound(src, 'sound/items/nuke_toy_lowpower.ogg', 50, 0)
				if(isliving(loc))
					var/mob/living/L = loc
					to_chat(L, "<span class='userdanger'>Your [name] vibrates and lets out a tinny alarm. Uh oh.</span>")

/obj/item/clothing/gloves/syndielad/proc/scan_for_target() // honestly only here because the pinpointer seemed to need it
	return

/obj/item/clothing/gloves/syndielad/update_icon()
	..()
	if(!syndilad_pinactive)
		return
	var/turf/here = get_turf(src)
	var/turf/there = get_turf(syndilad_target)
	if(bomb_armed)
		icon_state = "syndilad-nuke"
		return
	if(here.z != there.z || !syndilad_target)
		icon_state = "syndilad-pin-null"
		return
	if(get_dist_euclidian(here,there) <= syndilad_minimum_range)
		icon_state = "syndilad-pin-direct"
	else
		setDir(get_dir(here, there))
		icon_state = "syndilad-pin"

/obj/item/clothing/gloves/syndielad/proc/get_targets(mob/living/carbon/human/user)
	var/list/targets = list()
	for(var/B in user.mind.antag_datums)
		var/datum/antagonist/antobj = B
		if(LAZYLEN(antobj.objectives))
			for(var/A in antobj.objectives)
				var/datum/objective/O = A
				if(istype(O) && !O.check_completion())
					if(istype(O.target, /datum/mind))
						var/datum/mind/M = O.target
						targets[M.current.real_name] = M.current
					else if(istype(O, /datum/objective/steal))
						var/datum/objective/steal/S = O
						targets[S.targetinfo.name] = locate(S.targetinfo.targetitem)
	return targets

/obj/item/clothing/gloves/syndielad/proc/toggle_pinpointer(mob/living/user)
	if(syndilad_pinactive)
		syndilad_pinactive = FALSE
		STOP_PROCESSING(SSfastprocess, src)
	else
		syndilad_pinactive = TRUE
		var/list/radial_list = list()
		var/list/targets = get_targets(user)
		for(var/A in targets)
			if(istype(targets[A], /mob))
				radial_list[A] = getFlatIcon(targets[A])
			else if(istype(targets[A], /atom))
				var/atom/AT = targets[A]
				radial_list[A] = image(AT.icon, AT.icon_state)
		if(!targets)
			to_chat(user, "<span class = 'notice'>No targets found.</span>")
			syndilad_pinactive = FALSE
			return FALSE
		var/chosen = show_radial_menu(user, wearer, radial_list, custom_check = CALLBACK(src, .proc/check_menu, user))
		if(!check_menu(user))
			return
		if(chosen)
			syndilad_target = targets[chosen]
			START_PROCESSING(SSfastprocess, src)
		scan_for_target()
	update_icon()


// Detonate


/obj/item/clothing/gloves/syndielad/equipped(mob/user, slot)
	..()
	if(ishuman(user))
		wearer = user

/obj/item/clothing/gloves/syndielad/dropped()
	..()
	if(wearer)
		wearer = null

/obj/item/clothing/gloves/syndielad/proc/toggle_detonation(mob/living/user)
	var/prompt = alert("Confirm detonation?", "[syndilad_bombmessage]", "Yes", "No")
	if (prompt == "Yes" && !syndilad_detonating) // failsafe
		playsound(src, 'sound/items/screwdriver2.ogg', 50, 1)
		syndilad_detonating = TRUE
		icon_state = "syndilad-destruct"
		desc = "A Syndie-Lad portable arm-mounted computer. <span class = 'warning'>You should really stop gawking at this and run away.</span>"
		update_icon()
		to_chat(user, "<span class = 'notice'>You set the Syndie-Lad to explode!")
		message_admins("[ADMIN_LOOKUPFLW(user)] rigged a Syndie-Lad to explode!")
		log_game("[key_name(user)] rigged a Syndie-Lad to explode at [AREACOORD(user)]")
		notify_ghosts("[user] has set a Syndie-Lad to explode!", source = src, action = NOTIFY_ORBIT)
		addtimer(CALLBACK(src, .proc/kersplode), 100)
		addtimer(0.5)
		user.visible_message("<span class='warning'>[src] beeps ominously!</span>")
		playsound(user, 'sound/items/timer.ogg', 30, 0)
	else if(syndilad_detonating)
		to_chat(user, "<span class = 'userdanger'>Oh my god, [user], a bomb! Get out of there!</span>")

/obj/item/clothing/gloves/syndielad/proc/kersplode(mob/living/user, slot)
	if(wearer) // if you're wearing this and it explodes, you get a hilarious death
		var/turf/T = wearer.loc
		playsound(T, 'sound/magic/disintegrate.ogg', 200, 1, 8)
		for(var/I in 1 to 30)
			var/gibtype = pick(/obj/effect/decal/cleanable/blood/gibs/up, /obj/effect/decal/cleanable/blood/gibs/down, /obj/effect/decal/cleanable/blood/gibs, /obj/effect/decal/cleanable/blood/gibs, /obj/effect/decal/cleanable/blood/gibs/body, /obj/effect/decal/cleanable/blood/gibs/limb, /obj/effect/decal/cleanable/blood/gibs/core)
			var/obj/effect/decal/cleanable/blood/gibs/G = new gibtype(T)
			G.throw_at(get_edge_target_turf(T, pick(GLOB.alldirs)), rand(1,20), 1)
		for(var/turf/C in oview(T, 8))
			new /obj/effect/decal/cleanable/blood/splatter(C)
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(5, T, 1, 2)
		e.start()
		wearer.gib()
	explosion(src, 0, 0, 3)
	qdel(src)


// Radial Menu


/mob/living/carbon/human/key_down(_key, client/user) // STOLEN NANOSUIT CODE
	switch(_key)
		if("C")
			if(istype(gloves, /obj/item/clothing/gloves/syndielad))
				var/obj/item/clothing/gloves/syndielad/SL = gloves
				if(SL.syndilad_on && SL.syndilad_ready)
					SL.syndilad_menu(src)
				else
					SL.toggle_power(user)
				return
	..()

/obj/item/clothing/gloves/syndielad/proc/check_menu(mob/living/user)
	if(!user)
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/clothing/gloves/syndielad/proc/syndilad_menu(mob/living/user)
	if(syndilad_detonating)
		user.visible_message("<span class = 'warning'>[src] rattles violently! It's set to explode!</span>")
		return FALSE
	if(syndilad_pinactive)
		toggle_pinpointer(user)
	icon_state = "syndilad-on"
	update_icon()
	playsound(src, 'sound/items/screwdriver2.ogg', 50, 1)
	var/list/choices = list(
	"uplink" = image(icon = 'icons/obj/radio.dmi', icon_state = "radio"),
	"pinpointer" = image(icon = 'icons/obj/device.dmi', icon_state = "pinpointer"),
	"poweroff" = image(icon = 'icons/mob/radial.dmi', icon_state = "cable_invalid"),
	"detonate" = image(icon = 'icons/mob/actions/syndielad.dmi', icon_state = "detonate"),
	)
	var/choice = show_radial_menu(user,user, choices, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE)
	if(!check_menu(user) || !syndilad_ready)
		return
	switch(choice)
		if("uplink")
			var/datum/component/uplink/uplinkcomponent = GetComponent(/datum/component/uplink)
			uplinkcomponent.ui_interact(user)
			icon_state = "syndilad-uplink"
			playsound(src, 'sound/items/screwdriver2.ogg', 50, 1)
			return
		if("pinpointer")
			toggle_pinpointer(user)
			playsound(src, 'sound/items/screwdriver2.ogg', 50, 1)
			return
		if("poweroff")
			toggle_power(user)
			return
		if("detonate")
			toggle_detonation(user)
			return


// Nuclear Operative Variant


/obj/item/clothing/gloves/syndielad/nuke
	syndilad_bombmessage = "I'M NUCLEAR"

/obj/item/clothing/gloves/syndielad/nuke/Initialize()
	. = ..()
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	hidden_uplink.set_gamemode(/datum/game_mode/nuclear)

/obj/item/clothing/gloves/syndielad/nuke/scan_for_target()
	var/obj/item/disk/nuclear/N = locate() in GLOB.poi_list
	syndilad_target = N

/obj/item/clothing/gloves/syndielad/nuke/examine(mob/user)
	. = ..()
	var/msg = "Its tracking indicator reads \"nuclear disk\"."
	. += msg
	for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
		if(bomb.timing)
			. += "Extreme danger. Arming signal detected. Time remaining: [bomb.get_time_left()]."

/obj/item/clothing/gloves/syndielad/nuke/toggle_pinpointer(mob/living/user)
	syndilad_pinactive = !syndilad_pinactive
	if(syndilad_pinactive)
		START_PROCESSING(SSfastprocess, src)
	else
		syndilad_target = null
		STOP_PROCESSING(SSfastprocess, src)
	update_icon()

#undef POWEROFF
#undef UPLINK
#undef PINPOINTER
#undef DETONATE
