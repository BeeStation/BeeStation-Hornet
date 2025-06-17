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
	maxHealth = 0.5 * STANDARD_ORGAN_THRESHOLD		//half the normal health max since we go blind at 30, a permanent blindness at 50 therefore makes sense unless medicine is administered
	high_threshold = 0.3 * STANDARD_ORGAN_THRESHOLD	//threshold at 30
	low_threshold = 0.2 * STANDARD_ORGAN_THRESHOLD	//threshold at 20

	low_threshold_passed = span_info("Distant objects become somewhat less tangible.")
	high_threshold_passed = span_info("Everything starts to look a lot less clear.")
	now_failing = span_warning("Darkness envelopes you, as your eyes go blind!")
	now_fixed = span_info("Color and shapes are once again perceivable.")
	high_threshold_cleared = span_info("Your vision functions passably once more.")
	low_threshold_cleared = span_info("Your vision is cleared of any ailment.")

	var/sight_flags = 0
	var/see_in_dark = 2
	var/tint = 0
	var/eye_color = "" //set to a hex code to override a mob's eye color
	var/eye_icon_state = "eyes"
	var/old_eye_color = "fff"
	var/flash_protect = 0
	var/see_invisible = SEE_INVISIBLE_LIVING
	var/lighting_alpha
	var/no_glasses
	var/damaged	= FALSE	//damaged indicates that our eyes are undergoing some level of negative effect
	///the type of overlay we use for this eye's blind effect
	var/atom/movable/screen/fullscreen/blind/blind_type
	///Can these eyes every be cured of blind? - Each eye atom should handle this themselves, don't make this make you blind
	var/can_see = TRUE

/obj/item/organ/eyes/Insert(mob/living/carbon/eye_owner, special = FALSE, drop_if_replaced = FALSE, initialising, pref_load = FALSE)
	. = ..()
	if(!.)
		return
	if(ishuman(eye_owner))
		var/mob/living/carbon/human/human_owner = eye_owner
		old_eye_color = human_owner.eye_color
		if(eye_color)
			human_owner.eye_color = eye_color
		else
			eye_color = human_owner.eye_color
		if(HAS_TRAIT(human_owner, TRAIT_NIGHT_VISION_WEAK) && !lighting_alpha)
			lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT
	eye_owner.update_tint()
	owner.update_sight()
	if(eye_owner.has_dna() && ishuman(eye_owner))
		eye_owner.dna.species.handle_body(eye_owner) //updates eye icon

/obj/item/organ/eyes/Remove(mob/living/carbon/eye_owner, special = 0, pref_load = FALSE)
	..()
	if(ishuman(eye_owner) && eye_color)
		var/mob/living/carbon/human/human_owner = eye_owner
		human_owner.eye_color = old_eye_color
		human_owner.update_body()
	eye_owner.update_tint()
	eye_owner.update_sight()

//Gotta reset the eye color, because that persists
/obj/item/organ/eyes/enter_wardrobe()
	. = ..()
	eye_color = initial(eye_color)

/obj/item/organ/eyes/on_life(delta_time, times_fired)
	..()
	var/mob/living/carbon/C = owner
	//since we can repair fully damaged eyes, check if healing has occurred
	if((organ_flags & ORGAN_FAILING) && (damage < maxHealth))
		organ_flags &= ~ORGAN_FAILING
		C.cure_blind(EYE_DAMAGE)
	//various degrees of "oh fuck my eyes", from "point a laser at your eye" to "staring at the Sun" intensities
	if(damage > 20 && can_see)
		damaged = TRUE
		if((organ_flags & ORGAN_FAILING))
			C.become_blind(EYE_DAMAGE, blind_type)
		else if(damage > 30)
			C.overlay_fullscreen("eye_damage", /atom/movable/screen/fullscreen/impaired, 2)
		else
			C.overlay_fullscreen("eye_damage", /atom/movable/screen/fullscreen/impaired, 1)
	//called once since we don't want to keep clearing the screen of eye damage for people who are below 20 damage
	else if(damaged)
		damaged = FALSE
		C.clear_fullscreen("eye_damage")
	return


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
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/eyes/robotic/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	if(prob(30/severity))
		to_chat(owner, span_warning("Static obfuscates your vision!"))
		owner.flash_act(visual = 1)

/obj/item/organ/eyes/robotic/xray
	name = "\improper X-ray eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	eye_color = "000"
	see_in_dark = NIGHTVISION_FOV_RANGE
	sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS
	flash_protect = -INFINITY
	tint = -INFINITY

/obj/item/organ/eyes/robotic/xray/syndicate
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile. On closer look, they have been modified to protect from sudden bright flashes."
	flash_protect = 0

/obj/item/organ/eyes/robotic/thermals
	name = "thermal eyes"
	desc = "These cybernetic eye implants will give you thermal vision. Vertical slit pupil included."
	eye_color = "FC0"
	sight_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = -1
	see_in_dark = NIGHTVISION_FOV_RANGE

/obj/item/organ/eyes/robotic/flashlight
	name = "flashlight eyes"
	desc = "It's two flashlights rigged together with some wire. Why would you put these in someone's head?"
	eye_color ="fee5a3"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight_eyes"
	flash_protect = 2
	tint = INFINITY
	var/obj/item/flashlight/eyelight/eye

/obj/item/organ/eyes/robotic/flashlight/emp_act(severity)
	return

/obj/item/organ/eyes/robotic/flashlight/on_insert(mob/living/carbon/victim)
	. = ..()
	if(!eye)
		eye = new /obj/item/flashlight/eyelight()
	eye.on = TRUE
	eye.forceMove(victim)
	eye.update_brightness(victim)
	victim.become_blind("flashlight_eyes")


/obj/item/organ/eyes/robotic/flashlight/on_remove(mob/living/carbon/victim)
	. = ..()
	eye.on = FALSE
	eye.update_brightness(victim)
	eye.forceMove(src)
	victim.cure_blind("flashlight_eyes")

// Welding shield implant
/obj/item/organ/eyes/robotic/shield
	name = "shielded robotic eyes"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	flash_protect = 2

/obj/item/organ/eyes/robotic/shield/emp_act(severity)
	return

#define RGB2EYECOLORSTRING(definitionvar) ("[copytext_char(definitionvar, 2, 3)][copytext_char(definitionvar, 4, 5)][copytext_char(definitionvar, 6, 7)]")

/obj/item/organ/eyes/robotic/glow
	name = "High Luminosity Eyes"
	desc = "Special glowing eyes, used by snowflakes who want to be special."
	eye_color = "000"
	actions_types = list(/datum/action/item_action/organ_action/use, /datum/action/item_action/organ_action/toggle)
	var/current_color_string = "#ffffff"
	var/active = FALSE
	var/max_light_beam_distance = 5
	var/light_beam_distance = 5
	var/light_object_range = 2
	var/light_object_power = 2
	var/list/obj/effect/abstract/eye_lighting/eye_lighting
	var/obj/effect/abstract/eye_lighting/on_mob
	var/image/mob_overlay
	var/datum/component/mobhook

/obj/item/organ/eyes/robotic/glow/Initialize(mapload)
	. = ..()
	mob_overlay = image('icons/mob/human_face.dmi', "eyes_glow_gs")

/obj/item/organ/eyes/robotic/glow/Destroy()
	terminate_effects()
	. = ..()

/obj/item/organ/eyes/robotic/glow/Remove(mob/living/carbon/M, special = FALSE, pref_load = FALSE)
	terminate_effects()
	. = ..()

/obj/item/organ/eyes/robotic/glow/proc/terminate_effects()
	if(owner && active)
		deactivate()
	active = FALSE
	clear_visuals(TRUE)
	STOP_PROCESSING(SSfastprocess, src)

/obj/item/organ/eyes/robotic/glow/ui_action_click(owner, action)
	if(istype(action, /datum/action/item_action/organ_action/toggle))
		toggle_active()
	else if(istype(action, /datum/action/item_action/organ_action/use))
		prompt_for_controls(owner)

/obj/item/organ/eyes/robotic/glow/proc/toggle_active()
	if(active)
		deactivate()
	else
		activate()

/obj/item/organ/eyes/robotic/glow/proc/prompt_for_controls(mob/user)
	var/C = tgui_color_picker(owner, "Select Color", "Select color", "#ffffff")
	if(!C || QDELETED(src) || QDELETED(user) || QDELETED(owner) || owner != user)
		return
	var/range = input(user, "Enter range (0 - [max_light_beam_distance])", "Range Select", 0) as null|num

	set_distance(clamp(range, 0, max_light_beam_distance))
	assume_rgb(C)

/obj/item/organ/eyes/robotic/glow/proc/assume_rgb(newcolor)
	current_color_string = newcolor
	eye_color = RGB2EYECOLORSTRING(current_color_string)
	sync_light_effects()
	cycle_mob_overlay()
	if(!QDELETED(owner) && ishuman(owner))		//Other carbon mobs don't have eye color.
		owner.dna.species.handle_body(owner)

/obj/item/organ/eyes/robotic/glow/proc/cycle_mob_overlay()
	remove_mob_overlay()
	mob_overlay.color = current_color_string
	add_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/add_mob_overlay()
	if(!QDELETED(owner))
		owner.add_overlay(mob_overlay)

/obj/item/organ/eyes/robotic/glow/proc/remove_mob_overlay()
	if(!QDELETED(owner))
		owner.cut_overlay(mob_overlay)

/obj/item/organ/eyes/robotic/glow/emp_act()
	. = ..()
	if(!active || . & EMP_PROTECT_SELF)
		return
	deactivate(silent = TRUE)

/obj/item/organ/eyes/robotic/glow/Destroy()
	QDEL_NULL(mobhook) // mobhook is not our component
	return ..()

/obj/item/organ/eyes/robotic/glow/proc/activate(silent = FALSE)
	start_visuals()
	RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(update_visuals))
	if(!silent)
		to_chat(owner, span_warning("Your [src] clicks and makes a whining noise, before shooting out a beam of light!"))
	active = TRUE
	cycle_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/deactivate(silent = FALSE)
	UnregisterSignal(owner, COMSIG_ATOM_DIR_CHANGE)
	clear_visuals()
	if(!silent)
		to_chat(owner, span_warning("Your [src] shuts off!"))
	active = FALSE
	remove_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/update_visuals(datum/source, olddir, newdir)
	SIGNAL_HANDLER

	if((LAZYLEN(eye_lighting) < light_beam_distance) || !on_mob)
		regenerate_light_effects()
	var/turf/scanfrom = get_turf(owner)
	var/scandir = owner.dir
	if (newdir && scandir != newdir) // COMSIG_ATOM_DIR_CHANGE happens before the dir change, but with a reference to the new direction.
		scandir = newdir
	if(!istype(scanfrom))
		clear_visuals()
	var/turf/scanning = scanfrom
	var/stop = FALSE
	on_mob.set_light_flags(on_mob.light_flags & ~LIGHT_ATTACHED)
	on_mob.forceMove(scanning)
	for(var/i in 1 to light_beam_distance)
		scanning = get_step(scanning, scandir)
		if(IS_OPAQUE_TURF(scanning))
			stop = TRUE
		var/obj/effect/abstract/eye_lighting/L = LAZYACCESS(eye_lighting, i)
		if(stop)
			L.forceMove(src)
		else
			L.forceMove(scanning)

/obj/item/organ/eyes/robotic/glow/proc/clear_visuals(delete_everything = FALSE)
	if(delete_everything)
		QDEL_LIST(eye_lighting)
		QDEL_NULL(on_mob)
	else
		for(var/i in eye_lighting)
			var/obj/effect/abstract/eye_lighting/L = i
			L.forceMove(src)
		if(!QDELETED(on_mob))
			on_mob.set_light_flags(on_mob.light_flags | LIGHT_ATTACHED)
			on_mob.forceMove(src)

/obj/item/organ/eyes/robotic/glow/proc/start_visuals()
	if(!islist(eye_lighting))
		regenerate_light_effects()
	if((eye_lighting.len < light_beam_distance) || !on_mob)
		regenerate_light_effects()
	sync_light_effects()
	update_visuals()

/obj/item/organ/eyes/robotic/glow/proc/set_distance(dist)
	light_beam_distance = dist
	regenerate_light_effects()

/obj/item/organ/eyes/robotic/glow/proc/regenerate_light_effects()
	clear_visuals(TRUE)
	on_mob = new (src, light_object_range, light_object_power, current_color_string, LIGHT_ATTACHED)
	for(var/i in 1 to light_beam_distance)
		LAZYADD(eye_lighting, new /obj/effect/abstract/eye_lighting(src, light_object_range, light_object_power, current_color_string))
	sync_light_effects()


/obj/item/organ/eyes/robotic/glow/proc/sync_light_effects()
	for(var/e in eye_lighting)
		var/obj/effect/abstract/eye_lighting/eye_lighting = e
		eye_lighting.set_light_color(current_color_string)
	on_mob?.set_light_color(current_color_string)


/obj/effect/abstract/eye_lighting
	light_system = MOVABLE_LIGHT
	var/obj/item/organ/eyes/robotic/glow/parent


CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/abstract/eye_lighting)

/obj/effect/abstract/eye_lighting/Initialize(mapload, light_object_range, light_object_power, current_color_string, light_flags)
	. = ..()
	parent = loc
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	if(!istype(parent))
		stack_trace("/obj/effect/abstract/eye_lighting added to improper parent ([loc]). Deleting.")
		return INITIALIZE_HINT_QDEL
	if(!isnull(light_object_range))
		set_light_range(light_object_range)
	if(!isnull(light_object_power))
		set_light_power(light_object_power)
	if(!isnull(current_color_string))
		set_light_color(current_color_string)
	if(!isnull(light_flags))
		set_light_flags(light_flags)


/obj/item/organ/eyes/moth
	name = "moth eyes"
	desc = "These eyes seem to have increased sensitivity to bright light, with a small improvement to low light vision."
	see_in_dark = NIGHTVISION_FOV_RANGE/2 //4 tiles compared to 8 of the apids
	flash_protect = -1

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
	blind_type = /atom/movable/screen/fullscreen/blind/psychic
	sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS
	can_see = FALSE

/obj/item/organ/eyes/psyphoza/Insert(mob/living/carbon/M, special, drop_if_replaced, initialising)
	. = ..()
	M.become_blind("uncurable", /atom/movable/screen/fullscreen/blind/psychic, FALSE)
	M.remove_client_colour(/datum/client_colour/monochrome/blind)
	//Handle weird ability code
	var/datum/action/item_action/organ_action/psychic_highlight/P = locate(/datum/action/item_action/organ_action/psychic_highlight) in M.actions
	if(P?.removed)
		P.Grant(M)
		P?.removed = FALSE

/obj/item/organ/eyes/psyphoza/Remove(mob/living/carbon/M, special = FALSE, pref_load = FALSE)
	M.cure_blind("uncurable", TRUE)
	var/datum/action/item_action/organ_action/psychic_highlight/P = locate(/datum/action/item_action/organ_action/psychic_highlight) in M.actions
	P?.remove()
	return ..()

/obj/item/organ/eyes/diona
	name = "receptor node"
	desc = "A combination of plant matter and neurons used to produce visual feedback."
	icon_state = "diona_eyeballs"
	organ_flags = ORGAN_UNREMOVABLE
	flash_protect = -1

#undef RGB2EYECOLORSTRING
