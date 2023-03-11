//Malfunctions
//============
// Bear, produces a bear until it reaches its upper limit
//============
/datum/xenoartifact_trait/malfunction/bear
	label_name = "P.B.R."
	label_desc = "Parallel Bearspace Retrieval: A strange malfunction causes the Artifact to open a gateway to deep bearspace."
	weight = 15
	flags = URANIUM_TRAIT
	var/list/bears = list() //bear per bears

/datum/xenoartifact_trait/malfunction/bear/activate(obj/item/xenoartifact/X)
	if(length(bears) >= XENOA_MAX_BEARS)
		return
	var/turf/T = get_turf(X)
	var/mob/living/simple_animal/hostile/bear/malnourished/new_bear = new(T)
	new_bear.name = pick("Freddy", "Bearington", "Smokey", "Beorn", "Pooh", "Winnie", "Baloo", "Rupert", "Yogi", "Fozzie", "Boo") //Why not?
	bears += new_bear
	RegisterSignal(new_bear, COMSIG_MOB_DEATH, PROC_REF(handle_death))
	log_game("[X] spawned a (/mob/living/simple_animal/hostile/bear/malnourished) at [world.time]. [X] located at [AREACOORD(X)]")
	X.cooldown += 20 SECONDS

/datum/xenoartifact_trait/malfunction/bear/proc/handle_death(datum/source)
	bears -= source
	UnregisterSignal(source, COMSIG_MOB_DEATH)

//============
// Badtarget, changes target to user
//============
/datum/xenoartifact_trait/malfunction/badtarget
	label_name = "Maltargeting"
	label_desc = "Maltargeting: A strange malfunction that causes the Artifact to always target the original user."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT | PLASMA_TRAIT

/datum/xenoartifact_trait/malfunction/badtarget/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	var/mob/living/M
	if(isliving(user))
		M = user
	else if(isliving(user?.loc))
		M = user.loc
	else
		return
	X.true_target = X.process_target(M)
	X.cooldown += 5 SECONDS

//============
// Strip, moves a single clothing on target to floor
//============
/datum/xenoartifact_trait/malfunction/strip
	label_name = "B.A.D."
	label_desc = "Bluespace Axis Desync: A strange malfunction inside the Artifact causes it to shift the target's realspace position with its bluespace mass in an offset manner. This results in the target dropping all they're wearing. This is probably the plot to a very educational movie."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/malfunction/strip/activate(obj/item/xenoartifact/X, atom/target)
	if(isliving(target))
		var/mob/living/carbon/victim = target
		var/list/clothing_list = list()
		//Im okay with this targetting clothing in other non-worn slots
		for(var/obj/item/clothing/I in victim.contents)
			clothing_list += I
		//Stops this from stripping funky stuff
		var/obj/item/clothing/C = pick(clothing_list)
		if(!HAS_TRAIT_FROM(C, TRAIT_NODROP, GLUED_ITEM_TRAIT))
			victim.dropItemToGround(C)
			X.cooldown += 10 SECONDS

//============
// Trauma, gives target trauma, amazing
//============
/datum/xenoartifact_trait/malfunction/trauma
	label_name = "C.D.E."
	label_desc = "Cerebral Dysfunction Emergence: A strange malfunction that causes the Artifact to force brain traumas to develop in a given target."
	weight = 25
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT
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
		H.Unconscious(0.3 SECONDS)
		H.gain_trauma(trauma, TRAUMA_RESILIENCE_BASIC)
		X.cooldownmod += 10 SECONDS

//============
// Heated, causes artifact explode in flames
//============
/datum/xenoartifact_trait/malfunction/heated
	label_name = "Combustible"
	label_desc = "Combustible: A strange malfunction that causes the Artifact to violently combust."
	weight = 15
	flags = URANIUM_TRAIT

/datum/xenoartifact_trait/malfunction/heated/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	var/turf/T = get_turf(X)
	playsound(T, 'sound/effects/bamf.ogg', 50, TRUE)
	for(var/turf/open/turf in RANGE_TURFS(max(1, 4*((X.charge*1.5)/100)), T))
		if(!locate(/obj/effect/safe_fire) in turf)
			new /obj/effect/safe_fire(turf)

//Lights on fire, does nothing else damage / atmos wise
/obj/effect/safe_fire
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = GASFIRE_LAYER
	blend_mode = BLEND_ADD
	light_system = MOVABLE_LIGHT
	light_range = LIGHT_RANGE_FIRE
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

/obj/effect/safe_fire/Initialize(mapload)
	. = ..()
	for(var/atom/AT in loc)
		if(!QDELETED(AT) && AT != src) // It's possible that the item is deleted in temperature_expose
			AT.fire_act(400, 50) //should be average enough to not do too much damage
	addtimer(CALLBACK(src, PROC_REF(after_burn)), 0.3 SECONDS)

/obj/effect/safe_fire/proc/after_burn()
	qdel(src)

//============
// Radioactive, makes the artifact more radioactive with use
//============
/datum/xenoartifact_trait/malfunction/radioactive
	label_name = "Radioactive"
	label_desc = "Radioactive: The Artifact Emmits harmful particles when a reaction takes place."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT | PLASMA_TRAIT

/datum/xenoartifact_trait/malfunction/radioactive/on_init(obj/item/xenoartifact/X)
	X.rad_act(25)

/datum/xenoartifact_trait/malfunction/radioactive/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/geiger_counter))
		to_chat(user, "<span class='notice'>The [X.name] has residual radioactive decay features.</span>")
		return TRUE
	..()

/datum/xenoartifact_trait/malfunction/radioactive/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>You feel pins and needles after touching the [X.name].</span>")
	return TRUE

/datum/xenoartifact_trait/malfunction/radioactive/activate(obj/item/xenoartifact/X)
	X.rad_act(25)

//============
// twin, makes an evil twin of the target
//============
/datum/xenoartifact_trait/malfunction/twin
	label_name = "Anti-Cloning"
	label_desc = "Anti-Cloning: The Artifact produces an arguably maleviolent clone of target."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT | PLASMA_TRAIT
	var/list/clones = list()

/datum/xenoartifact_trait/malfunction/twin/activate(obj/item/xenoartifact/X, mob/living/target, atom/user, setup)
	//Stop artifact making one morbillion clones
	if(length(clones) >= XENOA_MAX_CLONES)
		return
	//Twin setup
	var/mob/living/simple_animal/hostile/twin/T = new(get_turf(X))
	//Setup appearance for evil twin
	T.name = target.name
	T.appearance = target.appearance
	if(istype(target) && length(target.vis_contents))
		T.add_overlay(target.vis_contents)
	T.alpha = 255
	T.pixel_y = initial(T.pixel_y)
	T.pixel_x = initial(T.pixel_x)
	T.color = COLOR_BLUE
	//Handle limit and hardel
	clones += T
	RegisterSignal(T, COMSIG_PARENT_QDELETING, PROC_REF(handle_death))

/datum/xenoartifact_trait/malfunction/twin/proc/handle_death(datum/source)
	clones -= source
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/mob/living/simple_animal/hostile/twin
	name = "evil twin"
	desc = "It looks just like... someone!"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	maxHealth = 10
	health = 10
	melee_damage = 5
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("evil_clone")
	status_flags = CANPUSH
	del_on_death = TRUE
	do_footstep = TRUE
	mobchatspan = "syndmob"

//============
// explode, a very small explosion takes place, destroying the artifact in the process
//============
/datum/xenoartifact_trait/malfunction/explode
	label_name = "Delaminating"
	label_desc = "Delaminating: The Artifact violently collapses, exploding."
	flags = URANIUM_TRAIT

/datum/xenoartifact_trait/malfunction/explode/activate(obj/item/xenoartifact/X, atom/target, atom/user, setup)
	. = ..()
	X.visible_message("<span class='warning'>The [X] begins to heat up, it's delaminating!</span>")
	apply_wibbly_filters(X, 3)
	addtimer(CALLBACK(src, PROC_REF(explode), X), 10 SECONDS)

/datum/xenoartifact_trait/malfunction/explode/proc/explode(obj/item/xenoartifact/X)
	SSexplosions.explode(X, 0, 1, 2, 1)
	qdel(X)

//============
// absorbant, absorbs nearby gasses
//============
/datum/xenoartifact_trait/malfunction/absorbant
	label_name = "Absorbing"
	label_desc = "Absorbing: The Artifact absorbs large volumes of nearby gasses."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT | PLASMA_TRAIT
	///What gasses we've S U C K E D
	var/datum/gas_mixture/air_contents
	///Gasses we can suck. Currently everything but, it's here if we need to blacklist in the future
	var/list/scrubbing = list(GAS_PLASMA, GAS_CO2, GAS_NITROUS, GAS_BZ, GAS_NITRYL, GAS_TRITIUM, GAS_HYPERNOB, GAS_H2O, GAS_O2, GAS_N2, GAS_STIMULUM, GAS_PLUOXIUM)
	///Adjust for balance - I'm sure this will have no ramifications
	var/volume = 1000000
	var/volume_rate = 200000
	///Ref to artifact for destruction
	var/obj/item/xenoartifact/parent

/datum/xenoartifact_trait/malfunction/absorbant/on_init(obj/item/xenoartifact/X)
	air_contents = new(volume)
	air_contents.set_temperature(T20C)
	parent = X

/datum/xenoartifact_trait/malfunction/absorbant/activate(obj/item/xenoartifact/X, atom/target, atom/user, setup)
	X.visible_message("<space class='warning'>[X] begins to vacuum nearby gasses!</span>")
	var/turf/T = get_turf(X)
	var/datum/gas_mixture/mixture = T.return_air()
	mixture.scrub_into(air_contents, volume_rate / mixture.return_volume(), scrubbing)
	X.air_update_turf()

//Throw sucked gas into our tile when we die
/datum/xenoartifact_trait/malfunction/absorbant/Destroy()
	. = ..()
	var/turf/T = get_turf(parent)
	T.assume_air(air_contents)
	parent.air_update_turf()

//============
// Hallucination, shows a random hallucination to the target once
//============
/datum/xenoartifact_trait/malfunction/hallucination
	label_name = "Hallucinogenic"
	label_desc = "Hallucinogenic: The Artifact causes the target to hallucinate."
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT | PLASMA_TRAIT

/datum/xenoartifact_trait/malfunction/hallucination/activate(obj/item/xenoartifact/X, atom/target, atom/user, setup)
	if(isliving(target))
		var/datum/hallucination/H = pick(GLOB.hallucination_list)
		H = new H(target)
