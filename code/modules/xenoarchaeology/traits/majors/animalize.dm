/*
	Bestialized
	The artifact shoots the target with a random projectile
*/
/datum/xenoartifact_trait/major/animalize
	label_name = "Bestialized"
	label_desc = "Bestialized: The artifact contains transforming components. Triggering these components transforms the target into an animal."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	weight = 15
	conductivity = 12
	///List of potential animals we could turn people into
	var/list/possible_animals = list(/mob/living/basic/pet/dog/corgi, /mob/living/basic/pet/dog/bullterrier, /mob/living/basic/pet/dog/pug)
	///The animal we will turn people into
	var/mob/choosen_animal
	///How long we keep them as animals
	var/animal_time = 15 SECONDS

/datum/xenoartifact_trait/major/animalize/New(atom/_parent)
	. = ..()
	choosen_animal = pick(possible_animals)

/datum/xenoartifact_trait/major/animalize/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/target in focus)
		if(istype(target, choosen_animal) || IS_DEAD_OR_INCAP(target))
			continue
		target.do_shapeshift(shapeshift_type = choosen_animal)
		var/atom/log_atom = component_parent.parent
		log_game("[component_parent] in [log_atom] transformed [key_name_admin(target)] into [choosen_animal] at [world.time]. [log_atom] located at [AREACOORD(log_atom)]")
		//Add timer to undo this
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/xenoartifact_trait, un_trigger), target), animal_time*(component_parent.trait_strength/100))
	clear_focus()

/datum/xenoartifact_trait/major/animalize/un_trigger(atom/override, handle_parent = FALSE)
	focus = override ? list(override) : targets
	if(!length(focus))
		return ..()
	//Restore every swap holder
	for(var/mob/living/target in focus)
		var/mob/living/form = target.loc
		form.forceMove(get_turf(form))
		form?.do_unshapeshift()
		target.Knockdown(2 SECONDS)
	return ..()

/datum/xenoartifact_trait/major/animalize/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("turn the target into a dog"))


/datum/xenoartifact_trait/major/animalize/vermin
	label_name = "Bestialized Δ"
	possible_animals = list(/mob/living/basic/mothroach, /mob/living/basic/mouse, /mob/living/basic/cockroach/strong)
	conductivity = 6

/datum/xenoartifact_trait/major/animalize/vermin/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("turn the target into a vermin"))

/datum/xenoartifact_trait/major/animalize/dangerous
	label_name = "Bestialized Σ"
	possible_animals = list(/mob/living/simple_animal/hostile/bear, /mob/living/simple_animal/hostile/carp, /mob/living/simple_animal/hostile/killertomato)
	conductivity = 3

/datum/xenoartifact_trait/major/animalize/dangerous/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("turn the target into a hostile animal"))
