// Bottom left
#define ui_leech_health "WEST:8,SOUTH:8"
#define ui_leech_brain_health "WEST:8,SOUTH+2:16"

// Middle right
#define ui_leech_saturation "EAST,CENTER-2"
#define ui_leech_substrate "EAST,CENTER-3"

// Bottom right, also toggles.
#define ui_leech_nightvision_toggle "EAST-1:-8,SOUTH:8"
#define ui_leech_hide_toggle "EAST:-8,SOUTH:8"

// Hud
/datum/hud/leech
	ui_style = 'icons/synapse_leech/hud.dmi'

	var/atom/movable/screen/leech/substrate_display/substrate_display
	var/atom/movable/screen/leech/saturation_display/saturation_display
	/// Host brain health display
	var/atom/movable/screen/leech/brain_health_display/brain_health_display
	/// Nightvision HUD toggle button
	var/atom/movable/screen/leech/nightvision_toggle/nightvision_button
	/// Hide HUD toggle button
	var/atom/movable/screen/leech/hide_toggle/hide_button

/datum/hud/leech/New(mob/owner)
	..()

	healths = new /atom/movable/screen/healths/leech(null, src)
	infodisplay += healths

	saturation_display = new /atom/movable/screen/leech/saturation_display(null, src)
	infodisplay += saturation_display

	substrate_display = new /atom/movable/screen/leech/substrate_display(null, src)
	infodisplay += substrate_display

	brain_health_display = new /atom/movable/screen/leech/brain_health_display(null, src)
	infodisplay += brain_health_display

	nightvision_button = new /atom/movable/screen/leech/nightvision_toggle(null, src)
	nightvision_button.screen_loc = ui_leech_nightvision_toggle
	static_inventory += nightvision_button

	hide_button = new /atom/movable/screen/leech/hide_toggle(null, src)
	hide_button.screen_loc = ui_leech_hide_toggle
	static_inventory += hide_button

// Screen things
/atom/movable/screen/leech
	icon = 'icons/synapse_leech/hud.dmi'

/**
 * Nightvision HUD toggle button.
 * Uses icon states from the standard hud.dmi: nightvision_off / nightvision_on.
 * Clicking it directly toggles the leech's darkvision; no action datum involved.
 */
/atom/movable/screen/leech/nightvision_toggle
	name = "Toggle Darkvision"
	icon = 'icons/synapse_leech/hud.dmi'
	icon_state = "nightvision_off"
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/leech/nightvision_toggle/Click()
	var/mob/living/basic/synapse_leech/leech = usr
	if(!istype(leech) || leech.stat != CONSCIOUS)
		return

	if(leech.nightvision_active)
		leech.lighting_alpha = initial(leech.lighting_alpha)
		leech.update_sight()
		to_chat(leech, span_notice("Your eyes settle back into their normal sensitivity."))
		icon_state = "nightvision_off"
		leech.nightvision_active = FALSE
	else
		leech.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		leech.update_sight()
		to_chat(leech, span_notice("Your sight pierces the dark."))
		icon_state = "nightvision_on"
		leech.nightvision_active = TRUE

/**
 * Hide HUD toggle button.
 * Uses icon states from the standard hud.dmi: hide_off / hide_on.
 * Clicking it directly toggles the leech's hidden state; saturation drain is handled in Life().
 */
/atom/movable/screen/leech/hide_toggle
	name = "Hide"
	icon = 'icons/synapse_leech/hud.dmi'
	icon_state = "hide_off"
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/leech/hide_toggle/Click()
	var/mob/living/basic/synapse_leech/leech = usr
	if(!istype(leech) || leech.stat != CONSCIOUS)
		return

	if(leech.hidden)
		leech.layer = initial(leech.layer)
		leech.visible_message(
			span_notice("[leech] uncoils back to its full height."),
			span_notice("You rise back up."),
		)
		icon_state = "hide_off"
		leech.hidden = FALSE
	else
		leech.layer = ABOVE_NORMAL_TURF_LAYER
		leech.visible_message(
			span_notice("[leech] flattens itself against the floor."),
			span_notice("You flatten yourself against the floor, slipping into the cracks."),
		)
		icon_state = "hide_on"
		leech.hidden = TRUE

// Health display.
/atom/movable/screen/healths/leech
	icon = 'icons/synapse_leech/hud_big.dmi'
	icon_state = "health_container"
	screen_loc = ui_leech_health
	appearance_flags = KEEP_TOGETHER

/atom/movable/screen/healths/leech/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	// Clip everything (base + overlays) to the bottle silhouette.
	add_filter("bottle_mask", 1, alpha_mask_filter(icon = icon('icons/synapse_leech/hud_big.dmi', "health_container")))

// Host brain health display; brain0 (healthy) to brain7 (dead/no host)
/atom/movable/screen/leech/brain_health_display
	icon = 'icons/synapse_leech/hud.dmi'
	icon_state = "brain7"
	name = "Host Brain Health"
	screen_loc = ui_leech_brain_health

// Saturation(hunger), from saturation0 to saturation7 at 100 saturation
/atom/movable/screen/leech/saturation_display
	icon_state = "saturation0"
	name = "Hunger"
	screen_loc = ui_leech_saturation

// Works like saturation, from substrate0 to substrate7 at max substrate
/atom/movable/screen/leech/substrate_display
	icon_state = "substrate0"
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
	var/tier = 7 - clamp(round(saturation / (max_saturation / 7)), 0, 7)
	leech_hud.saturation_display.icon_state = "saturation[tier]"

/// Updates the substrate HUD icon state based on current substrate value.
/mob/living/basic/synapse_leech/proc/update_substrate_display()
	if(!hud_used)
		return

	var/datum/hud/leech/leech_hud = hud_used

	if(!leech_hud.substrate_display)
		return

	// Clamp to 8 tiers: substrate0 (empty) through substrate7 (full), matching mob health display
	var/tier = 7 - clamp(round(substrate / (max_substrate / 7)), 0, 7)
	leech_hud.substrate_display.icon_state = "substrate[tier]"

/// Updates the host brain health HUD icon state. brain0 = healthy, brain7 = dead/no host.
/mob/living/basic/synapse_leech/proc/update_brain_health_display()
	if(!hud_used)
		return

	var/datum/hud/leech/leech_hud = hud_used
	if(!leech_hud.brain_health_display)
		return

	if(!host || !nested)
		leech_hud.brain_health_display.icon_state = "brain7"
		return

	var/brain_damage = host.getOrganLoss(ORGAN_SLOT_BRAIN)
	var/tier = clamp(round(brain_damage / (BRAIN_DAMAGE_DEATH / 7)), 0, 7)
	leech_hud.brain_health_display.icon_state = "brain[tier]"

/// Updates the health HUD using magic sponsored by racc-off
/// Render order (bottom to top), all on a KEEP_TOGETHER base, clipped by an alpha-mask filter:
///   1. `health_container` - the bottle silhouette (base icon_state, also the mask source)
///   2. `health_fill`      - 64x64 red square, BLEND_MULTIPLY so the glass tint shows through,
///                           pixel_y offset by health %
///   3. `health_shine`     - glass stuff, drawn on top of the liquid
///   4. `health_border`    - frame, rendered OUTSIDE the mask so it can extend past
///                           the silhouette, unused for now
/mob/living/basic/synapse_leech/update_health_hud()
	if(!hud_used?.healths)
		return

	var/healthpercent = (stat == DEAD) ? 0 : clamp(health / maxHealth, 0, 1)

	hud_used.healths.cut_overlays()

	// Liquid fill is a red square, multiplied through the glass tint and clipped by the mask filter.
	// Visible fill height ranges from 0px (empty) to 56px (full), the top of the bottle
	// is reserved for the neck
	var/mutable_appearance/fill = mutable_appearance('icons/synapse_leech/hud_big.dmi', "health_fill")
	fill.blend_mode = BLEND_MULTIPLY
	fill.pixel_y = -(12 + round(52 * (1 - healthpercent)))
	hud_used.healths.add_overlay(fill)

	// Glass shine. Default blend, draws on top of the liquid, still clipped by the mask.
	hud_used.healths.add_overlay(mutable_appearance('icons/synapse_leech/hud_big.dmi', "health_shine"))

	// Decorative border/frame. i think keep apart is meant for this?
	var/mutable_appearance/border = mutable_appearance('icons/synapse_leech/hud_big.dmi', "health_border")
	border.appearance_flags = KEEP_APART
	hud_used.healths.add_overlay(border)

	// Hurt screen overlay scaled by damage amount
	var/missing = 1 - healthpercent
	if(stat != DEAD && missing > 0)
		var/severity = clamp(round(missing * 6) + 1, 1, 6)
		overlay_fullscreen("brute", /atom/movable/screen/fullscreen/brute, severity)
	else
		clear_fullscreen("brute")

/// Convenience proc to update all leech HUD elements at once.
/mob/living/basic/synapse_leech/proc/update_leech_hud()
	update_health_hud()
	update_saturation_display()
	update_substrate_display()
	update_brain_health_display()
