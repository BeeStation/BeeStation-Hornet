/datum/surgery/upgrade_manipulation
	name = "Upgrade Manipulation"
	steps = list(
			/datum/surgery_step/mechanic_open,
			/datum/surgery_step/open_hatch,
			/datum/surgery_step/prepare_electronics,
			/datum/surgery_step/manipulate_upgrades,
			/datum/surgery_step/mechanic_close,
			)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = BODYTYPE_ROBOTIC
	surgery_flags = SURGERY_SELF_OPERABLE

/datum/surgery/upgrade_manipulation/can_start(mob/user, mob/living/patient)
	return HAS_TRAIT(patient, TRAIT_UPGRADE_COMPATIBLE) && ..()

/datum/surgery_step/manipulate_upgrades
	name = "manipulate upgrades"
	repeatable = TRUE
	implements = list(/obj/item/ipc_upgrade = 100, TOOL_CROWBAR = 100)
	preop_sound = 'sound/surgery/tape_flip.ogg'
	success_sound = 'sound/surgery/taperecorder_close.ogg'
	var/extracting //null if preop failed, TRUE if extracting, FALSE if inserting'
	var/datum/status_effect/ipc_upgrade/target_upgrade

/datum/surgery_step/manipulate_upgrades/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/ipc_upgrade))
		var/obj/item/ipc_upgrade/upgrade = tool
		if(get_ipc_upgrade_by_slot(target.status_effects, upgrade.slot))
			to_chat(user, span_notice("There is already an upgrade in this slot!"))
			return SURGERY_STEP_FAIL
		extracting = FALSE
		display_results(
			user,
			target,
			span_notice("You begin to install [upgrade] into [target]..."),
			span_notice("[user] begins to install [upgrade] into [target]."),
			span_notice("[user] begins to install something into [target]."),
		)
		return

	if(tool.tool_behaviour == TOOL_CROWBAR)
		var/list/datum/status_effect/ipc_upgrade/choices = list()
		for(var/datum/status_effect/ipc_upgrade/upgrade in target.status_effects)
			choices += upgrade
		if(!length(choices))
			to_chat(user, span_notice("There are no uninstallable upgrades in [target]."))
			return SURGERY_STEP_FAIL
		var/datum/status_effect/ipc_upgrade/upgrade = tgui_input_list(user, "Uninstall which Upgrade?", "Surgery", sort_list(choices))
		if(!upgrade)
			return SURGERY_STEP_FAIL
		extracting = TRUE
		target_upgrade = upgrade
		display_results(
			user,
			target,
			span_notice("You begin to uninstall [upgrade] from [target]..."),
			span_notice("[user] begins to uninstall [upgrade] from [target]."),
			span_notice("[user] begins to uninstall something from [target]."),
		)
		return
	return SURGERY_STEP_FAIL

/datum/surgery_step/manipulate_upgrades/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	if(!extracting)
		var/obj/item/ipc_upgrade/upgrade = tool
		display_results(
			user,
			target,
			span_notice("You install [upgrade] into [target]..."),
			span_notice("[user] installs [upgrade] into [target]."),
			span_notice("[user] installs something into [target]."),
		)
		upgrade.insert(target)
	else
		display_results(
			user,
			target,
			span_notice("You uninstall [target_upgrade.name] from [target]..."),
			span_notice("[user] uninstalls [target_upgrade.name] from [target]."),
			span_notice("[user] uninstalls something from [target]."),
		)
		target_upgrade.extract()
	return ..()

