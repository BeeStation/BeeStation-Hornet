/datum/techweb_node/clown
	tech_tier = 2
	display_name = "Clown Technology"
	description = "Honk?!"
	prerequisite_nodes = list(/datum/techweb_node/base)
	unlocked_designs = list(
		/datum/design/clown_car,
		/datum/design/air_horn,
		/datum/design/borg_transform_clown,
		/datum/design/honkmine,
		/datum/design/honk_chassis,
		/datum/design/honk_head,
		/datum/design/honk_left_arm,
		/datum/design/honk_left_leg,
		/datum/design/honk_right_arm,
		/datum/design/honk_right_leg,
		/datum/design/honk_torso,
		/datum/design/board/honker_main,
		/datum/design/board/honker_peri,
		/datum/design/board/honker_targ,
		/datum/design/implant_sadtrombone,
		/datum/design/mech_banana_mortar,
		/datum/design/mech_honker,
		/datum/design/mech_mousetrap_mortar,
		/datum/design/mech_punching_glove,
		/datum/design/shotgun_honk_slug,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SERVICE, RADIO_CHANNEL_SECURITY)

/datum/techweb_node/sanitation
	tech_tier = 1
	display_name = "Advanced Sanitation Technology"
	description = "Clean things better, faster, stronger, and harder!"
	prerequisite_nodes = list(/datum/techweb_node/adv_engi)
	unlocked_designs = list(
		/datum/design/advmop,
		/datum/design/beartrap,
		/datum/design/blutrash,
		/datum/design/buffer,
		/datum/design/light_replacer_bluespace,
		/datum/design/spraybottle,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SERVICE)

/datum/techweb_node/botany
	tech_tier = 1
	display_name = "Botanical Engineering"
	description = "Botanical tools"
	prerequisite_nodes = list(/datum/techweb_node/adv_engi, /datum/techweb_node/biotech)
	unlocked_designs = list(
		/datum/design/board/biogenerator,
		/datum/design/diskplantgene,
		/datum/design/flora_gun,
		/datum/design/board/hydroponics,
		/datum/design/board/plantgenes,
		/datum/design/portaseeder,
		/datum/design/board/seed_extractor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SERVICE)
