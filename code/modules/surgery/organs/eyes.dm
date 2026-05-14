/obj/item/organ/eyes
	name = BODY_ZONE_PRECISE_EYES
	icon_state = "eyeballs"
	desc = "I see you!"
	visual = TRUE
	zone = BODY_ZONE_PRECISE_EYES
	slot = ORGAN_SLOT_EYES
	gender = PLURAL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	maxHealth = 0.5 * STANDARD_ORGAN_THRESHOLD //half the normal health max since we go blind at 30, a permanent blindness at 50 therefore makes sense unless medicine is administered
	high_threshold = 0.3 * STANDARD_ORGAN_THRESHOLD //threshold at 30
	low_threshold = 0.2 * STANDARD_ORGAN_THRESHOLD //threshold at 20

	low_threshold_passed = span_info("Distant objects become somewhat less tangible.")
	high_threshold_passed = span_info("Everything starts to look a lot less clear.")
	now_failing = span_warning("Darkness envelopes you, as your eyes go blind!")
	now_fixed = span_info("Color and shapes are once again perceivable.")
	high_threshold_cleared = span_info("Your vision functions passably once more.")
	low_threshold_cleared = span_info("Your vision is cleared of any ailment.")

	/// Sight flags this eye pair imparts on its user.
	var/sight_flags = NONE
	/// changes how the eyes overlay is applied, makes it apply over the lighting layer
	var/overlay_ignore_lighting = FALSE
	/// How much a mob can see in the dark with these eyes
	var/see_in_dark = 2
	/// How much innate tint these eyes have
	var/tint = 0
	/// How much innare flash protection these eyes have, usually paired with tint
	var/flash_protect = FLASH_PROTECTION_NONE
	/// What level of invisibility these eyes can see
	var/see_invisible = SEE_INVISIBLE_LIVING
	/// How much alpha lighting has (basically, night vision)
	var/lighting_alpha

	var/eye_color_left = "" //set to a hex code to override a mob's left eye color
	var/eye_color_right = "" //set to a hex code to override a mob's right eye color
	/// The icon file of that eyes as its applied to the mob
	var/eye_icon = 'icons/mob/human/human_eyes.dmi'
	/// The icon state of that eyes as its applied to the mob
	var/eye_icon_state = "eyes"
	var/old_eye_color_left = COLOR_WHITE
	var/old_eye_color_right = COLOR_WHITE

	/// Glasses cannot be worn over these eyes. Currently unused
	var/no_glasses = FALSE
	/// indication that the eyes are undergoing some negative effect
	var/damaged = FALSE

/obj/item/organ/eyes/Insert(mob/living/carbon/eye_recipient, special = FALSE, drop_if_replaced = FALSE, pref_load = FALSE)
	// If we don't do this before everything else, heterochromia will be reset leading to eye_color_right no longer being accurate
	if(ishuman(eye_recipient))
		var/mob/living/carbon/human/human_recipient = eye_recipient
		old_eye_color_left = human_recipient.eye_color_left
		old_eye_color_right = human_recipient.eye_color_right

	. = ..()

	if(!.)
		return

	eye_recipient.cure_blind(NO_EYES)
	apply_damaged_eye_effects()
	refresh(eye_recipient, call_update = TRUE)

/// Refreshes the visuals of the eyes
/// If call_update is TRUE, we also will call udpate_body
/obj/item/organ/eyes/proc/refresh(mob/living/carbon/eye_owner = owner, call_update = TRUE)
	owner.update_sight()
	owner.update_tint()

	if(!ishuman(eye_owner))
		return

	var/mob/living/carbon/human/affected_human = eye_owner
	if(initial(eye_color_left))
		affected_human.eye_color_left = eye_color_left
	else
		eye_color_left = affected_human.eye_color_left
	if(initial(eye_color_right))
		affected_human.eye_color_right = eye_color_right
	else
		eye_color_right = affected_human.eye_color_right
	if(HAS_TRAIT(affected_human, TRAIT_NIGHT_VISION_WEAK) && !lighting_alpha)
		lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT

	if(call_update)
		affected_human.update_body()

/obj/item/organ/eyes/Remove(mob/living/carbon/eye_owner, special = FALSE, pref_load = FALSE)
	..()
	if(ishuman(eye_owner))
		var/mob/living/carbon/human/human_owner = eye_owner
		if(initial(eye_color_left))
			human_owner.eye_color_left = old_eye_color_left
		if(initial(eye_color_right))
			human_owner.eye_color_right = old_eye_color_right
		human_owner.update_body()

	// Cure blindness from eye damage
	eye_owner.cure_blind(EYE_DAMAGE)
	eye_owner.cure_nearsighted(EYE_DAMAGE)
	// Eye blind and temp blind go to, even if this is a bit of cheesy way to clear blindness
	eye_owner.remove_status_effect(/datum/status_effect/eye_blur)
	eye_owner.remove_status_effect(/datum/status_effect/temporary_blindness)
	// Then become blind anyways (if not special)
	if(!special)
		eye_owner.become_blind(NO_EYES)

	eye_owner.update_tint()
	eye_owner.update_sight()

#define OFFSET_X 1
#define OFFSET_Y 2

/// This proc generates a list of overlays that the eye should be displayed using for the given parent
/obj/item/organ/eyes/proc/generate_body_overlay(mob/living/carbon/human/parent)
	if(!istype(parent) || parent.get_organ_by_type(/obj/item/organ/eyes) != src)
		CRASH("Generating a body overlay for [src] targeting an invalid parent '[parent]'.")

	if(isnull(eye_icon_state))
		return list()

	var/mutable_appearance/eye_left = mutable_appearance(eye_icon, "[eye_icon_state]_l", CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
	var/mutable_appearance/eye_right = mutable_appearance(eye_icon, "[eye_icon_state]_r", CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
	var/list/overlays = list(eye_left, eye_right)

	var/obscured = parent.check_obscured_slots(TRUE)
	if(overlay_ignore_lighting && !(obscured & ITEM_SLOT_EYES))
		overlays += emissive_appearance(eye_left.icon, eye_left.icon_state, layer = CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER), alpha = eye_left.alpha)
		overlays += emissive_appearance(eye_right.icon, eye_right.icon_state, layer = CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER), alpha = eye_right.alpha)

	// Cry emote overlay
	if (HAS_TRAIT(parent, TRAIT_CRYING)) // Caused by either using *cry or being pepper sprayed
		var/mutable_appearance/tears_overlay = mutable_appearance('icons/mob/human/human_face.dmi', "tears", CALCULATE_MOB_OVERLAY_LAYER(BODY_ADJ_LAYER))
		tears_overlay.color = COLOR_DARK_CYAN
		overlays += tears_overlay

	var/obj/item/bodypart/head/my_head = parent.get_bodypart(BODY_ZONE_HEAD)
	if(my_head)
		if(my_head.head_flags & HEAD_EYECOLOR)
			eye_right.color = eye_color_right
			eye_left.color = eye_color_left
		if(my_head.worn_face_offset)
			my_head.worn_face_offset.apply_offset(eye_left)
			my_head.worn_face_offset.apply_offset(eye_right)

	return overlays

#undef OFFSET_X
#undef OFFSET_Y

//Gotta reset the eye color, because that persists
/obj/item/organ/eyes/enter_wardrobe()
	. = ..()
	eye_color_left = initial(eye_color_left)
	eye_color_right = initial(eye_color_right)

/obj/item/organ/eyes/apply_organ_damage(damage_amount, maximum = maxHealth, required_organ_flag)
	. = ..()
	if(!owner)
		return FALSE
	apply_damaged_eye_effects()

/// Applies effects to our owner based on how damaged our eyes are
/obj/item/organ/eyes/proc/apply_damaged_eye_effects()
	// we're in healthy threshold, either try to heal (if damaged) or do nothing
	if(damage <= low_threshold)
		if(damaged)
			damaged = FALSE
			// clear nearsightedness from damage
			owner.cure_nearsighted(EYE_DAMAGE)
			// if we're still nearsighted, reset its severity
			// this is kinda icky, ideally we'd track severity to source but that's way more complex
			var/datum/status_effect/grouped/nearsighted/nearsightedness = owner.is_nearsighted()
			nearsightedness?.set_nearsighted_severity(1)
			// and cure blindness from damage
			owner.cure_blind(EYE_DAMAGE)
		return

	//various degrees of "oh fuck my eyes", from "point a laser at your eye" to "staring at the Sun" intensities
	// 50 - blind
	// 49-31 - nearsighted (2 severity)
	// 30-20 - nearsighted (1 severity)
	if(organ_flags & ORGAN_FAILING)
		// become blind from damage
		owner.become_blind(EYE_DAMAGE)

	else
		// become nearsighted from damage
		owner.become_nearsighted(EYE_DAMAGE)
		// update the severity of our nearsightedness based on our eye damage
		var/datum/status_effect/grouped/nearsighted/nearsightedness = owner.is_nearsighted()
		nearsightedness.set_nearsighted_severity(damage > high_threshold ? 2 : 1)

	damaged = TRUE


/obj/item/organ/eyes/night_vision
	name = "shadow eyes"
	desc = "A spooky set of eyes that can see in the dark."
	see_in_dark = NIGHTVISION_FOV_RANGE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/night_vision = TRUE

/obj/item/organ/eyes/night_vision/ui_action_click()
	sight_flags = initial(sight_flags)
	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			sight_flags &= ~SEE_BLACKNESS
	owner.update_sight()

/obj/item/organ/eyes/night_vision/alien
	name = "alien eyes"
	desc = "It turned out they had them after all!"
	sight_flags = SEE_MOBS

/obj/item/organ/eyes/night_vision/zombie
	name = "undead eyes"
	desc = "Somewhat counterintuitively, these half-rotten eyes actually have superior vision to those of a living human."

/obj/item/organ/eyes/night_vision/nightmare
	name = "burning red eyes"
	desc = "Even without their shadowy owner, looking at these eyes gives you a sense of dread."
	icon_state = "burning_eyes"

/obj/item/organ/eyes/night_vision/mushroom
	name = "fung-eye"
	desc = "While on the outside they look inert and dead, the eyes of mushroom people are actually very advanced."

///Robotic

/obj/item/organ/eyes/robotic
	name = "robotic eyes"
	icon_state = "cybernetic_eyeballs"
	desc = "A very basic set of optical sensors with no extra vision modes or functions."
	organ_flags = ORGAN_ROBOTIC

/obj/item/organ/eyes/robotic/emp_act(severity)
	. = ..()
	if((. & EMP_PROTECT_SELF) || !owner)
		return
	if(prob(30/severity))
		to_chat(owner, span_warning("Static obfuscates your vision!"))
		owner.flash_act(visual = 1)

/obj/item/organ/eyes/robotic/xray
	name = "\improper X-ray eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	eye_color_left = COLOR_BLACK
	eye_color_right = COLOR_BLACK
	see_in_dark = NIGHTVISION_FOV_RANGE
	sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS
	flash_protect = -INFINITY
	tint = -INFINITY

/obj/item/organ/eyes/robotic/xray/syndicate
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile. On closer look, they have been modified to protect from sudden bright flashes."
	flash_protect = FLASH_PROTECTION_NONE

/obj/item/organ/eyes/robotic/thermals
	name = "thermal eyes"
	desc = "These cybernetic eye implants will give you thermal vision. Vertical slit pupil included."
	eye_color_left = COLOR_YELLOW
	eye_color_right = COLOR_YELLOW
	sight_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = FLASH_PROTECTION_SENSITIVE
	see_in_dark = NIGHTVISION_FOV_RANGE

/obj/item/organ/eyes/robotic/flashlight
	name = "flashlight eyes"
	desc = "It's two flashlights rigged together with some wire. Why would you put these in someone's head?"
	eye_color_left = "#fee5a3"
	eye_color_right = "#fee5a3"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight_eyes"
	flash_protect = FLASH_PROTECTION_WELDER
	tint = INFINITY
	var/obj/item/flashlight/eyelight/eye

/obj/item/organ/eyes/robotic/flashlight/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

/obj/item/organ/eyes/robotic/flashlight/on_insert(mob/living/carbon/victim)
	. = ..()
	if(!eye)
		eye = new /obj/item/flashlight/eyelight()
	eye.set_light_on(TRUE)
	eye.forceMove(victim)
	eye.update_brightness(victim)
	victim.become_blind("flashlight_eyes")


/obj/item/organ/eyes/robotic/flashlight/on_remove(mob/living/carbon/victim)
	. = ..()
	eye.set_light_on(FALSE)
	eye.update_brightness(victim)
	eye.forceMove(src)
	victim.cure_blind("flashlight_eyes")

// Welding shield implant
/obj/item/organ/eyes/robotic/shield
	name = "shielded robotic eyes"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/organ/eyes/robotic/shield/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

#define MATCH_LIGHT_COLOR 1
#define USE_CUSTOM_COLOR 0
#define UPDATE_LIGHT 0
#define UPDATE_EYES_LEFT 1
#define UPDATE_EYES_RIGHT 2

/obj/item/organ/eyes/robotic/glow
	name = "High Luminosity Eyes"
	desc = "Special glowing eyes, used by snowflakes who want to be special."
	eye_color_left = COLOR_BLACK
	eye_color_right = COLOR_BLACK
	actions_types = list(/datum/action/item_action/organ_action/use, /datum/action/item_action/organ_action/toggle)
	var/max_light_beam_distance = 5
	var/obj/item/flashlight/eyelight/glow/eye
	/// base icon state for eye overlays
	var/base_eye_state = "eyes_glow_gs"
	/// Whether or not to match the eye color to the light or use a custom selection
	var/eye_color_mode = USE_CUSTOM_COLOR
	/// The selected color for the light beam itself
	var/light_color_string = COLOR_WHITE
	/// The custom selected eye color for the left eye. Defaults to the mob's natural eye color
	var/left_eye_color_string
	/// The custom selected eye color for the right eye. Defaults to the mob's natural eye color
	var/right_eye_color_string

/obj/item/organ/eyes/robotic/glow/Initialize(mapload)
	. = ..()
	eye = new /obj/item/flashlight/eyelight/glow

/obj/item/organ/eyes/robotic/glow/Destroy()
	. = ..()
	deactivate(close_ui = TRUE)
	QDEL_NULL(eye)

/obj/item/organ/eyes/robotic/glow/emp_act()
	. = ..()
	if(!eye.light_on || . & EMP_PROTECT_SELF)
		return
	deactivate(close_ui = TRUE)

/// Set the initial color of the eyes on insert to be the mob's previous eye color.
/obj/item/organ/eyes/robotic/glow/Insert(mob/living/carbon/eye_recipient, special = FALSE, drop_if_replaced = FALSE)
	. = ..()
	left_eye_color_string = old_eye_color_left
	right_eye_color_string = old_eye_color_right
	update_mob_eye_color(eye_recipient)

/obj/item/organ/eyes/robotic/glow/on_insert(mob/living/carbon/eye_recipient)
	. = ..()
	deactivate(close_ui = TRUE)
	eye.forceMove(eye_recipient)

/obj/item/organ/eyes/robotic/glow/on_remove(mob/living/carbon/eye_owner)
	deactivate(eye_owner, close_ui = TRUE)
	if(!QDELETED(eye))
		eye.forceMove(src)
	return ..()

/obj/item/organ/eyes/robotic/glow/ui_state(mob/user)
	return GLOB.default_state

/obj/item/organ/eyes/robotic/glow/ui_status(mob/user)
	if(!QDELETED(owner))
		if(owner == user)
			return min(
				ui_status_user_is_abled(user, src),
				ui_status_only_living(user),
			)
		else return UI_CLOSE
	return ..()

/obj/item/organ/eyes/robotic/glow/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HighLuminosityEyesMenu")
		ui.autoupdate = FALSE
		ui.open()

/obj/item/organ/eyes/robotic/glow/ui_data(mob/user)
	var/list/data = list()

	data["eyeColor"] = list(
		mode = eye_color_mode,
		hasOwner = owner ? TRUE : FALSE,
		left = left_eye_color_string,
		right = right_eye_color_string,
	)
	data["lightColor"] = light_color_string
	data["range"] = eye.light_range

	return data

/obj/item/organ/eyes/robotic/glow/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_range")
			var/new_range = params["new_range"]
			set_beam_range(new_range)
			return TRUE
		if("pick_color")
			var/new_color = input(
				usr,
				"Choose eye color color:",
				"High Luminosity Eyes Menu",
				light_color_string
			) as color|null
			if(new_color)
				var/to_update = params["to_update"]
				set_beam_color(new_color, to_update)
				return TRUE
		if("enter_color")
			var/new_color = LOWER_TEXT(params["new_color"])
			var/to_update = params["to_update"]
			set_beam_color(new_color, to_update, sanitize = TRUE)
			return TRUE
		if("random_color")
			var/to_update = params["to_update"]
			randomize_color(to_update)
			return TRUE
		if("toggle_eye_color")
			toggle_eye_color_mode()
			return TRUE

/obj/item/organ/eyes/robotic/glow/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/organ_action/toggle))
		toggle_active()
	else if(istype(action, /datum/action/item_action/organ_action/use))
		ui_interact(user)

/**
 * Activates the light
 *
 * Turns on the attached flashlight object, updates the mob overlay to be added.
 */
/obj/item/organ/eyes/robotic/glow/proc/activate()
	if(eye.light_range)
		eye.set_light_on(TRUE)
	else
		eye.light_on = TRUE // at range 0 we are just going to make the eyes glow emissively, no light overlay
	update_mob_eye_color()


/**
 * Deactivates the light
 *
 * Turns off the attached flashlight object, closes UIs, updates the mob overlay to be removed.
 * Arguments:
 * * mob/living/carbon/eye_owner - the mob who the eyes belong to
 * * close_ui - whether or not to close the ui
 */
/obj/item/organ/eyes/robotic/glow/proc/deactivate(mob/living/carbon/eye_owner = owner, close_ui = FALSE)
	if(close_ui)
		SStgui.close_uis(src)
	eye.set_light_on(FALSE)
	update_mob_eye_color(eye_owner)

/**
 * Randomizes the light color
 *
 * Picks a random color and sets the beam color to that
 * Arguments:
 * * to_update - whether we are setting the color for the light beam itself, or the individual eyes
 */
/obj/item/organ/eyes/robotic/glow/proc/randomize_color(to_update = UPDATE_LIGHT)
	var/new_color = "#"
	for(var/i in 1 to 3)
		new_color += num2hex(rand(0, 255), 2)
	set_beam_color(new_color, to_update)

/**
 * Setter function for the light's range
 *
 * Sets the light range of the attached flashlight object
 * Includes some 'unique' logic to accomodate for some quirks of the lighting system
 * Arguments:
 * * new_range - the new range to set
 */
/obj/item/organ/eyes/robotic/glow/proc/set_beam_range(new_range)
	var/old_light_range = eye.light_range
	if(old_light_range == 0 && new_range > 0 && eye.light_on) // turn bring back the light overlay if we were previously at 0 (aka emissive eyes only)
		eye.light_on = FALSE // this is stupid, but this has to be FALSE for set_light_on() to work.
		eye.set_light_on(TRUE)
	eye.set_light_range(clamp(new_range, 0, max_light_beam_distance))

/**
 * Setter function for the light's color
 *
 * Sets the light color of the attached flashlight object. Sets the eye color vars of this eye organ as well and then updates the mob's eye color.
 * Arguments:
 * * newcolor - the new color hex string to set
 * * to_update - whether we are setting the color for the light beam itself, or the individual eyes
 * * sanitize - whether the hex string should be sanitized
 */
/obj/item/organ/eyes/robotic/glow/proc/set_beam_color(newcolor, to_update = UPDATE_LIGHT, sanitize = FALSE)
	var/newcolor_string
	if(sanitize)
		newcolor_string = sanitize_hexcolor(newcolor)
	else
		newcolor_string = newcolor
	switch(to_update)
		if(UPDATE_LIGHT)
			light_color_string = newcolor_string
			eye.set_light_color(newcolor_string)
		if(UPDATE_EYES_LEFT)
			left_eye_color_string = newcolor_string
		if(UPDATE_EYES_RIGHT)
			right_eye_color_string = newcolor_string

	update_mob_eye_color()

/**
 * Toggle the attached flashlight object on or off
 */
/obj/item/organ/eyes/robotic/glow/proc/toggle_active()
	if(eye.light_on)
		deactivate()
	else
		activate()

/**
 * Toggles for the eye color mode
 *
 * Toggles the eye color mode on or off and then calls an update on the mob's eye color
 */
/obj/item/organ/eyes/robotic/glow/proc/toggle_eye_color_mode()
	eye_color_mode = !eye_color_mode
	update_mob_eye_color()

/**
 * Updates the mob eye color
 *
 * Updates the eye color to reflect on the mob's body if it's possible to do so
 * Arguments:
 * * mob/living/carbon/eye_owner - the mob to update the eye color appearance of
 */
/obj/item/organ/eyes/robotic/glow/proc/update_mob_eye_color(mob/living/carbon/eye_owner = owner)
	switch(eye_color_mode)
		if(MATCH_LIGHT_COLOR)
			eye_color_left = light_color_string
			eye_color_right = light_color_string
		if(USE_CUSTOM_COLOR)
			eye_color_left = left_eye_color_string
			eye_color_right = right_eye_color_string

	if(QDELETED(eye_owner) || !ishuman(eye_owner)) //Other carbon mobs don't have eye color.
		return

	if(!eye.light_on)
		eye_icon_state = initial(eye_icon_state)
		overlay_ignore_lighting = FALSE
	else
		overlay_ignore_lighting = TRUE
		eye_icon_state = base_eye_state

	var/obj/item/bodypart/head/head = eye_owner.get_bodypart(BODY_ZONE_HEAD) //if we have eyes we definently have a head anyway
	var/previous_flags = head.head_flags
	head.head_flags = previous_flags | HEAD_EYECOLOR
	eye_owner.dna.species.handle_body(eye_owner)
	head.head_flags = previous_flags

#undef MATCH_LIGHT_COLOR
#undef USE_CUSTOM_COLOR
#undef UPDATE_LIGHT
#undef UPDATE_EYES_LEFT
#undef UPDATE_EYES_RIGHT


/obj/item/organ/eyes/moth
	name = "moth eyes"
	desc = "These eyes seem to have increased sensitivity to bright light, with a small improvement to low light vision."
	eye_icon = 'icons/mob/human/species/moth/eyes.dmi'
	eye_icon_state = "eyes"
	icon_state = "eyeballs-moth"
	see_in_dark = NIGHTVISION_FOV_RANGE/2 //4 tiles compared to 8 of the apids
	flash_protect = FLASH_PROTECTION_SENSITIVE

/obj/item/organ/eyes/moth/domestic
	name = "domestic moth eyes"
	desc = "A mutation of natural moth eyes present in more gregarious specimens."
	eye_icon_state = "motheyes"

/obj/item/organ/eyes/jelly
	name = "jelly eyes"
	desc = "These eyes are made of a soft jelly. Unlike all other eyes, though, there are three of them."
	eye_icon_state = "jelleyes"
	icon_state = "eyeballs-jelly"

/obj/item/organ/eyes/snail
	name = "snail eyes"
	desc = "These eyes seem to have a large range, but might be cumbersome with glasses."
	eye_icon_state = "snail_eyes"
	icon_state = "snail_eyeballs"

/obj/item/organ/eyes/apid
	name = "apid eyes"
	desc = "Designed for navigating dark hives, these eyes have improvement to low light vision."
	see_in_dark = NIGHTVISION_FOV_RANGE

/obj/item/organ/eyes/psyphoza
	name = "psyphoza eyes"
	desc = "Conduits for psychic energy, hardly even eyes."
	icon_state = "psyphoza_eyeballs"
	actions_types = list(/datum/action/item_action/organ_action/psychic_highlight)
	see_in_dark = NIGHTVISION_FOV_RANGE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS

/obj/item/organ/eyes/psyphoza/Insert(mob/living/carbon/M, special, drop_if_replaced, initialising)
	. = ..()
	M.become_blind("uncurable")
	M.overlay_fullscreen("blindness", /atom/movable/screen/fullscreen/blind/psychic)
	M.remove_client_colour(/datum/client_colour/monochrome/blind)
	//Handle weird ability code
	var/datum/action/item_action/organ_action/psychic_highlight/P = locate(/datum/action/item_action/organ_action/psychic_highlight) in M.actions
	if(P?.removed)
		P.Grant(M)
		P?.removed = FALSE

/obj/item/organ/eyes/psyphoza/Remove(mob/living/carbon/M, special = FALSE, pref_load = FALSE)
	M.cure_blind("uncurable")
	var/datum/action/item_action/organ_action/psychic_highlight/P = locate(/datum/action/item_action/organ_action/psychic_highlight) in M.actions
	P?.remove()
	return ..()

/obj/item/organ/eyes/diona
	name = "receptor node"
	desc = "A combination of plant matter and neurons used to produce visual feedback."
	icon_state = "diona_eyeballs"
	organ_flags = ORGAN_UNREMOVABLE
	flash_protect = FLASH_PROTECTION_SENSITIVE

