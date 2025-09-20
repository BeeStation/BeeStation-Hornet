#define GIBTONITE_QUALITY_HIGH 3
#define GIBTONITE_QUALITY_MEDIUM 2
#define GIBTONITE_QUALITY_LOW 1

/obj/item/gibtonite
	name = "gibtonite ore"
	desc = "Extremely explosive if struck with mining equipment, Gibtonite is often used by miners to speed up their work by using it as a mining charge. This material is illegal to possess by unauthorized personnel under space law."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Gibtonite ore"
	item_state = "Gibtonite ore"
	w_class = WEIGHT_CLASS_BULKY
	throw_range = 0
	var/primed = FALSE
	var/det_time = 100
	var/quality = GIBTONITE_QUALITY_LOW //How pure this gibtonite is, determines the explosion produced by it and is derived from the det_time of the rock wall it was taken from, higher value = better
	var/attacher = "UNKNOWN"
	var/det_timer

/obj/item/gibtonite/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/gibtonite/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/item/gibtonite/attackby(obj/item/I, mob/user, params)
	if(!wires && istype(I, /obj/item/assembly/igniter))
		user.visible_message("[user] attaches [I] to [src].", span_notice("You attach [I] to [src]."))
		wires = new /datum/wires/explosive/gibtonite(src)
		attacher = key_name(user)
		qdel(I)
		add_overlay("Gibtonite_igniter")
		return

	if(wires && !primed)
		if(is_wire_tool(I))
			wires.interact(user)
			return

	if(I.tool_behaviour == TOOL_MINING || istype(I, /obj/item/resonator) || I.force >= 10)
		GibtoniteReaction(user)
		return
	if(primed)
		if(istype(I, /obj/item/mining_scanner) || istype(I, /obj/item/t_scanner/adv_mining_scanner) || I.tool_behaviour == TOOL_MULTITOOL)
			primed = FALSE
			if(det_timer)
				deltimer(det_timer)
			user.visible_message("The chain reaction was stopped! ...The ore's quality looks diminished.", span_notice("You stopped the chain reaction. ...The ore's quality looks diminished."))
			icon_state = "Gibtonite ore"
			quality = GIBTONITE_QUALITY_LOW
			return
	..()

/obj/item/gibtonite/attack_self(user)
	if(wires)
		wires.interact(user)
	else
		..()

/obj/item/gibtonite/bullet_act(obj/projectile/P)
	GibtoniteReaction(P.firer)
	. = ..()

/obj/item/gibtonite/ex_act()
	GibtoniteReaction(null, 1)

/obj/item/gibtonite/proc/GibtoniteReaction(mob/user, triggered_by = 0)
	if(!primed)
		primed = TRUE
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		icon_state = "Gibtonite active"
		var/notify_admins = FALSE
		if(z != 5)//Only annoy the admins ingame if we're triggered off the mining zlevel
			notify_admins = TRUE

		if(triggered_by == 1)
			log_bomber(null, "An explosion has primed a", src, "for detonation", notify_admins)
		else if(triggered_by == 2)
			var/turf/bombturf = get_turf(src)
			if(notify_admins)
				message_admins("A signal has triggered a [name] to detonate at [ADMIN_VERBOSEJMP(bombturf)]. Igniter attacher: [ADMIN_LOOKUPFLW(attacher)]")
			var/bomb_message = "A signal has primed a [name] for detonation at [AREACOORD(bombturf)]. Igniter attacher: [key_name(attacher)]."
			log_game(bomb_message)
			GLOB.bombers += bomb_message
		else
			user.visible_message(span_warning("[user] strikes \the [src], causing a chain reaction!"), span_danger("You strike \the [src], causing a chain reaction."))
			log_bomber(user, "has primed a", src, "for detonation", notify_admins)
		det_timer = addtimer(CALLBACK(src, PROC_REF(detonate), notify_admins), det_time, TIMER_STOPPABLE)

/obj/item/gibtonite/proc/detonate(notify_admins)
	if(primed)
		switch(quality)
			if(GIBTONITE_QUALITY_HIGH)
				explosion(src,2,4,9,adminlog = notify_admins)
			if(GIBTONITE_QUALITY_MEDIUM)
				explosion(src,1,2,5,adminlog = notify_admins)
			if(GIBTONITE_QUALITY_LOW)
				explosion(src,0,1,3,adminlog = notify_admins)
		qdel(src)

#undef GIBTONITE_QUALITY_HIGH
#undef GIBTONITE_QUALITY_MEDIUM
#undef GIBTONITE_QUALITY_LOW
