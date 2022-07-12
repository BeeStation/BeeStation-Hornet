///Xenoartifact traits, datum-ised
/datum/xenoartifact_trait
	///Acts as a descriptor for when examining. Also used for naming stuff in the labeler. Keep these short.
	var/desc
	///Used when labeler needs a name and trait is too sneaky to have a descriptor when examining.
	var/label_name
	///Something briefly explaining it in IG terms or a pun.
	var/label_desc
	///Asscoiated flags for artifact typing
	var/flags = NONE
	///Other traits the original trait wont work with. Referenced when generating traits.
	var/list/blacklist_traits = list()
	///Weight in trait list, most traits wont change this
	var/weight = 50

///Proc used to compile trait weights into a list
/proc/compile_artifact_weights(path)
	if(!ispath(path))
		return
	var/list/temp = subtypesof(path)
	var/list/weighted = list()
	for(var/datum/xenoartifact_trait/T as() in temp)
		weighted += list((T) = initial(T?.weight))
	return weighted

///Compile a blacklist of traits from a given flag/s
/proc/compile_artifact_blacklist(var/flags)
	var/list/output = list()
	for(var/datum/xenoartifact_trait/T as() in XENOA_ALL_TRAITS)
		if(!(initial(T.flags) & flags))
			output += T
	return output

//Activator signal shenanignas 
/datum/xenoartifact_trait/activator
	///How much an activator trait can output on a standard, modified by the artifacts charge_req and circumstances.
	var/charge
	///which signals trait responds to
	var/list/signals
	///Not used outside of signal handle, please
	var/obj/item/xenoartifact/xenoa

/datum/xenoartifact_trait/activator/proc/calculate_charge(obj/item/xenoartifact/X)
	return

/datum/xenoartifact_trait/activator/on_init(obj/item/xenoartifact/X)
	. = ..()
	if(!X)
		return
	xenoa = X
	for(var/s in signals)
		switch(s) //Translating signal params to vaugely resemble (/obj/item, /mob/living, params)
			if(COMSIG_PARENT_ATTACKBY)
				RegisterSignal(xenoa, COMSIG_PARENT_ATTACKBY, .proc/translate_attackby)
			if(COMSIG_ITEM_ATTACK)
				RegisterSignal(xenoa, COMSIG_ITEM_ATTACK, .proc/translate_attack)
			if(COMSIG_MOVABLE_IMPACT)
				RegisterSignal(xenoa, COMSIG_MOVABLE_IMPACT, .proc/translate_impact)
			if(COMSIG_ITEM_AFTERATTACK)
				RegisterSignal(xenoa, COMSIG_ITEM_AFTERATTACK, .proc/translate_afterattack)
			if(COMSIG_ITEM_PICKUP)
				RegisterSignal(xenoa, COMSIG_ITEM_PICKUP, .proc/translate_pickup)
			if(COMSIG_ITEM_ATTACK_SELF)
				RegisterSignal(xenoa, COMSIG_ITEM_ATTACK_SELF, .proc/translate_attack_self)
			if(XENOA_SIGNAL)
				RegisterSignal(xenoa, XENOA_SIGNAL, .proc/translate_attackby)
	RegisterSignal(xenoa, XENOA_DEFAULT_SIGNAL, .proc/calculate_charge) //Signal sent by handles

/datum/xenoartifact_trait/activator/Destroy(force, ...)
	. = ..()
	if(!xenoa)
		return
	for(var/s in signals)
		UnregisterSignal(xenoa, s)
	UnregisterSignal(xenoa, XENOA_DEFAULT_SIGNAL)
	xenoa = null

/datum/xenoartifact_trait/activator/proc/translate_attackby(datum/source, obj/item/thing, mob/user, params)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, thing, user, user)

/datum/xenoartifact_trait/activator/proc/translate_attack_self(datum/source, mob/user, params)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, xenoa, user, user)

/datum/xenoartifact_trait/activator/proc/translate_attack(mob/living/target, mob/living/user)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, xenoa, user, target)

/datum/xenoartifact_trait/activator/proc/translate_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, xenoa, hit_atom, throwingdatum) //Weird order to fix this becuase signals are mean

/datum/xenoartifact_trait/activator/proc/translate_afterattack(atom/target, mob/user, params)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, target, params, user) //Weird order to fix this becuase signals are mean

/datum/xenoartifact_trait/activator/proc/translate_pickup(mob/user, params)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, xenoa, params, params) //Weird order to fix this becuase signals are mean

//End activator
//Declare procs
/datum/xenoartifact_trait/minor //Leave these here, for the future.

/datum/xenoartifact_trait/major

/datum/xenoartifact_trait/malfunction
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/proc/activate(obj/item/xenoartifact/X, atom/target, atom/user, setup = TRUE) //Typical behaviour
	return

/datum/xenoartifact_trait/proc/on_item(obj/item/xenoartifact/X, atom/user, atom/item) //Item hint responses
	return FALSE

///This is better than initialize just for our specific control purposes, definitely not becuase I forgot to use it somehow.
/datum/xenoartifact_trait/proc/on_init(obj/item/xenoartifact/X)
	return

/datum/xenoartifact_trait/proc/on_touch(obj/item/xenoartifact/X, atom/user) //Touch hint
	return FALSE

/datum/xenoartifact_trait/special/objective
	blacklist_traits = list(/datum/xenoartifact_trait/minor/delicate)

/datum/xenoartifact_trait/special/objective/on_init(obj/item/xenoartifact/X) //Exploration mission GPS trait
	X.AddComponent(/datum/component/gps, "[scramble_message_replace_chars("#########", 100)]", TRUE)

//Activation traits - only used to generate charge
//============
// Default acvitavor, on-use / interact
//============
/datum/xenoartifact_trait/activator/impact
	desc = "Sturdy"
	label_desc = "Sturdy: The material is sturdy. The amount of force applied seems to directly correlate to the size of the reaction."
	charge = 25
	signals = list(COMSIG_PARENT_ATTACKBY, COMSIG_MOVABLE_IMPACT, COMSIG_ITEM_ATTACK_SELF, COMSIG_ITEM_AFTERATTACK)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/activator/impact/calculate_charge(datum/source, obj/item/thing, mob/user, atom/target)
	var/obj/item/xenoartifact/X = source
	charge = charge*(thing?.force*0.1)
	X.default_activate(charge, user, target)

//============
// Burn activator, responds to fire
//============
/datum/xenoartifact_trait/activator/burn
	desc = "Flammable"
	label_desc = "Flammable: The material is flammable, and seems to react when ignited."
	charge = 25
	signals = list(COMSIG_PARENT_ATTACKBY)
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/activator/burn/on_init(obj/item/xenoartifact/X)
	..()
	X.max_range += 1

/datum/xenoartifact_trait/activator/burn/calculate_charge(datum/source, obj/item/thing, mob/user, atom/target, params) //xenoa item handles this, see process proc there
	var/obj/item/xenoartifact/X = source
	if(X.process_type != PROCESS_TYPE_LIT && thing.ignition_effect(X, user))
		X.visible_message("<span class='danger'>The [X.name] sparks on.</span>")
		X.process_type = PROCESS_TYPE_LIT
		sleep(1.8 SECONDS) //Give them a chance to escape
		START_PROCESSING(SSobj, X)
		log_game("[user]:[isliving(user) ? user?.ckey : "no ckey"] lit [X] at [world.time] using [thing]. [X] located at [X.x] [X.y] [X.z].")

//============
// Timed activator, activates on a timer. Timer is turned on when used, has a chance to turn off.
//============
/datum/xenoartifact_trait/activator/clock
	label_name = "Tuned"
	label_desc = "Tuned: The material produces a resonance pattern similar to quartz, causing it to produce a reaction every so often."
	charge = 25
	blacklist_traits = list(/datum/xenoartifact_trait/minor/capacitive)
	signals = list(COMSIG_PARENT_ATTACKBY, COMSIG_MOVABLE_IMPACT, COMSIG_ITEM_ATTACK_SELF, COMSIG_ITEM_AFTERATTACK)
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/activator/clock/on_init(obj/item/xenoartifact/X)
	..()
	X.max_range += 1
	X.malfunction_mod = 0.5

/datum/xenoartifact_trait/activator/clock/on_item(obj/item/xenoartifact/X, atom/user, atom/item) 
	if(istype(item, /obj/item/clothing/neck/stethoscope))
		to_chat(user, "<span class='info'>The [X.name] ticks deep from within.\n</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/activator/clock/calculate_charge(datum/source, obj/item/thing, mob/user, atom/target, params)
	var/obj/item/xenoartifact/X = source
	X.process_type = PROCESS_TYPE_TICK
	START_PROCESSING(SSobj, X)
	log_game("[user]:[isliving(user) ? user?.ckey : "no ckey"] set clock on [X] at [world.time] using [thing]. [X] located at [X.x] [X.y] [X.z].")

//============
// Signal activator, responds to respective signals sent through signallers
//============
/datum/xenoartifact_trait/activator/signal
	label_name = "Signal"
	label_desc = "Signal: The material recieves radio frequencies and reacts when a matching code is delivered."
	charge = 25
	signals = list(XENOA_SIGNAL)
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/activator/signal/on_init(obj/item/xenoartifact/X)
	..()
	X.code = rand(1, 100) //Random code is shared by all signaller traits
	X.frequency = FREQ_SIGNALER
	X.set_frequency(X.frequency)
	X.max_range += 1

/datum/xenoartifact_trait/activator/signal/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/analyzer))
		to_chat(user, "<span class='info'>The [item.name] displays a signal-input code of [X.code], and frequency [X.frequency].</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/activator/signal/calculate_charge(datum/source, obj/item/thing, mob/user, atom/target, params)
	var/obj/item/xenoartifact/X = source
	X.default_activate(charge, user, target)
	log_game("[user]:[isliving(user) ? user?.ckey : "no ckey"] signalled [X] at [world.time]. [X] located at [X.x] [X.y] [X.z].")

//============
// Battery activator, needs a cell to activate
//============
/datum/xenoartifact_trait/activator/batteryneed
	desc = "Charged"
	label_desc = "Charged: The material has a natural power draw. Supplying any current to this will cause a reaction."
	charge = 25
	signals = list(COMSIG_PARENT_ATTACKBY)
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/activator/batteryneed/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/multitool))
		to_chat(user, "<span class='info'>The [item.name] displays a draw of [X.charge_req].</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/activator/batteryneed/calculate_charge(datum/source, obj/item/thing, mob/user, atom/target, params)
	var/obj/item/xenoartifact/X = source
	if(istype(thing, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = thing
		if(C.use(X.charge_req*10))
			X.default_activate(charge, user, user)

//============
// Weighted activator, picking up activates
//============
/datum/xenoartifact_trait/activator/weighted
	desc = "Weighted"
	label_desc = "Weighted: The material is weighted and produces a reaction when picked up."
	charge = 25
	signals = list(COMSIG_ITEM_PICKUP)
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense, /datum/xenoartifact_trait/minor/anchor, /datum/xenoartifact_trait/major/distablizer)
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/activator/weighted/calculate_charge(datum/source, obj/item/thing, mob/user, atom/target)
	var/obj/item/clothing/gloves/artifact_pinchers/P = locate(/obj/item/clothing/gloves/artifact_pinchers) in target.contents
	P = (P ? P : locate(/obj/item/clothing/gloves/artifact_pinchers) in user.contents) //Signal black magic makes me need to check twice...
	if(P?.safety) //This trait is a special tism
		return
	var/obj/item/xenoartifact/X = source
	X.default_activate(charge, user, target)

//============
// Pitch activator, artifact activates when thrown. Credit to EvilDragon#4532
//============
/datum/xenoartifact_trait/activator/pitch
	label_name = "Pitched"
	label_desc = "Pitched: The material is aerodynamic and activates when thrown."
	charge = 25
	blacklist_traits = (/datum/xenoartifact_trait/minor/dense)
	signals = list(COMSIG_MOVABLE_IMPACT)
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/activator/pitch/calculate_charge(datum/source, obj/item/thing, mob/user, atom/target)
	var/obj/item/xenoartifact/X = source
	X.default_activate(charge, user, target)

//Minor traits - Use the to define aspects of the artifact without any immediate interaction
//============
// Looped, increases charge towards 100
//============
/datum/xenoartifact_trait/minor/looped
	desc = "Looped"
	label_desc = "Looped: The Artifact feeds into itself and amplifies its own charge."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/looped/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/multitool))
		to_chat(user, "<span class='info'>The [item.name] displays a resistance reading of [X.charge_req*0.1].</span>") 
		return TRUE
	..()

/datum/xenoartifact_trait/minor/looped/activate(obj/item/xenoartifact/X)
	X.charge = ((100-X.charge)*0.2)+X.charge //This should generally cut off around 100

//============
// Capacitive, gives the artifact extra uses before it starts cooldown
//============
/datum/xenoartifact_trait/minor/capacitive
	desc = "Capacitive"
	label_desc = "Capacitive: The Artifact's structure allows it to hold extra charges."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	var/charges //Extra uses, not total
	var/saved_cooldown //This may be considered messy but it's a more practical approach that avoids making an edgecase

/datum/xenoartifact_trait/minor/capacitive/on_init(obj/item/xenoartifact/X)
	charges = pick(0, 1, 2) //Extra charges, not total

/datum/xenoartifact_trait/minor/capacitive/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>The hairs on your neck stand up after touching the [X.name].</span>")
	return TRUE

/datum/xenoartifact_trait/minor/capacitive/activate(obj/item/xenoartifact/X)
	if(!(saved_cooldown) && X.cooldown)
		saved_cooldown = X.cooldown //Avoid doing this on init beacause malfunctions can change it in the future
	if(charges)
		charges -= 1
		X.cooldown = -1000 SECONDS //This is better than making a unique interaction in xenoartifact.dm
		return
	charges = pick(0, 1, 2)
	playsound(get_turf(X), 'sound/machines/capacitor_charge.ogg', 50, TRUE) 
	X.cooldown = saved_cooldown
	saved_cooldown = null

/datum/xenoartifact_trait/minor/capacitive/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/multitool))
		to_chat(user, "<span class='info'>The [item.name] displays an overcharge reading of [charges/3].</span>") 
		return TRUE
	..()

//============
// Dense, makes the artifact mimic a structure
//============
/datum/xenoartifact_trait/minor/dense //Rather large, quite gigantic, particularly big
	desc = "Dense"
	label_desc = "Dense: The Artifact is dense and cannot be easily lifted but, the design has a slightly higher reaction rate."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/wearable, /datum/xenoartifact_trait/minor/sharp, /datum/xenoartifact_trait/minor/light, /datum/xenoartifact_trait/minor/heavy, /datum/xenoartifact_trait/minor/blocking, /datum/xenoartifact_trait/minor/anchor)
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/dense/on_init(obj/item/xenoartifact/X)
	X.density = TRUE
	X.interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	X.interaction_flags_item = INTERACT_ATOM_ATTACK_HAND
	X.charge_req += 20

//============
// Sharp, makes the artifact do extra damage and slice type
//============
/datum/xenoartifact_trait/minor/sharp
	desc = "Sharp"
	label_desc = "Sharp: The Artifact is shaped into a fine point. Perfect for popping balloons."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	flags = PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/sharp/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>The [X.name] feels sharp.</span>")
	return TRUE

/datum/xenoartifact_trait/minor/sharp/on_init(obj/item/xenoartifact/X)
	X.sharpness = IS_SHARP_ACCURATE
	X.force = X.charge_req*0.12
	X.attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "tore", "ripped", "diced", "cut")
	X.attack_weight = 2
	X.armour_penetration = 5

//============
// Cooler, reduces cooldown times
//============
/datum/xenoartifact_trait/minor/cooler
	desc = "Frosted"
	label_desc = "Frosted: The Artifact has the unique property of actively cooling itself. This also seems to reduce time between uses."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/cooler/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>The [X.name] feels cold.</span>")
	return TRUE

/datum/xenoartifact_trait/minor/cooler/on_init(obj/item/xenoartifact/X)
	X.cooldown = 4 SECONDS //Might revisit the value.

/datum/xenoartifact_trait/minor/cooler/activate(obj/item/xenoartifact/X)
	X.charge -= 10

//============
// Sentient, allows a ghost to control the artifact
//============
/datum/xenoartifact_trait/minor/sentient
	label_name = "Sentient"
	label_desc = "Sentient: The Artifact seems to be alive, influencing events around it. The Artifact wants to return to its master..."
	///he who lives inside
	var/mob/living/simple_animal/man
	///His doorbell
	var/obj/effect/mob_spawn/sentient_artifact/S

/datum/xenoartifact_trait/minor/sentient/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='warning'>The [X.name] whispers to you...</span>")
	return TRUE

/datum/xenoartifact_trait/minor/sentient/on_init(obj/item/xenoartifact/X)
	addtimer(CALLBACK(src, .proc/get_canidate, X), 5 SECONDS)

/datum/xenoartifact_trait/minor/sentient/proc/get_canidate(obj/item/xenoartifact/X)
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the maleviolent force inside the [X.name]?", ROLE_SENTIENCE, null, FALSE, 5 SECONDS, POLL_IGNORE_SENTIENCE_POTION)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		setup_sentience(X, C.ckey)
		return
	S = new(get_turf(X), X)
	S.density = FALSE

/datum/xenoartifact_trait/minor/sentient/proc/setup_sentience(obj/item/xenoartifact/X, ckey)
	if(!(SSzclear.get_free_z_level()))
		playsound(get_turf(X), 'sound/machines/buzz-sigh.ogg', 50, TRUE) 
		return	
	man = new(get_turf(X))
	man.name = "[pick("Calcifer", "Lucifer", "Ahpuch", "Ahriman")]"
	man.real_name = "[man.name] - [X]"
	man.key = ckey
	man.maxbodytemp = INFINITY
	log_game("[man]:[man.ckey] took control of the sentient [X]. [X] located at [X.x] [X.y] [X.z]")
	ADD_TRAIT(man, TRAIT_NOBREATH, TRAIT_NODEATH)
	man.forceMove(X) //Better hope no greedy goblins took all the zlevels
	man.anchored = TRUE
	var/obj/effect/proc_holder/spell/targeted/xeno_senitent_action/P = new /obj/effect/proc_holder/spell/targeted/xeno_senitent_action(,X)
	man.AddSpell(P)
	if(man.key)
		playsound(get_turf(X), 'sound/items/haunted/ghostitemattack.ogg', 50, TRUE)
	qdel(S)

/obj/effect/proc_holder/spell/targeted/xeno_senitent_action //Lets sentience target goober
	name = "Activate"
	desc = "Select a target to activate your traits on."
	range = 1
	charge_max = 0 SECONDS
	clothes_req = 0
	include_user = 0
	action_icon = 'icons/mob/actions/actions_revenant.dmi'
	action_icon_state = "r_transmit"
	action_background_icon_state = "bg_spell"
	var/obj/item/xenoartifact/xeno

/obj/effect/proc_holder/spell/targeted/xeno_senitent_action/Initialize(mapload, var/obj/item/xenoartifact/Z)
	. = ..()
	xeno = Z
	range = Z.max_range+3

/obj/effect/proc_holder/spell/targeted/xeno_senitent_action/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	for(var/atom/M in targets)
		if(xeno)
			xeno.true_target = list(M)
			xeno.default_activate(xeno.charge_req+50)
			charge_max = xeno.cooldown+xeno.cooldownmod

/datum/xenoartifact_trait/minor/sentient/Destroy(force, ...)
	. = ..()
	if(man)
		qdel(man) //Kill the inner person. Otherwise invisible runs around
		man = null
	if(S)
		qdel(S)
		S = null

/obj/effect/mob_spawn/sentient_artifact
	death = FALSE
	name = "Sentient Xenoartifact"
	short_desc = "You're a maleviolent sentience, possesing an ancient alien artifact."
	flavour_text = "Return to your master..."
	use_cooldown = TRUE
	invisibility = 101
	var/obj/item/xenoartifact/X

/obj/effect/mob_spawn/sentient_artifact/Initialize(mapload, var/obj/item/xenoartifact/Z)
	if(!Z)
		qdel(src)
		return FALSE
	X = Z
	..()

/obj/effect/mob_spawn/sentient_artifact/create(ckey, name)
	var/datum/xenoartifact_trait/minor/sentient/S = X.get_trait(/datum/xenoartifact_trait/minor/sentient)
	S.setup_sentience(X, ckey)

//============
// Delicate, makes the artifact have limited uses
//============
/datum/xenoartifact_trait/minor/delicate
	desc = "Fragile"
	label_desc = "Fragile: The Artifact is poorly made. Continuous use will destroy it."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/delicate/on_init(obj/item/xenoartifact/X)
	X.max_integrity = pick(200, 300, 500, 800, 1000)
	X.obj_integrity = X.max_integrity
	X.alpha = X.alpha * 0.55

/datum/xenoartifact_trait/minor/delicate/activate(obj/item/xenoartifact/X, atom/user)
	if(X.obj_integrity)
		X.obj_integrity -= 100
	else if(X.obj_integrity <= 0)
		X.visible_message("<span class='danger'>The [X.name] shatters!</span>", "<span class='danger'>The [X.name] shatters!</span>")
		var/obj/effect/decal/cleanable/ash/A = new(get_turf(X))
		A.color = X.material
		playsound(get_turf(X), 'sound/effects/glassbr1.ogg', 50, TRUE) 
		qdel(X)

//============
// Aura, adds everything in the vicinity to the target list
//============
/datum/xenoartifact_trait/minor/aura
	desc = "Expansive"
	label_desc = "Expansive: The Artifact's surface reaches towards every creature in the room. Even the empty space behind you..."
	blacklist_traits = list(/datum/xenoartifact_trait/major/timestop, /datum/xenoartifact_trait/minor/long)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/aura/on_init(obj/item/xenoartifact/X)
	X.max_range += 2

/datum/xenoartifact_trait/minor/aura/activate(obj/item/xenoartifact/X)
	X.true_target = list()
	for(var/atom/M in oview(min(X.max_range, 5), get_turf(X.loc)))
		if(X.true_target.len >= XENOA_MAX_TARGETS)
			break
		var/obj/item/I = M
		if(istype(M, /mob/living))
			X.true_target |= X.process_target(M)
		else if(istype(I) && !(I.anchored))
			X.true_target |= X.process_target(I)

//============
// Long, makes the artifact ranged, allows effects to select targets from afar
//============
/datum/xenoartifact_trait/minor/long
	desc = "Scoped"
	label_desc = "Scoped: The Artifact has an almost magnifying effect to it. You could probably hit someone from really far away with it."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/aura)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/long/on_init(obj/item/xenoartifact/X)
	X.max_range += 18

//============
// Wearable, allows artifact to be worn like a glove.
//============
/datum/xenoartifact_trait/minor/wearable
	desc = "Shaped"
	label_desc = "Shaped: The Artifact is small and shaped. It looks as if it'd fit on someone's finger."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT

/datum/xenoartifact_trait/minor/wearable/on_init(obj/item/xenoartifact/X)
	X.slot_flags = ITEM_SLOT_GLOVES
	
/datum/xenoartifact_trait/minor/wearable/activate(obj/item/xenoartifact/X, atom/user)
	X.true_target += list(user)

//============
// Allows artifact to act like a shield
//============
/datum/xenoartifact_trait/minor/blocking
	desc = "Shielded"
	label_desc = "Shielded: The Artifact's composistion lends itself well to blocking attacks. It would do you good to bring this to a rage cage."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/blocking/on_init(obj/item/xenoartifact/X)
	X.block_level = pick(1, 2, 3, 4)
	X.block_upgrade_walk = 1
	X.block_power = 25 * pick(0.8, 1, 1.3, 1.5)

//============
// Light, allows artifact to be thrown far
//============
/datum/xenoartifact_trait/minor/light
	desc = "Light"
	label_desc = "Light: The Artifact is made from a light material. You can pitch it pretty far."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense, /datum/xenoartifact_trait/minor/heavy)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/light/on_init(obj/item/xenoartifact/X)
	X.throw_range = 8

//============
// Heavy, artifact cannot be throwwn far
//============
/datum/xenoartifact_trait/minor/heavy
	desc = "Heavy"
	label_desc = "Heavy: The Artifact is made from a heavy material. You can't pitch it very far."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense, /datum/xenoartifact_trait/minor/light)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/heavy/on_init(obj/item/xenoartifact/X)
	X.throw_range = 1

//============
// Signalsend, activating the artifact sends a set signal
//============
/datum/xenoartifact_trait/minor/signalsend
	label_name = "Signaler"
	label_desc = "Signaler: The Artifact sends out a signal everytime it's activated."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/signalsend/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/analyzer))
		to_chat(user, "<span class='info'>The [item.name] displays a signal-output code of [X.code], and frequency [X.frequency].</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/minor/signalsend/on_init(obj/item/xenoartifact/X)
	X.code = rand(1, 100)
	X.frequency = FREQ_SIGNALER
	X.set_frequency(X.frequency)

/datum/xenoartifact_trait/minor/signalsend/activate(obj/item/xenoartifact/X)
	var/datum/signal/signal = new(list("code" = X.code))
	X.send_signal(signal)
	log_game("[X] sent signal code [X.code] on frequency [X.frequency] at [world.time]. [X] located at [X.x] [X.y] [X.z]")

//============
// Anchor, the artifact can be anchored, anchors when activated
//============
/datum/xenoartifact_trait/minor/anchor
	desc = "Anchored"
	label_desc = "Anchored: The Artifact sends out a signal everytime it's activated."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/wearable)
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/anchor/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	if(isliving(X.loc))
		var/mob/living/holder = X.loc
		holder.dropItemToGround(X)
	X.visible_message("<span class='danger'>The [X.name] buckles to the floor!</span>")
	X.setAnchored(TRUE)
	X.density = TRUE

/datum/xenoartifact_trait/minor/anchor/on_item(obj/item/xenoartifact/X, atom/user, obj/item/item)
	if(item.tool_behaviour == TOOL_WRENCH)
		to_chat(user, "<span class='info'>You [X.anchored ? "unanchor" : "anchor"] the [X.name] to the [get_turf(X)].</span>")
		if(isliving(X.loc))
			var/mob/living/holder = X.loc
			holder.dropItemToGround(X)
		X.setAnchored(!X.anchored)
		if(!X.get_trait(/datum/xenoartifact_trait/minor/dense))
			X.density = !X.density
		return TRUE
	..()

//============
// Slippery, the artifact is slippery. Honk
//============
/datum/xenoartifact_trait/minor/slippery
	desc = "Slippery"
	label_desc = "Slippery: The Artifact's surface is perpetually slippery."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	var/datum/component/slippery/slipper

/datum/xenoartifact_trait/minor/slippery/on_init(obj/item/xenoartifact/X)
	slipper = X.AddComponent(/datum/component/slippery, 80)

/datum/xenoartifact_trait/minor/slippery/Destroy(force, ...)
	qdel(slipper)
	slipper = null
	..()

//============
// haunted, the artifact can be controlled by deadchat, works well with sentient
//============
/datum/xenoartifact_trait/minor/haunted
	label_name = "Haunted"
	label_desc = "Haunted: The Artifact's appears to interact with bluespace spatial regression, causing the item to appear haunted."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense, /datum/xenoartifact_trait/minor/anchor, /datum/xenoartifact_trait/minor/wearable)
	flags = BLUESPACE_TRAIT
	weight = 15
	var/datum/component/deadchat_control/controller

/datum/xenoartifact_trait/minor/haunted/on_init(obj/item/xenoartifact/X)
	controller = X._AddComponent(list(/datum/component/deadchat_control, "democracy", list(
			 "up" = CALLBACK(GLOBAL_PROC, .proc/_step, X, NORTH),
			 "down" = CALLBACK(GLOBAL_PROC, .proc/_step, X, SOUTH),
			 "left" = CALLBACK(GLOBAL_PROC, .proc/_step, X, WEST),
			 "right" = CALLBACK(GLOBAL_PROC, .proc/_step, X, EAST)), 10 SECONDS))

/datum/xenoartifact_trait/minor/haunted/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/storage/book/bible))
		to_chat(user, "<span class='warning'>The [X.name] rumbles on contact with the [item].</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/minor/haunted/Destroy(force, ...)
	qdel(controller)
	controller = null
	..()

//============
// Delay, delays the activation. Credit to EvilDragon#4532
//============
/datum/xenoartifact_trait/minor/delay
	label_name = "Delayed"
	label_desc = "Delayeed: The Artifact's composistion causes activations to be delayed."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	weight = 25

/datum/xenoartifact_trait/minor/delay/activate(obj/item/xenoartifact/X, atom/target, atom/user, setup)
	X.visible_message("<span class='danger'>The [X] halts and begins to hum deeply.", "The [X] halts and begins to hum deeply.</span>")
	playsound(get_turf(X), 'sound/effects/seedling_chargeup.ogg', 50, TRUE)
	sleep(3 SECONDS)
	
//Major traits - The artifact's main gimmick, how it interacts with the world

//============
// Simple debug trait, keep this in
//============
/datum/xenoartifact_trait/major/sing
	desc = "Bugged"
	label_desc = "Bugged: The shape resembles nothing. You are Godless."

/datum/xenoartifact_trait/major/sing/activate(obj/item/xenoartifact/X, atom/target)
	X.say("DEBUG::XENOARTIFACT::SING")
	X.say(X.charge)
	X.say(target)

//============
// Capture, moves target inside the artifact
//============
/datum/xenoartifact_trait/major/capture
	desc = "Hollow"
	label_desc = "Hollow: The shape is hollow, however the inside is deceptively large."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	var/fren

/datum/xenoartifact_trait/major/capture/on_init(obj/item/xenoartifact/X)
	if(prob(0.5)) 
		fren = TRUE

/datum/xenoartifact_trait/major/capture/activate(obj/item/xenoartifact/X, atom/target)
	if(!(SSzclear.get_free_z_level(FALSE))) //Sometimes we can get pressed on z-levels
		playsound(get_turf(X), 'sound/machines/buzz-sigh.ogg', 50, TRUE) //this shouldn't happen too often but, exploration can eat a few zlevels.
		return
	if(isliving(X.loc))
		var/mob/living/holder = X.loc
		holder.dropItemToGround(X, thrown = TRUE)
	if(ismovable(target) && !(istype(target, /obj/structure)))
		var/atom/movable/AM = target
		addtimer(CALLBACK(src, .proc/release, X, AM), X.charge*0.5 SECONDS)
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
	if(fren)
		new /mob/living/simple_animal/hostile/russian(T)
		log_game("[X] spawned (/mob/living/simple_animal/hostile/russian) at [world.time]. [X] located at [X.x] [X.y] [X.z]")
		fren = FALSE

//============
// Shock, the artifact electrocutes the target
//============
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

//============
// Timestop, spawns time-stop effect
//============
/datum/xenoartifact_trait/major/timestop
	desc = "Melted"
	label_desc = "Melted: The shape is drooling and sluggish. Additionally, light around it seems to invert."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/major/timestop/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>Your hand feels slow while stroking the [X.name].</span>")
	return TRUE

/datum/xenoartifact_trait/major/timestop/activate(obj/item/xenoartifact/X, atom/target)
	var/turf/T = get_turf(X.loc)
	if(!X)
		T = get_turf(target.loc)     
	new /obj/effect/timestop(T, 2, (X.charge*0.2) SECONDS)
	X.cooldownmod = (X.charge*0.35) SECONDS

//============
// Laser, shoots varying laser based on charge
//============
/datum/xenoartifact_trait/major/laser
	desc = "Barreled"
	label_desc = "Barreled: The shape resembles the barrel of a gun. It's possible that it might dispense candy."
	flags = PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/major/laser/activate(obj/item/xenoartifact/X, atom/target, mob/living/user)
	if(isliving(target))
		if(get_dist(target, user) <= 1)
			var/mob/living/victim = target
			victim.adjust_fire_stacks(5*(X.charge/X.charge_req))
			victim.IgniteMob()
			return
	var/obj/item/projectile/A
	switch(X.charge)
		if(0 to 24)
			A = new /obj/item/projectile/beam/disabler
		if(25 to 79)
			A = new /obj/item/projectile/beam/laser
		if(80 to 200)
			A = new /obj/item/ammo_casing/energy/laser/heavy
	A.preparePixelProjectile(get_turf(target), X)
	A.fire()
	playsound(get_turf(src), 'sound/mecha/mech_shield_deflect.ogg', 50, TRUE) 

//============
// Corginator, turns the target into a corgi for a short time
//============
/datum/xenoartifact_trait/major/corginator //All of this is stolen from corgium. 
	desc = "Fuzzy" //Weirdchamp
	label_desc = "Fuzzy: The shape is hard to discern under all the hair sprouting out from the surface. You swear you've heard it bark before."
	flags = BLUESPACE_TRAIT
	var/list/victims = list() //List of all affected targets, used for early qdel
	var/obj/item/xenoartifact/xenoa //Used for early qdel

/datum/xenoartifact_trait/major/corginator/on_init(obj/item/xenoartifact/X)
	. = ..()
	xenoa = X

/datum/xenoartifact_trait/major/corginator/activate(obj/item/xenoartifact/X, mob/living/target)
	X.say(pick("Woof!", "Bark!", "Yap!"))
	if(!(SSzclear.get_free_z_level(FALSE)))
		playsound(get_turf(X), 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return
	if(istype(target, /mob/living) && !(istype(target, /mob/living/simple_animal/pet/dog/corgi)))
		var/mob/living/simple_animal/pet/dog/corgi/new_corgi = transform(X, target)
		addtimer(CALLBACK(src, .proc/transform_back, X, target, new_corgi), (X.charge*0.7) SECONDS)
		victims |= list(target, new_corgi)
		X.cooldownmod = (X.charge*0.8) SECONDS

/datum/xenoartifact_trait/major/corginator/proc/transform(obj/item/xenoartifact/X, mob/living/target)
	var/mob/living/simple_animal/pet/dog/corgi/new_corgi
	new_corgi = new(get_turf(target))
	new_corgi.key = target.key
	new_corgi.name = target.real_name
	new_corgi.health = target.health
	new_corgi.real_name = target.real_name
	ADD_TRAIT(target, TRAIT_NOBREATH, CORGIUM_TRAIT)
	var/mob/living/C = target
	if(istype(C))
		var/obj/item/hat = C.get_item_by_slot(ITEM_SLOT_HEAD)
		if(hat)
			new_corgi.place_on_head(hat,null,FALSE)
	target.forceMove(new_corgi) //This is why we check for free z-levels
	return new_corgi

/datum/xenoartifact_trait/major/corginator/proc/transform_back(obj/item/xenoartifact/X, mob/living/target, mob/living/simple_animal/pet/dog/corgi/new_corgi)
	if(target)
		victims -= target
		REMOVE_TRAIT(target, TRAIT_NOBREATH, CORGIUM_TRAIT)
		if(QDELETED(new_corgi))
			if(!QDELETED(target))
				qdel(target)
			return
		target.key = new_corgi.key
		if(new_corgi.health <= 0) //Corgi health is offset from human, dead corgis count as alive humans otherwise.
			target.health = -1
		target.adjustBruteLoss(new_corgi.getBruteLoss()*10)
		target.adjustFireLoss(new_corgi.getFireLoss()*10)
		target.forceMove(get_turf(new_corgi))
		var/turf/T = get_turf(new_corgi)
		if (new_corgi.inventory_head)
			if(!target.equip_to_slot_if_possible(new_corgi.inventory_head, ITEM_SLOT_HEAD,disable_warning = TRUE, bypass_equip_delay_self=TRUE))
				new_corgi.inventory_head.forceMove(T)
		new_corgi.inventory_back?.forceMove(T)
		new_corgi.inventory_head = null
		new_corgi.inventory_back = null
		qdel(new_corgi)

/datum/xenoartifact_trait/major/corginator/Destroy(force, ...) //Transform goobers back if artifact is deleted.
	. = ..()
	if(victims.len < 1)
		return
	var/mob/living/H
	var/mob/living/simple_animal/pet/dog/corgi/C
	for(var/M in 1 to victims.len-1)
		H = victims[M]
		C = victims[M+1]
		if(!istype(H, /mob/living/simple_animal/pet/dog/corgi))
			transform_back(xenoa, H, C)

//============
// Mirrored, temporarily swaps last two target's minds
//============
/datum/xenoartifact_trait/major/mirrored
	desc = "Mirrored"
	label_desc = "Mirrored: The shape is perfectly symetrical. Perhaps you could interest the Captain?"
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT
	///List generally used for initial swap, contains the swapping mobs
	var/list/victims = list()
	///List used to hold lists that contain swapped mobs
	var/list/reverse_victims = list()

/datum/xenoartifact_trait/major/mirrored/activate(obj/item/xenoartifact/X, mob/target, atom/user)
	if(victims.len < 2)
		if(!isliving(target) || IS_DEAD_OR_INCAP(target))
			playsound(get_turf(X), 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			return
		else
			victims += target
			if(victims.len < 2) //one last check before hand
				return
	//type cast to check qdel
	var/atom/a = victims[1]
	var/atom/b = victims[2]
	if(QDELETED(a) || QDELETED(b))
		victims = list()
		return
	swap(victims[1], victims[2])
	log_game("[X] swapped the identities of [victims[1]] & [victims[2]] at [world.time]. [X] located at [X.x] [X.y] [X.z]")
	addtimer(CALLBACK(src, .proc/undo_swap), ((X.charge*0.20) SECONDS)+ 6 SECONDS) //6 extra seconds while targets are asleep
	X.cooldownmod = ((X.charge*0.3)SECONDS)+ 6 SECONDS
	victims = list()

/datum/xenoartifact_trait/major/mirrored/proc/swap(var/atom/victim_a, var/atom/victim_b)
	if(QDELETED(victim_a) || QDELETED(victim_b))
		victims = list()
		return
	var/mob/living/caster = victim_a
	var/mob/living/victim = victim_b

	var/mob/dead/observer/ghost_v = victim.ghostize(0)
	var/mob/dead/observer/ghost_c = caster.ghostize(0)
	ghost_v?.mind.transfer_to(caster)
	ghost_c?.mind.transfer_to(victim)
	if(ghost_v?.key)
		caster?.key = ghost_v?.key
	if(ghost_c?.key)
		victim?.key = ghost_c?.key
	qdel(ghost_v)
	qdel(ghost_c)

	caster.Unconscious(6 SECONDS)
	victim.Unconscious(6 SECONDS)
	reverse_victims += list(list(caster, victim))

/datum/xenoartifact_trait/major/mirrored/proc/undo_swap()
	for(var/list/L as() in reverse_victims)
		if(L.len > 1)
			//convert to atoms to check qdel
			var/atom/a = L[1]
			var/atom/b = L[2]
			if(!QDELETED(a) && !QDELETED(b))
				swap(L[1], L[2])
	reverse_victims = list()


//============
// EMP, produces an empulse
//============
/datum/xenoartifact_trait/major/emp
	label_name = "EMP"
	label_desc = "EMP: The shape of the Artifact doesn't resemble anything particularly interesting. Technology around the Artifact seems to malfunction."
	flags = URANIUM_TRAIT

/datum/xenoartifact_trait/major/emp/activate(obj/item/xenoartifact/X)
	playsound(get_turf(X), 'sound/magic/disable_tech.ogg', 50, TRUE)
	empulse(get_turf(X.loc), max(1, X.charge*0.03), max(1, X.charge*0.07, 1)) //This might be too big

//============
// Invisible, makes the target invisible for a short time
//============
/datum/xenoartifact_trait/major/invisible //One step closer to the one ring
	label_name = "Transparent"
	label_desc = "Transparent: The shape of the Artifact is difficult to percieve. You feel the need to call it, precious..."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT
	var/list/victims = list()
	///List of stored icons used for reversion
	var/list/stored_icons = list()

/datum/xenoartifact_trait/major/invisible/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/laser_pointer))
		var/obj/item/laser_pointer/L = item
		if(L.energy)
			to_chat(user, "<span class='info'>The [item.name]'s light passes through the structure.</span>")
			return TRUE
	..()

/datum/xenoartifact_trait/major/invisible/activate(obj/item/xenoartifact/X, mob/living/target)
	if(isliving(target))
		victims += target
		hide(target)
		addtimer(CALLBACK(src, .proc/reveal, target), ((X.charge*0.4) SECONDS))
		X.cooldownmod = ((X.charge*0.4)+1) SECONDS

/datum/xenoartifact_trait/major/invisible/proc/hide(mob/living/target)
	animate(target, ,alpha = 0, time = 5)

/datum/xenoartifact_trait/major/invisible/proc/reveal(mob/living/target)
	if(target)
		animate(target, ,alpha = 255, time = 5)
		target = null

/datum/xenoartifact_trait/major/invisible/Destroy(force, ...)
	. = ..()
	for(var/mob/living/M in victims)
		reveal(M)

//============
// Teleports the target to a random nearby location
//============
/datum/xenoartifact_trait/major/teleporting
	desc = "Displaced"
	label_desc = "Displaced: The shape's state is unstable, causing it to shift through planes at a localized axis. Just ask someone from science..."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/major/teleporting/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	if(istype(target, /atom/movable))
		var/atom/movable/victim = target //typecast to access anchored
		if(!victim.anchored)
			do_teleport(victim, get_turf(victim), (X.charge*0.3)+1, channel = TELEPORT_CHANNEL_BLUESPACE)

//============
// Lamp, creates a light with random color for a short time
//============
/datum/xenoartifact_trait/major/lamp
	label_name = "Lamp"
	label_desc = "Lamp: The Artifact emits light. Nothing in its shape suggests this."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT
	var/light_mod

/datum/xenoartifact_trait/major/lamp/on_init(obj/item/xenoartifact/X)
	X.light_system = MOVABLE_LIGHT
	X.light_color = pick(LIGHT_COLOR_FIRE, LIGHT_COLOR_BLUE, LIGHT_COLOR_GREEN, LIGHT_COLOR_RED, LIGHT_COLOR_ORANGE, LIGHT_COLOR_PINK)

/datum/xenoartifact_trait/major/lamp/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	X.AddComponent(/datum/component/overlay_lighting, 1.4+(X.charge*0.5), max(X.charge*0.05, 0.1), X.light_color)
	addtimer(CALLBACK(src, .proc/unlight, X), (X.charge*0.6) SECONDS)
	X.cooldownmod = (X.charge*0.6) SECONDS

/datum/xenoartifact_trait/major/lamp/proc/unlight(var/obj/item/xenoartifact/X)
	var/datum/component/overlay_lighting/L = X.GetComponent(/datum/component/overlay_lighting)
	if(L)
		qdel(L)

//============
// Dark, opposite of lamp, creates darkness
//============
/datum/xenoartifact_trait/major/lamp/dark
	label_name = "Shade"
	label_desc = "Shade: The Artifact retracts light. Nothing in its shape suggests this."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/major/lamp/dark/on_init(obj/item/xenoartifact/X)
	X.light_system = MOVABLE_LIGHT
	X.light_color = "#000000"
	if(prob(0.01)) //It's hard to explain
		X.icon_state = "IB901"
		X.icon_slots[1] = ""
		X.icon_slots[2] = ""
		X.icon_slots[3] = ""
		X.icon_slots[4] = ""

/datum/xenoartifact_trait/major/lamp/dark/activate(obj/item/xenoartifact/X)
	for(var/C in 1 to 3)
		X.AddComponent(/datum/component/overlay_lighting/dupable, 1.4+(X.charge*0.7), max(X.charge*0.05, 0.1), X.light_color)
		addtimer(CALLBACK(src, .proc/unlight, X), (X.charge*0.6) SECONDS)
		X.cooldownmod = (X.charge*0.6) SECONDS
		
/datum/xenoartifact_trait/major/lamp/dark/unlight(var/obj/item/xenoartifact/X)
	var/datum/component/overlay_lighting/dupable/L = X.GetComponent(/datum/component/overlay_lighting/dupable)
	if(L)
		qdel(L)

/datum/component/overlay_lighting/dupable //Lighting component for shade
	dupe_mode = COMPONENT_DUPE_ALLOWED

//============
// Forcefield, creates a random shape wizard wall
//============
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
		new /obj/effect/forcefield/xenoartifact_type(get_step(X, NORTH), (X.charge*0.4) SECONDS)
		new /obj/effect/forcefield/xenoartifact_type(get_step(X, SOUTH), (X.charge*0.4) SECONDS)
	if(size >= 5)
		new /obj/effect/forcefield/xenoartifact_type(get_step(X, WEST), (X.charge*0.4) SECONDS)
		new /obj/effect/forcefield/xenoartifact_type(get_step(X, EAST), (X.charge*0.4) SECONDS)

	X.cooldownmod = (X.charge*0.4) SECONDS
	
/obj/effect/forcefield/xenoartifact_type //Special wall type for artifact
	desc = "An impenetrable artifact wall."

//============
// Heal, heals a random damage type
//============
/datum/xenoartifact_trait/major/heal
	label_name = "Healing"
	label_desc = "Healing: The Artifact repeairs any damaged organic tissue the targat may contain. Widely considered the Holy Grail of Artifact traits."
	flags = BLUESPACE_TRAIT
	weight = 25
	var/healing_type

/datum/xenoartifact_trait/major/heal/on_init(obj/item/xenoartifact/X)
	healing_type = pick("brute", "burn", "toxin", "stamina")

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
			if("brute")
				victim.adjustBruteLoss((X.charge*0.25)*-1)
			if("burn")
				victim.adjustFireLoss((X.charge*0.25)*-1)
			if("toxin")
				victim.adjustToxLoss((X.charge*0.25)*-1)
			if("stamina")
				victim.adjustOxyLoss((X.charge*0.25)*-1)

//============
// Chem, injects a random safe chem into target
//============
/datum/xenoartifact_trait/major/chem
	desc = "Tubed"
	label_desc = "Tubed: The Artifact's shape is comprised of many twisting tubes and vials, it seems a liquid may be inside."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	var/datum/reagent/formula
	var/amount

/datum/xenoartifact_trait/major/chem/on_init(obj/item/xenoartifact/X)
	amount = pick(5, 9, 10, 15)
	formula = get_random_reagent_id(CHEMICAL_RNG_GENERAL)

/datum/xenoartifact_trait/major/chem/activate(obj/item/xenoartifact/X, atom/target)
	if(target?.reagents)
		playsound(get_turf(X), pick('sound/items/hypospray.ogg','sound/items/hypospray2.ogg'), 50, TRUE)
		var/datum/reagents/R = target.reagents
		R.add_reagent(formula, amount)
		log_game("[X] injected [target] with [amount]u of [formula] at [world.time]. [X] located at [X.x] [X.y] [X.z]")

//============
// Push, pushes target away from artifact
//============
/datum/xenoartifact_trait/major/push
	label_name = "Push"
	label_desc = "Push: The Artifact pushes anything not bolted down. The shape doesn't suggest this."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/major/push/activate(obj/item/xenoartifact/X, atom/target)
	if(istype(target, /mob/living)||istype(target, /obj/item))
		var/atom/movable/victim = target
		var/atom/trg = get_edge_target_turf(X.loc, get_dir(X.loc, target.loc))
		victim.throw_at(get_turf(trg), (X.charge*0.07)+1, 8)

//============
// Pull, pulls target towards artifact
//============
/datum/xenoartifact_trait/major/pull
	label_name = "Pull"
	label_desc = "Pull: The Artifact pulls anything not bolted down. The shape doesn't suggest this."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/major/pull/on_init(obj/item/xenoartifact/X)
	X.max_range += 1

/datum/xenoartifact_trait/major/pull/activate(obj/item/xenoartifact/X, atom/target)
	if(istype(target, /mob/living)||istype(target, /obj/item))
		var/atom/movable/victim = target
		victim.throw_at(get_turf(X), X.charge*0.08, 8)

//============
// Horn, produces a random noise
//============
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

//============
// Gas, replaces a random gas with another random gas
//============
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

//============
// Destabilizing, teleports the victim to that weird place from the exploration meme.
//============
/datum/xenoartifact_trait/major/distablizer
	desc = "Destabilizing"
	label_desc = "Destabilizing: The Artifact collapses an improper bluespace matrix on the target, sending them to an unknown location."
	weight = 25
	flags = URANIUM_TRAIT
	var/obj/item/xenoartifact/exit

/datum/xenoartifact_trait/major/distablizer/on_init(obj/item/xenoartifact/X)
	exit = X
	GLOB.destabliization_exits += X

/datum/xenoartifact_trait/major/distablizer/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	var/obj/item/clothing/gloves/artifact_pinchers/P = locate(/obj/item/clothing/gloves/artifact_pinchers) in user.contents
	if(do_banish(item) && !P?.safety)
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

/datum/xenoartifact_trait/major/distablizer/Destroy(force, ...)
	GLOB.destabliization_exits -= exit
	..()

//Malfunctions

//============
// Bear, produces a bear until it reaches its upper limit
//============
/datum/xenoartifact_trait/malfunction/bear
	label_name = "P.B.R" 
	label_desc = "Parallel Bearspace Retrieval: A strange malfunction causes the Artifact to open a gateway to deep bearspace."
	weight = 15
	var/bears //bear per bears

/datum/xenoartifact_trait/malfunction/bear/activate(obj/item/xenoartifact/X)
	if(bears < XENOA_MAX_BEARS)
		bears+=1
		var/mob/living/simple_animal/hostile/bear/new_bear
		new_bear = new(get_turf(X.loc))
		new_bear.name = pick("Freddy", "Bearington", "Smokey", "Beorn", "Pooh", "Paddington", "Winnie", "Baloo", "Rupert", "Yogi", "Fozzie", "Boo") //Why not?
		log_game("[X] spawned a (/mob/living/simple_animal/hostile/bear) at [world.time]. [X] located at [X.x] [X.y] [X.z]")
	else
		X.visible_message("<span class='danger'>The [X.name] shatters as bearspace collapses! Too many bears!</span>")
		var/obj/effect/decal/cleanable/ash/A = new(get_turf(X))
		A.color = X.material
		qdel(X)
	X.cooldown += 20 SECONDS

//============
// Badtarget, changes target to user
//============
/datum/xenoartifact_trait/malfunction/badtarget
	label_name = "Maltargeting"
	label_desc = "Maltargeting: A strange malfunction that causes the Artifact to always target the original user."

/datum/xenoartifact_trait/malfunction/badtarget/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	var/mob/living/M
	if(isliving(user))
		M = user
	else if(isliving(user?.loc))
		M = user.loc
	else
		return
	X.true_target = list(M)
	X.cooldown += 5 SECONDS

//============
// Strip, moves any clothing on target to floor
//============
/datum/xenoartifact_trait/malfunction/strip
	label_name = "B.A.D"
	label_desc = "Bluespace Axis Desync: A strange malfunction inside the Artifact causes it to shift the target's realspace position with its bluespace mass in an offset manner. This results in the target dropping all they're wearing. This is probably the plot to a very educational movie."

/datum/xenoartifact_trait/malfunction/strip/activate(obj/item/xenoartifact/X, atom/target)
	if(isliving(target))
		var/mob/living/carbon/victim = target
		for(var/obj/item/clothing/I in victim.contents)
			victim.dropItemToGround(I)
		X.cooldown += 10 SECONDS

//============
// Trauma, gives target trauma, amazing
//============
/datum/xenoartifact_trait/malfunction/trauma
	label_name = "C.D.E"
	label_desc = "Cerebral Dysfunction Emergence: A strange malfunction that causes the Artifact to force brain traumas to develop in a given target."
	weight = 25
	var/datum/brain_trauma/trauma

/datum/xenoartifact_trait/malfunction/trauma/on_init(obj/item/xenoartifact/X)
	trauma = pick(list(
			/datum/brain_trauma/mild/hallucinations, /datum/brain_trauma/mild/stuttering, /datum/brain_trauma/mild/dumbness,
			/datum/brain_trauma/mild/speech_impediment, /datum/brain_trauma/mild/concussion, /datum/brain_trauma/mild/muscle_weakness,
			/datum/brain_trauma/mild/expressive_aphasia, /datum/brain_trauma/severe/narcolepsy, /datum/brain_trauma/severe/discoordination,
			/datum/brain_trauma/severe/pacifism, /datum/brain_trauma/special/beepsky))

/datum/xenoartifact_trait/malfunction/trauma/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.Unconscious(5 SECONDS)
		H.gain_trauma(trauma, TRAUMA_RESILIENCE_BASIC)
		X.cooldownmod += 10 SECONDS

//============
// Heated, causes artifact explode in flames
//============
/datum/xenoartifact_trait/malfunction/heated
	label_name = "Combustible" 
	label_desc = "Combustible: A strange malfunction that causes the Artifact to violently combust."
	weight = 15

/datum/xenoartifact_trait/malfunction/heated/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	var/turf/T = get_turf(X)
	playsound(T, 'sound/effects/bamf.ogg', 50, TRUE) 
	for(var/turf/open/turf in RANGE_TURFS(max(1, 5*((X.charge*1.5)/100)), T))
		if(!locate(/obj/effect/hotspot) in turf)
			new /obj/effect/hotspot(turf)

//============
// Radioactive, makes the artifact more radioactive with use
//============
/datum/xenoartifact_trait/malfunction/radioactive
	label_name = "Radioactive"
	label_desc = "Radioactive: The Artifact Emmits harmful particles when a reaction takes place."

/datum/xenoartifact_trait/malfunction/radioactive/on_init(obj/item/xenoartifact/X)
	X.AddComponent(/datum/component/radioactive, 25)

/datum/xenoartifact_trait/malfunction/radioactive/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/geiger_counter))
		to_chat(user, "<span class='notice'>The [X.name] has residual radioactive decay features.</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/malfunction/radioactive/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>You feel pins and needles after touching the [X.name].</span>")
	return TRUE

/datum/xenoartifact_trait/malfunction/radioactive/activate(obj/item/xenoartifact/X)
	X.AddComponent(/datum/component/radioactive, 25)
