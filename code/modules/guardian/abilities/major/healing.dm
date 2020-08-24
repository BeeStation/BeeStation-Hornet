/datum/guardian_ability/major/healing
	name = "Healing"
	desc = "Allows the guardian to heal anything, living or inanimate, by touch."
	ui_icon = "briefcase-medical"
	cost = 4
	has_mode = TRUE
	mode_on_msg = "<span class='danger'><B>You switch to healing mode.</span></B>"
	mode_off_msg = "<span class='danger'><B>You switch to combat mode.</span></B>"
	arrow_weight = 1.1

/datum/guardian_ability/major/healing/Apply()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(guardian)

/datum/guardian_ability/major/healing/Remove()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.remove_hud_from(guardian)

/datum/guardian_ability/major/healing/Attack(atom/target)
	if(mode)
		if(target == guardian)
			to_chat(guardian, "<span class='danger bold'>You can't heal yourself!</span>")
			return TRUE
		if(isliving(target))
			var/mob/living/L = target
			guardian.do_attack_animation(L)
			var/heals = -(master_stats.potential * 0.8 + 3)
			if(!guardian.is_deployed())
				heals = min(heals * 0.5, -2)
			L.adjustBruteLoss(heals)
			L.adjustFireLoss(heals)
			L.adjustOxyLoss(heals)
			L.adjustToxLoss(heals)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(L))
			H.color = guardian.guardiancolor
			if(L == guardian.summoner?.current)
				guardian.update_health_hud()
				guardian.med_hud_set_health()
				guardian.med_hud_set_status()
			return TRUE
		else if(isobj(target))
			var/obj/O = target
			guardian.do_attack_animation(O)
			O.obj_integrity = min(O.obj_integrity + (O.max_integrity * 0.1), O.max_integrity)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(O))
			H.color = guardian.guardiancolor
			return TRUE
