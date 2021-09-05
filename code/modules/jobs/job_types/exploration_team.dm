/datum/job/exploration
	title = "Exploration Crew"
	flag = EXPLORATION_CREW
	department_head = list("Research Director")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"
	chat_color = "#85d8b8"

	outfit = /datum/outfit/job/exploration

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH, ACCESS_EXPLORATION, ACCESS_TOX, ACCESS_MECH_SCIENCE, ACCESS_XENOBIOLOGY)
	minimal_access = list(ACCESS_RESEARCH, ACCESS_EXPLORATION, ACCESS_TOX, ACCESS_MECH_SCIENCE)
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SCI

	display_order = JOB_DISPLAY_ORDER_EXPLORATION
	departments = DEPARTMENT_SCIENCE

/datum/job/exploration/equip(mob/living/carbon/human/H, visualsOnly, announce, latejoin, datum/outfit/outfit_override, client/preference_source)
	if(outfit_override)
		return ..()
	if(visualsOnly || latejoin)
		return ..()
	var/static/exploration_job_id = 0
	exploration_job_id ++
	switch(exploration_job_id)
		//Scientist is most important due to scanner
		if(1)
			to_chat(H, "<span class='notice big'>You are the exploration team's <span class'sciradio'>Scientist</span>!</span>")
			to_chat(H, "<span class='notice'>Scan undiscovered creates to gain discovery research points!</span>")
			outfit_override = /datum/outfit/job/exploration/scientist
		if(2)
			to_chat(H, "<span class='notice big'>You are the exploration team's <span class'medradio'>Medical Doctor</span>!</span>")
			to_chat(H, "<span class='notice'>Ensure your team's health by locating and healing injured team members.</span>")
			outfit_override = /datum/outfit/job/exploration/medic
		if(3)
			to_chat(H, "<span class='notice big'>You are the exploration team's <span class'engradio'>Engineer</span>!</span>")
			to_chat(H, "<span class='notice'>Create entry points with your explosives and maintain the hull of your ship.</span>")
			outfit_override = /datum/outfit/job/exploration/engineer
	. = ..(H, visualsOnly, announce, latejoin, outfit_override, preference_source)

/datum/outfit/job/exploration
	name = "Exploration Crew"
	jobtype = /datum/job/exploration

	id = /obj/item/card/id/job/exploration
	belt = /obj/item/pda/exploration
	ears = /obj/item/radio/headset/headset_exploration
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	uniform = /obj/item/clothing/under/rank/cargo/exploration
	backpack_contents = list(
		/obj/item/kitchen/knife/combat/survival=1,\
		/obj/item/stack/marker_beacon/thirty=1)
	l_pocket = /obj/item/gps/mining/exploration
	r_pocket = /obj/item/gun/energy/e_gun/mini/exploration

	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel/explorer
	duffelbag = /obj/item/storage/backpack/duffelbag

	chameleon_extras = /obj/item/gun/energy/e_gun/mini/exploration

/datum/outfit/job/exploration/engineer
	name = "Exploration Crew (Engineer)"

	belt = /obj/item/storage/belt/utility/full
	r_pocket = /obj/item/pda/exploration

	backpack_contents = list(
		/obj/item/kitchen/knife/combat/survival=1,
		/obj/item/stack/marker_beacon/thirty=1,
		/obj/item/gun/energy/e_gun/mini/exploration=1,
		/obj/item/grenade/exploration=3,				//Breaching charges for entering ruins
		/obj/item/exploration_detonator=1,				//Detonator for the breaching charges.
		/obj/item/discovery_scanner=1
	)

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering

/datum/outfit/job/exploration/scientist
	name = "Exploration Crew (Scientist)"

	glasses = /obj/item/clothing/glasses/science

	backpack_contents = list(
		/obj/item/kitchen/knife/combat/survival=1,
		/obj/item/stack/marker_beacon/thirty=1,
		/obj/item/discovery_scanner=1,
		/obj/item/sbeacondrop/exploration=1,			//Spawns in a bluespace beacon
		/obj/item/research_disk_pinpointer=1			//Locates research disks
	)

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox

/datum/outfit/job/exploration/medic
	name = "Exploration Crew (Medical Doctor)"

	backpack_contents = list(
		/obj/item/kitchen/knife/combat/survival=1,
		/obj/item/stack/marker_beacon/thirty=1,
		/obj/item/storage/firstaid/medical=1,
		/obj/item/pinpointer/crew=1,
		/obj/item/sensor_device=1,
		/obj/item/roller=1,
		/obj/item/discovery_scanner=1
	)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

/datum/outfit/job/exploration/hardsuit
	name = "Exploration Crew (Hardsuit)"
	suit = /obj/item/clothing/suit/space/hardsuit/exploration
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	mask = /obj/item/clothing/mask/breath
