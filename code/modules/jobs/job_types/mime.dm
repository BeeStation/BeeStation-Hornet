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
		/obj/item/book/mimery=1,
		/obj/item/reagent_containers/cup/glass/bottle/bottleofnothing=1,
		/obj/item/stamp/mime=1
	)

	backpack = /obj/item/storage/backpack/mime
	satchel = /obj/item/storage/backpack/mime


/datum/outfit/job/mime/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	// Start our mime out with a vow of silence and the ability to break (or make) it
	if(H.mind)
		var/datum/action/spell/vow_of_silence/vow = new(H.mind)
		vow.Grant(H)
		H.mind.miming = 1

/obj/item/book/mimery
	name = "Guide to Dank Mimery"
	desc = "A primer on basic pantomime."
	icon_state ="bookmime"

/obj/item/book/mimery/attack_self(mob/user)
	. = ..()
	if(.)
		return

	var/list/spell_icons = list(
		"Invisible Wall" = image(icon = 'icons/hud/actions/actions_mime.dmi', icon_state = "invisible_wall"),
		"Invisible Chair" = image(icon = 'icons/hud/actions/actions_mime.dmi', icon_state = "invisible_chair"),
		"Invisible Box" = image(icon = 'icons/hud/actions/actions_mime.dmi', icon_state = "invisible_box")
		)
	var/picked_spell = show_radial_menu(user, src, spell_icons, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 36, require_near = TRUE)
	var/datum/action/spell/picked_spell_type
	switch(picked_spell)
		if("Invisible Wall")
			picked_spell_type = /datum/action/spell/conjure/invisible_wall

		if("Invisible Chair")
			picked_spell_type = /datum/action/spell/conjure/invisible_chair

		if("Invisible Box")
			picked_spell_type = /datum/action/spell/conjure_item/invisible_box

	if(ispath(picked_spell_type))
		// Gives the user a vow ability too, if they don't already have one
		var/datum/action/spell/vow_of_silence/vow = locate() in user.actions
		if(!vow && user.mind)
			vow = new(user.mind)
			vow.Grant(user)

		picked_spell_type = new picked_spell_type(user.mind || user)
		picked_spell_type.Grant(user)

		to_chat(user, span_warning("The book disappears into thin air."))
		qdel(src)

	return TRUE

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The human mob interacting with the menu
 */
/obj/item/book/mimery/proc/check_menu(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE
	if(!user.is_holding(src))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(!user.mind)
		return FALSE
	return TRUE
