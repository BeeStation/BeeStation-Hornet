/datum/ai_project/security_hud
	name = "Advanced Security HUD"
	description = "Using experimental long range passive sensors should allow you to detect various implants such as loyalty implants and tracking implants."
	research_cost = 1000
	ram_required = 2
	research_requirements = "None"
	category = AI_PROJECT_HUDS

/datum/ai_project/security_hud/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.sec_hud = DATA_HUD_SECURITY_ADVANCED
	if(ai.sensors_on)
		ai.toggle_sensors()
	ai.toggle_sensors()


/datum/ai_project/security_hud/stop()
	if(ai.sensors_on) //HUDs are weird. This has to be first so we're removed from the "advanced" HUD. It checks the sec_hud variable to see which one we remove from first.
		ai.toggle_sensors()
	ai.sec_hud = DATA_HUD_SECURITY_BASIC

	ai.toggle_sensors()
	..()

/datum/ai_project/diag_med_hud
	name = "Advanced Medical & Diagnostic HUD"
	description = "Various data processing optimizations should allow you to gain extra knowledge about users when your medical and diagnostic hud is active."
	research_cost = 750
	ram_required = 1
	research_requirements = "None"
	category = AI_PROJECT_HUDS

/datum/ai_project/diag_med_hud/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.d_hud = DATA_HUD_DIAGNOSTIC_ADVANCED
	ai.med_hud = DATA_HUD_MEDICAL_ADVANCED

	if(ai.sensors_on)
		ai.toggle_sensors()
	ai.toggle_sensors()


/datum/ai_project/diag_med_hud/stop()
	if(ai.sensors_on) //HUDs are weird. This has to be first so we're removed from the "advanced" HUD. It checks the d_hud and med_hud variable to see which one we remove from first.
		ai.toggle_sensors()

	ai.d_hud = DATA_HUD_DIAGNOSTIC_BASIC
	ai.med_hud = DATA_HUD_MEDICAL_BASIC

	ai.toggle_sensors()
	..()
