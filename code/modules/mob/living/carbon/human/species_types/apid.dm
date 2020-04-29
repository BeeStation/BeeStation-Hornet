/datum/species/apid
	// Beepeople, god damn it. It's hip, and alive!
	name = "Apids"
	id = "apid"
	say_mod = "buzzes"
	default_color = "FFE800"
	species_traits = list(LIPS, NOEYESPRITES)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_BUG)
	mutanttongue = /obj/item/organ/tongue/bee
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/apid
	liked_food = VEGETABLES | FRUIT
	disliked_food = GROSS | DAIRY
	toxic_food = MEAT | RAW
	mutanteyes = /obj/item/organ/eyes/apid
	mutantlungs = /obj/item/organ/lungs/apid
	heatmod = 2
	coldmod = 2
	burnmod = 2
	staminamod = 2
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

/datum/species/apid/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	H.grant_language(/datum/language/apidite)

/datum/species/apid/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_apid_name(gender)

	var/randname = apid_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/apid/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	var/obj/item/clothing/neck = C.get_item_by_slot(SLOT_NECK)
	if(!istype(neck, /obj/item/clothing/shoes/bhop/apid))
		if(C.dropItemToGround(neck))
			C.equip_to_slot_or_del(new /obj/item/clothing/shoes/bhop/apid(C), SLOT_NECK)

/datum/species/apid/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 29 //Bees get x30 damage from flyswatters
	return 0

/datum/species/apid/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)

/obj/item/clothing/shoes/bhop/apid
	name = "apid wings"
	desc = "Apid wings that allow for the ability to dash forward."
	icon = 'icons/mob/neck.dmi'
	icon_state = "apid_wings"
	item_state = "apid_wings"
	item_color = null
	resistance_flags = null
	pocket_storage_component_path = null
	actions_types = list(/datum/action/item_action/bhop/apid)
	jumpdistance = 5
	jumpspeed = 3
	recharging_rate = 70
	recharging_time = 0
	slot_flags = ITEM_SLOT_NECK

/obj/item/clothing/shoes/bhop/apid/ui_action_click(mob/user, action)
	if(!isliving(user))
		return

	if(recharging_time > world.time)
		to_chat(user, "<span class='warning'>The wings aren't ready to dash yet!</span>")
		return

	var/turf/T = get_turf(user)
	var/datum/gas_mixture/environment = T.return_air()

	if(environment && !(environment.return_pressure() > 30))
		to_chat(user, "<span class='warning'>The atmosphere is too thin for you to dash!</span>")
		return

	var/atom/target = get_edge_target_turf(user, user.dir) //gets the user's direction

	if (user.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE))
		playsound(src, 'sound/creatures/bee.ogg', 50, 1, 1)
		user.visible_message("<span class='warning'>[usr] dashes forward into the air!</span>")
		recharging_time = world.time + recharging_rate
	else
		to_chat(user, "<span class='warning'>Something prevents you from dashing forward!</span>")

/obj/item/clothing/shoes/bhop/apid/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "apidwings")

/datum/species/apid/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.equip_to_slot_or_del(new /obj/item/clothing/shoes/bhop/apid(C), SLOT_NECK)
