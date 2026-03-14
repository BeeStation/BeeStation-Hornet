/*
	bio-malignant, this trait makes the plant spawn an evil plant. Can be eaten to stop it.
*/

/datum/plant_trait/fruit/killer
	name = "Bio-Malignant"
	desc = "The fruit exhibits semi-sentient tendincies. Triggering the fruit will transform it into a blood \
	thirsty monster!"
	///Are we already awakening
	var/awakening = FALSE
	///What kinda of mob do we awaken to be?
	var/mob/living/awaken_mob = /mob/living/simple_animal/hostile/killertomato //Remake killer tomato into an ambiguous plant monster

/datum/plant_trait/fruit/killer/setup_fruit_parent()
	. = ..()
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_TARGET, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_NO_CONTEXT, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))

/datum/plant_trait/fruit/killer/catch_activate(datum/source, datum/plant_trait/trait, mob/living/target)
	. = ..()
	if(QDELING(src))
		return
	if(awakening || isspaceturf(fruit_parent.loc))
		return
	fruit_parent.visible_message(span_notice("[fruit_parent] beings to awaken!"))
	awakening = TRUE
	log_game("[fruit_parent] was awakened at [AREACOORD(fruit_parent)].")
	addtimer(CALLBACK(src, PROC_REF(make_killer_tomato)), 30)

/datum/plant_trait/fruit/killer/proc/make_killer_tomato()
	if(QDELETED(src))
		return
	awaken_mob = new awaken_mob(get_turf(fruit_parent.loc))
	awaken_mob.maxHealth += (trait_power-1) * awaken_mob.maxHealth
	awaken_mob.health = awaken_mob.maxHealth
	awaken_mob.melee_damage += (trait_power-1) * 10
	awaken_mob.visible_message(span_notice("[awaken_mob] suddenly awakens!"))
	qdel(fruit_parent)

/*
	bio-benign, this trait makes the plant spawn an benign plant. Can be eaten to stop it.
*/

/datum/plant_trait/fruit/killer/friendly
	name = "Bio-Benign"
	desc = "The fruit exhibits semi-sentient tendincies. Triggering the fruit will transform it into a benign 'monster'."
	awaken_mob = /mob/living/simple_animal/friendly_fruit

/*
	Variant for walking mushroom
*/

/datum/plant_trait/fruit/killer/friendly/walking
	awaken_mob = /mob/living/simple_animal/hostile/mushroom
