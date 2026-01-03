/*
	Flashing
	Creates a flash effect at the position of the artfiact
*/
/datum/xenoartifact_trait/major/flash
	label_name = "Flashing"
	label_desc = "Flashing: The artifact seems to contain flashing components. Triggering these components will create a blinding flash."
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	weight = 18
	conductivity = 18
	///Maximum flash range
	var/max_flash_range = 5

/datum/xenoartifact_trait/major/flash/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/turf/T = get_turf(component_parent.parent)
	var/flash_range = max_flash_range * (component_parent.trait_strength/100)
	playsound(T, 'sound/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (T, flash_range + 2, 4, COLOR_WHITE, 2)
	for(var/mob/living/M in viewers(flash_range, T))
		flash(get_turf(M), M)
	for(var/mob/living/M in hearers(flash_range, T))
		bang(get_turf(M), M)

//IDK, I coped both of these from flashbang.dm
/datum/xenoartifact_trait/major/flash/proc/flash(turf/T, mob/living/M)
	if(M.stat == DEAD)	//They're dead!
		return
	var/distance = max(0,get_dist(get_turf(src),T))
	//When distance is 0, will be 1
	//When distance is 7, will be 0
	//Can be less than 0 due to hearers being a circular radius.
	var/distance_proportion = max(1 - (distance / (max_flash_range * (component_parent.trait_strength/100))), 0)

	if(M.flash_act(intensity = 1, affect_silicon = 1))
		if(distance_proportion)
			M.Paralyze(20 * distance_proportion)
			M.Knockdown(200 * distance_proportion)
	else
		M.flash_act(intensity = 2)

/datum/xenoartifact_trait/major/flash/proc/bang(turf/T, mob/living/M)
	if(M.stat == DEAD)
		return
	var/distance = max(0,get_dist(get_turf(src),T))
	M.show_message("<span class='warning'>BANG</span>", MSG_AUDIBLE)
	var/atom/atom_parent = component_parent.parent
	if(!distance || atom_parent.loc == M || atom_parent.loc == M.loc)	//Stop allahu akbarring rooms with this.
		M.Paralyze(20)
		M.Knockdown(200)
		M.soundbang_act(1, 200, 10, 15)
	else
		if(distance <= 1)
			M.Paralyze(5)
			M.Knockdown(30)

		var/distance_proportion = max(1 - (distance / (max_flash_range * (component_parent.trait_strength/100))), 0)
		if(distance_proportion)
			M.soundbang_act(1, 200 * distance_proportion, rand(0, 5))
