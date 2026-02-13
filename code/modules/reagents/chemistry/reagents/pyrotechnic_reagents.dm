
/datum/reagent/thermite
	name = "Thermite"
	description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
	reagent_state = SOLID
	color = "#550000"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "sweet tasting metal"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/thermite/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(reac_volume >= 1)
		exposed_turf.AddComponent(/datum/component/thermite, reac_volume)

/datum/reagent/thermite/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustFireLoss(1 * REM * delta_time, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/nitroglycerin
	name = "Nitroglycerin"
	description = "Nitroglycerin is a heavy, colorless, oily, explosive liquid obtained by nitrating glycerol."
	color = COLOR_GRAY
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "oil"

/datum/reagent/stabilizing_agent
	name = "Stabilizing Agent"
	description = "Keeps unstable chemicals stable. This does not work on everything."
	reagent_state = LIQUID
	color = COLOR_YELLOW
	chemical_flags = NONE
	taste_description = "metal"

/datum/reagent/clf3
	name = "Chlorine Trifluoride"
	description = "Makes a temporary 3x3 fireball when it comes into existence, so be careful when mixing. ClF3 applied to a surface burns things that wouldn't otherwise burn, sometimes through the very floors of the station and exposing it to the vacuum of space."
	reagent_state = LIQUID
	color = "#FFC8C8"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 10 * REAGENTS_METABOLISM
	taste_description = "burning"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/clf3/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_fire_stacks(2 * REM * delta_time)
	affected_mob.adjustFireLoss(0.3 * max(affected_mob.fire_stacks, 1) * REM * delta_time, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/clf3/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(isplatingturf(exposed_turf))
		var/turf/open/floor/plating/plating = exposed_turf
		if(prob(10 + plating.burnt + 5 * plating.broken)) //broken or burnt plating is more susceptible to being destroyed
			EX_ACT(plating, EXPLODE_DEVASTATE)

	else if(isfloorturf(exposed_turf))
		var/turf/open/floor/floor = exposed_turf
		if(prob(reac_volume))
			floor.make_plating()
		else if(prob(reac_volume))
			floor.burn_tile()
		if(isfloorturf(floor))
			for(var/turf/open/turf in RANGE_TURFS(1,floor))
				if(!locate(/obj/effect/hotspot) in turf)
					new /obj/effect/hotspot/bright(floor)

	else if(iswallturf(exposed_turf))
		var/turf/closed/wall/wall = exposed_turf
		if(prob(reac_volume))
			EX_ACT(wall, EXPLODE_DEVASTATE)

/datum/reagent/clf3/expose_mob(mob/living/exposed_mob, method = TOUCH, reac_volume)
	if(!istype(exposed_mob))
		return

	if(method != INGEST && method != INJECT)
		exposed_mob.adjust_fire_stacks(min(reac_volume/5, 10))
		exposed_mob.ignite_mob()
		if(!locate(/obj/effect/hotspot) in exposed_mob.loc)
			new /obj/effect/hotspot/bright(exposed_mob.loc)

/datum/reagent/sorium
	name = "Sorium"
	description = "Sends everything flying from the detonation point."
	reagent_state = LIQUID
	color = "#5A64C8"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "air and bitterness"

/datum/reagent/liquid_dark_matter
	name = "Liquid Dark Matter"
	description = "Sucks everything into the detonation point."
	reagent_state = LIQUID
	color = "#210021"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "compressed bitterness"

/datum/reagent/blackpowder
	name = "Black Powder"
	description = "Explodes. Violently."
	reagent_state = LIQUID
	color = COLOR_BLACK
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	taste_description = "salt"

/datum/reagent/blackpowder/on_new(data)
	. = ..()
	if(holder?.my_atom)
		RegisterSignal(holder.my_atom, COMSIG_ATOM_EX_ACT, PROC_REF(on_ex_act))

/datum/reagent/blackpowder/Destroy()
	. = ..()
	if(holder?.my_atom)
		UnregisterSignal(holder.my_atom, COMSIG_ATOM_EX_ACT)

/datum/reagent/blackpowder/proc/on_ex_act(atom/source, severity, target)
	SIGNAL_HANDLER
	if(source.flags_1 & PREVENT_CONTENTS_EXPLOSION_1)
		return
	var/location = get_turf(holder.my_atom)
	var/datum/effect_system/reagents_explosion/e = new()
	e.set_up(1 + round(volume/6, 1), location, 0, 0, message = 0)
	e.start()
	holder.clear_reagents()

/datum/reagent/flash_powder
	name = "Flash Powder"
	description = "Makes a very bright flash."
	reagent_state = LIQUID
	color = "#C8C8C8"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "salt"

/datum/reagent/smoke_powder
	name = "Smoke Powder"
	description = "Makes a large cloud of smoke that can carry reagents."
	reagent_state = LIQUID
	color = "#C8C8C8"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "smoke"

/datum/reagent/sonic_powder
	name = "Sonic Powder"
	description = "Makes a deafening noise."
	reagent_state = LIQUID
	color = "#C8C8C8"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "loud noises"

/datum/reagent/phlogiston
	name = "Phlogiston"
	description = "Catches you on fire and makes you ignite."
	reagent_state = LIQUID
	color = "#FA00AF"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "burning"
	self_consuming = TRUE
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/phlogiston/expose_mob(mob/living/exposed_mob, method = TOUCH, reac_volume)
	. = ..()
	exposed_mob.adjust_fire_stacks(1)
	exposed_mob.adjustFireLoss(max(0.3 * exposed_mob.fire_stacks, 0.3))
	exposed_mob.ignite_mob()

/datum/reagent/phlogiston/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_fire_stacks(1 * REM * delta_time)
	affected_mob.adjustFireLoss(0.3 * max(affected_mob.fire_stacks, 0.15) * REM * delta_time, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/napalm
	name = "Napalm"
	description = "Very flammable."
	reagent_state = LIQUID
	color = "#FA00AF"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "burning"
	self_consuming = TRUE
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/napalm/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_fire_stacks(1 * REM * delta_time)

/datum/reagent/napalm/expose_mob(mob/living/exposed_mob, method = TOUCH, reac_volume)
	if(!istype(exposed_mob))
		return

	if(method != INGEST && method != INJECT)
		exposed_mob.adjust_fire_stacks(min(reac_volume / 4, 20))

/datum/reagent/cryostylane
	name = "Cryostylane"
	description = "Comes into existence at 20K. As long as there is sufficient oxygen for it to react with, Cryostylane slowly cools all other reagents in the container 0K."
	color = "#0000DC"
	chemical_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "bitterness"
	self_consuming = TRUE
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/cryostylane/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired) //TODO: code freezing into an ice cube
	. = ..()
	if(holder.has_reagent(/datum/reagent/oxygen))
		holder.remove_reagent(/datum/reagent/oxygen, 0.5 * REM * delta_time)
		affected_mob.adjust_bodytemperature(-15 * REM * delta_time)

		if(ishuman(affected_mob))
			var/mob/living/carbon/human/affected_human = affected_mob
			affected_human.adjust_coretemperature(-15 * REM * delta_time)

/datum/reagent/cryostylane/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(reac_volume >= 5)
		for(var/mob/living/simple_animal/slime/slime in exposed_turf)
			slime.adjustToxLoss(rand(15, 30))

/datum/reagent/pyrosium
	name = "Pyrosium"
	description = "Comes into existence at 20K. As long as there is sufficient oxygen for it to react with, Pyrosium slowly heats all other reagents in the container."
	color = "#64FAC8"
	chemical_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "bitterness"
	self_consuming = TRUE
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/pyrosium/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(holder.has_reagent(/datum/reagent/oxygen))
		holder.remove_reagent(/datum/reagent/oxygen, 0.5 * REM * delta_time)
		affected_mob.adjust_bodytemperature(15 * REM * delta_time)

		if(ishuman(affected_mob))
			var/mob/living/carbon/human/affected_human = affected_mob
			affected_human.adjust_coretemperature(15 * REM * delta_time)

/datum/reagent/teslium //Teslium. Causes periodic shocks, and makes shocks against the target much more effective.
	name = "Teslium"
	description = "An unstable, electrically-charged metallic slurry. Periodically electrocutes its victim, and makes electrocutions against them more deadly. Excessively heating teslium results in dangerous destabilization. Do not allow to come into contact with water."
	reagent_state = LIQUID
	color = "#20324D" //RGB: 32, 50, 77
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "charged metal"
	self_consuming = TRUE
	process_flags = ORGANIC | SYNTHETIC

	var/shock_timer = 0

/datum/reagent/teslium/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	shock_timer++
	if(shock_timer >= rand(5, 30)) //Random shocks are wildly unpredictable
		shock_timer = 0
		affected_mob.electrocute_act(rand(5,20), "Teslium in their body", 1, SHOCK_NOGLOVES) //SHOCK_NOGLOVES because it's caused from INSIDE of you
		playsound(affected_mob, "sparks", 50, 1)

/datum/reagent/teslium/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	if(!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/affected_human = affected_mob
	affected_human.physiology.siemens_coeff *= 2

/datum/reagent/teslium/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	if(!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/affected_human = affected_mob
	affected_human.physiology.siemens_coeff *= 0.5

/datum/reagent/teslium/energized_jelly
	name = "Energized Jelly"
	description = "Electrically-charged jelly. Boosts Oozeling's nervous system, but only shocks other lifeforms."
	reagent_state = LIQUID
	color = "#CAFF43"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "jelly"
	overdose_threshold = 30

/datum/reagent/teslium/energized_jelly/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(isoozeling(affected_mob))
		shock_timer = 0 //immune to shocks
		affected_mob.AdjustAllImmobility(-40 * REM * delta_time)
		affected_mob.adjustStaminaLoss(-2 * REM * delta_time, updating_health = FALSE)

		if(isluminescent(affected_mob))
			var/mob/living/carbon/human/affected_human = affected_mob
			var/datum/species/oozeling/luminescent/luminescent_species = affected_human.dna.species
			luminescent_species.extract_cooldown = max(luminescent_species.extract_cooldown - 20 * REM * delta_time, 0)
		return UPDATE_MOB_HEALTH

/datum/reagent/teslium/energized_jelly/overdose_process(mob/living/carbon/affected_mob)
	. = ..()
	if(isoozeling(affected_mob))
		if(prob(25))
			affected_mob.electrocute_act(rand(5,20), "Energized Jelly overdose in their body", 1, 1) //Override because it's caused from INSIDE of you
			playsound(affected_mob, "sparks", 50, 1)

/datum/reagent/firefighting_foam
	name = "Firefighting Foam"
	description = "A historical fire suppressant. Originally believed to simply displace oxygen to starve fires, it actually interferes with the combustion reaction itself. Vastly superior to the cheap water-based extinguishers found on NT vessels."
	reagent_state = LIQUID
	color = "#A6FAFF55"
	chemical_flags = NONE
	taste_description = "the inside of a fire extinguisher"

/datum/reagent/firefighting_foam/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf))
		return

	if(reac_volume >= 1)
		var/obj/effect/particle_effect/foam/firefighting/foam = locate(/obj/effect/particle_effect/foam) in exposed_turf
		if(!foam)
			foam = new(exposed_turf)
		else if(istype(foam))
			foam.lifetime = initial(foam.lifetime) //reduce object churn a little bit when using smoke by keeping existing foam alive a bit longer

	var/obj/effect/hotspot/hotspot = locate(/obj/effect/hotspot) in exposed_turf
	if(hotspot && !isspaceturf(exposed_turf))
		if(exposed_turf.air)
			var/datum/gas_mixture/mix = exposed_turf.air

			if(mix.return_temperature() > T20C)
				mix.temperature = max(mix.return_temperature() / 2, T20C)
			mix.react(src)
			qdel(hotspot)

/datum/reagent/firefighting_foam/expose_obj(obj/exposed_obj, reac_volume)
	. = ..()
	exposed_obj.extinguish()

/datum/reagent/firefighting_foam/expose_mob(mob/living/exposed_mob, method = TOUCH, reac_volume)
	. = ..()
	if(method in list(VAPOR, TOUCH))
		exposed_mob.adjust_fire_stacks(-reac_volume)
		exposed_mob.extinguish_mob()
