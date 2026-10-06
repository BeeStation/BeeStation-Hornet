/datum/billing_changelog

/datum/billing_changelog/ui_state()
	return GLOB.always_state

/datum/billing_changelog/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "BillingChangelog")
		ui.open()

/datum/action/show_billing_changelog
	name = "Show Billing Changelog"
	button_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "random"

/datum/action/show_billing_changelog/on_activate(mob/user, atom/target, trigger_flags)
	. = ..()
	if(!GLOB.billing_changelog_tgui)
		GLOB.billing_changelog_tgui = new /datum/billing_changelog()
	GLOB.billing_changelog_tgui.ui_interact(user)
