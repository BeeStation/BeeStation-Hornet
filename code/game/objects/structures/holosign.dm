
//holographic signs and barriers

/obj/structure/holosign
	name = "holo sign"
	icon = 'icons/effects/holosigns.dmi'
	icon_state = "holosign"
	anchored = TRUE
	max_integrity = 1
	armor_type = /datum/armor/structure_holosign
	resistance_flags = FREEZE_PROOF
	layer = BELOW_OBJ_LAYER

	/// The holoprojector that created this sign
	var/obj/item/holosign_creator/projector

/datum/armor/structure_holosign
	bullet = 50
	laser = 50
	energy = 50
	fire = 20
	acid = 20

/obj/structure/holosign/Initialize(mapload, source_projector)
	. = ..()
	create_vis_overlay()
	if(source_projector)
		projector = source_projector
		LAZYADD(projector.signs, src)

/obj/structure/holosign/Destroy()
	if(projector)
		LAZYREMOVE(projector.signs, src)
		projector = null
	return ..()

/obj/structure/holosign/update_atom_colour()
	. = ..()
	create_vis_overlay()

/obj/structure/holosign/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!. && isprojectile(mover)) // Its short enough to be shot over
		return TRUE

/obj/structure/holosign/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	user.changeNext_move(CLICK_CD_MELEE)
	take_damage(5, BRUTE, MELEE, TRUE)
	log_combat(user, src, "swatted")

/obj/structure/holosign/emp_act(severity)
	take_damage(max_integrity / severity, BRUTE, MELEE, TRUE)

/obj/structure/holosign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/weapons/egloves.ogg', 80, 1)
		if(BURN)
			playsound(loc, 'sound/weapons/egloves.ogg', 80, 1)

/**
 * We are lying, don't use the actual icon, instead use an overlay
 */
/obj/structure/holosign/proc/create_vis_overlay()
	// You see mobs under it, but you hit them like they are above it
	alpha = 0
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	var/obj/effect/overlay/vis/overlay = SSvis_overlays.add_vis_overlay(src, icon, icon_state, ABOVE_MOB_LAYER, plane, dir, add_appearance_flags = RESET_ALPHA)
	if (color)
		overlay.add_atom_colour(color, FIXED_COLOUR_PRIORITY)

/obj/structure/holosign/wetsign
	name = "wet floor sign"
	desc = "The words flicker as if they mean nothing."
	icon_state = "holosign"

/obj/structure/holosign/barrier
	name = "security holobarrier"
	desc = "A strong short security holographic barrier used for crowd control and blocking crime scenes. Can only be passed by walking."
	icon_state = "holosign_sec"
	base_icon_state = "holosign_sec"
	pass_flags_self = PASSTABLE | PASSGRILLE | PASSTRANSPARENT | LETPASSTHROW
	density = TRUE
	max_integrity = 20

	/// Can we pass through it on walk intent?
	var/allow_walk = TRUE

/obj/structure/holosign/barrier/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return

	if(iscarbon(mover))
		var/mob/living/carbon/moving_carbon = mover
		if(moving_carbon.stat != CONSCIOUS) // Lets not prevent dragging unconscious/dead people.
			return TRUE
		if(allow_walk && moving_carbon.m_intent == MOVE_INTENT_WALK)
			return TRUE

	if(issilicon(mover))
		return TRUE

/obj/structure/holosign/barrier/wetsign
	name = "wet floor holobarrier"
	desc = "When it says walk it means walk."
	icon_state = "holosign"

/obj/structure/holosign/barrier/wetsign/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/vehicle/ridden/janicart))
		return TRUE

/obj/structure/holosign/barrier/engineering
	name = "engineering holobarrier"
	desc = "A short engineering holographic barrier used for designating hazardous zones, slightly blocks radiation. Can only be passed by walking."
	icon_state = "holosign_engi"
	rad_insulation = RAD_LIGHT_INSULATION

/obj/structure/holosign/barrier/atmos
	name = "holofirelock"
	desc = "A holographic barrier resembling a firelock. Though it does not prevent solid objects from passing through, gas is kept out."
	icon_state = "holo_firelock"
	density = FALSE
	anchored = TRUE
	can_atmos_pass = ATMOS_PASS_NO
	alpha = 150
	rad_insulation = RAD_LIGHT_INSULATION

/obj/structure/holosign/barrier/atmos/proc/clearview_transparency()
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 25
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	SSvis_overlays.add_vis_overlay(src, icon, icon_state, ABOVE_MOB_LAYER, plane, dir)

/obj/structure/holosign/barrier/atmos/proc/reset_transparency()
	mouse_opacity = initial(mouse_opacity)
	alpha = initial(alpha)
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	SSvis_overlays.add_vis_overlay(src, icon, icon_state, ABOVE_MOB_LAYER, plane, dir, add_appearance_flags = RESET_ALPHA)

/obj/structure/holosign/barrier/atmos/robust
	name = "holo blast door"
	desc = "A really robust holographic barrier resembling a blast door. Though it does not prevent solid objects from passing through, gas is kept out."
	icon_state = "holo_blastlock"
	max_integrity = 500


/obj/structure/holosign/barrier/atmos/Initialize(mapload)
	. = ..()
	var/turf/local = get_turf(loc)
	ADD_TRAIT(local, TRAIT_FIREDOOR_STOP, TRAIT_GENERIC)
	air_update_turf(TRUE, TRUE)

/obj/structure/holosign/barrier/atmos/Destroy()
	var/turf/local = get_turf(loc)
	REMOVE_TRAIT(local, TRAIT_FIREDOOR_STOP, TRAIT_GENERIC)
	air_update_turf(TRUE, FALSE)
	return ..()

/obj/structure/holosign/barrier/atmos/Move(atom/newloc, direct)
	var/turf/local = get_turf(loc)
	REMOVE_TRAIT(local, TRAIT_FIREDOOR_STOP, TRAIT_GENERIC)
	return ..()

/obj/structure/holosign/barrier/cyborg
	name = "Energy Field"
	desc = "A fragile energy field that blocks movement. Excels at blocking lethal projectiles."
	density = TRUE
	max_integrity = 10
	allow_walk = FALSE

/obj/structure/holosign/barrier/cyborg/bullet_act(obj/projectile/projectile)
	take_damage(projectile.damage / 5, BRUTE, MELEE, TRUE)	// Doesn't really matter what damage flag it is.

	if(istype(projectile, /obj/projectile/energy/electrode))
		take_damage(10, BRUTE, MELEE, 1) // Tasers aren't harmful.
	else if(istype(projectile, /obj/projectile/beam/disabler))
		take_damage(5, BRUTE, MELEE, 1) // Disablers aren't harmful.

	return BULLET_ACT_HIT

/obj/structure/holosign/barrier/medical
	name = "\improper PENLITE holobarrier"
	desc = "A holobarrier that uses biometrics to detect human viruses. Denies passing to personnel with easily-detected, malicious viruses. Good for quarantines."
	icon_state = "holo_medical"
	base_icon_state = "holo_medical"

	COOLDOWN_DECLARE(virus_detected)

/obj/structure/holosign/barrier/medical/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/vehicle/ridden))
		for(var/mob/rider in mover.buckled_mobs)
			if(ishuman(rider))
				return check_human(rider)
	if(ishuman(mover))
		return check_human(mover)
	return TRUE

/obj/structure/holosign/barrier/medical/Bumped(atom/movable/AM)
	. = ..()
	icon_state = base_icon_state
	update_icon_state()
	if(!ishuman(AM) && check_human(AM))
		return

	if(!COOLDOWN_FINISHED(src, virus_detected))
		return

	playsound(src, 'sound/machines/buzz-sigh.ogg', 65, TRUE, 4)
	COOLDOWN_START(src, virus_detected, 1 SECONDS)
	icon_state = "holo_medical-deny"
	update_icon_state()

/obj/structure/holosign/barrier/medical/proc/check_human(mob/living/carbon/human/sickboi)
	var/threat = sickboi.check_virus()
	if(get_disease_danger_value(threat) > get_disease_danger_value(DISEASE_MINOR))
		return FALSE
	return TRUE

/obj/structure/holosign/barrier/cyborg/hacked
	name = "Charged Energy Field"
	desc = "A powerful energy field that blocks movement. Energy arcs off it."
	max_integrity = 20

	COOLDOWN_DECLARE(shock_cooldown)

/obj/structure/holosign/barrier/cyborg/hacked/bullet_act(obj/projectile/projectile)
	take_damage(projectile.damage, BRUTE, MELEE, 1)	//Yeah no this doesn't get projectile resistance.
	return BULLET_ACT_HIT

/obj/structure/holosign/barrier/cyborg/hacked/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(!COOLDOWN_FINISHED(src, shock_cooldown))
		return

	if(isliving(user))
		var/mob/living/living_user = user
		living_user.electrocute_act(15, "Energy Barrier", flags = SHOCK_NOGLOVES)
		COOLDOWN_START(src, shock_cooldown, 0.5 SECONDS)

/obj/structure/holosign/barrier/cyborg/hacked/Bumped(atom/movable/AM)
	if(!isliving(AM))
		return

	if(!COOLDOWN_FINISHED(src, shock_cooldown))
		return

	var/mob/living/victim = AM
	victim.electrocute_act(15, "Energy Barrier", flags = SHOCK_NOGLOVES)
	COOLDOWN_START(src, shock_cooldown, 0.5 SECONDS)
