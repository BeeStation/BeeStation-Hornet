// Defines for UI element locations
#define ui_leech_health "EAST,CENTER-1:15"
#define ui_leech_saturation "EAST,CENTER-2:15"
#define ui_leech_substrate "EAST,CENTER-3:15"

// We will need:
// - A health display
// - A saturation display
// - A substrate display

// Hud
/datum/hud/leech
	ui_style = 'icons/synapse_leech/hud.dmi'

	var/atom/movable/screen/leech/substrate_display/substrate_display
	var/atom/movable/screen/leech/saturation_display/saturation_display

/datum/hud/leech/New(mob/owner)
	..()

	healths = new /atom/movable/screen/healths/leech(null, src)
	infodisplay += healths

	saturation_display = new /atom/movable/screen/leech/saturation_display(null, src)
	infodisplay += saturation_display

	substrate_display = new /atom/movable/screen/leech/substrate_display(null, src)
	infodisplay += substrate_display

// Screen things
/atom/movable/screen/leech
	icon = 'icons/synapse_leech/hud.dmi'

// Health display, works like the basic mob health display, just custom sprites.
/atom/movable/screen/healths/leech
	icon = 'icons/synapse_leech/hud.dmi'
	screen_loc = ui_leech_health

// Saturation(hunger) works like health, from saturation0 to saturation7 at 100 saturation
/atom/movable/screen/leech/saturation_display
	icon_state = "health0"
	name = "Hunger"
	screen_loc = ui_leech_saturation

// Works like saturation, from substrate0 to substrate7 at max substrate
/atom/movable/screen/leech/substrate_display
	icon_state = "health0"
	name = "Neuroplasmic Substrate"
	screen_loc = ui_leech_substrate

/// Updates the saturation HUD icon state based on current saturation (0-100).
/mob/living/basic/synapse_leech/proc/update_saturation_display()
	if(!hud_used)
		return
	var/datum/hud/leech/leech_hud = hud_used
	if(!leech_hud.saturation_display)
		return
	// Clamp to 8 tiers: saturation0 (empty) through saturation7 (full), matching mob health display
	var/tier = 7 - clamp(round(saturation / (LEECH_MAX_SATURATION / 7)), 0, 7)
	leech_hud.saturation_display.icon_state = "health[tier]"
	leech_hud.saturation_display.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='yellow'>[round(saturation)]</font></div>")

/// Updates the substrate HUD icon state based on current substrate value.
/mob/living/basic/synapse_leech/proc/update_substrate_display()
	if(!hud_used)
		return
	var/datum/hud/leech/leech_hud = hud_used
	if(!leech_hud.substrate_display)
		return
	// Clamp to 8 tiers: substrate0 (empty) through substrate7 (full), matching mob health display
	var/tier = 7 - clamp(round(substrate / (max_substrate / 7)), 0, 7)
	leech_hud.substrate_display.icon_state = "health[tier]"
	leech_hud.substrate_display.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='cyan'>[round(substrate)]</font></div>")

/// Convenience proc to update all leech HUD elements at once.
/mob/living/basic/synapse_leech/proc/update_leech_hud()
	update_saturation_display()
	update_substrate_display()
