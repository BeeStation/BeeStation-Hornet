/datum/component/rot
	var/gas_amount = "miasma=0.005;TEMP=310.15" //MonkeStation Edit: Miasma Rework Issue#183

/datum/component/rot/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSprocessing, src)

/datum/component/rot/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/component/rot/process()
	//MonkeStation Edit Start: Miasma Rework Issue#183
	var/atom/atom_parent = parent
	var/turf/open/parent_turf = get_turf(atom_parent)
	if(!istype(parent_turf) || parent_turf.return_air().return_pressure() > (WARNING_HIGH_PRESSURE))
		return

	var/area_temperature = parent_turf.GetTemperature()
	if(area_temperature > BODYTEMP_HEAT_DAMAGE_LIMIT || area_temperature < BODYTEMP_COLD_DAMAGE_LIMIT)
		return

	parent_turf.atmos_spawn_air(gas_amount)
	//MonkeStation Edit End

/datum/component/rot/corpse
	gas_amount = "miasma=0.02;TEMP=310.15" //MonkeStation Edit: Miasma Rework Issue#183

/datum/component/rot/corpse/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()

/datum/component/rot/corpse/process()
	var/mob/living/carbon/C = parent
	if(!C) //can't delete what doesnt exist
		return

	if(C.stat != DEAD)
		qdel(src)
		return

	//Not when the corpse is charred
	if(HAS_TRAIT(C, TRAIT_HUSK)) //MonkeStation Edit: Miasma Rework Issue#183
		return

	// Also no decay if corpse chilled or inorganic
	if(C.bodytemperature <= T0C-10 || (!(MOB_ORGANIC in C.mob_biotypes))) //MonkeStation Edit: Miasma Rework Issue#183
		return

	..()
