/datum/symptom/flesh
	name = "Exolocomotive Xenomitosis"
	desc = "The virus will grow on any surfaces it can, such as the host's skin, or even the ground, should the host remain stationary"
	stealth = -2
	resistance = 3
	stage_speed = 3
	transmittable = 1
	level = 9
	severity = 2
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/cachedcolor = null
	var/turf/open/currentloc = null
	var/cycles = 0
	var/lastcycle = 0
	var/requiredcycles = 0
	var/maxradius = 1
	threshold_desc = "<b>Stage Speed:</b>Influences the time the host must stand still to begin spreading infectious mass.<br>\
                      <b>Stage Speed 6:</b>Infectious mass will patch wounds in the host's flesh, healing their brute damage. Standing on infectious mass heals the host far quicker, and laying down even faster. -3 severity.<br>\
					  <b>Transmission:</b>Influences the maximum spread radius of infectious mass.<br>\
                      <b>Transmission 10:</b>Infectious mass will contain all viruses currently afflicting the host. +1 severity."

/datum/symptom/flesh/severityset(datum/disease/advance/A)
	. = ..()
	if(A.properties["stage_rate"] >= 6)
		severity -= 3
	if(A.properties["transmittable"] >= 10)
		severity += 1

/datum/symptom/flesh/Start(datum/disease/advance/A)
	. = ..()
	requiredcycles = (max(2, round((18 - A.properties["stage_rate"]) / 2))) //14 speed is the highest possible rate of growth
	maxradius = (round(A.properties["transmittable"] / 3))
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna.species.use_skintones)
			cachedcolor = H.skin_tone
		else if(MUTCOLORS in H.dna.species.species_traits)
			cachedcolor	= H.dna.features["mcolor"]

/datum/symptom/flesh/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	var/list/diseases = list(A)
	var/healfactor = 0
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		switch(A.stage)
			if(5)
				if(currentloc == C.loc)
					cycles += 1
				else if(isturf(C.loc) && !isspaceturf(C.loc))
					currentloc = C.loc
					cycles = 0
					lastcycle = 0
				var/obj/structure/alien/flesh/W = locate(/obj/structure/alien/flesh) in currentloc
				if(W)
					healfactor += 1
					if(istype(W, /obj/structure/alien/flesh/node))
						healfactor += 1
						var/obj/structure/alien/flesh/node/node = W
						if(round(cycles / requiredcycles) >= lastcycle && node.node_range < maxradius)
							node.node_range += 1
							lastcycle += 1
					if(!(C.mobility_flags & MOBILITY_STAND))
						healfactor *= 2
				else if(round(cycles / requiredcycles) >= 1)
					if(A.properties["transmittable"] >= 10)
						for(var/datum/disease/D in M.diseases)
							if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS) || (D.spread_flags & DISEASE_SPREAD_FALTERED))
								continue
							if(D == A)
								continue
							diseases += D
					if(maxradius >= 1)
						var/obj/structure/alien/flesh/node/N = new(currentloc, diseases)
						N.node_range = 0
					else
						new /obj/structure/alien/flesh(currentloc, diseases)
					C.visible_message("<span class='warning'>The film on [C]'s skin grows onto the floor!</span>", "<span class='userdanger'>The film creeping along your skin secretes onto the floor!</span>")
					lastcycle += 1
				if(A.properties["stage_rate"] >= 8)
					healfactor += 0.5
					C.heal_overall_damage(healfactor, required_status = BODYPART_ORGANIC)//max passive healing is 4.5, whilst laying down on a node.
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(istype(H.dna.species, /datum/species/zombie/infectious))
						var/datum/species/zombie/infectious/Z = H.dna.species
						if(Z.limbs_id == "pinkzombie")
							return
						else
							Z.limbs_id = "pinkzombie"
							H.regenerate_icons()
					if(H.skin_tone == "pink")
						return
					else if(H.dna.features["mcolor"] == "D37")
						return
					if(H.dna.species.use_skintones)
						H.skin_tone = "pink"
						H.visible_message("<span class='warning'>A film of pinkish material grows over [H]'s skin!</span>", "<span class='userdanger'>Your skin is completely covered by a film of pinkish, fleshy mass!</span>")
						H.regenerate_icons()
					else if(MUTCOLORS in H.dna.species.species_traits)
						H.dna.features["mcolor"] = "D37" //pinkish red
						H.visible_message("<span class='warning'>A film of pinkish material grows over [H]'s skin!</span>", "<span class='userdanger'>Your skin is completely covered by a film of pinkish, fleshy mass!</span>")
						H.regenerate_icons()

/datum/symptom/flesh/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna.species.use_skintones)
			H.skin_tone = cachedcolor
		else if(MUTCOLORS in H.dna.species.species_traits)
			H.dna.features["mcolor"] = cachedcolor
		H.regenerate_icons()


/obj/structure/alien/flesh //this isn't a subtype of alien weeds so it wont heal aliens
	gender = PLURAL
	name = "infested floor"
	desc = "A thick film of flesh covers the floor."
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	icon_state = "weeds"
	max_integrity = 15
	canSmoothWith = list(/obj/structure/alien/flesh, /turf/closed/wall)
	smooth = SMOOTH_MORE
	var/last_expand = 0 //last world.time this weed expanded
	var/growth_cooldown_low = 150
	var/growth_cooldown_high = 200
	var/static/list/blacklisted_turfs
	var/list/nodediseases = list()

/obj/structure/alien/flesh/Initialize(mapload, list/datum/disease/diseases)
	pixel_x = -4
	pixel_y = -4 //so the sprites line up right in the map editor
	. = ..()

	if(!blacklisted_turfs) //note: if some sort of sanitary floors are added, put them in here
		blacklisted_turfs = typecacheof(list(
			/turf/open/space,
			/turf/open/chasm,
			/turf/open/lava))


	last_expand = world.time + rand(growth_cooldown_low, growth_cooldown_high)
	if(icon == initial(icon))
		switch(rand(1,3))
			if(1)
				icon = 'icons/obj/smooth_structures/alien/flesh1.dmi'
			if(2)
				icon = 'icons/obj/smooth_structures/alien/flesh2.dmi'
			if(3)
				icon = 'icons/obj/smooth_structures/alien/flesh3.dmi'
	if(LAZYLEN(diseases))
		for(var/datum/disease/D in diseases)
			nodediseases += D
		if(LAZYLEN(nodediseases))
			AddComponent(/datum/component/infective, nodediseases)

/obj/structure/alien/flesh/examine(mob/user)
	. = ..()
	if(isliving(user))
		var/mob/living/U = user
		for(var/datum/disease/advance/A in U.diseases)
			for(var/datum/symptom/S in A.symptoms)
				if(istype(S, /datum/symptom/flesh))
					. += "It looks warm and inviting. It would be so wonderful to just lay down in it..."
					return

/obj/structure/alien/flesh/proc/expand()
	var/turf/U = get_turf(src)
	if(is_type_in_typecache(U, blacklisted_turfs))
		qdel(src)
		return FALSE

	for(var/turf/T in U.GetAtmosAdjacentTurfs())
		if(locate(/obj/structure/alien/flesh) in T)
			continue

		if(is_type_in_typecache(T, blacklisted_turfs))
			continue

		var/obj/structure/alien/weeds/W = locate(/obj/structure/alien/weeds) in T //we infect and subsume alien weeds and replace them with our own shit
		if(W)
			if(istype(W, /obj/structure/alien/weeds/node))
				new /obj/structure/alien/flesh/node(T, nodediseases)
				continue
			else
				qdel(W)
		new /obj/structure/alien/flesh(T, nodediseases)
	return TRUE

/obj/structure/alien/flesh/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

//Weed nodes
/obj/structure/alien/flesh/node
	name = "putrid infection"
	desc = "A sickly red glow emanates from the pustules on this fleshy film."
	icon_state = "weednode"
	light_color = LIGHT_COLOR_BLOOD_MAGIC //a good, sickly atmosphere
	light_power = 0.5
	var/lon_range = 4
	var/node_range = 3


/obj/structure/alien/flesh/node/Initialize()
	icon = 'icons/obj/smooth_structures/alien/fleshpolyp.dmi'
	. = ..()
	set_light(lon_range)
	var/obj/structure/alien/W = locate(/obj/structure/alien) in loc //we infect and take over alien resin
	if(W && W != src)
		qdel(W)
	START_PROCESSING(SSobj, src)

/obj/structure/alien/flesh/node/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/alien/flesh/node/process()
	if(node_range)
		for(var/obj/structure/alien/flesh/W in range(node_range, src))
			if(W.last_expand <= world.time)
				if(W.expand())
					W.last_expand = world.time + rand(growth_cooldown_low, growth_cooldown_high)