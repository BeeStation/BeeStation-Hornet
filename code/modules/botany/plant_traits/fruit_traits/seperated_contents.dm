#define SEPERATED_CONTENTS_DEFAULT_VOLUME 50
#define SEPERATED_CONTENTS_MINIMUM_TIMER 2 SECONDS

/*
	Keep reagents in the fruit seperated until something triggers it
	Juts uses NO_REACT flags
*/

/datum/plant_trait/seperated_contents
	name = "Seperated Contents"
	desc = "The fruit's chemical reagent's are seperated until triggered."
	plant_feature_compat = /datum/plant_feature/fruit

/datum/plant_trait/seperated_contents/setup_component_parent(datum/source)
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent.parent, COMSIG_FRUIT_PREPARE, PROC_REF(prepare_fruit))

/datum/plant_trait/seperated_contents/proc/prepare_fruit(datum/source, obj/item/fruit)
	SIGNAL_HANDLER

	//Reset the reagents to have the no-react flag
	fruit.create_reagents(fruit.reagents?.maximum_volume || SEPERATED_CONTENTS_DEFAULT_VOLUME, NO_REACT)
	RegisterSignal(fruit, COMSIG_FRUIT_ACTIVATE_TARGET, PROC_REF(catch_activate))
	RegisterSignal(fruit, COMSIG_FRUIT_ACTIVATE_NO_CONTEXT, PROC_REF(catch_activate))

/datum/plant_trait/seperated_contents/proc/catch_activate(datum/source)
	INVOKE_ASYNC(src, PROC_REF(async_catch_activate), source)

/datum/plant_trait/seperated_contents/proc/async_catch_activate(datum/source)
	var/obj/item/fruit = source
	if(!istype(fruit))
		return
	//Sleep for a bit to give people time to react
	fruit?.visible_message("<span class='warning'>[fruit] starts to mix its contents!</span>")
	playsound(fruit, 'sound/effects/bubbles.ogg', 45)
	sleep(SEPERATED_CONTENTS_MINIMUM_TIMER)
	//Recreate fruit reagents without the NO_REACT flag
	//You can't just remove the flag and call the reactions, apparently
	var/list/reagents = list()
	for(var/datum/reagent/reagent_index as anything in fruit.reagents.reagent_list)
		if(QDELETED(reagent_index))
			continue
		reagents += list(reagent_index.type = reagent_index.volume)
	fruit.create_reagents(fruit.reagents?.maximum_volume || SEPERATED_CONTENTS_DEFAULT_VOLUME)
	fruit.reagents.add_reagent_list(reagents)

#undef SEPERATED_CONTENTS_DEFAULT_VOLUME
#undef SEPERATED_CONTENTS_MINIMUM_TIMER

//Watermelon
/obj/item/plant_seeds/preset/watermelon/bomb
	name = "watermelon seeds"
	name_override = "watermelon"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/corn_stalk/ground, /datum/plant_feature/fruit/watermelon/bomb)

/datum/plant_feature/fruit/watermelon/bomb
	plant_traits = list(/datum/plant_trait/seperated_contents, /datum/plant_trait/fruit/liquid_contents/sensitive)
	fast_reagents = list(/datum/reagent/water = PLANT_REAGENT_MEDIUM, /datum/reagent/potassium = PLANT_REAGENT_MEDIUM)

