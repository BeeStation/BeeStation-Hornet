//Psyphoza species mutation
/datum/mutation/spores
	name = "Agaricale Pores" //Pores, not spores
	desc = "An ancient mutation that gives psyphoza the ability to produce spores."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	power_path = /datum/action/spell/spores
	instability = 30
	energy_coeff = 1
	power_coeff = 1
	species_allowed = list(
		/datum/species/psyphoza,
	)

/datum/action/spell/spores
	name = "Release Spores"
	desc = "A rare genome that forces the subject to evict spores from their pores."
	school = "evocation"
	invocation = ""
	spell_requirements = null
	cooldown_time = 300 SECONDS
	invocation_type = INVOCATION_NONE
	button_icon_state = "smoke"
	mindbound = FALSE

/datum/action/spell/spores/on_cast(mob/user, atom/target)
	. = ..()
	//Setup reagents
	var/datum/reagents/holder = new()
	//If our user is a carbon, use their blood
	var/mob/living/carbon/C = user
	if(iscarbon(user) && C.blood_volume > 0)
		C.blood_volume = max(0, C.blood_volume-15)
		if(C.get_blood_id())
			holder.add_reagent(C.get_blood_id(), min(C.blood_volume, 15))
		else
			holder.add_reagent(/datum/reagent/blood, min(C.blood_volume, 15))
	else
		holder.add_reagent(/datum/reagent/drug/mushroomhallucinogen, 15)

	var/location = get_turf(user)
	var/smoke_radius = round(sqrt(holder.total_volume / 2), 1)
	var/datum/effect_system/smoke_spread/chem/S = new
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	if(S)
		S.set_up(holder, smoke_radius, location, 0)
		S.start()
	if(holder?.my_atom)
		holder.clear_reagents()
