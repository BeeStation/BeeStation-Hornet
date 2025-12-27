//generic procs copied from obj/effect/alien
/obj/structure/spider
	name = "web"
	icon = 'icons/effects/effects.dmi'
	desc = "It's stringy and sticky."
	anchored = TRUE
	density = FALSE
	max_integrity = 15

/obj/structure/spider/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/obj/structure/spider/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0, 0)

/obj/structure/spider/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive)

/obj/structure/spider/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN)//the stickiness of the web mutes all attack sounds except fire damage type
		playsound(loc, 'sound/items/welder.ogg', 100, 1)

/obj/structure/spider/attackby(obj/item/I, mob/living/user, params)
	if(I.damtype != BURN)
		if(prob(35))
			user.transferItemToLoc(I, drop_location())
			to_chat(user, span_danger("The [I] gets stuck in \the [src]!"))
	return ..()

/obj/structure/spider/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BURN)
				damage_amount *= 2
	. = ..()

/obj/structure/spider/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/obj/structure/spider/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0, 0)

/obj/structure/spider/stickyweb
	icon_state = "stickyweb1"

/obj/structure/spider/stickyweb/Initialize(mapload)
	if(prob(50))
		icon_state = "stickyweb2"
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/spider/stickyweb/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(isliving(AM) && !istype(AM, /mob/living/simple_animal/hostile/poison/giant_spider))
		var/mob/living/L = AM
		if(!L.IsImmobilized()) //Don't spam the shit out of them if they're being dragged by a spider
			to_chat(L, span_danger("You get stuck in \the [src] for a moment."))
		L.Immobilize(1.5 SECONDS)
	if(ismecha(AM))
		var/obj/vehicle/sealed/mecha/mech = AM
		mech.step_restricted += 1 SECONDS //unlike the above, this one stacks based on number of webs. Punch the webs to destroy them you dolt.
		if(mech.occupants && !mech.step_restricted)
			to_chat(mech.occupants, span_danger("\the [mech] gets stuck in \the [src]!"))

/obj/structure/spider/stickyweb/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/projectile))
		return prob(30)

/obj/structure/spider/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "spiderling"
	anchored = FALSE
	layer = PROJECTILE_HIT_THRESHOLD_LAYER
	max_integrity = 3
	var/amount_grown = 0
	var/grow_as = null
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	var/list/faction = list(FACTION_SPIDER)

/obj/structure/spider/spiderling/Destroy()
	new /obj/item/food/spiderling(get_turf(src))
	. = ..()

/obj/structure/spider/spiderling/Initialize(mapload)
	. = ..()
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)
	START_PROCESSING(SSobj, src)
	AddElement(/datum/element/point_of_interest)
	AddComponent(/datum/component/swarming)

/obj/structure/spider/spiderling/hunter
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/hunter

/obj/structure/spider/spiderling/nurse
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/nurse

/obj/structure/spider/spiderling/broodmother
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/broodmother

/obj/structure/spider/spiderling/viper
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/hunter/viper

/obj/structure/spider/spiderling/Bump(atom/user)
	if(istype(user, /obj/structure/table))
		forceMove(user.loc)
	else
		..()

/obj/structure/spider/spiderling/process()
	if(travelling_in_vent)
		if(isturf(loc))
			travelling_in_vent = 0
			entry_vent = null
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			var/list/vents = list()
			var/datum/pipenet/entry_vent_parent = entry_vent.parents[1]
			for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in entry_vent_parent.other_atmos_machines)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = pick(vents)
			if(prob(50))
				visible_message("<B>[src] scrambles into the ventilation ducts!</B>", \
								span_italics("You hear something scampering through the ventilation ducts."))

			spawn(rand(20,60))
				forceMove(exit_vent)
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)

					if(!exit_vent || exit_vent.welded)
						forceMove(entry_vent)
						entry_vent = null
						return

					if(prob(50))
						audible_message(span_italics("You hear something scampering through the ventilation ducts."))
					sleep(travel_time)

					if(!exit_vent || exit_vent.welded)
						forceMove(entry_vent)
						entry_vent = null
						return
					forceMove(exit_vent.loc)
					entry_vent = null
					var/area/new_area = get_area(loc)
					if(new_area)
						new_area.Entered(src)
	//=================

	else if(prob(33))
		var/target_atom = pick(oview(10, src))
		if(target_atom)
			SSmove_manager.move_to(src, target_atom)
			if(prob(40))
				src.visible_message(span_notice("\The [src] skitters[pick(" away"," around","")]."))
	else if(prob(10))
		//ventcrawl!
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/v in view(7,src))
			if(!v.welded)
				entry_vent = v
				SSmove_manager.move_to(src, entry_vent, 1)
				break
	if(isturf(loc))
		amount_grown += rand(0,2)
		if(amount_grown >= 100)
			if(!grow_as)
				if(prob(3))
					grow_as = pick(/mob/living/simple_animal/hostile/poison/giant_spider/hunter/viper, /mob/living/simple_animal/hostile/poison/giant_spider/broodmother)
				else
					grow_as = pick(/mob/living/simple_animal/hostile/poison/giant_spider, /mob/living/simple_animal/hostile/poison/giant_spider/hunter, /mob/living/simple_animal/hostile/poison/giant_spider/nurse)
			var/mob/living/simple_animal/hostile/poison/giant_spider/S = new grow_as(src.loc)
			S.faction = faction.Copy()
			qdel(src)



/obj/structure/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web."
	icon_state = "cocoon1"
	max_integrity = 60

/obj/structure/spider/cocoon/Initialize(mapload)
	icon_state = pick("cocoon1","cocoon2","cocoon3")
	. = ..()

/obj/structure/spider/cocoon/container_resist(mob/living/user)
	var/breakout_time = 600
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, span_notice("You struggle against the tight bonds... (This will take about [DisplayTimeText(breakout_time)].)"))
	visible_message("You see something struggling and writhing in \the [src]!")
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src)
			return
		qdel(src)



/obj/structure/spider/cocoon/Destroy()
	var/turf/T = get_turf(src)
	src.visible_message(span_warning("\The [src] splits open."))
	for(var/atom/movable/A in contents)
		A.forceMove(T)
	return ..()
