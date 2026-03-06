/datum/job/mime
	title = JOB_NAME_MIME
	description = "Be the Clown's mute counterpart and arch nemesis. Conduct pantomimes and performances, create interesting situations with your mime powers. Remember your job is to keep things funny for others, not just yourself."
	department_for_prefs = DEPT_NAME_SERVICE
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	faction = "Station"
	total_positions = 1
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/mime

	base_access = list(
		ACCESS_THEATRE,
		ACCESS_SERVICE,
	)
	extra_access = list()

	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_MINIMAL)

	display_order = JOB_DISPLAY_ORDER_MIME
	rpg_title = "Fool"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/mime
	)

	minimal_lightup_areas = list(/area/crew_quarters/theatre)

	manuscript_jobs = list(
		JOB_NAME_MIME,
		JOB_NAME_COOK // the cultural power of french cuisine
	)

/datum/job/mime/after_spawn(mob/living/carbon/human/H, mob/M, latejoin = FALSE, client/preference_source, on_dummy = FALSE)
	. = ..()
	if(!ishuman(H))
		return
	if(!M.client || on_dummy)
		return
	H.apply_pref_name(/datum/preference/name/mime, preference_source)


/datum/outfit/job/mime
	name = JOB_NAME_MIME
	jobtype = /datum/job/mime

	id = /obj/item/card/id/job/mime
	belt = /obj/item/modular_computer/tablet/pda/preset/mime
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/mime
	mask = /obj/item/clothing/mask/gas/mime
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/frenchberet
	suit = /obj/item/clothing/suit/suspenders
	backpack_contents = list(
		/obj/item/book/granter/action/spell/mime/mimery=1,
		/obj/item/reagent_containers/cup/glass/bottle/bottleofnothing=1,
		/obj/item/stamp/mime=1
	)

	backpack = /obj/item/storage/backpack/mime
	satchel = /obj/item/storage/backpack/mime


/datum/outfit/job/mime/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()

	if(visuals_only)
		return

	// Start our mime out with a vow of silence and the ability to break (or make) it
	if(H.mind)
		var/datum/action/cooldown/spell/vow_of_silence/vow = new(H.mind)
		vow.Grant(H)

/obj/item/book/granter/action/spell/mime/mimery
	name = "Guide to Dank Mimery"
	desc = "Teaches one of three classic pantomime routines, allowing a practiced mime to conjure invisible objects into corporeal existence. One use only."
	pages_to_mastery = 0
	reading_time = 0

/obj/item/book/granter/action/spell/mime/mimery/on_reading_start(mob/living/user)
	var/list/spell_icons = list()
	var/list/name_to_spell = list()
	for(var/datum/action/type as anything in list(/datum/action/cooldown/spell/conjure/invisible_wall, /datum/action/cooldown/spell/conjure/invisible_chair, /datum/action/cooldown/spell/conjure_item/invisible_box))
		if(!(locate(type) in user.actions))
			spell_icons[initial(type.name)] = image(icon = initial(type.button_icon), icon_state = initial(type.button_icon_state))
		name_to_spell[initial(type.name)] = type

	var/picked_spell = show_radial_menu(user, src, spell_icons, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 36, require_near = TRUE)
	if(!picked_spell)
		return FALSE
	granted_action = name_to_spell[picked_spell]
	return TRUE

/obj/item/book/granter/action/spell/mime/mimery/on_reading_finished(mob/living/user)
	// Gives the user a vow ability too, if they don't already have one
	var/datum/action/cooldown/spell/vow_of_silence/vow = locate() in user.actions
	if(!vow && user.mind)
		vow = new(user.mind)
		vow.Grant(user)
	var/datum/action/new_action = new granted_action(user.mind || user)
	new_action.Grant(user)
	to_chat(user, span_warning("The book disappears into thin air."))
	qdel(src)

/obj/item/book/granter/action/spell/mime/mimery/can_learn(mob/living/user)
	for(var/type in list(/datum/action/cooldown/spell/conjure/invisible_wall, /datum/action/cooldown/spell/conjure/invisible_chair, /datum/action/cooldown/spell/conjure_item/invisible_box))
		if(!(locate(type) in user.actions))
			return TRUE
	to_chat(user, span_warning("You already know the secrets of mimery!"))
	return FALSE

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The human mob interacting with the menu
 */
/obj/item/book/granter/action/spell/mime/mimery/proc/check_menu(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE
	if(!user.is_holding(src))
		return FALSE
	if(user.incapacitated)
		return FALSE
	if(!user.mind)
		return FALSE
	return TRUE
