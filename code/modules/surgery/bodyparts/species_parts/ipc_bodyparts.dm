/obj/item/bodypart/head/ipc
	static_icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth" //Overriden in /species/ipc/replace_body()
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC | BODYTYPE_BOXHEAD
	light_brute_msg = "scratched"
	medium_brute_msg = "dented"
	heavy_brute_msg = "sheared"

	light_burn_msg = "burned"
	medium_burn_msg = "scorched"
	heavy_burn_msg = "seared"

	organ_slots = list(
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_HUD,
		ORGAN_SLOT_TONGUE,
		ORGAN_SLOT_VOICE
	)

/obj/item/bodypart/head/ipc/setup_injury_trees()
	return	// TODO: IPC trees are incomplete as they would need to be unique from organics

/obj/item/bodypart/chest/ipc
	static_icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC

	light_brute_msg = "scratched"
	medium_brute_msg = "dented"
	heavy_brute_msg = "sheared"

	light_burn_msg = "burned"
	medium_burn_msg = "scorched"
	heavy_burn_msg = "seared"

	organ_slots = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_BRAIN_ANTIDROP,
		ORGAN_SLOT_BRAIN_ANTISTUN,
		ORGAN_SLOT_BRAIN_SURGICAL_IMPLANT,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_STOMACH_AID,
		ORGAN_SLOT_WINGS,
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_THRUSTERS,
		ORGAN_SLOT_HEART_AID,
		ORGAN_SLOT_TAIL
	)

/obj/item/bodypart/chest/ipc/setup_injury_trees()
	return	// TODO: IPC trees are incomplete as they would need to be unique from organics

/obj/item/bodypart/l_arm/ipc
	static_icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC

	light_brute_msg = "scratched"
	medium_brute_msg = "dented"
	heavy_brute_msg = "sheared"

	light_burn_msg = "burned"
	medium_burn_msg = "scorched"
	heavy_burn_msg = "seared"

/obj/item/bodypart/l_arm/ipc/setup_injury_trees()
	return	// TODO: IPC trees are incomplete as they would need to be unique from organics

/obj/item/bodypart/r_arm/ipc
	static_icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC

	light_brute_msg = "scratched"
	medium_brute_msg = "dented"
	heavy_brute_msg = "sheared"

	light_burn_msg = "burned"
	medium_burn_msg = "scorched"
	heavy_burn_msg = "seared"

/obj/item/bodypart/r_arm/ipc/setup_injury_trees()
	return	// TODO: IPC trees are incomplete as they would need to be unique from organics

/obj/item/bodypart/l_leg/ipc
	static_icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC

	light_brute_msg = "scratched"
	medium_brute_msg = "dented"
	heavy_brute_msg = "sheared"

	light_burn_msg = "burned"
	medium_burn_msg = "scorched"
	heavy_burn_msg = "seared"

/obj/item/bodypart/l_leg/ipc/setup_injury_trees()
	return	// TODO: IPC trees are incomplete as they would need to be unique from organics

/obj/item/bodypart/r_leg/ipc
	static_icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC

	light_brute_msg = "scratched"
	medium_brute_msg = "dented"
	heavy_brute_msg = "sheared"

	light_burn_msg = "burned"
	medium_burn_msg = "scorched"
	heavy_burn_msg = "seared"

/obj/item/bodypart/r_leg/ipc/setup_injury_trees()
	return	// TODO: IPC trees are incomplete as they would need to be unique from organics
