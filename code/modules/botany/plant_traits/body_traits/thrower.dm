/*
	The body throws fruits at nearby  mobs
	Just overwrite a bunch of shit from thorns since they share enough logic
*/
/datum/plant_trait/body/thorns/thrower
	name = "Oxalis"
	desc = "The plant will throw grown fruits at nearby trespassers."
	turf_range = 2
	///Quick reference to our neighbour fruit feature
	var/datum/plant_feature/fruit/fruit_feature

/datum/plant_trait/body/thorns/thrower/setup_component_parent(datum/source)
	. = ..()
	if(!parent || !parent.parent)
		return
	//A little hacky but it shouldn't matter too much
	addtimer(CALLBACK(src, PROC_REF(finish_setup)), 1 SECONDS)

/datum/plant_trait/body/thorns/thrower/proc/finish_setup()
	turf_range = turf_range * parent.trait_power
	fruit_feature = locate(/datum/plant_feature/fruit) in parent.parent.plant_features

/datum/plant_trait/body/thorns/thrower/catch_entered(datum/source, atom/movable/entering)
	if(!plant_item.loc.GetComponent(/datum/component/planter))
		return
	if(SEND_SIGNAL(plant_item.loc, COMSIG_PLANTER_PAUSE_PLANT))
		return
	var/mob/living/victim = entering
	if(!isliving(victim))
		return
	if(!length(fruit_feature?.fruits))
		return
//FX
	playsound(plant_item, 'sound/weapons/throw.ogg', 60, TRUE)
	var/matrix/o_transform = plant_item.transform
	animate(plant_item, time = 1.5, loop = 0, transform = matrix().Scale(1.07, 0.9))
	animate(time = 2, transform = o_transform)
	plant_item.visible_message(span_warning("[plant_item] throws a fruit at [victim]!"))
//Throw that mf
	var/obj/lobbed = pick(fruit_feature.fruits)
	lobbed.forceMove(get_turf(plant_item))
	lobbed.throw_at(victim, turf_range, 1*parent.trait_power)
//Cleanup
	fruit_feature.fruits -= lobbed
	if(!length(fruit_feature?.fruits))
		SEND_SIGNAL(parent.parent, COMSIG_PLANT_ACTION_HARVEST)

