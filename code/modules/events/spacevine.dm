/datum/round_event_control/spacevine
	name = "Spacevine"
	typepath = /datum/round_event/spacevine
	weight = 15
	max_occurrences = 3
	min_players = 10

/datum/round_event/spacevine
	fakeable = FALSE

/datum/round_event/spacevine/start()
	var/list/turfs = list() //list of all the empty floor turfs in the maintenance areas

	var/obj/structure/spacevine/SV = new()

	for(var/area/maintenance/A in world)
		for(var/turf/F in A)
			if(F.Enter(SV) && !isspaceturf(F))
				turfs += F

	qdel(SV)

	if(turfs.len) //Pick a turf to spawn at if we can
		var/turf/T = pick(turfs)
		new /datum/spacevine_controller(T, list(pick(subtypesof(/datum/spacevine_mutation))), rand(10,100), rand(1,6), src) //spawn a controller at turf with randomized stats and a single random mutation


/datum/spacevine_mutation
	var/name = ""
	var/severity = 1
	var/hue
	var/quality

/datum/spacevine_mutation/proc/add_mutation_to_vinepiece(obj/structure/spacevine/holder)
	holder.mutations |= src
	holder.add_atom_colour(hue, FIXED_COLOUR_PRIORITY)

/datum/spacevine_mutation/proc/process_mutation(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/process_temperature(obj/structure/spacevine/holder, temp, volume)
	return

/datum/spacevine_mutation/proc/on_birth(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_grow(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_death(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/I, expected_damage)
	. = expected_damage

/datum/spacevine_mutation/proc/on_cross(obj/structure/spacevine/holder, mob/crosser)
	return

/datum/spacevine_mutation/proc/on_chem(obj/structure/spacevine/holder, datum/reagent/R)
	return

/datum/spacevine_mutation/proc/on_eat(obj/structure/spacevine/holder, mob/living/eater)
	return

/datum/spacevine_mutation/proc/on_spread(obj/structure/spacevine/holder, turf/target)
	return

/datum/spacevine_mutation/proc/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
	return

/datum/spacevine_mutation/proc/on_explosion(severity, target, obj/structure/spacevine/holder)
	return


/datum/spacevine_mutation/light
	name = "light"
	hue = "#ffff00"
	quality = POSITIVE
	severity = 4

/datum/spacevine_mutation/light/on_grow(obj/structure/spacevine/holder)
	if(holder.energy)
		holder.set_light(severity, 0.3)

/datum/spacevine_mutation/toxicity
	name = "toxic"
	hue = "#ff00ff"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/toxicity/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(issilicon(crosser))
		return
	if(prob(severity) && istype(crosser) && !isvineimmune(crosser))
		to_chat(crosser, "<span class='alert'>You accidentally touch the vine and feel a strange sensation.</span>")
		crosser.adjustToxLoss(5)

/datum/spacevine_mutation/toxicity/on_eat(obj/structure/spacevine/holder, mob/living/eater)
	if(!isvineimmune(eater))
		eater.adjustToxLoss(5)

/datum/spacevine_mutation/explosive  //OH SHIT IT CAN CHAINREACT RUN!!!
	name = "explosive"
	hue = "#ff0000"
	quality = NEGATIVE
	severity = 2

/datum/spacevine_mutation/explosive/on_explosion(explosion_severity, target, obj/structure/spacevine/holder)
	if(explosion_severity < 3)
		qdel(holder)
	else
		. = 1
		QDEL_IN(holder, 5)

/datum/spacevine_mutation/aggressive_spread/proc/aggrospread_act(obj/structure/spacevine/S, mob/living/M)
	return

/datum/spacevine_mutation/explosive/on_death(obj/structure/spacevine/holder, mob/hitter, obj/item/I)
	explosion(holder.loc, 0, 0, severity, 0, 0)

/datum/spacevine_mutation/fire_proof
	name = "fire proof"
	hue = "#ff8888"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/fire_proof/process_temperature(obj/structure/spacevine/holder, temp, volume)
	return 1

/datum/spacevine_mutation/fire_proof/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/I, expected_damage)
	if(I && I.damtype == "fire")
		. = 0
	else
		. = expected_damage

/datum/spacevine_mutation/vine_eating
	name = "vine eating"
	hue = "#ff7700"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/vine_eating/on_spread(obj/structure/spacevine/holder, turf/target)
	for(var/obj/structure/spacevine/prey in target)
		qdel(prey)

/datum/spacevine_mutation/aggressive_spread  //very OP, but im out of other ideas currently
	name = "aggressive spreading"
	hue = "#333333"
	severity = 3
	quality = NEGATIVE

/// Checks mobs on spread-target's turf to see if they should be hit by a damaging proc or not.
/datum/spacevine_mutation/aggressive_spread/on_spread(obj/structure/spacevine/holder, turf/target, mob/living)
	for(var/mob/living/M in target)
		if(!isvineimmune(M) && M.stat != DEAD) // Don't kill immune creatures. Dead check to prevent log spam when a corpse is trapped between vine eaters.
			aggrospread_act(holder, M)

/datum/spacevine_mutation/aggressive_spread/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
		aggrospread_act(holder, buckled)

/// Hurts mobs. To be used when a vine with aggressive spread mutation spreads into the mob's tile or buckles them.
/datum/spacevine_mutation/aggressive_spread/aggrospread_act(obj/structure/spacevine/S, mob/living/M)
	var/mob/living/carbon/C = M //If the mob is carbon then it now also exists as a "C", and not just an M.
	if(istype(C)) //If the mob (M) is a carbon subtype (C) we move on to pick a more complex damage proc, with damage zones, wounds and armor mitigation.
		var/obj/item/bodypart/limb = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_HEAD, BODY_ZONE_CHEST) //Picks a random bodypart. Does not runtime even if it's missing.
		var/armor = C.run_armor_check(limb, "melee", null, null) //armor = the armor value of that randomly chosen bodypart. Nulls to not print a message, because it would still print on pierce.
		var/datum/spacevine_mutation/thorns/T = locate() in S.mutations //Searches for the thorns mutation in the "mutations"-list inside obj/structure/spacevine, and defines T if it finds it.
		if(T && (prob(40))) //If we found the thorns mutation there is now a chance to get stung instead of lashed or smashed.
			C.apply_damage(50, BRUTE, def_zone = limb) //This one gets a bit lower damage because it ignores armor.
			C.Stun(1 SECONDS) //Stopped in place for a moment.
			playsound(M, 'sound/weapons/pierce.ogg', 50, TRUE, -1)
			M.visible_message("<span class='danger'>[M] is nailed by a sharp thorn!</span>", \
			"<span class='userdanger'>You are nailed by a sharp thorn!</span>")
			log_combat(S, M, "aggressively pierced") //"Aggressively" for easy ctrl+F'ing in the attack logs.
		else
			if(prob(80))
				C.apply_damage(60, BRUTE, def_zone = limb, blocked = armor)
				C.Knockdown(2 SECONDS)
				playsound(M, 'sound/weapons/whip.ogg', 50, TRUE, -1)
				M.visible_message("<span class='danger'>[M] is lacerated by an outburst of vines!</span>", \
				"<span class='userdanger'>You are lacerated by an outburst of vines!</span>")
				log_combat(S, M, "aggressively lacerated")
			else
				C.apply_damage(60, BRUTE, def_zone = limb, blocked = armor)
				C.Knockdown(3 SECONDS)
				var/atom/throw_target = get_edge_target_turf(C, get_dir(S, get_step_away(C, S)))
				C.throw_at(throw_target, 3, 6)
				playsound(M, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
				M.visible_message("<span class='danger'>[M] is smashed by a large vine!</span>", \
				"<span class='userdanger'>You are smashed by a large vine!</span>")
				log_combat(S, M, "aggressively smashed")
	else //Living but not a carbon? Maybe a silicon? Can't be wounded so have a big chunk of simple bruteloss with no special effects. They can be entangled.
		M.adjustBruteLoss(75)
		playsound(M, 'sound/weapons/whip.ogg', 50, TRUE, -1)
		M.visible_message("<span class='danger'>[M] is brutally threshed by [S]!</span>", \
		"<span class='userdanger'>You are brutally threshed by [S]!</span>")
		log_combat(S, M, "aggressively spread into") //You aren't being attacked by the vines. You just happen to stand in their way.

/datum/spacevine_mutation/transparency
	name = "transparent"
	hue = ""
	quality = POSITIVE

/datum/spacevine_mutation/transparency/on_grow(obj/structure/spacevine/holder)
	holder.set_opacity(0)
	holder.alpha = 125

/datum/spacevine_mutation/oxy_eater
	name = "oxygen consuming"
	hue = "#ffff88"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/oxy_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.set_moles(/datum/gas/oxygen, max(GM.get_moles(/datum/gas/oxygen) - severity * holder.energy, 0))

/datum/spacevine_mutation/nitro_eater
	name = "nitrogen consuming"
	hue = "#8888ff"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/nitro_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.set_moles(/datum/gas/nitrogen, max(GM.get_moles(/datum/gas/nitrogen) - severity * holder.energy, 0))

/datum/spacevine_mutation/carbondioxide_eater
	name = "CO2 consuming"
	hue = "#00ffff"
	severity = 3
	quality = POSITIVE

/datum/spacevine_mutation/carbondioxide_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.set_moles(/datum/gas/carbon_dioxide, max(GM.get_moles(/datum/gas/carbon_dioxide) - severity * holder.energy, 0))

/datum/spacevine_mutation/plasma_eater
	name = "toxins consuming"
	hue = "#ffbbff"
	severity = 3
	quality = POSITIVE

/datum/spacevine_mutation/plasma_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.set_moles(/datum/gas/plasma, max(GM.get_moles(/datum/gas/plasma) - severity * holder.energy, 0))

/datum/spacevine_mutation/thorns
	name = "thorny"
	hue = "#666666"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/thorns/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(prob(severity) && istype(crosser) && !isvineimmune(holder))
		var/mob/living/M = crosser
		M.adjustBruteLoss(5)
		to_chat(M, "<span class='alert'>You cut yourself on the thorny vines.</span>")

/datum/spacevine_mutation/thorns/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/I, expected_damage)
	if(prob(severity) && istype(hitter) && !isvineimmune(holder))
		var/mob/living/M = hitter
		M.adjustBruteLoss(5)
		to_chat(M, "<span class='alert'>You cut yourself on the thorny vines.</span>")
	. =	expected_damage

/datum/spacevine_mutation/woodening
	name = "hardened"
	hue = "#997700"
	quality = NEGATIVE

/datum/spacevine_mutation/woodening/on_grow(obj/structure/spacevine/holder)
	if(holder.energy)
		holder.density = TRUE
	holder.max_integrity = 100
	holder.obj_integrity = holder.max_integrity

/datum/spacevine_mutation/woodening/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/I, expected_damage)
	if(I.is_sharp())
		. = expected_damage * 0.5
	else
		. = expected_damage

/datum/spacevine_mutation/flowering
	name = "flowering"
	hue = "#0A480D"
	quality = NEGATIVE
	severity = 10

/datum/spacevine_mutation/flowering/on_grow(obj/structure/spacevine/holder)
	if(holder.energy == 2 && prob(severity) && !locate(/obj/structure/alien/resin/flower_bud_enemy) in range(5,holder))
		new/obj/structure/alien/resin/flower_bud_enemy(get_turf(holder))

/datum/spacevine_mutation/flowering/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(prob(25))
		holder.entangle(crosser)


// SPACE VINES (Note that this code is very similar to Biomass code)
/obj/structure/spacevine
	name = "space vines"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	anchored = TRUE
	density = FALSE
	layer = SPACEVINE_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE //Clicking anywhere on the turf is good enough
	pass_flags = PASSTABLE | PASSGRILLE
	max_integrity = 50
	var/energy = 0
	var/datum/spacevine_controller/master = null
	var/list/mutations = list()

/obj/structure/spacevine/Initialize()
	. = ..()
	add_atom_colour("#ffffff", FIXED_COLOUR_PRIORITY)

/obj/structure/spacevine/examine(mob/user)
	. = ..()
	var/text = "This one is a"
	if(mutations.len)
		for(var/A in mutations)
			var/datum/spacevine_mutation/SM = A
			text += " [SM.name]"
	else
		text += " normal"
	text += " vine."
	. += text

/obj/structure/spacevine/Destroy()
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_death(src)
	if(master)
		master.VineDestroyed(src)
	mutations = list()
	set_opacity(0)
	if(has_buckled_mobs())
		unbuckle_all_mobs(force=1)
	return ..()

/obj/structure/spacevine/proc/on_chem_effect(datum/reagent/R)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_chem(src, R)
	if(!override && istype(R, /datum/reagent/toxin/plantbgone))
		if(prob(50))
			qdel(src)

/obj/structure/spacevine/proc/eat(mob/eater)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_eat(src, eater)
	if(!override)
		qdel(src)

/obj/structure/spacevine/attacked_by(obj/item/I, mob/living/user)
	var/damage_dealt = I.force
	if(I.is_sharp())
		damage_dealt *= 4
	if(I.damtype == BURN)
		damage_dealt *= 4

	for(var/datum/spacevine_mutation/SM in mutations)
		damage_dealt = SM.on_hit(src, user, I, damage_dealt) //on_hit now takes override damage as arg and returns new value for other mutations to permutate further
	take_damage(damage_dealt, I.damtype, "melee", 1)

/obj/structure/spacevine/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/slash.ogg', 50, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/structure/spacevine/Crossed(mob/crosser)
	if(isliving(crosser))
		for(var/datum/spacevine_mutation/SM in mutations)
			SM.on_cross(src, crosser)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/spacevine/attack_hand(mob/user)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_hit(src, user)
	user_unbuckle_mob(user, user)
	. = ..()

/obj/structure/spacevine/attack_paw(mob/living/user)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_hit(src, user)
	user_unbuckle_mob(user,user)

/obj/structure/spacevine/attack_alien(mob/living/user)
	eat(user)

/datum/spacevine_controller
	var/list/obj/structure/spacevine/vines
	var/list/growth_queue
	var/spread_multiplier = 5
	var/spread_cap = 30
	var/list/vine_mutations_list
	var/mutativeness = 1

/datum/spacevine_controller/New(turf/location, list/muts, potency, production, var/datum/round_event/event = null)
	vines = list()
	growth_queue = list()
	var/obj/structure/spacevine/SV = spawn_spacevine_piece(location, null, muts)
	if (event)
		event.announce_to_ghosts(SV)
	START_PROCESSING(SSobj, src)
	vine_mutations_list = list()
	init_subtypes(/datum/spacevine_mutation/, vine_mutations_list)
	if(potency != null)
		mutativeness = potency / 10
	if(production != null && production <= 10) //Prevents runtime in case production is set to 11.
		spread_cap *= (11 - production) / 5 //Best production speed of 1 doubles spread_cap to 60 while worst speed of 10 lowers it to 6. Even distribution.
		spread_multiplier /= (11 - production) / 5

/datum/spacevine_controller/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_SPACEVINE_PURGE, "Delete Vines")

/datum/spacevine_controller/vv_do_topic(href_list)
	. = ..()
	if(href_list[VV_HK_SPACEVINE_PURGE])
		if(alert(usr, "Are you sure you want to delete this spacevine cluster?", "Delete Vines", "Yes", "No") == "Yes")
			DeleteVines()

/datum/spacevine_controller/proc/DeleteVines()	//this is kill
	QDEL_LIST(vines)	//this will also qdel us

/datum/spacevine_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/spacevine_controller/proc/spawn_spacevine_piece(turf/location, obj/structure/spacevine/parent, list/muts)
	var/obj/structure/spacevine/SV = new(location)
	growth_queue += SV
	vines += SV
	SV.master = src
	if(muts?.len)
		for(var/datum/spacevine_mutation/M in muts)
			M.add_mutation_to_vinepiece(SV)
		return
	if(parent)
		SV.mutations |= parent.mutations
		var/parentcolor = parent.atom_colours[FIXED_COLOUR_PRIORITY]
		SV.add_atom_colour(parentcolor, FIXED_COLOUR_PRIORITY)
		if(prob(mutativeness))
			var/datum/spacevine_mutation/randmut = pick(vine_mutations_list - SV.mutations)
			randmut.add_mutation_to_vinepiece(SV)

	for(var/datum/spacevine_mutation/SM in SV.mutations)
		SM.on_birth(SV)
	location.Entered(SV)
	return SV

/datum/spacevine_controller/proc/VineDestroyed(obj/structure/spacevine/S)
	S.master = null
	vines -= S
	growth_queue -= S
	if(!vines.len)
		var/obj/item/seeds/kudzu/KZ = new(S.loc)
		KZ.mutations |= S.mutations
		KZ.set_potency(mutativeness * 10)
		KZ.set_production(11 - (spread_cap / initial(spread_cap)) * 5) //Reverts spread_cap formula so resulting seed gets original production stat or equivalent back.
		qdel(src)

/datum/spacevine_controller/process()
	if(!LAZYLEN(vines))
		qdel(src) //space vines exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src) //Sanity check
		return

	var/length = 0

	length = min( spread_cap , max( 1 , vines.len / spread_multiplier ) )
	var/i = 0
	var/list/obj/structure/spacevine/queue_end = list()

	for(var/obj/structure/spacevine/SV in growth_queue)
		if(QDELETED(SV))
			continue
		i++
		queue_end += SV
		growth_queue -= SV
		for(var/datum/spacevine_mutation/SM in SV.mutations)
			SM.process_mutation(SV)
		if(SV.energy < 2) //If tile isn't fully grown
			if(prob(20))
				SV.grow()
		else //If tile is fully grown
			SV.entangle_mob()

		SV.spread()
		if(i >= length)
			break

	growth_queue = growth_queue + queue_end

/obj/structure/spacevine/proc/grow()
	if(!energy)
		src.icon_state = pick("Med1", "Med2", "Med3")
		energy = 1
		set_opacity(1)
	else
		src.icon_state = pick("Hvy1", "Hvy2", "Hvy3")
		energy = 2

	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_grow(src)

/obj/structure/spacevine/proc/entangle_mob()
	if(!has_buckled_mobs() && prob(25))
		for(var/mob/living/V in src.loc)
			entangle(V)
			if(has_buckled_mobs())
				break //only capture one mob at a time


/obj/structure/spacevine/proc/entangle(mob/living/V)
	if(!V || isvineimmune(V))
		return
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_buckle(src, V)
	if((V.stat != DEAD) && (V.buckled != src)) //not dead or captured
		to_chat(V, "<span class='danger'>The vines [pick("wind", "tangle", "tighten")] around you!</span>")
		buckle_mob(V, 1)

/obj/structure/spacevine/proc/spread()
	var/direction = pick(GLOB.cardinals)
	var/turf/stepturf = get_step(src,direction)
	if(locate(/obj/structure, stepturf) || locate(/obj/machinery, stepturf))//if we can't grow into a turf, we'll start digging into it
		for(var/obj/structure/S in stepturf)
			if(S.density && !istype(S, /obj/structure/reagent_dispensers/fueltank)) //don't breach the station!
				S.take_damage(25)
		for(var/obj/machinery/M in stepturf)
			if(M.density && !istype(M, /obj/machinery/power/smes) && !istype(M, /obj/machinery/door/airlock/external) && !istype(M, /obj/machinery/door/firedoor)) //please don't sabotage power or cause a hullbreach!
				M.take_damage(40) //more damage, because machines are more commonplace and tend to be more durable
	if(!isspaceturf(stepturf) && stepturf.Enter(src))
		var/obj/structure/spacevine/spot_taken = locate() in stepturf //Locates any vine on target turf. Calls that vine "spot_taken".
		var/datum/spacevine_mutation/vine_eating/E = locate() in mutations //Locates the vine eating trait in our own seed and calls it E.
		if(!spot_taken || (E && (spot_taken && !spot_taken.mutations.Find(E)))) //Proceed if there isn't a vine on the target turf, OR we have vine eater AND target vine is from our seed and doesn't. Vines from other seeds are eaten regardless.
			if(master)
				for(var/datum/spacevine_mutation/SM in mutations)
					SM.on_spread(src, stepturf) //Only do the on_spread proc if it actually spreads.
					stepturf = get_step(src,direction) //in case turf changes, to make sure no runtimes happen
				master.spawn_spacevine_piece(stepturf, src)

/obj/structure/spacevine/ex_act(severity, target)
	if(istype(target, type)) //if its agressive spread vine dont do anything
		return
	var/i
	for(var/datum/spacevine_mutation/SM in mutations)
		i += SM.on_explosion(severity, target, src)
	if(!i && prob(100/severity))
		qdel(src)

/obj/structure/spacevine/temperature_expose(null, temp, volume)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.process_temperature(src, temp, volume)
	if(!override)
		qdel(src)

/obj/structure/spacevine/CanPass(atom/movable/mover, turf/target)
	if(isvineimmune(mover))
		. = TRUE
	else
		. = ..()

/proc/isvineimmune(atom/A)
	. = FALSE
	if(isliving(A))
		var/mob/living/M = A
		if(("vines" in M.faction) || ("plants" in M.faction))
			. = TRUE
