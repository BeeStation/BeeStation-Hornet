/datum/job/clown
	title = JOB_NAME_CLOWN
	description = "Be the life and soul of the station. Entertain the crew with your hilarious jokes and silly antics, including slipping, pie-ing and honking around. Remember your job is to keep things funny for others, not just yourself."
	department_for_prefs = DEPT_NAME_SERVICE
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	faction = "Station"
	total_positions = 1
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/clown

	base_access = list(
		ACCESS_THEATRE,
		ACCESS_SERVICE,
	)
	extra_access = list()

	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_MINIMAL)


	display_order = JOB_DISPLAY_ORDER_CLOWN
	rpg_title = "Jester"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/honk
	)

	minimal_lightup_areas = list(/area/crew_quarters/theatre)

	manuscript_jobs = list(
		JOB_NAME_CLOWN,
		JOB_NAME_BOTANIST // because banana
	)

/datum/job/clown/after_spawn(mob/living/carbon/human/H, mob/M, latejoin = FALSE, client/preference_source, on_dummy = FALSE)
	. = ..()
	if(!ishuman(H))
		return
	if(!M.client || on_dummy)
		return
	H.apply_pref_name(/datum/preference/name/clown, preference_source)


/datum/outfit/job/clown
	name = JOB_NAME_CLOWN
	jobtype = /datum/job/clown

	id = /obj/item/card/id/job/clown
	belt = /obj/item/modular_computer/tablet/pda/preset/clown
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/food/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/food/pie/cream = 1,
		/obj/item/megaphone/clown = 1,
		)

	implants = list(/obj/item/implant/sad_trombone)

	backpack = /obj/item/storage/backpack/clown
	satchel = /obj/item/storage/backpack/clown
	duffelbag = /obj/item/storage/backpack/duffelbag/clown //strangely has a duffel

	box = /obj/item/storage/box/survival/hug

	chameleon_extras = /obj/item/stamp/clown

/datum/outfit/job/clown/mod
	name = "Clown (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/cosmohonk
	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/job/clown/pre_equip(mob/living/carbon/human/H, visuals_only)
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_BANANIUM_SHIPMENTS))
		backpack_contents[/obj/item/stack/sheet/mineral/bananium/five] = 1

/datum/outfit/job/clown/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	if(visuals_only)
		return

	H.fully_replace_character_name(H.real_name, pick(GLOB.clown_names)) //rename the mob AFTER they're equipped so their ID gets updated properly.
	H.dna.add_mutation(/datum/mutation/clumsy)
	ADD_TRAIT(H, TRAIT_NAIVE, JOB_TRAIT)
	H.faction |= FACTION_CLOWN
