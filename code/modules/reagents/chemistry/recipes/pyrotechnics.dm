/datum/chemical_reaction/reagent_explosion
	name = "Generic explosive"
	var/strengthdiv = 10
	var/modifier = 0
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/reagent_explosion/New()
	. = ..()
	hints[REACTION_HINT_EXPLOSION_OTHER] = "Explodes upon creation"
	hints[REACTION_HINT_RADIUS_TABLE] = list(
		explosion_size(10),
		explosion_size(50),
		explosion_size(100),
		explosion_size(200),
		explosion_size(500),
	)

/datum/chemical_reaction/reagent_explosion/proc/explosion_size(volume)
	var/power = modifier + round(volume/strengthdiv, 1)
	if (power <= 0)
		return 0
	return round((2 * power)**GLOB.DYN_EX_SCALE)

/datum/chemical_reaction/reagent_explosion/on_reaction(datum/reagents/holder, created_volume)
	explode(holder, created_volume)

/datum/chemical_reaction/reagent_explosion/proc/explode(datum/reagents/holder, created_volume)
	var/power = modifier + round(created_volume/strengthdiv, 1)
	if(power > 0)
		reaction_alert_admins(holder)
		var/turf/T = get_turf(holder.my_atom)
		var/datum/effect_system/reagents_explosion/e = new()
		if(istype(holder.my_atom, /obj/item/grenade/chem_grenade))
			e.explosion_sizes = list(0, 1, 1, 1)
		e.set_up(power , T, 0, 0)
		e.start()
		holder.clear_reagents()

/datum/chemical_reaction/proc/reaction_alert_admins(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	var/inside_msg
	if(ismob(holder.my_atom))
		var/mob/M = holder.my_atom
		inside_msg = " inside [ADMIN_LOOKUPFLW(M)]"
	var/lastkey = holder.my_atom?.fingerprintslast
	var/touch_msg = "N/A"
	if(lastkey)
		var/mob/toucher = get_mob_by_ckey(lastkey)
		touch_msg = "[ADMIN_LOOKUPFLW(toucher)]"
	if(!istype(holder.my_atom, /obj/machinery/plumbing)) //excludes standard plumbing equipment from spamming admins with this shit
		message_admins("[src] created at [ADMIN_VERBOSEJMP(T)][inside_msg]. Last Fingerprint: [touch_msg].")
	log_game("[src] created at [AREACOORD(T)]. Last Fingerprint: [lastkey ? lastkey : "N/A"]." )

/datum/chemical_reaction/reagent_explosion/nitroglycerin
	name = "Nitroglycerin"
	results = list(/datum/reagent/nitroglycerin = 2)
	required_reagents = list(/datum/reagent/glycerol = 1, /datum/reagent/toxin/acid/fluacid = 1, /datum/reagent/toxin/acid = 1)
	strengthdiv = 2

/datum/chemical_reaction/reagent_explosion/nitroglycerin/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent(/datum/reagent/stabilizing_agent))
		return
	holder.remove_reagent(/datum/reagent/nitroglycerin, created_volume*2)
	..()

/datum/chemical_reaction/reagent_explosion/nitroglycerin_explosion
	name = "Nitroglycerin explosion"
	required_reagents = list(/datum/reagent/nitroglycerin = 1)
	required_temp = 474
	strengthdiv = 2


/datum/chemical_reaction/reagent_explosion/potassium_explosion
	name = "Potassium Water explosion"
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/potassium = 1)
	strengthdiv = 10

/datum/chemical_reaction/reagent_explosion/potassium_explosion/holyboom
	name = "Holy Explosion"
	required_reagents = list(/datum/reagent/water/holywater = 1, /datum/reagent/potassium = 1)

/datum/chemical_reaction/reagent_explosion/potassium_explosion/holyboom/on_reaction(datum/reagents/holder, created_volume)
	if(created_volume >= 150)
		playsound(get_turf(holder.my_atom), 'sound/effects/pray.ogg', 80, 0, round(created_volume/48))
		strengthdiv = 8
		for(var/mob/living/simple_animal/revenant/R in hearers(7,get_turf(holder.my_atom)))
			var/deity = GLOB.deity || "Christ"
			to_chat(R, span_userdanger("The power of [deity] compels you!"))
			R.stun(20)
			R.reveal(100)
			R.adjustHealth(50)
		addtimer(CALLBACK(src, PROC_REF(divine_explosion), round(created_volume/48,1),get_turf(holder.my_atom)), 2 SECONDS)
	..()

/datum/chemical_reaction/reagent_explosion/potassium_explosion/holyboom/proc/divine_explosion(size, turf/T)
	for(var/mob/living/carbon/C in hearers(size,T))
		if(iscultist(C))
			to_chat(C, span_userdanger("The divine explosion sears you!"))
			C.Paralyze(40)
			C.adjust_fire_stacks(5)
			C.IgniteMob()

/datum/chemical_reaction/plasma
	name = "Plasma Flash"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_temp = 320 //extremely volatile
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Releasea cloud of burning plasma."
	)

/datum/chemical_reaction/plasma/on_reaction(datum/reagents/holder, created_volume)
	holder.my_atom.plasma_ignition(created_volume/30, reagent_reaction = TRUE)
	holder.clear_reagents()

/datum/chemical_reaction/gunpowder
	name = "Gunpowder"
	results = list(/datum/reagent/gunpowder = 3)
	required_reagents = list(/datum/reagent/saltpetre = 1, /datum/reagent/medicine/charcoal = 1, /datum/reagent/sulfur = 1)
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/gunpowder/on_reaction(datum/reagents/holder, created_volume)
	reaction_alert_admins(holder)

/datum/chemical_reaction/reagent_explosion/gunpowder_explosion
	name = "Gunpowder Kaboom"
	required_reagents = list(/datum/reagent/gunpowder = 1)
	required_temp = 474
	strengthdiv = 6
	modifier = 1
	mix_message = span_boldnotice("Sparks start flying around the gunpowder!")

/datum/chemical_reaction/reagent_explosion/blackpowder_explosion/on_reaction(datum/reagents/holder, created_volume)
	addtimer(CALLBACK(src, PROC_REF(explode), holder, created_volume, modifier, strengthdiv), rand(5,10) SECONDS)

/datum/chemical_reaction/thermite
	name = "Thermite"
	results = list(/datum/reagent/thermite = 3)
	required_reagents = list(/datum/reagent/aluminium = 1, /datum/reagent/iron = 1, /datum/reagent/oxygen = 1)
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Can be placed onto walls and safes to melt them."
	)
	reaction_tags = REACTION_TAG_EXPLOSIVE | REACTION_TAG_OTHER

/datum/chemical_reaction/emp_pulse
	name = "EMP Pulse"
	required_reagents = list(/datum/reagent/uranium = 1, /datum/reagent/iron = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Disables nearby electronics",
		REACTION_HINT_RADIUS_TABLE = list(
			1, 7, 14, 28, 71
		)
	)
	reaction_tags = REACTION_TAG_EXPLOSIVE | REACTION_TAG_OTHER

/datum/chemical_reaction/emp_pulse/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
	// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
	empulse(location, round(created_volume / 12), round(created_volume / 7), 1)
	holder.clear_reagents()


/datum/chemical_reaction/beesplosion
	name = "Bee Explosion"
	required_reagents = list(/datum/reagent/consumable/honey = 1, /datum/reagent/medicine/strange_reagent = 1, /datum/reagent/uranium/radium = 1)
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates a swarm of bees"
	)
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/beesplosion/on_reaction(datum/reagents/holder, created_volume)
	var/location = holder.my_atom.drop_location()
	if(created_volume < 5)
		playsound(location,'sound/effects/sparks1.ogg', 100, TRUE)
	else
		playsound(location,'sound/creatures/bee.ogg', 100, TRUE)
		var/list/beeagents = list()
		for(var/R in holder.reagent_list)
			if(required_reagents[R])
				continue
			beeagents += R
		var/bee_amount = round(created_volume * 0.2)
		for(var/i in 1 to bee_amount)
			var/mob/living/simple_animal/hostile/poison/bees/short/new_bee = new(location)
			if(LAZYLEN(beeagents))
				new_bee.assign_reagent(pick(beeagents))


/datum/chemical_reaction/stabilizing_agent
	name = /datum/reagent/stabilizing_agent
	results = list(/datum/reagent/stabilizing_agent = 3)
	required_reagents = list(/datum/reagent/iron = 1, /datum/reagent/oxygen = 1, /datum/reagent/hydrogen = 1)
	hints = list(
		REACTION_HINT_SAFETY = "Prevents some explosive reactions from occurring"
	)
	reaction_tags = REACTION_TAG_EXPLOSIVE | REACTION_TAG_CHEMICAL | REACTION_TAG_PLANT

/datum/chemical_reaction/clf3
	name = "Chlorine Trifluoride"
	results = list(/datum/reagent/clf3 = 4)
	required_reagents = list(/datum/reagent/chlorine = 1, /datum/reagent/fluorine = 3)
	required_temp = 424
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Heats up other reagents stored in the container"
	)
	reaction_tags = REACTION_TAG_EXPLOSIVE | REACTION_TAG_CHEMICAL | REACTION_TAG_BURN

/datum/chemical_reaction/clf3/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	for(var/turf/open/turf in RANGE_TURFS(1,T))
		if(!locate(/obj/effect/hotspot) in turf)
			new /obj/effect/hotspot(turf)
	holder.chem_temp = 1000 // hot as shit

/datum/chemical_reaction/reagent_explosion/methsplosion
	name = "Strong meth explosion"
	required_temp = 380 //slightly above the meth mix time.
	required_reagents = list(/datum/reagent/drug/methamphetamine = 1)
	strengthdiv = 6
	modifier = 1
	mob_react = FALSE

/datum/chemical_reaction/reagent_explosion/methsplosion/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	for(var/turf/open/turf in RANGE_TURFS(1,T))
		if(!locate(/obj/effect/hotspot) in turf)
			new /obj/effect/hotspot(turf)
	holder.chem_temp = 1000 // hot as shit
	..()

/datum/chemical_reaction/reagent_explosion/methsplosion/methboom2
	name = "Weak meth explosion"
	required_reagents = list(/datum/reagent/diethylamine = 1, /datum/reagent/iodine = 1, /datum/reagent/phosphorus = 1, /datum/reagent/hydrogen = 1) //diethylamine is often left over from mixing the ephedrine.
	required_temp = 300 //room temperature, chilling it even a little will prevent the explosion

/datum/chemical_reaction/sorium
	name = "Sorium"
	results = list(/datum/reagent/sorium = 4)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/oxygen = 1, /datum/reagent/nitrogen = 1, /datum/reagent/carbon = 1)
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/sorium/New()
	. = ..()
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates a vortex which pushes objects away from itself",
		REACTION_HINT_RADIUS_TABLE = list(
			clamp(sqrt(10*4), 1, 6),
			clamp(sqrt(50*4), 1, 6),
			clamp(sqrt(100*4), 1, 6),
			clamp(sqrt(200*4), 1, 6),
			clamp(sqrt(500*4), 1, 6),
		),
		REACTION_HINT_SAFETY = "Reaction prevented by stabilizing agent"
	)

/datum/chemical_reaction/sorium/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent(/datum/reagent/stabilizing_agent))
		return
	holder.remove_reagent(/datum/reagent/sorium, created_volume*4)
	var/turf/T = get_turf(holder.my_atom)
	var/range = clamp(sqrt(created_volume*4), 1, 6)
	goonchem_vortex(T, 1, range)

/datum/chemical_reaction/sorium_vortex
	name = "Sorium vortex"
	required_reagents = list(/datum/reagent/sorium = 1)
	required_temp = 474
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/sorium_vortex/New()
	. = ..()
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates a vortex which pushes objects away from itself",
		REACTION_HINT_RADIUS_TABLE = list(
			clamp(sqrt(10), 1, 6),
			clamp(sqrt(50), 1, 6),
			clamp(sqrt(100), 1, 6),
			clamp(sqrt(200), 1, 6),
			clamp(sqrt(500), 1, 6),
		)
	)

/datum/chemical_reaction/sorium_vortex/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	var/range = clamp(sqrt(created_volume), 1, 6)
	goonchem_vortex(T, 1, range)

/datum/chemical_reaction/liquid_dark_matter
	name = "Liquid Dark Matter"
	results = list(/datum/reagent/liquid_dark_matter = 3)
	required_reagents = list(/datum/reagent/stable_plasma = 1, /datum/reagent/uranium/radium = 1, /datum/reagent/carbon = 1)
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/liquid_dark_matter/New()
	. = ..()
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates a vortex which pulls objects towards itself",
		REACTION_HINT_RADIUS_TABLE = list(
			clamp(sqrt(10*3), 1, 6),
			clamp(sqrt(50*3), 1, 6),
			clamp(sqrt(100*3), 1, 6),
			clamp(sqrt(200*3), 1, 6),
			clamp(sqrt(500*3), 1, 6),
		),
		REACTION_HINT_SAFETY = "Reaction prevented by stabilizing agent"
	)

/datum/chemical_reaction/liquid_dark_matter/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent(/datum/reagent/stabilizing_agent))
		return
	holder.remove_reagent(/datum/reagent/liquid_dark_matter, created_volume*3)
	var/turf/T = get_turf(holder.my_atom)
	var/range = clamp(sqrt(created_volume*3), 1, 6)
	goonchem_vortex(T, 0, range)

/datum/chemical_reaction/ldm_vortex
	name = "LDM Vortex"
	required_reagents = list(/datum/reagent/liquid_dark_matter = 1)
	required_temp = 474
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/ldm_vortex/New()
	. = ..()
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates a vortex which pulls objects towards itself",
		REACTION_HINT_RADIUS_TABLE = list(
			clamp(sqrt(10/2), 1, 6),
			clamp(sqrt(50/2), 1, 6),
			clamp(sqrt(100/2), 1, 6),
			clamp(sqrt(200/2), 1, 6),
			clamp(sqrt(500/2), 1, 6),
		),
	)

/datum/chemical_reaction/ldm_vortex/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	var/range = clamp(sqrt(created_volume/2), 1, 6)
	goonchem_vortex(T, 0, range)

/datum/chemical_reaction/flash_powder
	name = "Flash powder"
	results = list(/datum/reagent/flash_powder = 3)
	required_reagents = list(/datum/reagent/aluminium = 1, /datum/reagent/potassium = 1, /datum/reagent/sulfur = 1 )
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/flash_powder/New()
	. = ..()
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates a flash of light",
		REACTION_HINT_RADIUS_TABLE = list(
			round(10/3),
			round(50/3),
			round(100/3),
			round(200/3),
			round(500/3),
		),
		REACTION_HINT_SAFETY = "Reaction prevented by stabilizing agent"
	)

/datum/chemical_reaction/flash_powder/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent(/datum/reagent/stabilizing_agent))
		return
	var/location = get_turf(holder.my_atom)
	do_sparks(2, TRUE, location)
	var/range = created_volume/3
	if(isatom(holder.my_atom))
		var/atom/A = holder.my_atom
		A.flash_lighting_fx(range = (range + 2))
	for(var/mob/living/carbon/C in hearers(range, location))
		if(C.flash_act())
			if(get_dist(C, location) < 4)
				C.Paralyze(60)
			else
				C.Stun(100)
	holder.remove_reagent(/datum/reagent/flash_powder, created_volume*3)

/datum/chemical_reaction/flash_powder_flash
	name = "Flash powder activation"
	required_reagents = list(/datum/reagent/flash_powder = 1)
	required_temp = 374
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/flash_powder_flash/New()
	. = ..()
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates a flash of light",
		REACTION_HINT_RADIUS_TABLE = list(
			round(10/10),
			round(50/10),
			round(100/10),
			round(200/10),
			round(500/10),
		),
	)

/datum/chemical_reaction/flash_powder_flash/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	do_sparks(2, TRUE, location)
	var/range = created_volume/10
	if(isatom(holder.my_atom))
		var/atom/A = holder.my_atom
		A.flash_lighting_fx(range = (range + 2))
	for(var/mob/living/carbon/C in hearers(range, location))
		if(C.flash_act())
			if(get_dist(C, location) < 4)
				C.Paralyze(60)
			else
				C.Stun(100)

/datum/chemical_reaction/smoke_powder
	name = /datum/reagent/smoke_powder
	results = list(/datum/reagent/smoke_powder = 3)
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/phosphorus = 1)
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/smoke_powder/New()
	. = ..()
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates a cloud of smoke which carries reagents",
		REACTION_HINT_RADIUS_TABLE = list(
			round(sqrt(10 * 1.5), 1),
			round(sqrt(50 * 1.5), 1),
			round(sqrt(100 * 1.5), 1),
			round(sqrt(200 * 1.5), 1),
			round(sqrt(500 * 1.5), 1),
		),
		REACTION_HINT_SAFETY = "Reaction prevented by stabilizing agent"
	)

/datum/chemical_reaction/smoke_powder/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent(/datum/reagent/stabilizing_agent))
		return
	holder.remove_reagent(/datum/reagent/smoke_powder, created_volume*3)
	var/smoke_radius = round(sqrt(created_volume * 1.5), 1)
	var/location = get_turf(holder.my_atom)
	var/datum/effect_system/smoke_spread/chem/S = new
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	if(S)
		S.set_up(holder, smoke_radius, location, 0)
		S.start()
	if(holder && holder.my_atom)
		holder.clear_reagents()

/datum/chemical_reaction/smoke_powder_smoke
	name = "Smoke powder smoke"
	required_reagents = list(/datum/reagent/smoke_powder = 1)
	required_temp = 374
	mob_react = FALSE
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/smoke_powder_smoke/New()
	. = ..()
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates a cloud of smoke which carries reagents",
		REACTION_HINT_RADIUS_TABLE = list(
			round(sqrt(10 * 0.5), 1),
			round(sqrt(50 * 0.5), 1),
			round(sqrt(100 * 0.5), 1),
			round(sqrt(200 * 0.5), 1),
			round(sqrt(500 * 0.5), 1),
		)
	)

/datum/chemical_reaction/smoke_powder_smoke/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	var/smoke_radius = round(sqrt(created_volume / 2), 1)
	var/datum/effect_system/smoke_spread/chem/S = new
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	if(S)
		S.set_up(holder, smoke_radius, location, 0)
		S.start()
	if(holder?.my_atom)
		holder.clear_reagents()

/datum/chemical_reaction/sonic_powder
	name = /datum/reagent/sonic_powder
	results = list(/datum/reagent/sonic_powder = 3)
	required_reagents = list(/datum/reagent/oxygen = 1, /datum/reagent/consumable/space_cola = 1, /datum/reagent/phosphorus = 1)
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/sonic_powder/New()
	. = ..()
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates a sonic bang",
		REACTION_HINT_RADIUS_TABLE = list(
			round(10 / 3),
			round(50 / 3),
			round(100 / 3),
			round(200 / 3),
			round(500 / 3),
		),
		REACTION_HINT_SAFETY = "Reaction prevented by stabilizing agent"
	)

/datum/chemical_reaction/sonic_powder/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent(/datum/reagent/stabilizing_agent))
		return
	holder.remove_reagent(/datum/reagent/sonic_powder, created_volume*3)
	var/location = get_turf(holder.my_atom)
	playsound(location, 'sound/effects/bang.ogg', 25, 1)
	for(var/mob/living/carbon/C in hearers(created_volume/3, location))
		C.soundbang_act(1, 100, rand(0, 5))

/datum/chemical_reaction/sonic_powder_deafen
	name = "Sonic powder deafen"
	required_reagents = list(/datum/reagent/sonic_powder = 1)
	required_temp = 374
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/sonic_powder_deafen/New()
	. = ..()
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates a sonic bang",
		REACTION_HINT_RADIUS_TABLE = list(
			round(10 / 10),
			round(50 / 10),
			round(100 / 10),
			round(200 / 10),
			round(500 / 10),
		),
	)

/datum/chemical_reaction/sonic_powder_deafen/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	playsound(location, 'sound/effects/bang.ogg', 25, 1)
	for(var/mob/living/carbon/C in hearers(created_volume/10, location))
		C.soundbang_act(1, 100, rand(0, 5))

/datum/chemical_reaction/phlogiston
	name = "Phlogiston"
	results = list(/datum/reagent/phlogiston = 3)
	required_reagents = list(/datum/reagent/phosphorus = 1, /datum/reagent/toxin/acid = 1, /datum/reagent/stable_plasma = 1)
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates a clloud of ignited plasma",
		REACTION_HINT_SAFETY = "Reaction prevented by stabilizing agent"
	)
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/phlogiston/on_reaction(datum/reagents/holder, created_volume)
	reaction_alert_admins(holder)
	if(holder.has_reagent(/datum/reagent/stabilizing_agent))
		return
	var/turf/open/T = get_turf(holder.my_atom)
	if(istype(T))
		T.atmos_spawn_air("plasma=[created_volume];TEMP=1000")
	holder.clear_reagents()
	return

/datum/chemical_reaction/napalm
	name = "Napalm"
	results = list(/datum/reagent/napalm = 3)
	required_reagents = list(/datum/reagent/oil = 1, /datum/reagent/fuel = 1, /datum/reagent/consumable/ethanol = 1 )
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Ignites victims when ingested",
	)
	reaction_tags = REACTION_TAG_EXPLOSIVE | REACTION_TAG_PLANT

/datum/chemical_reaction/cryostylane
	name = /datum/reagent/cryostylane
	results = list(/datum/reagent/cryostylane = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/stable_plasma = 1, /datum/reagent/nitrogen = 1)
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Reduces the temperature of the container when created",
	)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/cryostylane/on_reaction(datum/reagents/holder, created_volume)
	holder.chem_temp = 20 // cools the fuck down
	return

/datum/chemical_reaction/cryostylane_oxygen
	name = "ephemeral cryostylane reaction"
	results = list(/datum/reagent/cryostylane = 1)
	required_reagents = list(/datum/reagent/cryostylane = 1, /datum/reagent/oxygen = 1)
	mob_react = FALSE
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Reduces the temperature of the container when created, according to the amount created",
	)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/cryostylane_oxygen/on_reaction(datum/reagents/holder, created_volume)
	holder.chem_temp = max(holder.chem_temp - 10*created_volume,0)

/datum/chemical_reaction/pyrosium_oxygen
	name = "ephemeral pyrosium reaction"
	results = list(/datum/reagent/pyrosium = 1)
	required_reagents = list(/datum/reagent/pyrosium = 1, /datum/reagent/oxygen = 1)
	mob_react = FALSE
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Increases the temperature of the container when created, according to the amount created",
	)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/pyrosium_oxygen/on_reaction(datum/reagents/holder, created_volume)
	holder.chem_temp += 10*created_volume

/datum/chemical_reaction/pyrosium
	name = /datum/reagent/pyrosium
	results = list(/datum/reagent/pyrosium = 3)
	required_reagents = list(/datum/reagent/stable_plasma = 1, /datum/reagent/uranium/radium = 1, /datum/reagent/phosphorus = 1)
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Increases the temperature of the container when created",
	)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/pyrosium/on_reaction(datum/reagents/holder, created_volume)
	holder.chem_temp = 20 // also cools the fuck down
	return

/datum/chemical_reaction/teslium
	name = "Teslium"
	results = list(/datum/reagent/teslium = 3)
	required_reagents = list(/datum/reagent/stable_plasma = 1, /datum/reagent/silver = 1, /datum/reagent/gunpowder = 1)
	mix_message = span_danger("A jet of sparks flies from the mixture as it merges into a flickering slurry.")
	required_temp = 400
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/energized_jelly
	name = "Energized Jelly"
	results = list(/datum/reagent/teslium/energized_jelly = 2)
	required_reagents = list(/datum/reagent/toxin/slimejelly = 1, /datum/reagent/teslium = 1)
	mix_message = span_danger("The slime jelly starts glowing intermittently.")
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/teslium_lightning
	name = "Teslium Destabilization"
	required_reagents = list(/datum/reagent/teslium = 1, /datum/reagent/water = 1)
	mix_message = span_boldannounce("The teslium starts to spark as electricity arcs away from it!")
	mix_sound = 'sound/machines/defib_zap.ogg'
	var/tesla_flags = TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE | TESLA_MOB_STUN
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates a high-energy lightning bolt on creation",
	)
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/teslium_lightning/on_reaction(datum/reagents/holder, created_volume)
	var/T1 = created_volume * 20 //100 units : Zap 3 times, with powers 2000/5000/12000. Tesla revolvers have a power of 10000 for comparison.
	var/T2 = created_volume * 50
	var/T3 = created_volume * 120
	var/added_delay = 0.5 SECONDS
	if(created_volume >= 75)
		addtimer(CALLBACK(src, PROC_REF(zappy_zappy), holder, T1), added_delay)
		added_delay += 1.5 SECONDS
	if(created_volume >= 40)
		addtimer(CALLBACK(src, PROC_REF(zappy_zappy), holder, T2), added_delay)
		added_delay += 1.5 SECONDS
	if(created_volume >= 10) //10 units minimum for lightning, 40 units for secondary blast, 75 units for tertiary blast.
		addtimer(CALLBACK(src, PROC_REF(zappy_zappy), holder, T3), added_delay)

/datum/chemical_reaction/teslium_lightning/proc/zappy_zappy(datum/reagents/holder, power)
	if(QDELETED(holder.my_atom))
		return
	tesla_zap(holder.my_atom, 7, power, tesla_flags)
	playsound(holder.my_atom, 'sound/machines/defib_zap.ogg', 50, TRUE)

/datum/chemical_reaction/teslium_lightning/heat
	required_temp = 474
	required_reagents = list(/datum/reagent/teslium = 1)

/datum/chemical_reaction/reagent_explosion/nitrous_oxide
	name = "N2O explosion"
	required_reagents = list(/datum/reagent/nitrous_oxide = 1)
	strengthdiv = 7
	required_temp = 575
	modifier = 1

/datum/chemical_reaction/firefighting_foam
	name = "Firefighting Foam"
	results = list(/datum/reagent/firefighting_foam = 3)
	required_reagents = list(/datum/reagent/stabilizing_agent = 1,/datum/reagent/fluorosurfactant = 1,/datum/reagent/carbon = 1)
	required_temp = 200
	is_cold_recipe = 1
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/reagent_explosion/cults_explosion
	name = "Cults Explosion"
	required_reagents = list(/datum/reagent/consumable/ethanol/ratvander = 1, /datum/reagent/consumable/ethanol/narsour = 1)
	strengthdiv = 10
