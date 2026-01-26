GLOBAL_LIST_EMPTY(bluespace_slime_crystals)

/obj/structure/slime_crystal
	name = "slimic pylon"
	desc = "Glassy, pure, transparent. Powerful artifact that relays the slimecore's influence onto space around it."
	max_integrity = 5
	anchored = TRUE
	density = TRUE
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "slime_pylon"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	///Assoc list of affected mobs, the key is the mob while the value of the map is the amount of ticks spent inside of the zone.
	var/list/affected_mobs = list()
	///What color is it?
	var/colour
	///Does it use process?
	var/uses_process = TRUE

/obj/structure/slime_crystal/New(loc, obj/structure/slime_crystal/master_crystal, ...)
	. = ..()
	if(master_crystal)
		invisibility = INVISIBILITY_MAXIMUM
		max_integrity = 1000
		atom_integrity = 1000

/obj/structure/slime_crystal/Initialize(mapload)
	. = ..()
	name =  "[colour] slimic pylon"
	var/itemcolor = "#FFFFFF"

	switch(colour)
		if(SLIME_TYPE_ORANGE)
			itemcolor = "#FFA500"
		if(SLIME_TYPE_PURPLE)
			itemcolor = "#B19CD9"
		if(SLIME_TYPE_BLUE)
			itemcolor = "#ADD8E6"
		if(SLIME_TYPE_METAL)
			itemcolor = "#7E7E7E"
		if(SLIME_TYPE_YELLOW)
			itemcolor = "#FFFF00"
		if(SLIME_TYPE_DARK_PURPLE)
			itemcolor = "#551A8B"
		if(SLIME_TYPE_DARK_BLUE)
			itemcolor = "#0000FF"
		if(SLIME_TYPE_SILVER)
			itemcolor = "#D3D3D3"
		if(SLIME_TYPE_BLUESPACE)
			itemcolor = "#32CD32"
		if(SLIME_TYPE_SEPIA)
			itemcolor = "#704214"
		if(SLIME_TYPE_CERULEAN)
			itemcolor = "#2956B2"
		if(SLIME_TYPE_PYRITE)
			itemcolor = "#FAFAD2"
		if(SLIME_TYPE_RED)
			itemcolor = "#FF0000"
		if(SLIME_TYPE_GREEN)
			itemcolor = "#00FF00"
		if(SLIME_TYPE_PINK)
			itemcolor = "#FF69B4"
		if(SLIME_TYPE_GOLD)
			itemcolor = "#FFD700"
		if(SLIME_TYPE_OIL)
			itemcolor = "#505050"
		if(SLIME_TYPE_BLACK)
			itemcolor = "#000000"
		if(SLIME_TYPE_LIGHT_PINK)
			itemcolor = "#FFB6C1"
		if(SLIME_TYPE_ADAMANTINE)
			itemcolor = "#008B8B"
	add_atom_colour(itemcolor, FIXED_COLOUR_PRIORITY)
	if(uses_process)
		START_PROCESSING(SSobj, src)

/obj/structure/slime_crystal/Destroy()
	if(uses_process)
		STOP_PROCESSING(SSobj, src)
	for(var/X in affected_mobs)
		on_mob_leave(X)
	return ..()

/obj/structure/slime_crystal/process()
	if(!uses_process)
		return PROCESS_KILL

	var/list/current_mobs = get_targets()
	for(var/mob/living/mob_in_range in current_mobs)
		if(!(mob_in_range in affected_mobs))
			on_mob_enter(mob_in_range)
			affected_mobs[mob_in_range] = 0

		affected_mobs[mob_in_range]++
		on_mob_effect(mob_in_range)

	for(var/M in affected_mobs - current_mobs)
		on_mob_leave(M)
		affected_mobs -= M

/obj/structure/slime_crystal/proc/get_targets()
	return range(3, src)

/obj/structure/slime_crystal/gold/process()
	var/list/current_mobs = range(3, src)
	for(var/M in affected_mobs - current_mobs)
		on_mob_leave(M)
		affected_mobs -= M

	for(var/mob/living/M in affected_mobs)
		if(M.stat == DEAD)
			on_mob_leave(M)
			affected_mobs -= M

/obj/structure/slime_crystal/proc/master_crystal_destruction()
	qdel(src)

/obj/structure/slime_crystal/proc/on_mob_enter(mob/living/affected_mob)
	return

/obj/structure/slime_crystal/proc/on_mob_effect(mob/living/affected_mob)
	return

/obj/structure/slime_crystal/proc/on_mob_leave(mob/living/affected_mob)
	return

/obj/structure/slime_crystal/grey
	colour = SLIME_TYPE_GREY

/obj/structure/slime_crystal/grey/get_targets()
	return view(3, src)

/obj/structure/slime_crystal/grey/on_mob_effect(mob/living/affected_mob)
	if(!istype(affected_mob, /mob/living/simple_animal/slime))
		return
	var/mob/living/simple_animal/slime/slime_mob = affected_mob
	slime_mob.nutrition += 2

/obj/structure/slime_crystal/orange
	colour = SLIME_TYPE_ORANGE

/obj/structure/slime_crystal/orange/get_targets()
	return view(3, src)

/obj/structure/slime_crystal/orange/on_mob_effect(mob/living/affected_mob)
	if(!istype(affected_mob, /mob/living/carbon))
		return
	var/mob/living/carbon/carbon_mob = affected_mob
	carbon_mob.adjust_fire_stacks(1)
	carbon_mob.ignite_mob()

/obj/structure/slime_crystal/orange/process()
	. = ..()
	var/turf/open/T = get_turf(src)
	if(!istype(T))
		return
	var/datum/gas_mixture/gas = T.return_air()
	gas.temperature = (T0C + 200)
	T.air_update_turf(FALSE, FALSE)

/obj/structure/slime_crystal/purple
	colour = SLIME_TYPE_PURPLE

	var/heal_amt = 2

/obj/structure/slime_crystal/purple/on_mob_effect(mob/living/affected_mob)
	if(!istype(affected_mob, /mob/living/carbon))
		return
	var/mob/living/carbon/carbon_mob = affected_mob
	var/rand_dam_type = rand(0, 10)

	new /obj/effect/temp_visual/heal(get_turf(affected_mob), "#e180ff")

	switch(rand_dam_type)
		if(0)
			carbon_mob.adjustBruteLoss(-heal_amt)
		if(1)
			carbon_mob.adjustFireLoss(-heal_amt)
		if(2)
			carbon_mob.adjustOxyLoss(-heal_amt)
		if(3)
			carbon_mob.adjustToxLoss(-heal_amt, forced = TRUE)
		if(4)
			carbon_mob.adjustCloneLoss(-heal_amt)
		if(5)
			carbon_mob.adjustStaminaLoss(-heal_amt)
		if(6 to 10)
			carbon_mob.adjustOrganLoss(pick(ORGAN_SLOT_BRAIN,ORGAN_SLOT_HEART,ORGAN_SLOT_LIVER,ORGAN_SLOT_LUNGS), -heal_amt)

/obj/structure/slime_crystal/blue
	colour = SLIME_TYPE_BLUE

/obj/structure/slime_crystal/blue/process()
	for(var/turf/open/T in view(2, src))
		if(isspaceturf(T))
			continue

		var/datum/gas_mixture/air = T.return_air()
		var/moles_to_remove = air.total_moles()
		T.remove_air(moles_to_remove)

		var/datum/gas_mixture/base_mix = SSair.parse_gas_string(OPENTURF_DEFAULT_ATMOS)
		T.assume_air(base_mix)
		T.air_update_turf(FALSE, FALSE)

/obj/structure/slime_crystal/metal
	colour = SLIME_TYPE_METAL

	var/heal_amt = 3

/obj/structure/slime_crystal/metal/on_mob_effect(mob/living/affected_mob)
	if(!iscyborg(affected_mob))
		return
	var/mob/living/silicon/borgo = affected_mob
	borgo.adjustBruteLoss(-heal_amt)

/obj/structure/slime_crystal/yellow
	colour = SLIME_TYPE_YELLOW
	light_color = LIGHT_COLOR_DIM_YELLOW //a good, sickly atmosphere
	light_power = 0.75
	uses_process = FALSE

/obj/structure/slime_crystal/yellow/Initialize(mapload)
	. = ..()
	set_light(3)

/obj/structure/slime_crystal/yellow/attacked_by(obj/item/stock_parts/cell/cell, mob/living/user)
	if(!istype(cell))
		return ..()
	if(cell.charge == cell.maxcharge) // Punishment for greed
		to_chat(user, span_danger("You try to charge [cell], but it is already fully energized. You are not sure if this was a good idea..."))
		cell.explode()
		return
	to_chat(user, span_notice("You charge [cell] on [src]!"))
	cell.give(cell.maxcharge)
	cell.update_appearance()

/obj/structure/slime_crystal/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE

/obj/structure/slime_crystal/darkpurple/process()
	var/turf/T = get_turf(src)
	if(!istype(T, /turf/open))
		return
	var/turf/open/open_turf = T
	var/datum/gas_mixture/air = open_turf.return_air()

	if(GET_MOLES(/datum/gas/plasma, air) > 15)
		REMOVE_MOLES(/datum/gas/plasma, air, 15)
		new /obj/item/stack/sheet/mineral/plasma(open_turf)

/obj/structure/slime_crystal/darkpurple/Destroy()
	atmos_spawn_air("plasma=[20];TEMP=[500]")
	return ..()

/obj/structure/slime_crystal/darkblue
	colour = SLIME_TYPE_DARK_BLUE

/obj/structure/slime_crystal/darkblue/process(delta_time)
	for(var/turf/open/T in RANGE_TURFS(5, src))
		if(DT_PROB(75, delta_time))
			continue
		T.MakeDry(TURF_WET_LUBE)

	for(var/obj/item/trash/trashie in range(5, src))
		if(DT_PROB(25, delta_time))
			qdel(trashie)

/obj/structure/slime_crystal/silver
	colour = SLIME_TYPE_SILVER

/obj/structure/slime_crystal/silver/process(delta_time)
	for(var/obj/machinery/hydroponics/hydr in range(5, src))
		hydr.weedlevel = 0
		hydr.pestlevel = 0
		if(DT_PROB(10, delta_time))
			hydr.age++

/obj/structure/slime_crystal/bluespace
	colour = SLIME_TYPE_BLUESPACE
	density = FALSE
	uses_process = FALSE
	///Is it in use?
	var/in_use = FALSE

/obj/structure/slime_crystal/bluespace/Initialize(mapload)
	. = ..()
	GLOB.bluespace_slime_crystals += src

/obj/structure/slime_crystal/bluespace/Destroy()
	GLOB.bluespace_slime_crystals -= src
	return ..()

/obj/structure/slime_crystal/bluespace/attack_hand(mob/user, list/modifiers)

	if(in_use)
		return

	var/list/local_bs_list = GLOB.bluespace_slime_crystals.Copy()
	local_bs_list -= src
	if(!LAZYLEN(local_bs_list))
		return ..()

	if(local_bs_list.len == 1)
		do_teleport(user, local_bs_list[1])
		return

	in_use = TRUE

	var/list/assoc_list = list()

	for(var/BSC in local_bs_list)
		var/area/bsc_area = get_area(BSC)
		var/name = "[bsc_area.name] bluespace slimic pylon"
		var/counter = 0

		do
			counter++
		while(assoc_list["[name]([counter])"])

		name += "([counter])"

		assoc_list[name] = BSC

	var/chosen_input = input(user,"What destination do you want to choose",null) as null|anything in assoc_list
	in_use = FALSE

	if(!chosen_input || !assoc_list[chosen_input])
		return

	do_teleport(user ,assoc_list[chosen_input])

/obj/structure/slime_crystal/sepia
	colour = SLIME_TYPE_SEPIA

/obj/structure/slime_crystal/sepia/on_mob_enter(mob/living/affected_mob)
	ADD_TRAIT(affected_mob,TRAIT_NOBREATH,type)
	ADD_TRAIT(affected_mob,TRAIT_NOCRITDAMAGE,type)
	ADD_TRAIT(affected_mob,TRAIT_RESISTLOWPRESSURE,type)
	ADD_TRAIT(affected_mob,TRAIT_RESISTHIGHPRESSURE,type)
	ADD_TRAIT(affected_mob,TRAIT_NOSOFTCRIT,type)
	ADD_TRAIT(affected_mob,TRAIT_NOHARDCRIT,type)

/obj/structure/slime_crystal/sepia/on_mob_leave(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob,TRAIT_NOBREATH,type)
	REMOVE_TRAIT(affected_mob,TRAIT_NOCRITDAMAGE,type)
	REMOVE_TRAIT(affected_mob,TRAIT_RESISTLOWPRESSURE,type)
	REMOVE_TRAIT(affected_mob,TRAIT_RESISTHIGHPRESSURE,type)
	REMOVE_TRAIT(affected_mob,TRAIT_NOSOFTCRIT,type)
	REMOVE_TRAIT(affected_mob,TRAIT_NOHARDCRIT,type)

/obj/structure/cerulean_slime_crystal
	name = "Cerulean slime poly-crystal"
	desc = "Translucent and irregular, it can duplicate matter on a whim"
	anchored = TRUE
	density = FALSE
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "cerulean_crystal"
	max_integrity = 5
	var/stage = 0
	var/max_stage = 5
	var/datum/weakref/pylon

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/cerulean_slime_crystal)

/obj/structure/cerulean_slime_crystal/Initialize(mapload, obj/structure/slime_crystal/cerulean/master_pylon)
	. = ..()
	if(istype(master_pylon))
		pylon = WEAKREF(master_pylon)
	transform *= 1/(max_stage-1)
	stage_growth()

/obj/structure/cerulean_slime_crystal/proc/stage_growth()
	if(stage == max_stage)
		return

	if(stage == 3)
		density = TRUE

	stage ++

	var/matrix/M = new
	M.Scale(1/max_stage * stage)

	animate(src, transform = M, time = 120 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(stage_growth)), 120 SECONDS)

/obj/structure/cerulean_slime_crystal/Destroy()
	if(stage > 3)
		var/obj/item/cerulean_slime_crystal/crystal = new(get_turf(src))
		if(stage == 5)
			crystal.amt = rand(1,3)
		else
			crystal.amt = 1
	if(pylon)
		var/obj/structure/slime_crystal/cerulean/C = pylon.resolve()
		if(C)
			C.crystals--
			C.spawn_crystal()
		else
			pylon = null
	return ..()

/obj/structure/slime_crystal/cerulean
	colour = SLIME_TYPE_CERULEAN
	uses_process = FALSE
	var/crystals = 0

/obj/structure/slime_crystal/cerulean/Initialize(mapload)
	. = ..()
	for (var/i in 1 to 10) // doesn't guarantee 3 but it's a good effort
		spawn_crystal()

/obj/structure/slime_crystal/cerulean/proc/spawn_crystal()
	if(crystals >= 3)
		return
	for(var/turf/T as anything in RANGE_TURFS(2, src))
		if(T.is_blocked_turf() || isspaceturf(T)  || T == get_turf(src) || prob(50))
			continue
		var/obj/structure/cerulean_slime_crystal/CSC = locate() in range(1, T)
		if(CSC)
			continue
		new /obj/structure/cerulean_slime_crystal(T, src)
		crystals++
		return

/obj/structure/slime_crystal/pyrite
	colour = SLIME_TYPE_PYRITE
	uses_process = FALSE

/obj/structure/slime_crystal/pyrite/Initialize(mapload)
	. = ..()
	change_colour()

/obj/structure/slime_crystal/pyrite/proc/change_colour()
	var/list/color_list = list("#FFA500","#B19CD9", "#ADD8E6","#7E7E7E","#FFFF00","#551A8B","#0000FF","#D3D3D3", "#32CD32","#704214","#2956B2","#FAFAD2", "#FF0000",
					"#00FF00", "#FF69B4","#FFD700", "#505050", "#FFB6C1","#008B8B")
	for(var/turf/T as anything in RANGE_TURFS(4, src))
		T.add_atom_colour(pick(color_list), FIXED_COLOUR_PRIORITY)

	addtimer(CALLBACK(src,PROC_REF(change_colour)),rand(0.75 SECONDS,1.25 SECONDS))

/obj/structure/slime_crystal/red
	colour = SLIME_TYPE_RED

	var/blood_amt = 0

	var/max_blood_amt = 300

/obj/structure/slime_crystal/red/examine(mob/user)
	. = ..()
	. += "It has [blood_amt] u of blood."

/obj/structure/slime_crystal/red/process()

	if(blood_amt == max_blood_amt)
		return

	var/list/range_objects = range(3, src)

	for(var/obj/effect/decal/cleanable/blood/trail_holder/TH in range_objects)
		qdel(TH)

		blood_amt++
		if(blood_amt == max_blood_amt)
			return

	for(var/obj/effect/decal/cleanable/blood/B in range_objects)
		qdel(B)

		blood_amt++
		if(blood_amt == max_blood_amt)
			return

/obj/structure/slime_crystal/red/attack_hand(mob/user, list/modifiers)
	if(blood_amt < 100)
		return ..()

	blood_amt -= 100
	var/type = pick(/obj/item/food/meat/slab,/obj/item/organ/heart,/obj/item/organ/lungs,/obj/item/organ/liver,/obj/item/organ/eyes,/obj/item/organ/tongue,/obj/item/organ/stomach,/obj/item/organ/ears)
	new type(get_turf(src))

/obj/structure/slime_crystal/red/attacked_by(obj/item/I, mob/living/user)
	if(blood_amt < 10)
		return ..()

	if(!istype(I, /obj/item/reagent_containers/cup/beaker))
		return ..()

	var/obj/item/reagent_containers/cup/beaker/item_beaker = I

	if(!item_beaker.is_refillable() || (item_beaker.reagents.total_volume + 10 > item_beaker.reagents.maximum_volume))
		return ..()
	blood_amt -= 10
	item_beaker.reagents.add_reagent(/datum/reagent/blood,10)

/obj/structure/slime_crystal/green
	colour = SLIME_TYPE_GREEN
	var/datum/mutation/stored_mutation

/obj/structure/slime_crystal/green/examine(mob/user)
	. = ..()
	if(stored_mutation)
		. += "It currently stores [stored_mutation.name]"
	else
		. += "It doesn't hold any mutations"

/obj/structure/slime_crystal/green/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!iscarbon(user) || !user.has_dna())
		return
	var/mob/living/carbon/carbon_user = user
	var/list/mutation_list = carbon_user.dna.mutations
	stored_mutation = pick(mutation_list)
	stored_mutation = stored_mutation.type

/obj/structure/slime_crystal/green/on_mob_effect(mob/living/affected_mob)
	if(!iscarbon(affected_mob) || !affected_mob.has_dna() || !stored_mutation || HAS_TRAIT(affected_mob,TRAIT_BADDNA))
		return
	var/mob/living/carbon/carbon_mob = affected_mob
	carbon_mob.dna.add_mutation(stored_mutation)

	if(affected_mobs[affected_mob] % 60 != 0)
		return

	var/list/mut_list = carbon_mob.dna.mutations
	var/list/secondary_list = list()

	for(var/X in mut_list)
		if(istype(X,stored_mutation))
			continue
		var/datum/mutation/t_mutation = X
		secondary_list += t_mutation.type

	var/datum/mutation/mutation = pick(secondary_list)
	carbon_mob.dna.remove_mutation(mutation)

/obj/structure/slime_crystal/green/on_mob_leave(mob/living/affected_mob)
	if(!iscarbon(affected_mob) || !affected_mob.has_dna())
		return
	var/mob/living/carbon/carbon_mob = affected_mob
	carbon_mob.dna.remove_mutation(stored_mutation)

/obj/structure/slime_crystal/pink
	colour = SLIME_TYPE_PINK

/obj/structure/slime_crystal/pink/on_mob_enter(mob/living/affected_mob)
	ADD_TRAIT(affected_mob,TRAIT_PACIFISM,type)

/obj/structure/slime_crystal/pink/on_mob_leave(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob,TRAIT_PACIFISM,type)

/obj/structure/slime_crystal/gold
	colour = SLIME_TYPE_GOLD

/obj/structure/slime_crystal/gold/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_mob = user
	var/mob/living/simple_animal/pet/chosen_pet = pick(/mob/living/basic/pet/dog/corgi,/mob/living/basic/pet/dog/pug,/mob/living/basic/pet/dog/bullterrier,/mob/living/simple_animal/pet/fox,/mob/living/simple_animal/pet/cat/kitten,/mob/living/simple_animal/pet/cat/space,/mob/living/simple_animal/pet/penguin/emperor)
	chosen_pet = new chosen_pet(get_turf(human_mob))
	human_mob.forceMove(chosen_pet)
	human_mob.mind.transfer_to(chosen_pet)
	ADD_TRAIT(human_mob, TRAIT_NOBREATH, type)
	affected_mobs += chosen_pet

/obj/structure/slime_crystal/gold/on_mob_leave(mob/living/affected_mob)
	var/mob/living/carbon/human/human_mob = locate() in affected_mob
	affected_mob.mind.transfer_to(human_mob)
	human_mob.grab_ghost()
	human_mob.forceMove(get_turf(affected_mob))
	REMOVE_TRAIT(human_mob, TRAIT_NOBREATH, type)
	qdel(affected_mob)

/obj/structure/slime_crystal/oil
	colour = SLIME_TYPE_OIL

/obj/structure/slime_crystal/oil/process()
	for(var/turf/open/turf_in_range in RANGE_TURFS(3, src))
		turf_in_range.MakeSlippery(TURF_WET_LUBE, 5 SECONDS)

/obj/structure/slime_crystal/black
	colour = SLIME_TYPE_BLACK

/obj/structure/slime_crystal/black/on_mob_effect(mob/living/affected_mob)
	if(!ishuman(affected_mob) || isoozeling(affected_mob))
		return

	if(affected_mobs[affected_mob] < 60) //Around 2 minutes
		return

	var/mob/living/carbon/human/human_transformed = affected_mob
	human_transformed.set_species(pick(typesof(/datum/species/oozeling)))

/obj/structure/slime_crystal/lightpink
	colour = SLIME_TYPE_LIGHT_PINK

/obj/structure/slime_crystal/lightpink/attack_ghost(mob/user)
	. = ..()
	var/mob/living/simple_animal/hostile/lightgeist/slime/L = new(get_turf(src))
	L.ckey = user.ckey
	affected_mobs[L] = 0
	ADD_TRAIT(L,TRAIT_MUTE,type)
	ADD_TRAIT(L,TRAIT_EMOTEMUTE,type)

/obj/structure/slime_crystal/lightpink/on_mob_leave(mob/living/affected_mob)
	if(istype(affected_mob,/mob/living/simple_animal/hostile/lightgeist/slime))
		affected_mob.ghostize(TRUE)
		qdel(affected_mob)

/obj/structure/slime_crystal/adamantine
	colour = SLIME_TYPE_ADAMANTINE

/obj/structure/slime_crystal/adamantine/on_mob_enter(mob/living/affected_mob)
	if(!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/human = affected_mob
	human.dna.species.brutemod -= 0.1
	human.dna.species.burnmod -= 0.1

/obj/structure/slime_crystal/adamantine/on_mob_leave(mob/living/affected_mob)
	if(!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/human = affected_mob
	human.dna.species.brutemod += 0.1
	human.dna.species.burnmod += 0.1

/obj/structure/slime_crystal/rainbow
	colour = SLIME_TYPE_RAINBOW
	uses_process = FALSE
	var/list/inserted_cores = list()

/obj/structure/slime_crystal/rainbow/Initialize(mapload)
	. = ..()
	for(var/X in subtypesof(/obj/item/slimecross/crystalline) - /obj/item/slimecross/crystalline/rainbow)
		inserted_cores[X] = FALSE

/obj/structure/slime_crystal/rainbow/attacked_by(obj/item/I, mob/living/user)
	. = ..()

	if(!istype(I,/obj/item/slimecross/crystalline) || istype(I,/obj/item/slimecross/crystalline/rainbow))
		return

	var/obj/item/slimecross/crystalline/slimecross = I

	if(inserted_cores[slimecross.type])
		return

	inserted_cores[slimecross.type] = new slimecross.crystal_type(get_turf(src),src)
	qdel(slimecross)

/obj/structure/slime_crystal/rainbow/Destroy()
	for(var/X in inserted_cores)
		if(inserted_cores[X])
			var/obj/structure/slime_crystal/SC = inserted_cores[X]
			SC.master_crystal_destruction()
	return ..()

/obj/structure/slime_crystal/rainbow/attack_hand(mob/user, list/modifiers)
	for(var/X in inserted_cores)
		if(inserted_cores[X])
			var/obj/structure/slime_crystal/SC = inserted_cores[X]
			SC.attack_hand(user)
	. = ..()

/obj/structure/slime_crystal/rainbow/attacked_by(obj/item/I, mob/living/user)
	for(var/X in inserted_cores)
		if(inserted_cores[X])
			var/obj/structure/slime_crystal/SC = inserted_cores[X]
			SC.attacked_by(user)
	. = ..()
