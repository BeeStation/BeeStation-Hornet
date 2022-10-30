#define GROD_BRUTEMOD 1.1
#define GROD_BURNMOD 1.2
#define GROD_HEATMOD 1.3
#define GROD_COLDMOD 0.7
#define GROD_TOXMOD 0.8
#define GROD_STAMMOD 1.2

#define CROWNSPIDER_MAX_HEALTH 30
#define CROWNSPIDER_BASE_HEALTH 30

/datum/species/grod
	name = "\improper Grod"
	id = SPECIES_GROD
	bodyflag = FLAG_GROD
	sexes = FALSE
	default_color = "#00FF00"
	species_traits = list(NO_DNA_COPY, AGENDER, NOHUSK, NO_UNDERWEAR, NOEYESPRITES, MUTCOLORS)
	inherent_traits = list(TRAIT_NO_DEFIB, TRAIT_RESISTLOWPRESSURE, TRAIT_NOSLIPWATER, TRAIT_NEVER_STUBS)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	species_chest = /obj/item/bodypart/chest/grod
	species_head = /obj/item/bodypart/head/grod
	species_l_arm = /obj/item/bodypart/l_arm/grod
	species_r_arm = /obj/item/bodypart/r_arm/grod
	species_l_leg = /obj/item/bodypart/l_leg/grod
	species_r_leg = /obj/item/bodypart/r_leg/grod
	mutanttongue = /obj/item/organ/tongue/grod
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/plant
	mutant_bodyparts = list("grod_crown", "grod_marks", "grod_tail")
	default_features = list("grod_crown" = "Crown", "grod_marks" = "None", "grod_tail" = "Regular")
	mutant_brain = /obj/item/organ/brain/grod
	brutemod = GROD_BRUTEMOD
	burnmod = GROD_BURNMOD
	heatmod = GROD_HEATMOD
	coldmod = GROD_COLDMOD
	toxmod = GROD_TOXMOD
	staminamod = GROD_STAMMOD
	species_language_holder = /datum/language_holder/grod
	offset_features = list(OFFSET_LEFT_HAND = list(-1,-4), OFFSET_RIGHT_HAND = list(2,-4))
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | RACE_SWAP

	var/datum/action/innate/grod/crownspider/crownspider

/datum/species/grod/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.grod_first)]" //Alpha
	. += "[pick(GLOB.grod_middle)]" //Thra

	. += pick(" the", " of the") //Of the

	if(lastname) //Divine
		. += " [lastname]"
	else
		. += " [pick(GLOB.grod_last)]"

	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, lastname, ++attempts)

/datum/species/grod/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	if(!istype(H))
		return
	//color crown
	var/obj/item/organ/brain/grod/G = H.getorganslot(ORGAN_SLOT_BRAIN)
	G.color = H.dna.features["mcolor"]
	//Abilities
	H.AddComponent(/datum/component/grod_pockets)
	if(!crownspider)
		crownspider = new
		crownspider.Grant(H)

/datum/species/grod/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	if(crownspider)
		crownspider.Remove(H)
		QDEL_NULL(crownspider)

/datum/species/grod/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/pestkiller || chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return FALSE
	return ..()
/datum/action/innate/grod/crownspider
	name = "Detach Crown"
	desc = "Detach your crown from your current body. This should only be done in dire circumstances!"
	icon_icon = 'icons/mob/actions/actions_grod.dmi'
	button_icon_state = "crownspider"

/datum/action/innate/grod/crownspider/Grant()
	..()
	if(!isgrod(owner))
		return

/datum/action/innate/grod/crownspider/Activate()
	if(!isgrod(owner)) //Stop trying to break shit
		return
	var/mob/living/carbon/human/H = owner
	if(!istype(H.getorganslot(ORGAN_SLOT_BRAIN), /obj/item/organ/brain/grod))
		to_chat(H, "<span class = 'warning'>You dont have a crown! Contact a coder!</span>")
		return
	if(H.incapacitated())
		to_chat(H, "<span class='warning'>You cannot use this ability right now</span>")
		return
	if(alert("Are you sure you wish to leave your current body, this will cause massive damage to your Crown!",,"Yes", "No") == "No")
		return
	do_leave_body()

/datum/action/innate/grod/crownspider/proc/do_leave_body() //disconnect from body
	var/mob/living/carbon/human/H = owner
	var/datum/mind/M = H.mind
	var/list/organs = H.getorganszone(BODY_ZONE_HEAD, 1)
	var/turf = get_turf(H)

	for(var/obj/item/organ/brain/I in organs)
		I.Remove(H, 1)

	var/mob/living/simple_animal/hostile/crown_spider/crown = new(turf)

	crown.name = "[H.name]'s Crown"
	crown.color = "#" + H.dna.features["mcolor"]
	for(var/obj/item/organ/brain/I in organs)
		I.forceMove(crown)
		crown.health = crown.health*abs(1-(I.damage/I.maxHealth)) //Adjust crown-mob's health to match brain health

	crown.origin = M
	if(crown.origin)
		crown.origin.active = 1
		crown.origin.transfer_to(crown)
		to_chat(crown, "<span class='warning'>Your consiousness returns to its Crown and you leave your body!</span>")

/datum/species/grod/get_custom_icons(part)
	switch(part)
		if("head")
			return 'icons/mob/species/grod/onmob_grod_head.dmi'
		if("mask")
			return 'icons/mob/species/grod/onmob_grod_mask.dmi'
		if("gloves")
			return 'icons/mob/species/grod/onmob_grod_gloves.dmi'
		if("uniform")
			return 'icons/mob/species/grod/onmob_grod_under.dmi'
		if("ears")
			return 'icons/mob/species/grod/onmob_grod_ears.dmi'
		if("back")
			return 'icons/mob/species/grod/onmob_grod_back.dmi'
		if("shoes")
			return 'icons/mob/species/grod/onmob_grod_shoes.dmi'
		if("glasses")
			return 'icons/mob/species/grod/onmob_grod_glasses.dmi'
		if("neck")
			return 'icons/mob/species/grod/onmob_grod_neck.dmi'
		if("generic")
			return 'icons/mob/species/grod/onmob_grod_generic.dmi'
		if("belt")
			return 'icons/mob/species/grod/onmob_grod_belt.dmi'
		/*if("bloodmask") NOT READY
			return 'icons/mob/species/grod/bloodmask_grod.dmi'*/
		else
			return

/datum/species/grod/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(5)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return FALSE
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(10)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

/datum/species/grod/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	var/current_job = J.title
	var/datum/outfit/grod/O = new /datum/outfit/grod
	switch(current_job)
		if("Chaplain")
			O = new /datum/outfit/grod/chaplain

		if("Curator")
			O = new /datum/outfit/grod/curator

		if("Janitor")
			O = new /datum/outfit/grod/janitor

		if("Botanist")
			O = new /datum/outfit/grod/botanist

		if("Bartender")
			O = new /datum/outfit/grod/barman

		if("VIP")
			O = new /datum/outfit/grod/vip

		if("Debtor")
			O = new /datum/outfit/grod/debtor

		if("Cook")
			O = new /datum/outfit/grod/chef

		if("Security Officer")
			O = new /datum/outfit/grod/sec

		if("Deputy")
			O = new /datum/outfit/grod/sec

		if("Brig Physician")
			O = new /datum/outfit/grod/secmed

		if("Detective")
			O = new /datum/outfit/grod/detective

		if("Warden")
			O = new /datum/outfit/grod/warden

		if("Cargo Technician")
			O = new /datum/outfit/grod/cargo

		if("Quartermaster")
			O = new /datum/outfit/grod/qm

		if("Shaft Miner")
			O = new /datum/outfit/grod/miner

		if("Medical Doctor")
			O = new /datum/outfit/grod/md

		if("Paramedic")
			O = new /datum/outfit/grod/paramed

		if("Chemist")
			O = new /datum/outfit/grod/chem

		if("Geneticist")
			O = new /datum/outfit/grod/gene

		if("Roboticist")
			O = new /datum/outfit/grod/robo

		if("Virologist")
			O = new /datum/outfit/grod/viro

		if("Scientist")
			O = new /datum/outfit/grod/scientist

		if("Station Engineer")
			O = new /datum/outfit/grod/engineer

		if("Atmospheric Technician")
			O = new /datum/outfit/grod/atmos

		if("Captain")
			O = new /datum/outfit/grod/captain

		if("Chief Engineer")
			O = new /datum/outfit/grod/ce

		if("Chief Medical Officer")
			O = new /datum/outfit/grod/cmo

		if("Head of Security")
			O = new /datum/outfit/grod/hos

		if("Research Director")
			O = new /datum/outfit/grod/rd

		if("Head of Personnel")
			O = new /datum/outfit/grod/hop

		if("Clown")
			O = new /datum/outfit/grod/clown

		if("Mime")
			O = new /datum/outfit/grod/mime

		if("Assistant")
			O = new /datum/outfit/grod/assistant
	H.equipOutfit(O, visualsOnly)
	return 0

/datum/species/grod/get_item_offsets_for_index(var/i) //a fall-back incase the mob loses its dir tracking somehow
	switch(i)
		if(3) //odd = left hands
			return list("x" = -1, "y" = 5)
		if(4) //even = right hands
			return list("x" = 1, "y" = 5)
		else
			return

/datum/species/grod/get_item_offsets_for_dir(var/dir)
	////BOTTOM LEFT | BOTTOM RIGHT | TOP LEFT | TOP RIGHT
	switch(dir)
		if(SOUTH)
			return list(list("x" = -1, "y" = -4), list("x" = 2, "y" = -4), list("x" = -2, "y" = 1),list("x" = 3, "y" = 1))
		if(NORTH)
			return list(list("x" = 3, "y" = 0), list("x" = -2, "y" = 0), list("x" = 3, "y" = 5),list("x" = -2, "y" = 5))
		if(EAST)
			return list(list("x" = 4, "y" = -4), list("x" = 10, "y" = -3), list("x" = 6, "y" = 2),list("x" = 10, "y" = 1))
		if(WEST)
			return list(list("x" = -10, "y" = -3), list("x" = -4, "y" = -4), list("x" = -10, "y" = 1),list("x" = -6, "y" = 2))

///////Grod Crown////////
/mob/living/simple_animal/hostile/crown_spider
	name = "Crownspider"
	desc = "It looks like a Grod's crown..."
	icon = 'icons/mob/species/grod/crown_spider.dmi'
	icon_state = "crown_spider"
	icon_living = "crown_spider"
	icon_dead = "crown_spider_dead"
	gender = NEUTER
	health = CROWNSPIDER_MAX_HEALTH
	maxHealth = CROWNSPIDER_BASE_HEALTH
	melee_damage = 0
	attacktext = "pinches"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("squeaks")
	color = "#00FF00"
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'icons/mob/species/grod/crown_spider_worn.dmi'
	held_state = "crown_spider"
	initial_language_holder = /datum/language_holder/grodcrown //They can only speak Poh'lan in spider
	var/datum/mind/origin

	pass_flags = PASSMOB
	speed = 3
	can_be_held = TRUE

/mob/living/simple_animal/hostile/crown_spider/UnarmedAttack(atom/M)
	if(try_infect(M))
		return
	..()

/mob/living/simple_animal/hostile/crown_spider/MouseDrop(over)
	. = ..()
	try_infect(over)

/mob/living/simple_animal/hostile/crown_spider/proc/try_infect(atom/target) //default process before action
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.stat > CONSCIOUS && (alert("This one is no longer living. Are you sure we should infest it?",,"Yes", "No") == "No"))
			return
		if(H.getorganslot(ORGAN_SLOT_BRAIN))
			to_chat(src, "<span class='userdanger'>A foreign presence repels us from this body. Perhaps we should try to infest another?</span>")
			return
		Infect(H)
		return TRUE

	else if(istype(target, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/O = target
		for(var/obj/item/organ/brain/grod/brain in src)
			if(O.myseed)
				to_chat(src, "<span class='userdanger'>This tray is already in use!</span>")
				return
			O.myseed = brain.seed
			src.visible_message("<span class='danger'>[src] burrows into the hydroponics tray!</span>", "<span class='danger'>You borrow into the hydroponics tray, attempting to grow a new body!</span>")
			qdel(src)
		return TRUE

/mob/living/simple_animal/hostile/crown_spider/proc/Infect(mob/living/carbon/C)
	if(!origin)
		return
	for(var/obj/item/organ/I in src)
		I.Insert(C, 1)
		//Deal a minimum of 30 damage, if damage dealt is greater than 115, (116 will kill a brain), the amount of damage dealt will taper off until it's safe.
		//So 30 damage_to_deal at 90 I.damage would taper down to 25
		var/damage_to_deal = (maxHealth - health) * 4 > CROWNSPIDER_MAX_HEALTH ? (maxHealth - health) * 4 : CROWNSPIDER_MAX_HEALTH
		damage_to_deal = ((damage_to_deal+I.damage) < 115) ? damage_to_deal : damage_to_deal - ((damage_to_deal+I.damage)-115)
		I.damage += damage_to_deal
	if(!isgrod(C)) //Convert non-grod hosts to grods over time
		C.ForceContractDisease(new /datum/disease/transformation/grod())
	announce_infest(C)
	origin.transfer_to(C)
	C.key = origin.key
	qdel(src)

/mob/living/simple_animal/hostile/crown_spider/proc/announce_infest(mob/living/carbon/target)
	if(isgrod(target))
		src.visible_message("<span class='danger'>[src] burrows into [target], planting itself firmly into [target.p_their()] head!</span>")
	else
		src.visible_message("<span class='danger'>[src] burrows into [target]'s head!</span>")

/mob/living/simple_animal/hostile/crown_spider/death(gibbed)
	. = ..()
	var/obj/item/organ/brain/B = locate(/obj/item/organ/brain) in contents
	B.forceMove(get_turf(src))
	qdel(src)

//Caccoon for assimilation
/obj/structure/grod_caccoon
	name = "grod caccoon"
	desc = "A mysterious phenominom, rarely observed."
	icon = 'icons/mob/species/grod/bodyparts.dmi'
	icon_state = "caccoon"

/obj/structure/grod_caccoon/attack_hand(mob/user)
	..()
	if(prob(33))
		visible_message("<span class ='warning'>[user] rips the [src] open!</span>", "<span class ='warning'>You rip open the [src]!</span>")
		qdel(src)
	else
		Shake(5, 5, 2 SECONDS)
		visible_message("<span class ='warning'>[user] shakes the [src]!</span>", "<span class ='warning'>You shake the [src]!</span>")

/obj/structure/grod_caccoon/Destroy()
	for(var/atom/movable/AM in contents)
		visible_message("<span class ='warning'>[AM] emerges from the [src]!</span>")
		AM.forceMove(get_turf(src))
	..()
