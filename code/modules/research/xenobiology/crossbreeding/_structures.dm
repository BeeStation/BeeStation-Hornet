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
	///Used to determine wether we use view or range
	var/range_type = "range"
	///What color is it?
	var/colour

/obj/structure/slime_crystal/Initialize(obj/structure/slime_crystal/master_crystal)
	. = ..()
	if(master_crystal)
		invisibility = INVISIBILITY_MAXIMUM

	name =  colour + " slimic pylon"
	var/itemcolor = "#FFFFFF"
	switch(colour)
		if("orange")
			itemcolor = "#FFA500"
		if("purple")
			itemcolor = "#B19CD9"
		if("blue")
			itemcolor = "#ADD8E6"
		if("metal")
			itemcolor = "#7E7E7E"
		if("yellow")
			itemcolor = "#FFFF00"
		if("dark purple")
			itemcolor = "#551A8B"
		if("dark blue")
			itemcolor = "#0000FF"
		if("silver")
			itemcolor = "#D3D3D3"
		if("bluespace")
			itemcolor = "#32CD32"
		if("sepia")
			itemcolor = "#704214"
		if("cerulean")
			itemcolor = "#2956B2"
		if("pyrite")
			itemcolor = "#FAFAD2"
		if("red")
			itemcolor = "#FF0000"
		if("green")
			itemcolor = "#00FF00"
		if("pink")
			itemcolor = "#FF69B4"
		if("gold")
			itemcolor = "#FFD700"
		if("oil")
			itemcolor = "#505050"
		if("black")
			itemcolor = "#000000"
		if("light pink")
			itemcolor = "#FFB6C1"
		if("adamantine")
			itemcolor = "#008B8B"
	add_atom_colour(itemcolor, FIXED_COLOUR_PRIORITY)
	START_PROCESSING(SSobj,src)

/obj/structure/slime_crystal/Destroy()
	STOP_PROCESSING(SSobj,src)
	for(var/X in affected_mobs)
		on_mob_leave(X)
	return ..()

/obj/structure/slime_crystal/process()
	for(var/mob/living/mob_in_range in view_or_range(3,src,range_type))
		if(!(mob_in_range in affected_mobs))
			on_mob_enter(mob_in_range)
			affected_mobs[mob_in_range] = 0

		affected_mobs[mob_in_range]++
		on_mob_effect(mob_in_range)

	for(var/M in affected_mobs)
		if(get_dist(M,src) <= 5)
			continue
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
	colour = "grey"
	range_type = "view"

/obj/structure/slime_crystal/grey/on_mob_effect(mob/living/affected_mob)
	. = ..()
	if(!istype(affected_mob,/mob/living/simple_animal/slime))
		return
	var/mob/living/simple_animal/slime/slime_mob = affected_mob
	slime_mob.nutrition += 2

/obj/structure/slime_crystal/orange
	colour = "orange"
	range_type = "view"

/obj/structure/slime_crystal/orange/on_mob_effect(mob/living/affected_mob)
	. = ..()
	if(!istype(affected_mob,/mob/living/carbon))
		return
	var/mob/living/carbon/carbon_mob = affected_mob
	carbon_mob.fire_stacks++
	carbon_mob.IgniteMob()

/obj/structure/slime_crystal/orange/process()
	. = ..()
	var/turf/open/T = get_turf(src)
	if(!istype(T))
		return
	var/datum/gas_mixture/gas = T.return_air()
	gas.set_temperature(T0C + 200)
	T.air_update_turf()

/obj/structure/slime_crystal/purple
	colour = "purple"

	var/heal_amt = 2

/obj/structure/slime_crystal/purple/on_mob_effect(mob/living/affected_mob)
	. = ..()
	if(!istype(affected_mob,/mob/living/carbon))
		return
	var/mob/living/carbon/carbon_mob = affected_mob
	var/rand_dam_type = rand(0,10)

	switch(rand_dam_type)
		if(0)
			carbon_mob.adjustBruteLoss(-heal_amt)
		if(1)
			carbon_mob.adjustFireLoss(-heal_amt)
		if(2)
			carbon_mob.adjustOxyLoss(-heal_amt)
		if(3)
			carbon_mob.adjustToxLoss(-heal_amt)
		if(4)
			carbon_mob.adjustCloneLoss(-heal_amt)
		if(5)
			carbon_mob.adjustStaminaLoss(-heal_amt)
		if(6 to 10)
			carbon_mob.adjustOrganLoss(pick(ORGAN_SLOT_BRAIN,ORGAN_SLOT_HEART,ORGAN_SLOT_LIVER,ORGAN_SLOT_LUNGS),-heal_amt)

/obj/structure/slime_crystal/blue
	colour = "blue"
	range_type = "view"

/obj/structure/slime_crystal/blue/process()
	for(var/turf/open/T in view(2,src))
		if(isspaceturf(T))
			continue
		var/datum/gas_mixture/gas = T.return_air()
		gas.parse_gas_string(OPENTURF_DEFAULT_ATMOS)
		T.air_update_turf()

/obj/structure/slime_crystal/metal
	colour = "metal"

	var/heal_amt = 1

/obj/structure/slime_crystal/metal/on_mob_effect(mob/living/affected_mob)
	. = ..()
	if(!iscyborg(affected_mob))
		return
	var/mob/living/silicon/borgo = affected_mob
	borgo.adjustBruteLoss(-heal_amt)

/obj/structure/slime_crystal/yellow
	colour = "yellow"
	light_color = LIGHT_COLOR_YELLOW //a good, sickly atmosphere
	light_power = 0.75

/obj/structure/slime_crystal/yellow/Initialize()
	. = ..()
	set_light(3)

/obj/structure/slime_crystal/yellow/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I,/obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/cell = I
		//Punishment for greed
		if(cell.charge == cell.maxcharge)
			cell.explode()
			return
		cell.give(cell.maxcharge)

/obj/structure/slime_crystal/darkpurple
	colour = "dark purple"

/obj/structure/slime_crystal/darkpurple/process()
	var/turf/T = get_turf(src)
	if(!istype(T,/turf/open))
		return
	var/turf/open/open_turf = T
	var/datum/gas_mixture/air = open_turf.return_air()

	if(air.get_moles(/datum/gas/plasma) > 15)
		air.adjust_moles(/datum/gas/plasma,-15)
		new /obj/item/stack/sheet/mineral/plasma(open_turf)

/obj/structure/slime_crystal/darkpurple/Destroy()
	atmos_spawn_air("plasma=[20];TEMP=[500]")
	return ..()

/obj/structure/slime_crystal/darkblue
	colour = "dark blue"

/obj/structure/slime_crystal/darkblue/process()
	var/list/listie = range(5,src)
	for(var/turf/open/T in listie)
		if(prob(75))
			continue
		var/turf/open/open_turf = T
		open_turf.MakeDry(TURF_WET_LUBE)

	for(var/obj/item/trash/trashie in listie)
		if(prob(75))
			continue
		qdel(trashie)

/obj/structure/slime_crystal/silver
	colour = "silver"

/obj/structure/slime_crystal/silver/process()
	for(var/obj/machinery/hydroponics/hydr in range(5,src))
		hydr.weedlevel = 0
		hydr.pestlevel = 0
		hydr.age++

/obj/structure/slime_crystal/bluespace
	colour = "bluespace"
	density = FALSE
	///Is it in use?
	var/in_use = FALSE

/obj/structure/slime_crystal/bluespace/Initialize()
	. = ..()
	GLOB.bluespace_slime_crystals += src

/obj/structure/slime_crystal/bluespace/Destroy()
	GLOB.bluespace_slime_crystals -= src
	return ..()

/obj/structure/slime_crystal/bluespace/attack_hand(mob/user)

	if(in_use)
		return

	var/list/local_bs_list = GLOB.bluespace_slime_crystals.Copy()
	local_bs_list -= src
	if(local_bs_list.len == 0)
		return ..()

	if(local_bs_list.len == 1)
		do_teleport(user ,local_bs_list[1])
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

	if(!chosen_input)
		return

	do_teleport(user ,assoc_list[chosen_input])

/obj/structure/slime_crystal/sepia
	colour = "sepia"

/obj/structure/slime_crystal/sepia/on_mob_enter(mob/living/affected_mob)
	. = ..()
	ADD_TRAIT(affected_mob,TRAIT_NOBREATH,type)
	ADD_TRAIT(affected_mob,TRAIT_NOCRITDAMAGE,type)
	ADD_TRAIT(affected_mob,TRAIT_RESISTLOWPRESSURE,type)
	ADD_TRAIT(affected_mob,TRAIT_RESISTHIGHPRESSURE,type)
	ADD_TRAIT(affected_mob,TRAIT_NOSOFTCRIT,type)
	ADD_TRAIT(affected_mob,TRAIT_NOHARDCRIT,type)

/obj/structure/slime_crystal/sepia/on_mob_leave(mob/living/affected_mob)
	. = ..()
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

/obj/structure/cerulean_slime_crystal/Initialize()
	. = ..()
	transform *= 1/(max_stage-1)
	stage_growth()

/obj/structure/cerulean_slime_crystal/proc/stage_growth()
	if(stage == max_stage)
		return

	stage++

	if(stage == 4)
		density = TRUE

	var/matrix/M = new
	M.Scale(1/(max_stage-1) * stage)

	animate(src,transform = matrix(), time = 60 SECONDS)

	addtimer(CALLBACK(src,.proc/stage_growth),60 SECONDS)

/obj/structure/cerulean_slime_crystal/Destroy()
	new /obj/item/cerulean_slime_crystal(get_turf(src),stage)
	return ..()

/obj/structure/slime_crystal/cerulean
	colour = "cerulean"

/obj/structure/slime_crystal/cerulean/process()
	for(var/turf/T in orange(1,src))
		if(prob(10))
			var/obj/structure/cerulean_slime_crystal/CSC = locate() in T
			if(CSC)
				continue
			new /obj/structure/cerulean_slime_crystal()

/obj/structure/slime_crystal/pyrite
	colour = "pyrite"

/obj/structure/slime_crystal/pyrite/Initialize()
	. = ..()
	change_colour()

/obj/structure/slime_crystal/pyrite/process()
	return PROCESS_KILL

/obj/structure/slime_crystal/pyrite/proc/change_colour()
	for(var/turf/T in RANGE_TURFS(4,src))
		T.add_atom_colour(get_colour(), FIXED_COLOUR_PRIORITY)

	addtimer(CALLBACK(src,.proc/change_colour),rand(5 SECONDS,20 SECONDS))

/obj/structure/slime_crystal/pyrite/proc/get_colour()
	var/itemcolor = "#FFFFFF"
	var/C = rand(0,19)
	switch(C)
		if(0)
			itemcolor = "#FFA500"
		if(1)
			itemcolor = "#B19CD9"
		if(2)
			itemcolor = "#ADD8E6"
		if(3)
			itemcolor = "#7E7E7E"
		if(4)
			itemcolor = "#FFFF00"
		if(5)
			itemcolor = "#551A8B"
		if(6)
			itemcolor = "#0000FF"
		if(7)
			itemcolor = "#D3D3D3"
		if(8)
			itemcolor = "#32CD32"
		if(9)
			itemcolor = "#704214"
		if(10)
			itemcolor = "#2956B2"
		if(11)
			itemcolor = "#FAFAD2"
		if(12)
			itemcolor = "#FF0000"
		if(13)
			itemcolor = "#00FF00"
		if(14)
			itemcolor = "#FF69B4"
		if(15)
			itemcolor = "#FFD700"
		if(16)
			itemcolor = "#505050"
		if(17)
			itemcolor = "#000000"
		if(18)
			itemcolor = "#FFB6C1"
		if(19)
			itemcolor = "#008B8B"
	return itemcolor

/obj/structure/slime_crystal/red
	colour = "red"

	var/blood_amt = 0

	var/max_blood_amt = 300

/obj/structure/slime_crystal/red/examine(mob/user)
	. = ..()
	. += "It has [blood_amt] u of blood."

/obj/structure/slime_crystal/red/process()

	if(blood_amt == max_blood_amt)
		return

	for(var/obj/effect/decal/cleanable/blood/B in range(3,src))
		qdel(B)

		blood_amt++
		if(blood_amt == max_blood_amt)
			return

/obj/structure/slime_crystal/red/attack_hand(mob/user)
	if(blood_amt < 100)
		return ..()

	blood_amt -= 100
	var/type = pick(/obj/item/reagent_containers/food/snacks/meat/slab,/obj/item/organ/heart,/obj/item/organ/lungs,/obj/item/organ/liver,/obj/item/organ/eyes,/obj/item/organ/tongue,/obj/item/organ/stomach,/obj/item/organ/ears)
	new type(get_turf(src))

/obj/structure/slime_crystal/red/attacked_by(obj/item/I, mob/living/user)
	if(blood_amt < 10)
		return ..()

	if(!istype(I,/obj/item/reagent_containers/glass/beaker))
		return ..()

	var/obj/item/reagent_containers/glass/beaker/item_beaker = I

	if(!item_beaker.is_refillable() || (item_beaker.reagents.total_volume + 10 > item_beaker.reagents.maximum_volume))
		return ..()
	blood_amt -= 10
	item_beaker.reagents.add_reagent(/datum/reagent/blood,10)

/obj/structure/slime_crystal/green
	colour = "green"
	var/datum/mutation/stored_mutation

/obj/structure/slime_crystal/green/examine(mob/user)
	. = ..()
	if(stored_mutation)
		. += "It currently stores [stored_mutation.name]"
	else
		. += "It doesn't hold any mutations"

/obj/structure/slime_crystal/green/attack_hand(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	var/list/mutation_list = human_user.dna.mutations
	stored_mutation = pick(mutation_list)
	stored_mutation = stored_mutation.type

/obj/structure/slime_crystal/green/on_mob_effect(mob/living/affected_mob)
	. = ..()
	if(!ishuman(affected_mob))
		return
	var/mob/living/carbon/human/human_mob = affected_mob
	human_mob.dna.add_mutation(stored_mutation)
	if(!prob(5))
		return
	var/mutation = pick(human_mob.dna.mutations)
	human_mob.dna.remove_mutation(mutation)

/obj/structure/slime_crystal/green/on_mob_leave(mob/living/affected_mob)
	. = ..()
	if(!ishuman(affected_mob))
		return
	var/mob/living/carbon/human/human_mob = affected_mob
	human_mob.dna.remove_mutation(stored_mutation)

/obj/structure/slime_crystal/pink
	colour = "pink"

/obj/structure/slime_crystal/pink/on_mob_enter(mob/living/affected_mob)
	. = ..()
	ADD_TRAIT(affected_mob,TRAIT_PACIFISM,MAGIC_TRAIT)

/obj/structure/slime_crystal/pink/on_mob_leave(mob/living/affected_mob)
	. = ..()
	REMOVE_TRAIT(affected_mob,TRAIT_PACIFISM,MAGIC_TRAIT)

/obj/structure/slime_crystal/gold
	colour = "gold"

/obj/structure/slime_crystal/gold/attack_hand(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_mob = user
	var/mob/living/simple_animal/pet/chosen_pet = pick(subtypesof(/mob/living/simple_animal/pet))
	chosen_pet = new chosen_pet(get_turf(human_mob))
	human_mob.forceMove(chosen_pet)
	human_mob.mind.transfer_to(chosen_pet)

/obj/structure/slime_crystal/gold/on_mob_leave(mob/living/affected_mob)
	. = ..()
	if(!istype(affected_mob,/mob/living/simple_animal/pet))
		return

	var/mob/living/carbon/human/human_mob = locate() in affected_mob

	if(!human_mob)
		return

	affected_mob.mind.transfer_to(human_mob)
	human_mob.forceMove(get_turf(affected_mob))
	qdel(affected_mob)

/obj/structure/slime_crystal/oil
	colour = "oil"

/obj/structure/slime_crystal/oil/process()
	for(var/T in RANGE_TURFS(3,src))
		if(!isopenturf(T))
			continue
		var/turf/open/turf_in_range = T
		turf_in_range.MakeSlippery(TURF_WET_LUBE,5 SECONDS)

/obj/structure/slime_crystal/black
	colour = "black"

/obj/structure/slime_crystal/black/on_mob_effect(mob/living/affected_mob)
	. = ..()
	if(!ishuman(affected_mob) || isjellyperson(affected_mob))
		return

	if(affected_mobs[affected_mob] < 60) //Around 2 minutes
		return

	var/mob/living/carbon/human/human_transformed = affected_mob
	human_transformed.set_species(pick(typesof(/datum/species/jelly)))

/obj/structure/slime_crystal/lightpink
	colour = "light pink"

/obj/structure/slime_crystal/lightpink/attack_ghost(mob/user)
	. = ..()
	var/mob/living/simple_animal/hostile/lightgeist/L = new(get_turf(src))
	L.ckey = user.ckey
	affected_mobs[L] = 0

/obj/structure/slime_crystal/lightpink/on_mob_leave(mob/living/affected_mob)
	. = ..()
	if(istype(affected_mob,/mob/living/simple_animal/hostile/lightgeist))
		affected_mob.ghostize(TRUE)
		qdel(affected_mob)

/obj/structure/slime_crystal/adamantine
	colour = "adamantine"

/obj/structure/slime_crystal/adamantine/on_mob_enter(mob/living/affected_mob)
	. = ..()
	if(!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/human = affected_mob
	human.dna.species.brutemod *= 0.9
	human.dna.species.burnmod *= 0.9

/obj/structure/slime_crystal/adamantine/on_mob_leave(mob/living/affected_mob)
	. = ..()
	if(!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/human = affected_mob
	human.dna.species.brutemod /= 0.9
	human.dna.species.burnmod /= 0.9

/obj/structure/slime_crystal/rainbow
	colour = "rainbow"
	var/list/inserted_cores = list()

/obj/structure/slime_crystal/rainbow/Initialize()
	. = ..()
	for(var/X in subtypesof(/obj/item/slimecross/crystalized) - /obj/item/slimecross/crystalized/rainbow)
		inserted_cores[X] = FALSE

/obj/structure/slime_crystal/rainbow/attacked_by(obj/item/I, mob/living/user)
	. = ..()

	if(!istype(I,/obj/item/slimecross/crystalized) || istype(I,/obj/item/slimecross/crystalized/rainbow))
		return

	var/obj/item/slimecross/crystalized/slimecross = I

	if(inserted_cores[slimecross.type])
		return

	inserted_cores[slimecross.type] = new slimecross.crystal_type(get_turf(src),src)
	qdel(slimecross)

/obj/structure/slime_crystal/rainbow/Destroy()
	for(var/X in inserted_cores)
		if(inserted_cores[X])
			var/obj/structure/slime_crystal/SC = X
			SC.master_crystal_destruction()
	return ..()
