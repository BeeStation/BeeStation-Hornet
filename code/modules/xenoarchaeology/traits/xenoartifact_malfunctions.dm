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
	X.AddComponent(/datum/component/radioactive, 25, X)

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
