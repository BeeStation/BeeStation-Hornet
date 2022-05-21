/datum/xenoartifact_trait
	var/desc //Acts as a descriptor for when examining. Also used for naming stuff in the labeler. Keep these short.
	var/label_name //Used when labeler needs a name and trait is too sneaky to have a descriptor when examining.
	var/label_desc //Something briefly explaining it in IG terms or a pun.
	var/list/blacklist_traits = list() //Other traits the original trait wont work with. Referenced when generating traits.

//Activator signal shenanignas 
/datum/xenoartifact_trait/activator
	var/charge //How much an activator trait can output on a standard, modified by the artifacts charge_req and circumstances.
	var/list/signals //which signals trait responds to
	var/obj/item/xenoartifact/xenoa //Not used outside of signal handle, please

/datum/xenoartifact_trait/activator/proc/calculate_charge(obj/item/xenoartifact/X)
	return

/datum/xenoartifact_trait/activator/on_init(obj/item/xenoartifact/X)
	. = ..()
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
			if(XENOA_INTERACT)
				RegisterSignal(xenoa, XENOA_INTERACT, .proc/translate_attackby)
			if(XENOA_SIGNAL)
				RegisterSignal(xenoa, XENOA_SIGNAL, .proc/translate_attackby)
	RegisterSignal(xenoa, XENOA_DEFAULT_SIGNAL, .proc/calculate_charge) //Signal sent by handles

/datum/xenoartifact_trait/activator/on_del(obj/item/xenoartifact/X)
	. = ..()
	for(var/s in signals)
		UnregisterSignal(xenoa, s)
	UnregisterSignal(xenoa, XENOA_DEFAULT_SIGNAL)
	xenoa = null

/datum/xenoartifact_trait/activator/proc/translate_attackby(datum/source, obj/item/thing, mob/user, params)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, thing, user, user)

/datum/xenoartifact_trait/activator/proc/translate_attack(mob/living/target, mob/living/user)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, xenoa, user, target)

/datum/xenoartifact_trait/activator/proc/translate_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, xenoa, hit_atom, throwingdatum) //Weird order to fix this

/datum/xenoartifact_trait/activator/proc/translate_afterattack(atom/target, mob/user, params)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, xenoa, target, user)//And this

//End activator
//Declare procs
/datum/xenoartifact_trait/minor //Leave these here, for the future.

/datum/xenoartifact_trait/major

/datum/xenoartifact_trait/malfunction

/datum/xenoartifact_trait/proc/activate(obj/item/xenoartifact/X, atom/target, atom/user) //Typical behaviour
	return

/datum/xenoartifact_trait/proc/on_item(obj/item/xenoartifact/X, atom/user, atom/item) //Item hint responses
	return FALSE

/datum/xenoartifact_trait/proc/on_init(obj/item/xenoartifact/X)
	return

/datum/xenoartifact_trait/proc/on_touch(obj/item/xenoartifact/X, atom/user) //Touch hint
	return FALSE

/datum/xenoartifact_trait/proc/on_del(obj/item/xenoartifact/X)	//Hard del addressal
	return

/datum/xenoartifact_trait/special/objective/on_init(obj/item/xenoartifact/X) //Exploration mission GPS trait
	X.AddComponent(/datum/component/gps, "[scramble_message_replace_chars("#########", 100)]", TRUE)

//Activation traits - only used to generate charge
/datum/xenoartifact_trait/activator/impact
	desc = "Sturdy"
	label_desc = "Sturdy: The material is sturdy, striking it against the clown's skull seems to cause a unique reaction."
	charge = 25
	signals = list(COMSIG_PARENT_ATTACKBY, COMSIG_MOVABLE_IMPACT, XENOA_INTERACT, COMSIG_ITEM_AFTERATTACK)

/datum/xenoartifact_trait/activator/impact/calculate_charge(datum/source, obj/item/thing, mob/user, atom/target)
	var/obj/item/xenoartifact/X = source
	charge = charge*(thing?.force*0.1)
	X.default_activate(charge, user, target)

/datum/xenoartifact_trait/activator/burn
	desc = "Flammable"
	label_desc = "Flammable: The material is flamable, and seems to react when ignited."
	charge = 25
	signals = list(COMSIG_PARENT_ATTACKBY)

/datum/xenoartifact_trait/activator/burn/on_init(obj/item/xenoartifact/X)
	..()
	X.max_range += 2

/datum/xenoartifact_trait/activator/burn/calculate_charge(datum/source, obj/item/thing, mob/user, atom/target, params) //xenoa item handles this, see process proc there
	var/obj/item/xenoartifact/X = source
	if(X.process_type != IS_LIT && thing.ignition_effect(X, user))
		X.visible_message("<span class='danger'>The [X.name] sparks on.</span>")
		X.process_type = IS_LIT
		sleep(5) //Give them a chance to escape
		START_PROCESSING(SSobj, X)
		log_game("[user]:[isliving(user) ? user?.ckey : "no ckey"] lit [X] at [world.time] using [thing]. [X] located at [X.x] [X.y] [X.z].")

/datum/xenoartifact_trait/activator/clock
	label_name = "Tuned"
	label_desc = "Tuned: The material produces a resonance pattern similar to quartz, causing it to produce a reaction every so often."
	charge = 25
	blacklist_traits = list(/datum/xenoartifact_trait/minor/capacitive)
	signals = list(COMSIG_PARENT_ATTACKBY, COMSIG_MOVABLE_IMPACT, XENOA_INTERACT, COMSIG_ITEM_AFTERATTACK)

/datum/xenoartifact_trait/activator/clock/on_init(obj/item/xenoartifact/X)
	..()
	X.max_range += 1

/datum/xenoartifact_trait/activator/clock/on_item(obj/item/xenoartifact/X, atom/user, atom/item) 
	if(istype(item, /obj/item/clothing/neck/stethoscope))
		to_chat(user, "<span class='info'>The [X.name] ticks deep from within.\n</span>") //Same message as the bomb
		return TRUE
	..()

/datum/xenoartifact_trait/activator/clock/calculate_charge(datum/source, obj/item/thing, mob/user, atom/target, params)
	var/obj/item/xenoartifact/X = source
	X.process_type = IS_TICK
	START_PROCESSING(SSobj, X)
	log_game("[user]:[isliving(user) ? user?.ckey : "no ckey"] set clock on [X] at [world.time] using [thing]. [X] located at [X.x] [X.y] [X.z].")

/datum/xenoartifact_trait/activator/signal
	label_name = "Signal"
	label_desc = "Signal: The material recieves radio frequencies and reacts when a matching code is delivered."
	charge = 25
	signals = list(XENOA_SIGNAL)

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

/datum/xenoartifact_trait/activator/batteryneed
	desc = "Charged"
	label_desc = "Charged: The material has a natural power draw. Supplying any current to this will cause a reaction."
	charge = 25
	signals = list(COMSIG_PARENT_ATTACKBY)

/datum/xenoartifact_trait/activator/batteryneed/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/multitool))
		to_chat(user, "<span class='info'>The [item.name] displays a draw of [X.charge_req].</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/activator/batteryneed/calculate_charge(datum/source, obj/item/thing, mob/user, atom/target, params)
	var/obj/item/xenoartifact/X = source
	if(istype(thing, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = thing
		if(X.default_activate(charge, user, user))
			C.charge -= X.charge_req*10

//Minor traits - Use the to define aspects of the artifact without any immediate interaction
/datum/xenoartifact_trait/minor/looped
	desc = "Looped"
	label_desc = "Looped: The Artifact feeds into itself and amplifies its own charge."

/datum/xenoartifact_trait/minor/looped/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/multitool))
		to_chat(user, "<span class='info'>The [item.name] displays a resistance reading of [X.charge_req*0.1].</span>") 
		return TRUE
	..()

/datum/xenoartifact_trait/minor/looped/activate(obj/item/xenoartifact/X)
	X.charge = ((100-X.charge)*0.2)+X.charge //This should generally cut off around 100

/datum/xenoartifact_trait/minor/capacitive
	desc = "Capacitive"
	label_desc = "Capacitive: The Artifact's structure allows it to hold extra charges."
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
	X.cooldown = saved_cooldown
	saved_cooldown = null

/datum/xenoartifact_trait/minor/capacitive/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/multitool))
		to_chat(user, "<span class='info'>The [item.name] displays an overcharge reading of [charges/3].</span>") 
		return TRUE
	..()

/datum/xenoartifact_trait/minor/dense //Rather large, quite gigantic, particularly big
	desc = "Dense"
	label_desc = "Dense: The Artifact is dense and cannot be easily lifted but, the design has a slightly higher reaction rate."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/wearable, /datum/xenoartifact_trait/minor/sharp, /datum/xenoartifact_trait/minor/light, /datum/xenoartifact_trait/minor/heavy, /datum/xenoartifact_trait/minor/blocking)

/datum/xenoartifact_trait/minor/dense/on_init(obj/item/xenoartifact/X)
	X.density = TRUE
	X.interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND

/datum/xenoartifact_trait/minor/sharp
	desc = "Sharp"
	label_desc = "Sharp: The Artifact is shaped into a fine point. Perfect for popping balloons."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)

/datum/xenoartifact_trait/minor/sharp/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>The [X.name] feels sharp.</span>")
	return TRUE

/datum/xenoartifact_trait/minor/sharp/on_init(obj/item/xenoartifact/X)
	X.sharpness = IS_SHARP_ACCURATE
	X.force = X.charge_req*0.15
	X.throwforce = 10
	X.attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "tore", "ripped", "diced", "cut")
	X.attack_weight = 2
	X.armour_penetration = 5
	X.throw_speed = 3
	X.throw_range = 6

/datum/xenoartifact_trait/minor/radioactive
	label_name = "Roadiactive"
	label_desc = "Roadiactive: The Artifact Emmits harmful particles when a reaction takes place."

/datum/xenoartifact_trait/minor/radioactive/on_init(obj/item/xenoartifact/X)
	X.AddComponent(/datum/component/radioactive, 25)

/datum/xenoartifact_trait/minor/radioactive/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/geiger_counter))
		to_chat(user, "<span class='notice'>The [X.name] has residual radioactive decay features.</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/minor/radioactive/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>You feel pins and needles after touching the [X.name].</span>")
	return TRUE

/datum/xenoartifact_trait/minor/radioactive/activate(obj/item/xenoartifact/X)
	X.AddComponent(/datum/component/radioactive, 80)

/datum/xenoartifact_trait/minor/cooler //Faster cooldowns
	desc = "Frosted"
	label_desc = "Frosted: The Artifact has the unique property of actively cooling itself. This also seems to reduce time between uses."

/datum/xenoartifact_trait/minor/cooler/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>The [X.name] feels cold.</span>")
	return TRUE

/datum/xenoartifact_trait/minor/cooler/on_init(obj/item/xenoartifact/X)
	X?.cooldown = 4 SECONDS //Might revisit the value.

/datum/xenoartifact_trait/minor/cooler/activate(obj/item/xenoartifact/X)
	X.charge -= 10

/datum/xenoartifact_trait/minor/sentient //One-ring type sentience
	label_name = "Sentient"
	label_desc = "Sentient: The Artifact seems to be alive, influencing events around it. The Artifact wants to return to its master..."
	var/mob/living/simple_animal/man

/datum/xenoartifact_trait/minor/sentient/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='warning'>The [X.name] whispers to you...</span>")
	return TRUE

/datum/xenoartifact_trait/minor/sentient/on_init(obj/item/xenoartifact/X)
	addtimer(CALLBACK(src, .proc/get_canidate, X), 5 SECONDS)

/datum/xenoartifact_trait/minor/sentient/proc/get_canidate(obj/item/xenoartifact/X)
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the maleviolent force inside the [X.name]?", ROLE_SENTIENCE, null, FALSE, 5 SECONDS, POLL_IGNORE_SENTIENCE_POTION)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		man = new /mob/living/simple_animal(get_turf(X))
		man.key = C.key
		log_game("[man]:[man.ckey] took control of the sentient [X]. [X] located at [X.x] [X.y] [X.z]")
		ADD_TRAIT(man, TRAIT_NOBREATH, TRAIT_MUTE)
		man.forceMove(X)
		man.anchored = TRUE
		var/obj/effect/proc_holder/spell/targeted/xeno_senitent_action/P = new /obj/effect/proc_holder/spell/targeted/xeno_senitent_action(get_turf(man), X)
		man.AddSpell(P)

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
	range = Z.max_range

/obj/effect/proc_holder/spell/targeted/xeno_senitent_action/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	for(var/atom/M in targets)
		if(xeno)
			xeno.true_target = list(M)
			xeno.default_activate(xeno.charge_req)
			charge_max = xeno.cooldown+xeno.cooldownmod

/datum/xenoartifact_trait/minor/sentient/on_del(obj/item/xenoartifact/X)
	qdel(man) //Kill the inner person. Otherwise invisible 'animal' runs around

/datum/xenoartifact_trait/minor/delicate //Limited uses.
	desc = "Fragile"
	label_desc = "Fragile: The Artifact is poorly made. Continuous use will destroy it."

/datum/xenoartifact_trait/minor/delicate/on_init(obj/item/xenoartifact/X)
	X.max_integrity = pick(200, 300, 500, 800, 1000)
	X.obj_integrity = X.max_integrity
	X.alpha = X.alpha * 0.55

/datum/xenoartifact_trait/minor/delicate/activate(obj/item/xenoartifact/X, atom/user)
	if(X.obj_integrity)
		X.obj_integrity -= 100
	else if(X.obj_integrity <= 0)
		X.visible_message("<span class='danger'>The [X.name] shatters!</span>")
		to_chat(user, "<span class='danger'>The [X.name] shatters!</span>")
		qdel(X)

/datum/xenoartifact_trait/minor/aura
	desc = "Expansive"
	label_desc = "Expansive: The Artifact's surface reaches towards every creature in the room. Even the empty space behind you..."
	blacklist_traits = list(/datum/xenoartifact_trait/major/timestop, /datum/xenoartifact_trait/minor/long)

/datum/xenoartifact_trait/minor/aura/on_init(obj/item/xenoartifact/X)
	X.max_range += 2

/datum/xenoartifact_trait/minor/aura/activate(obj/item/xenoartifact/X)
	X.true_target = list()
	for(var/mob/living/M in oview(min(X.max_range, 5), get_turf(X.loc))) //Look for mobs
		X.true_target += M
	for(var/obj/M in oview(min(X.max_range, 5), get_turf(X.loc))) //Look for items
		if(!(M.anchored))
			X.true_target += M

/datum/xenoartifact_trait/minor/long //Essentially makes the artifact a ranged wand. Makes barreled useful.
	desc = "Scoped"
	label_desc = "Scoped: The Artifact has an almost magnifying effect to it. You could probably hit someone from really far away with it."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/aura)

/datum/xenoartifact_trait/minor/long/on_init(obj/item/xenoartifact/X)
	X.max_range += 18

/datum/xenoartifact_trait/minor/wearable //Convert item to glove
	desc = "Shaped"
	label_desc = "Shaped: The Artifact is small and shaped. It looks as if it'd fit on someone's finger."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)

/datum/xenoartifact_trait/minor/wearable/on_init(obj/item/xenoartifact/X)
	X.slot_flags = ITEM_SLOT_GLOVES
	
/datum/xenoartifact_trait/minor/wearable/activate(obj/item/xenoartifact/X, atom/user)
	X.true_target += list(user)

/datum/xenoartifact_trait/minor/blocking
	desc = "Shielded"
	label_desc = "Shielded: The Artifact's composistion lends itself well to blocking attacks. It would do you good to bring this to a rage cage."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)

/datum/xenoartifact_trait/minor/blocking/on_init(obj/item/xenoartifact/X)
	X.block_level = pick(1, 2, 3, 4)
	X.block_upgrade_walk = 1
	X.block_power = 25 * pick(0.8, 1, 1.3, 1.5)

/datum/xenoartifact_trait/minor/light //Light weight
	desc = "Light"
	label_desc = "Light: The Artifact is made from a light material. You can pitch it pretty far."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense, /datum/xenoartifact_trait/minor/heavy)

/datum/xenoartifact_trait/minor/light/on_init(obj/item/xenoartifact/X)
	X.throw_range = 8

/datum/xenoartifact_trait/minor/heavy //heavy weight
	desc = "Heavy"
	label_desc = "Heavy: The Artifact is made from a heavy material. You can't pitch it very far."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense, /datum/xenoartifact_trait/minor/light)

/datum/xenoartifact_trait/minor/heavy/on_init(obj/item/xenoartifact/X)
	X.throw_range = 1

/datum/xenoartifact_trait/minor/signalsend
	label_name = "Signaler"
	label_desc = "Signaler: The Artifact sends out a signal everytime it's activated."

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
	
//Major traits - The artifact's main gimmick, how it interacts with the world

/datum/xenoartifact_trait/major/sing //Debug
	desc = "Bugged"
	label_desc = "Bugged: The shape resembles nothing. You are Godless."

/datum/xenoartifact_trait/major/sing/activate(obj/item/xenoartifact/X, atom/target)
	X.say("DEBUG::XENOARTIFACT::SING")
	X.say(X.charge)
	X.say(target)

/datum/xenoartifact_trait/major/capture
	desc = "Hollow"
	label_desc = "Hollow: The shape is hollow, however the inside is deceptively large."
	var/fren

/datum/xenoartifact_trait/major/capture/on_init(obj/item/xenoartifact/X)
	if(prob(0.01)) 
		fren = TRUE

/datum/xenoartifact_trait/major/capture/activate(obj/item/xenoartifact/X, atom/target)
	if(ismovable(target))
		var/atom/movable/AM 
		if(!istype(target, /obj/item/xenoartifact))
			AM = target
		else if(isliving(X.loc)) //occurs when xenoartifact has maltargetting
			AM = X.loc
		else
			return
		AM.forceMove(X)
		AM.anchored = TRUE
		addtimer(CALLBACK(src, .proc/release, X, AM), X.charge*0.3 SECONDS)
		X.cooldownmod = X.charge*0.5 SECONDS

/datum/xenoartifact_trait/major/capture/proc/release(obj/item/xenoartifact/X, var/atom/movable/AM) //Empty contents
	var/turf/T = get_turf(X.loc)
	AM.anchored = FALSE
	AM.forceMove(T)
	if(fren)
		new /mob/living/simple_animal/hostile/russian(T)
		log_game("[X] spawned (/mob/living/simple_animal/hostile/russian) at [world.time]. [X] located at [X.x] [X.y] [X.z]")
		fren = FALSE

/datum/xenoartifact_trait/major/shock
	desc = "Conductive"
	label_desc = "Conductive: The shape resembles two lighting forks. Subtle arcs seem to leaps across them."

/datum/xenoartifact_trait/major/shock/on_init(obj/item/xenoartifact/X)
	X.icon_slots[1] = "901"

/datum/xenoartifact_trait/major/shock/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>You feel a slight static after touching the [X.name].</span>")
	return TRUE

/datum/xenoartifact_trait/major/shock/activate(obj/item/xenoartifact/X, atom/target, mob/user)
	do_sparks(pick(1, 2), FALSE, X)
	if(istype(target, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = target //Have to type convert to work with other traits
		C.charge += (X.charge/100)*C.maxcharge
		
	else if(istype(target, /mob/living))
		var/damage = X.charge*0.5
		var/mob/living/carbon/victim = target
		victim.electrocute_act(damage, X, 1, 1)
	X.cooldownmod = (X.charge*0.1) SECONDS

/datum/xenoartifact_trait/major/timestop
	desc = "Melted"
	label_desc = "Melted: The shape is drooling and sluggish. Additionally, light around it seems to invert."

/datum/xenoartifact_trait/major/timestop/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>Your hand feels slow while stroking the [X.name].</span>")
	return TRUE

/datum/xenoartifact_trait/major/timestop/activate(obj/item/xenoartifact/X, atom/target)
	var/turf/T = get_turf(X.loc)
	if(!X)
		T = get_turf(target.loc)     
	new /obj/effect/timestop(T, 2, (X.charge*0.1) SECONDS)
	X.cooldownmod = (X.charge*0.1) SECONDS

/datum/xenoartifact_trait/major/laser
	desc = "Barreled"
	label_desc = "Barreled: The shape resembles the barrel of a gun. It's possible that it might dispense candy."

/datum/xenoartifact_trait/major/laser/activate(obj/item/xenoartifact/X, atom/target, mob/living/user)
	if(isliving(target))
		if(get_dist(target, user) <= 1)
			var/mob/living/victim = target
			victim.adjust_fire_stacks(1)
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

/datum/xenoartifact_trait/major/bomb
	label_name = "Bomb"
	label_desc = "Explosive: The shape resembles nothing particularly interesting but, it is certain that it probably explodes."
	var/preserved_charge //I've forgotten why this is here but, I think it's becuase the callback references the current charge, which is usually 0

/datum/xenoartifact_trait/major/bomb/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/clothing/neck/stethoscope))
		to_chat(user, "<span class='info'>The [X.name] ticks deep from within.\n</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/major/bomb/activate(obj/item/xenoartifact/X, atom/target, mob/user)
	X.visible_message("<span class='danger'>The [X.name] begins to tick loudly...</span>")
	to_chat(user,"<span class='danger'>The [X.name] begins to tick loudly...</span>")
	X.visible_message("<span class='danger'>The [X.name] begins to tick loudly...</span>")
	addtimer(CALLBACK(src, .proc/explode, X), (10-(X.charge*0.06)) SECONDS)
	log_game("[X] primed an explosion at [world.time]. [X] will detonate in [(10-(X.charge*0.06))] seconds. [X] located at [X.x] [X.y] [X.z]")
	X.cooldownmod = (10-(X.charge*0.06)) SECONDS
	preserved_charge = X.charge

/datum/xenoartifact_trait/major/bomb/proc/explode(obj/item/xenoartifact/X)
	explosion(X.loc,1*(preserved_charge*0.1) > 0 ? 1*(preserved_charge*0.1) : 0, 1.5*(preserved_charge*0.1), 2*(preserved_charge*0.1))
	qdel(X) //Bon voyage. If you remove this, keep in mind there's a callback bug regarding a looping issue.

/datum/xenoartifact_trait/major/corginator //All of this is stolen from corgium. 
	desc = "Fuzzy" //Weirdchamp
	label_desc = "Fuzzy: The shape is hard to discern under all the hair sprouting out from the surface. You swear you've heard it bark before."
	var/list/victims = list() //List of all affected targets, used for early qdel
	var/obj/item/xenoartifact/xenoa //Used for early qdel

/datum/xenoartifact_trait/major/corginator/on_init(obj/item/xenoartifact/X)
	. = ..()
	xenoa = X

/datum/xenoartifact_trait/major/corginator/activate(obj/item/xenoartifact/X, mob/living/target)
	X.say(pick("Woof!", "Bark!", "Yap!"))
	if(istype(target, /mob/living) && !(istype(target, /mob/living/simple_animal/pet/dog/corgi)))
		var/mob/living/simple_animal/pet/dog/corgi/new_corgi = transform(X, target)
		addtimer(CALLBACK(src, .proc/transform_back, X, target, new_corgi), (X.charge*0.6) SECONDS)
		victims += list(target, new_corgi)
		X.cooldownmod = (X.charge*0.6) SECONDS

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
	target.forceMove(new_corgi)
	return new_corgi

/datum/xenoartifact_trait/major/corginator/proc/transform_back(obj/item/xenoartifact/X, mob/living/target, mob/living/simple_animal/pet/dog/corgi/new_corgi)
	if(target)
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

/datum/xenoartifact_trait/major/corginator/on_del() //Transform goobers back if artifact is deleted.
	var/mob/living/H
	var/mob/living/simple_animal/pet/dog/corgi/C
	for(var/M in 1 to victims.len-1)
		H = victims[M]
		C = victims[M+1]
		xenoa.say("[H] [C]")
		if(!istype(H, /mob/living/simple_animal/pet/dog/corgi))
			transform_back(xenoa, H, C)

/datum/xenoartifact_trait/major/mirrored //Swaps the last two target's minds
	desc = "Mirrored"
	label_desc = "Mirrored: The shape is perfectly symetrical. Perhaps you could interest the Captain?"
	var/mob/living/victim
	var/mob/living/caster

/datum/xenoartifact_trait/major/mirrored/on_touch(obj/item/xenoartifact/X, mob/user)
	if(victim.key != user.key)
		to_chat(user, "<span class='warning'>You see a reflection in the [X.name], it isn't yours...</span>")
	else    
		to_chat(user, "<span class='notice'>You see your reflection in the [X.name].</span>")
	return TRUE

/datum/xenoartifact_trait/major/mirrored/activate(obj/item/xenoartifact/X, mob/target, atom/user)
	if(!isliving(target) || target?.key)
		playsound(get_turf(X), 'sound/machines/buzz-sigh.ogg', 15, TRUE)
		return
	victim = target
	caster = user
	var/obj/effect/proc_holder/spell/targeted/mind_transfer/M = new
	M.range = X.max_range
	M.cast(list(victim), caster, TRUE)
	log_game("[X] swapped the identities of [victim] & [caster] at [world.time]. [X] located at [X.x] [X.y] [X.z]")
	victim = null
	caster = null
	qdel(M)

/datum/xenoartifact_trait/major/emp
	label_name = "EMP"
	label_desc = "EMP: The shape of the Artifact doesn't resemble anything particularly interesting. Technology around the Artifact seems to malfunction."

/datum/xenoartifact_trait/major/emp/activate(obj/item/xenoartifact/X)
	empulse(get_turf(X.loc), X.charge*0.03, X.charge*0.07, 1) //This might be too big

/datum/xenoartifact_trait/major/invisible //One step closer to the one ring
	label_name = "Transparent"
	label_desc = "Transparent: The shape of the Artifact is difficult to percieve. You feel the need to call it, precious..."
	var/list/victims = list()

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
		addtimer(CALLBACK(src, .proc/reveal, target), ((X.charge*0.3) SECONDS))
		X.cooldownmod = ((X.charge*0.3)+1) SECONDS

/datum/xenoartifact_trait/major/invisible/proc/hide(mob/living/target)
	animate(target, , alpha = 0, time = 5)

/datum/xenoartifact_trait/major/invisible/proc/reveal(mob/living/target)
	if(target)
		animate(target, , alpha = 255, time = 10)
		target = null

/datum/xenoartifact_trait/major/invisible/on_del()
	for(var/mob/living/M in victims)
		reveal(M)

/datum/xenoartifact_trait/major/teleporting
	desc = "Displaced"
	label_desc = "Displaced: The shape's state is unstable, causing it to shift through planes at a localized axis. Just ask someone from science..."

/datum/xenoartifact_trait/major/teleporting/on_init(obj/item/xenoartifact/X)
	if(prob(0.1))
		X.icon_state = "IB902"
		X.generate_icon(X.icon, "IBL902", X.material)
		X.icon_slots[1] = ""
		X.icon_slots[2] = ""
		X.icon_slots[3] = ""
		X.icon_slots[4] = ""

/datum/xenoartifact_trait/major/teleporting/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	if(istype(target, /atom/movable))
		var/atom/movable/victim = target //typecast to access anchored
		if(!victim.anchored)
			do_teleport(victim, get_turf(victim), (X.charge*0.1)+1, channel = TELEPORT_CHANNEL_BLUESPACE)

/datum/xenoartifact_trait/major/handmore //Adds up to four hands to target. Trying to add more will remove all limbs
	desc = "Limbed"
	label_desc = "Limped: Seperate limbs sprout from the Artifact. The shape resembles your favourite fantasy monster."

/datum/xenoartifact_trait/major/handmore/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	if(istype(target, /mob/living))
		var/mob/living/victim = target
		if(victim.held_items.len < 4)
			victim.change_number_of_hands(victim.held_items.len+1)
		else
			X.visible_message("<span class='danger'>[victim]'s arms dissapear into the [X]!</span>")//They currently don't dissapear, they just fall off. This is far funnier.
			if(user == target)
				to_chat(user, "<span class='danger'>Your arms dissapear into the [X]!</span>")
			victim.change_number_of_hands(0)

/datum/xenoartifact_trait/major/lamp
	label_name = "Lamp"
	label_desc = "Lamp: The Artifact emits light. Nothing in its shape suggests this."
	var/light_mod

/datum/xenoartifact_trait/major/lamp/on_init(obj/item/xenoartifact/X)
	X.light_system = MOVABLE_LIGHT
	X.light_color = pick(LIGHT_COLOR_FIRE, LIGHT_COLOR_BLUE, LIGHT_COLOR_GREEN, LIGHT_COLOR_RED, LIGHT_COLOR_ORANGE, LIGHT_COLOR_PINK, LIGHT_COLOR_WHITE)
	if(prob(0.1))
		X.icon_state = "IB902"
		X.generate_icon(X.icon, "IBL902", X.material)
		X.icon_slots[1] = ""
		X.icon_slots[2] = ""
		X.icon_slots[3] = ""
		X.icon_slots[4] = ""

/datum/xenoartifact_trait/major/lamp/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	X.AddComponent(/datum/component/overlay_lighting, 1.4+(X.charge*0.5), max(X.charge*0.05, 0.1), X.light_color)
	addtimer(CALLBACK(src, .proc/unlight, X), (X.charge*0.6) SECONDS)
	X.cooldownmod = (X.charge*0.6) SECONDS

/datum/xenoartifact_trait/major/lamp/proc/unlight(var/obj/item/xenoartifact/X)
	var/datum/component/overlay_lighting/L = X.GetComponent(/datum/component/overlay_lighting)
	if(L)
		qdel(L)

/datum/xenoartifact_trait/major/lamp/dark
	label_name = "Shade"
	label_desc = "Shade: The Artifact retracts light. Nothing in its shape suggests this."

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

/datum/xenoartifact_trait/major/forcefield
	label_name = "Wall"
	label_desc = "Wall: The Artifact produces a resonance that forms impenetrable walls. Here's one you'll never crawl!"
	var/size

/datum/xenoartifact_trait/major/forcefield/on_init(obj/item/xenoartifact/X)
	size = pick(1, 3, 5)

/datum/xenoartifact_trait/major/forcefield/activate(obj/item/xenoartifact/X)
	if(size >= 1)
		new /obj/effect/forcefield/xenoartifact_type(get_turf(X.loc), (X.charge*0.3) SECONDS)
	if(size >= 3)
		new /obj/effect/forcefield/xenoartifact_type(get_step(X, NORTH), (X.charge*0.3) SECONDS)
		new /obj/effect/forcefield/xenoartifact_type(get_step(X, SOUTH), (X.charge*0.3) SECONDS)
	if(size >= 5)
		new /obj/effect/forcefield/xenoartifact_type(get_step(X, WEST), (X.charge*0.3) SECONDS)
		new /obj/effect/forcefield/xenoartifact_type(get_step(X, EAST), (X.charge*0.3) SECONDS)

	X.cooldownmod = (X.charge*0.3) SECONDS
	
/obj/effect/forcefield/xenoartifact_type //Special wall type for artifact
	desc = "An impenetrable artifact wall."

/datum/xenoartifact_trait/major/heal
	label_name = "Healing"
	label_desc = "Healing: The Artifact repeairs any damaged organic tissue the targat may contain. Widely considered the Holy Grail of Artifact traits."
	var/healing_type

/datum/xenoartifact_trait/major/heal/on_init(obj/item/xenoartifact/X)
	healing_type = pick(1, 2, 3, 4)

/datum/xenoartifact_trait/major/heal/activate(obj/item/xenoartifact/X, atom/target)
	playsound(get_turf(target), 'sound/magic/staff_healing.ogg', 15, TRUE)
	if(istype(target, /mob/living))
		var/mob/living/victim = target
		switch(healing_type)
			if(1)
				victim.adjustBruteLoss((X.charge*0.2)*-1)
			if(2)
				victim.adjustFireLoss((X.charge*0.2)*-1)
			if(3)
				victim.adjustToxLoss((X.charge*0.2)*-1)
			if(4)
				victim.adjustOxyLoss((X.charge*0.2)*-1)

/datum/xenoartifact_trait/major/chem //Inject target with random chem
	desc = "Tubed"
	label_desc = "Tubed: The Artifact's shape is comprised of many twisting tubes and vials, it seems a liquid may be inside."
	var/datum/reagent/formula
	var/amount

/datum/xenoartifact_trait/major/chem/on_init(obj/item/xenoartifact/X)
	amount = pick(5, 9, 10, 15)
	formula = get_random_reagent_id()

/datum/xenoartifact_trait/major/chem/activate(obj/item/xenoartifact/X, atom/target)
	if(target?.reagents)
		var/datum/reagents/R = target.reagents
		R.add_reagent(formula, amount)
		log_game("[X] injected [target] with [amount]u of [formula] at [world.time]. [X] located at [X.x] [X.y] [X.z]")

/datum/xenoartifact_trait/major/push
	label_name = "Push"
	label_desc = "Push: The Artifact pushes anything not bolted down. The shape doesn't suggest this."

/datum/xenoartifact_trait/major/push/activate(obj/item/xenoartifact/X, atom/target)
	if(istype(target, /mob/living)||istype(target, /obj/item))
		var/atom/movable/victim = target
		var/atom/trg = get_edge_target_turf(X.loc, get_dir(X.loc, target.loc))
		victim.throw_at(get_turf(trg), (X.charge*0.07)+1, 8)

/datum/xenoartifact_trait/major/pull
	label_name = "Pull"
	label_desc = "Pull: The Artifact pulls anything not bolted down. The shape doesn't suggest this."

/datum/xenoartifact_trait/major/pull/on_init(obj/item/xenoartifact/X)
	X.max_range += 1

/datum/xenoartifact_trait/major/pull/activate(obj/item/xenoartifact/X, atom/target)
	if(istype(target, /mob/living)||istype(target, /obj/item))
		var/atom/movable/victim = target
		victim.throw_at(get_turf(X), X.charge*0.08, 8)

/datum/xenoartifact_trait/major/horn
	desc = "Horned"
	label_name = "Horn"
	label_desc = "Horn: The Artifact's shape resembles a horn. These Artifacts are widely deployed by the most clever clowns."
	var/sound

/datum/xenoartifact_trait/major/horn/on_init(obj/item/xenoartifact/X)
	sound = pick(list('sound/effects/adminhelp.ogg', 'sound/effects/applause.ogg', 'sound/effects/bubbles.ogg', 
					'sound/effects/empulse.ogg', 'sound/effects/explosion1.ogg', 'sound/effects/explosion_distant.ogg',
					'sound/effects/laughtrack.ogg', 'sound/effects/magic.ogg', 'sound/effects/meteorimpact.ogg',
					'sound/effects/phasein.ogg', 'sound/effects/supermatter.ogg', 'sound/weapons/armbomb.ogg',
					'sound/weapons/blade1.ogg'))

/datum/xenoartifact_trait/major/horn/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	playsound(get_turf(target), sound, 18, TRUE)

//Malfunctions

/datum/xenoartifact_trait/malfunction/bear //makes bears
	label_name = "P.B.R" 
	label_desc = "Parallel Bearspace Retrieval: A strange malfunction causes the Artifact to open a gateway to deep bearspace."
	var/bears //bear per bears

/datum/xenoartifact_trait/malfunction/bear/activate(obj/item/xenoartifact/X)
	if(prob(33) && bears < 7)
		bears+=1
		var/mob/living/simple_animal/hostile/bear/new_bear
		new_bear = new(get_turf(X.loc))
		new_bear.name = pick("Freddy", "Bearington", "Smokey", "Beorn", "Pooh", "Paddington", "Winnie", "Baloo", "Rupert", "Yogi", "Fozzie", "Boo") //Why not?
		log_game("[X] spawned a (/mob/living/simple_animal/hostile/bear) at [world.time]. [X] located at [X.x] [X.y] [X.z]")
	else
		qdel(X)

/datum/xenoartifact_trait/malfunction/badtarget
	label_name = "Maltargeting"
	label_desc = "Maltargeting: A strange malfunction that causes the Artifact to always target the original user."

/datum/xenoartifact_trait/malfunction/badtarget/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	var/mob/living/M = user
	if(M)
		X.true_target = list(M)

/datum/xenoartifact_trait/malfunction/strip
	label_name = "B.A.D"
	label_desc = "Bluespace Axis Desync: A strange malfunction inside the Artifact causes it to shift the target's realspace position with its bluespace mass in an offset manner. This results in the target dropping all they're wearing. This is probably the plot to a very educational movie."

/datum/xenoartifact_trait/malfunction/strip/activate(obj/item/xenoartifact/X, atom/target)
	if(isliving(target))
		var/mob/living/carbon/victim = target
		for(var/obj/item/I in victim.contents)
			victim.dropItemToGround(I)

/datum/xenoartifact_trait/malfunction/limbdenier
	label_name = "O.E.E"
	label_desc = "Organic Extrusion Exclusion: A strange malfunction that causes the Artifact to sever any extruding organic matter on a given user."

/datum/xenoartifact_trait/malfunction/limbdenier/activate(obj/item/xenoartifact/X, atom/target, atom/user) //Borrowed from self_amputation
	var/list/parts = list()
	if(istype(target, /mob/living/carbon))
		var/mob/living/carbon/victim = target
		for(var/obj/item/bodypart/BP as() in victim.bodyparts)
			if(BP.body_part != HEAD && BP.body_part != CHEST)
				if(BP.dismemberable)
					parts += BP
		if(parts.len)
			var/obj/item/bodypart/BP = pick(parts)
			BP.dismember()
