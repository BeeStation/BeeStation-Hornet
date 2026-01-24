/datum/job/chaplain
	title = JOB_NAME_CHAPLAIN
	description = "Tend to the spiritual well-being of the crew, conduct rites and rituals in your Chapel, exorcise evil spirits and other supernatural beings."
	department_for_prefs = DEPT_NAME_CIVILIAN
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	faction = "Station"
	total_positions = 1
	selection_color = "#dddddd"
	exp_requirements = 60
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/chaplain

	base_access = list(ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_MORGUE, ACCESS_THEATRE)
	extra_access = list()

	departments = DEPT_BITFLAG_CIV
	bank_account_department = ACCOUNT_CIV_BITFLAG
	payment_per_department = list(ACCOUNT_CIV_ID = PAYCHECK_EASY)


	display_order = JOB_DISPLAY_ORDER_CHAPLAIN
	rpg_title = "Paladin"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/chaplain
	)

	minimal_lightup_areas = list(
		/area/chapel,
		/area/medical/morgue,
		/area/crew_quarters/theatre
	)

	manuscript_jobs = list(
		JOB_NAME_CHAPLAIN,
		JOB_NAME_BOTANIST // in a sense of religion
	)

/datum/job/chaplain/after_spawn(mob/living/H, mob/M, latejoin = FALSE, client/preference_source, on_dummy = FALSE)
	. = ..()
	if(!M.client || on_dummy)
		return

	var/obj/item/storage/book/bible/booze/B = new

	if(GLOB.religion)
		H.mind?.holy_role = HOLY_ROLE_PRIEST
		B.deity_name = GLOB.deity
		B.name = GLOB.bible_name
		B.icon_state = GLOB.bible_icon_state
		B.inhand_icon_state = GLOB.bible_inhand_icon_state
		to_chat(H, "There is already an established religion onboard the station. You are an acolyte of [GLOB.deity]. Defer to the Chaplain.")
		H.equip_to_slot_or_del(B, ITEM_SLOT_BACKPACK)
		GLOB.religious_sect?.on_conversion(H)
		return
	H.mind?.holy_role = HOLY_ROLE_HIGHPRIEST

	var/new_religion = preference_source?.prefs?.read_character_preference(/datum/preference/name/religion) || DEFAULT_RELIGION
	var/new_deity = preference_source?.prefs?.read_character_preference(/datum/preference/name/deity) || DEFAULT_DEITY

	B.deity_name = new_deity

	switch(LOWER_TEXT(new_religion))
		if("christianity") // DEFAULT_RELIGION
			B.name = pick("The Holy Bible","The Dead Sea Scrolls")
		if("buddhism")
			B.name = "The Sutras"
		if("clownism","honkmother","honk","honkism","comedy")
			B.name = pick("The Holy Joke Book", "Just a Prank", "Hymns to the Honkmother")
		if("chaos")
			B.name = "The Book of Lorgar"
		if("cthulhu")
			B.name = "The Necronomicon"
		if("hinduism")
			B.name = "The Vedas"
		if("imperium")
			B.name = "Uplifting Primer"
		if("islam")
			B.name = "Quran"
		if("judaism")
			B.name = "The Torah"
		if("lampism")
			B.name = "Fluorescent Incandescence"
		if("monkeyism","apism","gorillism","primatism")
			B.name = pick("Going Bananas", "Bananas Out For Harambe")
		if("mormonism")
			B.name = "The Book of Mormon"
		if("pastafarianism")
			B.name = "The Gospel of the Flying Spaghetti Monster"
		if("rastafarianism","rasta")
			B.name = "The Holy Piby"
		if("satanism")
			B.name = "The Unholy Bible"
		if("science")
			B.name = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
		if("scientology")
			B.name = pick("The Biography of L. Ron Hubbard","Dianetics")
		if("servicianism", "partying")
			B.name = "The Tenets of Servicia"
			B.deity_name = pick("Servicia", "Space Bacchus", "Space Dionysus")
			B.desc = "Happy, Full, Clean. Live it and give it."
		if("subgenius")
			B.name = "Book of the SubGenius"
		if("toolboxia","greytide")
			B.name = pick("Toolbox Manifesto","iGlove Assistants")
		if("weeaboo","kawaii")
			B.name = pick("Fanfiction Compendium","Japanese for Dummies","The Manganomicon","Establishing Your O.T.P")
		else
			B.name = preference_source?.prefs?.read_character_preference(/datum/preference/name/bible) || "The Holy Book of [new_religion]"

	GLOB.religion = new_religion
	GLOB.bible_name = B.name
	GLOB.deity = B.deity_name

	H.equip_to_slot_or_del(B, ITEM_SLOT_BACKPACK)

	SSblackbox.record_feedback("text", "religion_name", 1, "[new_religion]", 1)
	SSblackbox.record_feedback("text", "religion_deity", 1, "[new_deity]", 1)

/datum/outfit/job/chaplain
	name = JOB_NAME_CHAPLAIN
	jobtype = /datum/job/chaplain

	id = /obj/item/card/id/job/chaplain
	belt = /obj/item/modular_computer/tablet/pda/preset/chaplain
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	backpack_contents = list(
		/obj/item/nullrod = 1,
		/obj/item/choice_beacon/radial/holy = 1,
		/obj/item/camera/spooky = 1,
		/obj/item/stamp/chap=1
	)
	backpack = /obj/item/storage/backpack/cultpack
	satchel = /obj/item/storage/backpack/cultpack
