/datum/wires/explosive
	var/duds_number = 2

/datum/wires/explosive/New(atom/holder)
	add_duds(duds_number) // In this case duds actually explode.
	..()

/datum/wires/explosive/on_pulse(index)
	explode()

/datum/wires/explosive/on_cut(index, mob/user, mend)
	explode()

/datum/wires/explosive/proc/explode()
	return

/datum/wires/explosive/chem_grenade
	duds_number = 1
	holder_type = /obj/item/grenade/chem_grenade
	randomize = TRUE
	var/fingerprint

/datum/wires/explosive/chem_grenade/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/item/grenade/chem_grenade/G = holder
	return !G.active

/datum/wires/explosive/chem_grenade/attach_assembly(color, obj/item/assembly/S)
	if(istype(S,/obj/item/assembly/timer))
		var/obj/item/grenade/chem_grenade/G = holder
		var/obj/item/assembly/timer/T = S
		G.det_time = T.saved_time*10
	else if(istype(S,/obj/item/assembly/prox_sensor))
		var/obj/item/assembly/prox_sensor/sensor = S
		var/obj/item/grenade/chem_grenade/grenade = holder
		grenade.landminemode = sensor
		sensor.proximity_monitor.set_ignore_if_not_on_turf(FALSE)
	fingerprint = S.fingerprintslast
	return ..()

/datum/wires/explosive/chem_grenade/explode()
	var/obj/item/grenade/chem_grenade/grenade = holder
	var/obj/item/assembly/assembly = get_attached(get_wire(1))
	if(!grenade.dud_flags)
		message_admins("\An [assembly] has pulsed [grenade] ([grenade.type]), which was installed by [fingerprint].")
	log_game("\An [assembly] has pulsed [grenade] ([grenade.type]), which was installed by [fingerprint].")
	var/mob/M = get_mob_by_ckey(fingerprint)
	var/turf/T = get_turf(M)
	grenade.log_grenade(M, T)
	grenade.prime()

/datum/wires/explosive/chem_grenade/detach_assembly(color)
	var/obj/item/grenade/chem_grenade/grenade = holder
	grenade.landminemode = null
	. = ..()

/datum/wires/explosive/c4
	holder_type = /obj/item/grenade/plastic/c4
	duds_number = 1
	randomize = TRUE	//Same behaviour since no wire actually disarms it

/datum/wires/explosive/c4/explode()
	var/obj/item/grenade/plastic/c4/P = holder
	P.prime() //omg The Thick of It


/datum/wires/explosive/pizza
	holder_type = /obj/item/pizzabox
	randomize = TRUE

/datum/wires/explosive/pizza/New(atom/holder)
	wires = list(
		WIRE_DISARM
	)
	add_duds(3) // Duds also explode here.
	..()

/datum/wires/explosive/pizza/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/item/pizzabox/P = holder
	if(P.open && P.bomb)
		return TRUE

/datum/wires/explosive/pizza/get_status()
	var/obj/item/pizzabox/P = holder
	var/list/status = list()
	status += "The red light is [P.bomb_active ? "on" : "off"]."
	status += "The green light is [P.bomb_defused ? "on": "off"]."
	return status

/datum/wires/explosive/pizza/on_pulse(wire)
	var/obj/item/pizzabox/P = holder
	switch(wire)
		if(WIRE_DISARM) // Pulse to toggle
			P.bomb_defused = !P.bomb_defused
			ui_update()
		else // Boom
			explode()

/datum/wires/explosive/pizza/on_cut(wire, mob/user, mend)
	var/obj/item/pizzabox/P = holder
	switch(wire)
		if(WIRE_DISARM) // Disarm and untrap the box.
			if(!mend)
				P.bomb_defused = TRUE
				ui_update()
		else
			if(!mend && !P.bomb_defused)
				explode()

/datum/wires/explosive/pizza/explode()
	var/obj/item/pizzabox/P = holder
	P.bomb.detonate()

/datum/wires/explosive/gibtonite
	holder_type = /obj/item/gibtonite

/datum/wires/explosive/gibtonite/explode()
	var/obj/item/gibtonite/P = holder
	P.GibtoniteReaction(null, 2)
