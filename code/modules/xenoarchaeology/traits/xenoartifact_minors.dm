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
		to_chat(user, span_info("The [item.name] displays a resistance reading of [X.charge_req*0.1]."))
		return TRUE
	return ..()

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
	to_chat(user, span_notice("The hairs on your neck stand up after touching the [X.name]."))
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
		to_chat(user, span_info("The [item.name] displays an overcharge reading of [charges/3]."))
		return TRUE
	return ..()

//============
// Dense, makes the artifact mimic a structure
//============
/datum/xenoartifact_trait/minor/dense //Rather large, quite gigantic, particularly big
	desc = "Dense"
	label_desc = "Dense: The Artifact is dense and cannot be easily lifted but, the design has a slightly higher reaction rate."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/wearable, /datum/xenoartifact_trait/minor/sharp, /datum/xenoartifact_trait/minor/light, /datum/xenoartifact_trait/minor/heavy, /datum/xenoartifact_trait/minor/blocking, /datum/xenoartifact_trait/minor/anchor, /datum/xenoartifact_trait/minor/slippery)
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/dense/on_init(obj/item/xenoartifact/X)
	X.set_density(TRUE)
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
	to_chat(user, span_notice("The [X.name] feels sharp."))
	return TRUE

/datum/xenoartifact_trait/minor/sharp/on_init(obj/item/xenoartifact/X)
	X.sharpness = SHARP
	X.bleed_force = BLEED_CUT
	X.force = X.charge_req*0.12
	X.attack_verb_continuous = list("cleaves", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	X.attack_verb_simple = list("cleave", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
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
	to_chat(user, span_notice("The [X.name] feels cold."))
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
	//Slightly increase weight - muh arpee serber
	weight = 55
	///he who lives inside
	var/mob/living/simple_animal/shade/man
	///His doorbell
	var/obj/effect/mob_spawn/sentient_artifact/S

/datum/xenoartifact_trait/minor/sentient/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, span_warning("The [X.name] whispers to you..."))
	return TRUE

/datum/xenoartifact_trait/minor/sentient/on_init(obj/item/xenoartifact/X)
	addtimer(CALLBACK(src, PROC_REF(get_canidate), X), 5 SECONDS)
	RegisterSignal(X, COMSIG_PARENT_EXAMINE, PROC_REF(handle_ghost), TRUE)

//Proc used to give access to ghosts when original player leaves
/datum/xenoartifact_trait/minor/sentient/proc/handle_ghost(datum/source, mob/M, list/examine_text)
	if(isobserver(M) && man && !man?.key && (alert(M, "Are you sure you want to control of [man]?", "Assume control of [man]", "Yes", "No") == "Yes"))
		man.key = M.ckey

/datum/xenoartifact_trait/minor/sentient/proc/get_canidate(obj/item/xenoartifact/X, mob/M)
	var/list/mob/dead/observer/candidates = poll_ghost_candidates("Do you want to play as the maleviolent force inside the [X.name]?", ROLE_SENTIENT_XENOARTIFACT, null, 8 SECONDS)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		setup_sentience(X, C.ckey)
		return
	S = new(get_turf(X), X)
	S.set_density(FALSE)

/datum/xenoartifact_trait/minor/sentient/proc/setup_sentience(obj/item/xenoartifact/X, ckey)
	if(!(SSzclear.get_free_z_level()))
		playsound(get_turf(X), 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return
	man = new(get_turf(X))
	man.name = pick(GLOB.xenoa_artifact_names)
	man.real_name = "[man.name] - [X]"
	man.key = ckey
	man.status_flags |= GODMODE
	log_game("[key_name_admin(man)] took control of the sentient [X]. [X] located at [AREACOORD(X)]")
	man.forceMove(X)
	man.set_anchored(TRUE)
	var/datum/action/xeno_senitent_action/P = new /datum/action/xeno_senitent_action(X)
	P.Grant(man)
	//show little guy his traits
	to_chat(man, span_notice("Your traits are: \n"))
	for(var/datum/xenoartifact_trait/T in X.traits)
		to_chat(man, span_notice("[(T.desc || T.label_name)]\n"))
	if(man.key)
		playsound(get_turf(X), 'sound/items/haunted/ghostitemattack.ogg', 50, TRUE)
	qdel(S)

/datum/action/xeno_senitent_action //Lets sentience target goober
	name = "Activate"
	desc = "Select a target to activate your traits on."
	icon_icon = 'icons/hud/actions/actions_revenant.dmi'
	button_icon_state = "r_transmit"
	background_icon_state = "bg_spell"
	requires_target = TRUE

/datum/action/xeno_senitent_action/New(master)
	. = ..()
	if (!istype(master, /obj/item/xenoartifact))
		CRASH("Xeno artifact action assigned to a non-xeno artifact")

/datum/action/xeno_senitent_action/on_activate(mob/user, atom/target)
	. = ..()
	var/obj/item/xenoartifact/xeno = master
	xeno.true_target += xeno.process_target(target)
	xeno.default_activate(xeno.charge_req+10)
	cooldown_time = xeno.cooldown+xeno.cooldownmod
	start_cooldown()

/datum/xenoartifact_trait/minor/sentient/Destroy(force, ...)
	. = ..()
	QDEL_NULL(man) //Kill the inner person. Otherwise invisible runs around
	QDEL_NULL(S)

/obj/effect/mob_spawn/sentient_artifact
	death = FALSE
	name = "Sentient Xenoartifact"
	short_desc = "You're a maleviolent sentience, possesing an ancient alien artifact."
	flavour_text = "Return to your master..."
	use_cooldown = TRUE
	banType = ROLE_SENTIENT_XENOARTIFACT
	invisibility = 101
	var/obj/item/xenoartifact/artifact

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/mob_spawn/sentient_artifact)

/obj/effect/mob_spawn/sentient_artifact/Initialize(mapload, obj/item/xenoartifact/Z)
	if(!Z)
		qdel(src)
		return FALSE
	artifact = Z
	return ..()

/obj/effect/mob_spawn/sentient_artifact/create(ckey, name)
	var/datum/xenoartifact_trait/minor/sentient/S = artifact.get_trait(/datum/xenoartifact_trait/minor/sentient)
	S.setup_sentience(artifact, ckey)

//============
// Delicate, makes the artifact have limited uses
//============
/datum/xenoartifact_trait/minor/delicate
	desc = "Fragile"
	label_desc = "Fragile: The Artifact is poorly made. Continuous use will destroy it."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/delicate/on_init(obj/item/xenoartifact/X)
	X.max_integrity = pick(200, 300, 500, 800, 1000)
	X.update_integrity(X.max_integrity)
	X.alpha = X.alpha * 0.55

/datum/xenoartifact_trait/minor/delicate/activate(obj/item/xenoartifact/X, atom/user)
	if(X.get_integrity() > 0)
		X.update_integrity(-100)
		X.visible_message(span_danger("The [X.name] cracks!"), span_danger("The [X.name] cracks!"))
	else
		X.visible_message(span_danger("The [X.name] shatters!"), span_danger("The [X.name] shatters!"))
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
	for(var/atom/M in oview(min(X.max_range, 5), get_turf(X.loc)))
		if(X.true_target.len >= XENOA_MAX_TARGETS)
			return
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
	label_desc = "Scoped: The Artifact has an almost magnifying effect to it. You could probably target someone from really far away with it."
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
	X.true_target |= list(user)

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
		to_chat(user, span_info("The [item.name] displays an outputting signal code of [X.code], and frequency [X.frequency]."))
		return TRUE
	return ..()

/datum/xenoartifact_trait/minor/signalsend/on_init(obj/item/xenoartifact/X)
	X.code = rand(1, 100)
	X.frequency = FREQ_SIGNALER
	X.set_frequency(X.frequency)

/datum/xenoartifact_trait/minor/signalsend/activate(obj/item/xenoartifact/X)
	var/datum/signal/signal = new(list("code" = X.code))
	X.send_signal(signal)
	log_game("[X] sent signal code [X.code] on frequency [X.frequency] at [world.time]. [X] located at [AREACOORD(X)]")

//============
// Anchor, the artifact can be anchored, anchors when activated
//============
/datum/xenoartifact_trait/minor/anchor
	desc = "Anchored"
	label_desc = "Anchored: The Artifact buckles to the floor with the weight of a sun every time it activates. Heavier than you, somehow."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/wearable, /datum/xenoartifact_trait/minor/haunted)
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/anchor/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	if(isliving(X.loc))
		var/mob/living/holder = X.loc
		holder.dropItemToGround(X)
	X.visible_message(span_danger("The [X.name] buckles to the floor!"))
	X.set_anchored(TRUE)
	X.set_density(TRUE)

/datum/xenoartifact_trait/minor/anchor/on_item(obj/item/xenoartifact/X, atom/user, obj/item/item)
	if(item.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_info("You [X.anchored ? "unanchor" : "anchor"] the [X.name] to the [get_turf(X)]."))
		if(isliving(X.loc))
			var/mob/living/holder = X.loc
			holder.dropItemToGround(X)
		X.set_anchored(!X.anchored)
		if(!X.get_trait(/datum/xenoartifact_trait/minor/dense))
			X.set_density(!X.density)
		return TRUE
	return ..()

//============
// Slippery, the artifact is slippery. Honk
//============
/datum/xenoartifact_trait/minor/slippery
	desc = "Slippery"
	label_desc = "Slippery: The Artifact's surface is perpetually slippery. Popular amongst scientific-clown groups."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	var/datum/component/slippery/slipper

/datum/xenoartifact_trait/minor/slippery/on_init(obj/item/xenoartifact/X)
	slipper = X.AddComponent(/datum/component/slippery, 80)

/datum/xenoartifact_trait/minor/slippery/Destroy(force, ...)
	QDEL_NULL(slipper)
	return ..()

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
			"up" = CALLBACK(src, PROC_REF(haunted_step), X, NORTH),
			"down" = CALLBACK(src, PROC_REF(haunted_step), X, SOUTH),
			"left" = CALLBACK(src, PROC_REF(haunted_step), X, WEST),
			"right" = CALLBACK(src, PROC_REF(haunted_step), X, EAST),
			"activate" = CALLBACK(src, PROC_REF(activate_parent), X)), 10 SECONDS))

/datum/xenoartifact_trait/minor/haunted/proc/haunted_step(obj/item/xenoartifact/ref, dir)
	if(isliving(ref.loc)) //Make any mobs drop this before it moves
		var/mob/living/M = ref.loc
		M.dropItemToGround(ref)
	playsound(get_turf(ref), 'sound/effects/magic.ogg', 50, TRUE)
	step(ref, dir)

///Used for ghost command
/datum/xenoartifact_trait/minor/haunted/proc/activate_parent(obj/item/xenoartifact/ref)
	//Get a target to style on
	ref.true_target = ref.get_target_in_proximity(min(ref.max_range+1, 5))
	if(ref.true_target.len)
		ref.check_charge(ref.true_target[1])

/datum/xenoartifact_trait/minor/haunted/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/storage/book/bible))
		to_chat(user, span_warning("The [X.name] rumbles on contact with the [item]."))
		return TRUE
	return ..()

/datum/xenoartifact_trait/minor/haunted/Destroy(force, ...)
	QDEL_NULL(controller)
	return ..()

//============
// Delay, delays the activation. Credit to EvilDragon#4532
//============
/datum/xenoartifact_trait/minor/delay
	label_name = "Delayed"
	label_desc = "Delayed: The Artifact's composistion causes activations to be delayed."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	weight = 25

/datum/xenoartifact_trait/minor/delay/activate(obj/item/xenoartifact/X, atom/target, atom/user, setup)
	X.visible_message(span_danger("The [X] halts and begins to hum deeply."), span_danger("The [X] halts and begins to hum deeply."))
	playsound(get_turf(X), 'sound/effects/seedling_chargeup.ogg', 50, TRUE)
	sleep(3 SECONDS)

//============
// Blink, the artifact dissapears for a short duration after use
//============
/datum/xenoartifact_trait/minor/blink
	label_name = "Desynced"
	label_desc = "Desynced: The Artifact falls in & out of existence regularly."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	///Where your eyes don't go
	var/obj/effect/confiscate

/datum/xenoartifact_trait/minor/blink/activate(obj/item/xenoartifact/X, atom/target, atom/user, setup)
	X.visible_message(span_warning("[X] slips between dimensions!"))
	confiscate = new(get_turf(X))
	X.forceMove(confiscate)
	addtimer(CALLBACK(src, PROC_REF(comeback), X), X.charge*0.20 SECONDS)

/datum/xenoartifact_trait/minor/blink/proc/comeback(obj/item/xenoartifact/X)
	X.visible_message(span_warning("[X] slips between dimensions!"))
	X.forceMove(get_turf(confiscate))
	QDEL_NULL(confiscate)

/datum/xenoartifact_trait/minor/blink/Destroy(force, ...)
	. = ..()
	if(!isnull(confiscate))
		comeback()
