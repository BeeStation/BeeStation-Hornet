//Major traits - The artifact's main gimmick, how it interacts with the world
///============
/// Capture, moves target inside the artifact
///============
/datum/xenoartifact_trait/major/capture
	desc = "Hollow"
	label_desc = "Hollow: The shape is hollow, however the inside is deceptively large."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	var/spawn_russian = FALSE

/datum/xenoartifact_trait/major/capture/on_init(obj/item/xenoartifact/X)
	if(prob(1))
		spawn_russian = TRUE

/datum/xenoartifact_trait/major/capture/activate(obj/item/xenoartifact/X, atom/target)
	if(isliving(X.loc))
		var/mob/living/holder = X.loc
		holder.dropItemToGround(X, force = TRUE)
	if(ismovable(target) && (istype(target, /obj/item) || istype(target, /mob/living)))
		var/atom/movable/AM = target
		if(AM?.anchored || !AM)
			return
		addtimer(CALLBACK(src, PROC_REF(release), X, AM), X.charge*0.5 SECONDS)
		AM.forceMove(X)
		X.buckle_mob(AM)
		if(isliving(target)) //stop awful hobbit-sis from wriggling
			var/mob/living/victim = target
			victim.Paralyze(X.charge*0.5 SECONDS, ignore_canstun = TRUE)
		X.cooldownmod = X.charge*0.6 SECONDS

/datum/xenoartifact_trait/major/capture/proc/release(obj/item/xenoartifact/X, var/atom/movable/AM) //Empty contents
	if(QDELETED(src) || QDELETED(X) || QDELETED(AM))
		return
	var/turf/T = get_turf(X.loc)
	AM.anchored = FALSE
	AM.forceMove(T)
	if(spawn_russian)
		new /mob/living/simple_animal/hostile/russian(T)
		log_game("[X] spawned (/mob/living/simple_animal/hostile/russian) at [world.time]. [X] located at [AREACOORD(X)]")
		spawn_russian = FALSE

///============
/// Shock, the artifact electrocutes the target
///============
/datum/xenoartifact_trait/major/shock
	desc = "Conductive"
	label_desc = "Conductive: The shape resembles two lighting forks. Subtle arcs seem to leaps across them."
	flags = PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/major/shock/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>You feel a slight static after touching the [X.name].</span>")
	return TRUE

/datum/xenoartifact_trait/major/shock/activate(obj/item/xenoartifact/X, atom/target, mob/user)
	do_sparks(pick(1, 2), FALSE, X)
	if(istype(target, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = target //Have to type convert to work with other traits
		C.give((X.charge/100)*C.maxcharge)

	else if(istype(target, /mob/living))
		var/damage = X.charge*0.25
		var/mob/living/carbon/victim = target
		victim.electrocute_act(damage, X, 1, 1)
		playsound(get_turf(X), 'sound/machines/defib_zap.ogg', 50, TRUE)
	X.cooldownmod = (X.charge*0.1) SECONDS

///============
/// Timestop, spawns time-stop effect
///============
/datum/xenoartifact_trait/major/timestop
	desc = "Temporal"
	label_desc = "Temporal: The shape is drooling and sluggish. Additionally, light around it seems to invert."

/datum/xenoartifact_trait/major/timestop/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>Your hand feels slow while stroking the [X.name].</span>")
	return TRUE

/datum/xenoartifact_trait/major/timestop/activate(obj/item/xenoartifact/X, atom/target)
	var/turf/T = (get_turf(X?.loc) || get_turf(target?.loc))
	if(!T)
		return
	new /obj/effect/timestop(T, 2, (X.charge*0.2) SECONDS)
	X.cooldownmod = (X.charge*0.35) SECONDS

///============
/// Laser, shoots varying laser based on charge
///============
/datum/xenoartifact_trait/major/laser
	desc = "Barreled"
	label_desc = "Barreled: The shape resembles the barrel of a gun. It's possible that it might dispense candy."
	flags = PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/major/laser/activate(obj/item/xenoartifact/X, atom/target, mob/living/user)
	//light target on fire if we're close
	if(isliving(target) && get_dist(target, X.loc || user) <= 1)
		var/mob/living/victim = target
		victim.adjust_fire_stacks(5*(X.charge/X.charge_req))
		victim.IgniteMob()
		return
	//otherwise shoot laser
	var/obj/item/projectile/A
	switch(X.charge)
		if(0 to 24)
			A = new /obj/item/projectile/beam/disabler
		if(25 to 79)
			A = new /obj/item/projectile/beam/laser
		if(80 to 200)
			A = new /obj/item/projectile/beam/laser/heavylaser
	//If target is our own turf, aka someone probably threw us, target a random direction to avoid always shooting east
	if(istype(target, /turf) && X.loc == target)
		target = get_edge_target_turf(pick(NORTH, EAST, SOUTH, WEST))
	//FIRE!
	A.preparePixelProjectile(get_turf(target), X)
	A.fire()
	playsound(get_turf(src), 'sound/mecha/mech_shield_deflect.ogg', 50, TRUE)

///============
/// Corginator, turns the target into a corgi for a short time
///============
/datum/xenoartifact_trait/major/corginator ///All of this is stolen from corgium.
	desc = "Fuzzy" //Weirdchamp
	label_desc = "Fuzzy: The shape is hard to discern under all the hair sprouting out from the surface. You swear you've heard it bark before."
	flags = BLUESPACE_TRAIT
	///List of all affected targets, used for early qdel
	var/list/victims = list()
	///Ref to timer - if corgi is deleted early remove this reference to the puppy
	var/timer

/datum/xenoartifact_trait/major/corginator/activate(obj/item/xenoartifact/X, mob/living/target)
	X.say(pick("Woof!", "Bark!", "Yap!"))
	if(istype(target, /mob/living) && !(istype(target, /mob/living/simple_animal/pet/dog/corgi)) && !IS_DEAD_OR_INCAP(target))
		var/mob/living/simple_animal/pet/dog/corgi/new_corgi = transform(target)
		timer = addtimer(CALLBACK(src, PROC_REF(transform_back), new_corgi), (X.charge*0.6) SECONDS, TIMER_STOPPABLE)
		victims |= new_corgi
		X.cooldownmod = (X.charge*0.8) SECONDS

/datum/xenoartifact_trait/major/corginator/proc/transform(mob/living/target)
	if(!istype(target))
		return
	var/obj/shapeshift_holder/H = locate() in target
	if(H)
		playsound(get_turf(target), 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return
	ADD_TRAIT(target, TRAIT_NOBREATH, TRAIT_NOMOBSWAP)
	var/mob/living/simple_animal/pet/dog/corgi/new_corgi = new(target.loc)
	H = new(new_corgi,src,target)
	//hat check
	var/mob/living/carbon/C = target
	if(istype(C))
		var/obj/item/hat = C.get_item_by_slot(ITEM_SLOT_HEAD)
		if(hat?.dog_fashion)
			new_corgi.place_on_head(hat,null,FALSE)
	RegisterSignal(new_corgi, COMSIG_MOB_DEATH, PROC_REF(transform_back))
	return new_corgi

/datum/xenoartifact_trait/major/corginator/proc/transform_back(mob/living/simple_animal/pet/dog/corgi/new_corgi)
	//Kill timer
	deltimer(timer)
	timer = null

	var/obj/shapeshift_holder/H = locate() in new_corgi
	if(!H)
		return
	var/mob/living/target = H.stored
	UnregisterSignal(new_corgi, COMSIG_MOB_DEATH)
	REMOVE_TRAIT(target, TRAIT_NOBREATH, TRAIT_NOMOBSWAP)
	victims -= new_corgi
	var/turf/T = get_turf(new_corgi)
	if(new_corgi.inventory_head && !target.equip_to_slot_if_possible(new_corgi.inventory_head, ITEM_SLOT_HEAD,disable_warning = TRUE, bypass_equip_delay_self=TRUE))
		new_corgi.inventory_head.forceMove(T)
	new_corgi.inventory_back?.forceMove(T)
	new_corgi.inventory_head = null
	new_corgi.inventory_back = null
	H.restore(FALSE, FALSE)
	target.Knockdown(0.2 SECONDS)

/datum/xenoartifact_trait/major/corginator/Destroy() //Transform goobers back if artifact is deleted.
	. = ..()
	if(victims.len)
		for(var/mob/living/simple_animal/pet/dog/corgi/H as() in victims)
			transform_back(H)

///============
/// EMP, produces an empulse
///============
/datum/xenoartifact_trait/major/emp
	label_name = "EMP"
	label_desc = "EMP: The shape of the Artifact doesn't resemble anything particularly interesting. Technology around the Artifact seems to malfunction."
	flags = URANIUM_TRAIT
	weight = 25 //annoying trait

/datum/xenoartifact_trait/major/emp/activate(obj/item/xenoartifact/X)
	playsound(get_turf(X), 'sound/magic/disable_tech.ogg', 50, TRUE)
	empulse(get_turf(X.loc), max(1, X.charge*0.03), max(1, X.charge*0.07, 1)) //This might be too big

///============
/// Invisible, makes the target invisible for a short time
///============
/datum/xenoartifact_trait/major/invisible //One step closer to the one ring
	label_name = "Transparent"
	label_desc = "Transparent: The shape of the Artifact is difficult to percieve. You feel the need to call it, precious..."
	weight = 25
	var/list/victims = list()

/datum/xenoartifact_trait/major/invisible/on_item(obj/item/xenoartifact/X, atom/user, obj/item/I)
	if(istype(I) && I.light_power > 0)
		to_chat(user, "<span class='info'>The [I.name]'s light passes through the structure.</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/major/invisible/activate(obj/item/xenoartifact/X, mob/living/target)
	if(isliving(target))
		victims += WEAKREF(target)
		hide(target)
		addtimer(CALLBACK(src, PROC_REF(reveal), target), ((X.charge*0.4) SECONDS))
		X.cooldownmod = ((X.charge*0.4)+1) SECONDS

/datum/xenoartifact_trait/major/invisible/proc/hide(mob/living/target)
	ADD_TRAIT(target, TRAIT_PACIFISM, type)
	animate(target, alpha = 0, time = 5)

/datum/xenoartifact_trait/major/invisible/proc/reveal(mob/living/target)
	if(target)
		REMOVE_TRAIT(target, TRAIT_PACIFISM, type)
		animate(target, alpha = 255, time = 5)

/datum/xenoartifact_trait/major/invisible/Destroy()
	. = ..()
	for(var/M in victims)
		var/datum/weakref/r = M
		var/mob/living/L = r.resolve()
		reveal(L)

///============
/// Teleports the target to a random nearby location
///============
/datum/xenoartifact_trait/major/teleporting
	desc = "Displaced"
	label_desc = "Displaced: The shape's state is unstable, causing it to shift through planes at a localized axis. Just ask someone from science..."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/major/teleporting/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	if(istype(target, /atom/movable))
		var/atom/movable/victim = target //typecast to access anchored
		if(!victim.anchored)
			do_teleport(victim, get_turf(victim), (X.charge*0.3)+1, channel = TELEPORT_CHANNEL_BLUESPACE)

///============
/// Lamp, creates a light with random color for a short time
///============
/datum/xenoartifact_trait/major/lamp
	label_name = "Lamp"
	label_desc = "Lamp: The Artifact emits light. Nothing in its shape suggests this."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT
	var/light_mod

/datum/xenoartifact_trait/major/lamp/on_init(obj/item/xenoartifact/X)
	X.light_color = pick(LIGHT_COLOR_FIRE, LIGHT_COLOR_BLUE, LIGHT_COLOR_GREEN, LIGHT_COLOR_RED, LIGHT_COLOR_ORANGE, LIGHT_COLOR_PINK)

/datum/xenoartifact_trait/major/lamp/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	X.visible_message("<span class='notice'>The [X] lights up!</span>")
	X.set_light(X.charge*0.08, max(X.charge*0.05, 5), X.light_color)
	addtimer(CALLBACK(src, PROC_REF(unlight), X), (X.charge*0.6) SECONDS)
	X.cooldownmod = (X.charge*0.6) SECONDS

/datum/xenoartifact_trait/major/lamp/proc/unlight(var/obj/item/xenoartifact/X)
	X.set_light(0, 0)

///============
/// Forcefield, creates a random shape wizard wall
///============
/datum/xenoartifact_trait/major/forcefield
	label_name = "Wall"
	label_desc = "Wall: The Artifact produces a resonance that forms impenetrable walls. Here's one you'll never crawl!"
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT
	var/size

/datum/xenoartifact_trait/major/forcefield/on_init(obj/item/xenoartifact/X)
	size = pick(1, 3, 5)

/datum/xenoartifact_trait/major/forcefield/activate(obj/item/xenoartifact/X)
	if(size >= 1)
		new /obj/effect/forcefield/xenoartifact_type(get_turf(X.loc), (X.charge*0.4) SECONDS)
	if(size >= 3)
		var/outcome = pick(0, 1)
		if(outcome || size >= 5)
			new /obj/effect/forcefield/xenoartifact_type(get_step(X, NORTH), (X.charge*0.4) SECONDS)
			new /obj/effect/forcefield/xenoartifact_type(get_step(X, SOUTH), (X.charge*0.4) SECONDS)
		else
			new /obj/effect/forcefield/xenoartifact_type(get_step(X, EAST), (X.charge*0.4) SECONDS)
			new /obj/effect/forcefield/xenoartifact_type(get_step(X, WEST), (X.charge*0.4) SECONDS)
	if(size >= 5)
		new /obj/effect/forcefield/xenoartifact_type(get_step(X, WEST), (X.charge*0.4) SECONDS)
		new /obj/effect/forcefield/xenoartifact_type(get_step(X, EAST), (X.charge*0.4) SECONDS)

	X.cooldownmod = (X.charge*0.4) SECONDS

/obj/effect/forcefield/xenoartifact_type //Special wall type for artifact
	desc = "An impenetrable artifact wall."

///============
/// Heal, heals a random damage type
///============
/datum/xenoartifact_trait/major/heal
	label_name = "Healing"
	label_desc = "Healing: The Artifact repeairs any damaged organic tissue the targat may contain. Widely considered the Holy Grail of Artifact traits."
	flags = BLUESPACE_TRAIT
	weight = 25
	var/healing_type

/datum/xenoartifact_trait/major/heal/on_init(obj/item/xenoartifact/X)
	healing_type = pick(BRUTE, BURN, TOX)

/datum/xenoartifact_trait/major/heal/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/healthanalyzer))
		to_chat(user, "<span class='info'>The [item] recognizes foreign [healing_type] healing proteins.\n</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/major/heal/activate(obj/item/xenoartifact/X, atom/target)
	playsound(get_turf(target), 'sound/magic/staff_healing.ogg', 50, TRUE)
	if(istype(target, /mob/living))
		var/mob/living/victim = target
		switch(healing_type)
			if(BRUTE)
				victim.adjustBruteLoss((X.charge*0.25)*-1)
			if(BURN)
				victim.adjustFireLoss((X.charge*0.25)*-1)
			if(TOX)
				victim.adjustToxLoss((X.charge*0.25)*-1)

///============
/// Chem, injects a random safe chem into target
///============
/datum/xenoartifact_trait/major/chem
	desc = "Hypodermic"
	label_desc = "Hypodermic: The Artifact's shape is comprised of many twisting tubes and vials, it seems a liquid may be inside."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/long)
	var/datum/reagent/formula
	var/amount

/datum/xenoartifact_trait/major/chem/on_init(obj/item/xenoartifact/X)
	amount = pick(7, 14, 21)
	formula = get_random_reagent_id(CHEMICAL_RNG_GENERAL)

/datum/xenoartifact_trait/major/chem/activate(obj/item/xenoartifact/X, atom/target)
	if(target?.reagents)
		playsound(get_turf(X), pick('sound/items/hypospray.ogg','sound/items/hypospray2.ogg'), 50, TRUE)
		var/datum/reagents/R = target.reagents
		R.add_reagent(formula, amount*(initial(formula.metabolization_rate)))
		log_game("[X] injected [key_name_admin(target)] with [amount]u of [formula] at [world.time]. [X] located at [AREACOORD(X)]")

///============
/// Push, pushes target away from artifact
///============
/datum/xenoartifact_trait/major/push
	label_name = "Push"
	label_desc = "Push: The Artifact pushes anything not bolted down. The shape doesn't suggest this."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/major/push/activate(obj/item/xenoartifact/X, atom/target)
	if(ismovable(target))
		var/atom/movable/victim = target
		if(victim.anchored)
			return
		var/atom/trg = get_edge_target_turf(X.loc, get_dir(X.loc, target.loc) || pick(NORTH, EAST, SOUTH, WEST))
		victim.throw_at(get_turf(trg), (X.charge*0.07)+1, 8)

///============
/// Pull, pulls target towards artifact
///============
/datum/xenoartifact_trait/major/pull
	label_name = "Pull"
	label_desc = "Pull: The Artifact pulls anything not bolted down. The shape doesn't suggest this."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/major/pull/on_init(obj/item/xenoartifact/X)
	X.max_range += 1

/datum/xenoartifact_trait/major/pull/activate(obj/item/xenoartifact/X, atom/target)
	if(ismovable(target))
		var/atom/movable/victim = target
		if(victim.anchored)
			return
		if(get_dist(X, target) <= 1 && isliving(target))
			var/mob/living/living_victim = target
			living_victim.Knockdown(SHOVE_KNOCKDOWN_SOLID)
		victim.throw_at(get_turf(X), X.charge*0.08, 8)

///============
/// Horn, produces a random noise
///============
/datum/xenoartifact_trait/major/horn
	desc = "Horned"
	label_name = "Horn"
	label_desc = "Horn: The Artifact's shape resembles a horn. These Artifacts are widely deployed by the most clever clowns."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	var/sound

/datum/xenoartifact_trait/major/horn/on_init(obj/item/xenoartifact/X)
	sound = pick(list('sound/effects/adminhelp.ogg', 'sound/effects/applause.ogg', 'sound/effects/bubbles.ogg',
					'sound/effects/empulse.ogg', 'sound/effects/explosion1.ogg', 'sound/effects/explosion_distant.ogg',
					'sound/effects/laughtrack.ogg', 'sound/effects/magic.ogg', 'sound/effects/meteorimpact.ogg',
					'sound/effects/phasein.ogg', 'sound/effects/supermatter.ogg', 'sound/weapons/armbomb.ogg',
					'sound/weapons/blade1.ogg'))

/datum/xenoartifact_trait/major/horn/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	playsound(get_turf(target), sound, 50, FALSE)

///============
/// Gas, replaces a random gas with another random gas
///============
/datum/xenoartifact_trait/major/gas
	desc = "Porous"
	label_desc = "Porous: The Artifact absorbs a specific nearby gas and replaces it with an undeterminable one."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT
	var/static/list/valid_inputs = list(
		/datum/gas/oxygen = 6,
		/datum/gas/nitrogen = 3,
		/datum/gas/plasma = 1,
		/datum/gas/carbon_dioxide = 1,
		/datum/gas/water_vapor = 3
	)
	var/static/list/valid_outputs = list(
		/datum/gas/bz = 3,
		/datum/gas/hypernoblium = 1,
		/datum/gas/plasma = 3,
		/datum/gas/tritium = 2,
		/datum/gas/nitryl = 1
	)
	var/datum/gas/input
	var/datum/gas/output

/datum/xenoartifact_trait/major/gas/on_init(obj/item/xenoartifact/X)
	input = pickweight(valid_inputs)
	valid_outputs -= input //in the rare case the artifact wants to exhcange plasma for more plasma.
	output = pickweight(valid_outputs)

/datum/xenoartifact_trait/major/gas/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/analyzer))
		to_chat(user, "<span class='info'>The [item] detects trace amounts of [initial(output.name)] exchanging with [initial(input.name)].\n</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/major/gas/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	var/turf/T = get_turf(X)
	var/datum/gas_mixture/air = T.return_air()
	var/input_id = initial(input.id)
	var/output_id = initial(output.id)
	var/moles = min(air.get_moles(input_id), 5)
	if(moles)
		air.adjust_moles(input_id, -moles)
		air.adjust_moles(output_id, moles)

///============
/// Destabilizing, teleports the victim to that weird place from the exploration meme.
///============
/datum/xenoartifact_trait/major/distablizer
	desc = "Destabilizing"
	label_desc = "Destabilizing: The Artifact collapses an improper bluespace matrix on the target, sending them to an unknown location."
	weight = 25
	flags = URANIUM_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/aura)
	var/obj/item/xenoartifact/exit

/datum/xenoartifact_trait/major/distablizer/on_init(obj/item/xenoartifact/X)
	exit = X
	GLOB.destabliization_exits += X

/datum/xenoartifact_trait/major/distablizer/on_item(obj/item/xenoartifact/X, mob/living/carbon/human/user, atom/item)
	var/obj/item/clothing/gloves/artifact_pinchers/P
	if(istype(user))
		P = user.get_item_by_slot(ITEM_SLOT_GLOVES)
	if(!P?.safety && do_banish(item))
		to_chat(user, "<span class='warning'>The [item] dissapears!</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/major/distablizer/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	if(do_banish(target))
		X.cooldownmod = X.charge*0.2 SECONDS

/datum/xenoartifact_trait/major/distablizer/proc/do_banish(atom/target)
	. = FALSE
	if(isliving(exit.loc))
		var/mob/living/holder = exit.loc
		holder.dropItemToGround(exit)
	if(istype(target, /obj/item/xenoartifact))
		return
	if(ismovable(target))
		var/atom/movable/AM = target
		if(AM.anchored)
			return
		if(AM.forceMove(pick(GLOB.destabilization_spawns)))
			return TRUE

/datum/xenoartifact_trait/major/distablizer/Destroy()
	GLOB.destabliization_exits -= exit
	..()

///============
/// Dissipating, the artifact creates a could of smoke.
///============
/datum/xenoartifact_trait/major/smokey
	desc = "Dissipating"
	label_desc = "Dissipating: The Artifact is dissipating as if it was made of smoke."
	flags = URANIUM_TRAIT | PLASMA_TRAIT | BLUESPACE_TRAIT

/datum/xenoartifact_trait/major/smokey/activate(obj/item/xenoartifact/X, atom/target, atom/user, setup)
	var/datum/effect_system/smoke_spread/E = new()
	E.set_up(max(3, X.charge*0.08), get_turf(X))
	E.start()

///============
/// Marker, colors target with a random color
///============
/datum/xenoartifact_trait/major/marker
	label_name = "Marker"
	label_desc = "Marker: The Artifact causes the target to refract a unique color index."
	flags = PLASMA_TRAIT | BLUESPACE_TRAIT
	///The color this artifact dispenses
	var/color

/datum/xenoartifact_trait/major/marker/on_init(obj/item/xenoartifact/X)
	color = pick(COLOR_RED, COLOR_GREEN, COLOR_BLUE, COLOR_PURPLE, COLOR_ORANGE, COLOR_YELLOW, COLOR_CYAN, COLOR_PINK, "all")

/datum/xenoartifact_trait/major/marker/activate(obj/item/xenoartifact/X, atom/target, atom/user, setup)
	if(color == "all")
		target.color = pick(COLOR_RED, COLOR_GREEN, COLOR_BLUE, COLOR_PURPLE, COLOR_ORANGE, COLOR_YELLOW, COLOR_CYAN, COLOR_PINK)
	else
		target.color = color

///============
/// emote, makes user do a random emote
///============
/datum/xenoartifact_trait/major/emote
	label_name = "Emotional"
	label_desc = "Emotional: The Artifact causes the target to experience, or preform, a random emotion."
	flags = PLASMA_TRAIT | BLUESPACE_TRAIT | URANIUM_TRAIT
	///Emote to preform
	var/datum/emote/emote

/datum/xenoartifact_trait/major/emote/on_init(obj/item/xenoartifact/X)
	emote = pick(GLOB.xenoa_emote)
	emote = new emote()

/datum/xenoartifact_trait/major/emote/activate(obj/item/xenoartifact/X, atom/target, atom/user, setup)
	if(iscarbon(target))
		emote.run_emote(target)
	//Not all mobs can preform the given emotes, spin is pretty common though
	else if(isliving(target))
		var/datum/emote/spin/E = new()
		E.run_emote(target)

/datum/xenoartifact_trait/major/emote/Destroy()
	. = ..()
	QDEL_NULL(emote)
