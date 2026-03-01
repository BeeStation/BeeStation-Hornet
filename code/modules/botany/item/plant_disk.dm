/obj/item/disk/plant_disk
	name = "plant disk"
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "disk"
	///Our saved plant data
	var/saved

/obj/item/disk/plant_disk/proc/set_saved(_saved)
	saved = _saved
	name = "plant disk"
	if(istype(saved, /datum/plant_trait))
		var/datum/plant_trait/trait = saved
		name = "[name] - [trait.name]"
	else if(istype(saved, /datum/plant_feature))
		var/datum/plant_feature/feature = saved
		name = "[name] - [feature.name]([feature.species_name])"
