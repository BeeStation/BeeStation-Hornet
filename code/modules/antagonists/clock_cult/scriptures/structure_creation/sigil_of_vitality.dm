/datum/clockcult/scripture/create_structure/sigil_vitality
	name = "Vitality Matrix"
	desc = "Summons a vitality matrix, which drains the life force of non servants, and can be used to heal or revive servants. Requires 2 invokers."
	tip = "Heal and revive dead servants, while draining the health from non servants."
	invokation_text = list("My life in your hands.")
	invokation_time = 5 SECONDS
	button_icon_state = "Vitality Matrix"
	invokers_required = 2
	power_cost = 300
	cogs_required = 2
	summoned_structure = /obj/structure/destructible/clockwork/sigil/vitality
	category = SPELLTYPE_SERVITUDE

/obj/structure/destructible/clockwork/sigil/vitality
	name = "vitality matrix"
	desc = "A twisting, confusing artifact that drains the unenlightended on contact."
	clockwork_desc = span_brass("A beautiful artifact that will drain the life of heretics placed on top of it.")
	icon_state = "sigilvitality"
	effect_charge_time = 2 SECONDS
	idle_color = "#5e87c4"
	invokation_color = "#83cbe7"
	success_color = "#c761d4"
	fail_color = "#525a80"
	looping = TRUE

/obj/structure/destructible/clockwork/sigil/vitality/can_affect(atom/movable/target_atom)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/living_target = target_atom

	if(IS_SERVANT_OF_RATVAR(living_target))
		return TRUE
	if(living_target.stat == DEAD)
		return FALSE
	if(HAS_TRAIT(living_target, TRAIT_NODEATH))
		return FALSE
	if(issilicon(living_target))
		return FALSE

/obj/structure/destructible/clockwork/sigil/vitality/apply_effects()
	var/mob/living/living_target = affected_atom

	if(IS_SERVANT_OF_RATVAR(living_target))
		heal_target(living_target)
	else
		drain_target(living_target)
	. = ..()

/obj/structure/destructible/clockwork/sigil/vitality/proc/heal_target(mob/living/living_target)
	if(living_target.stat == DEAD)
		// Lets try to revive our target
		var/damage_healed = 20 + (living_target.maxHealth - living_target.health) * 0.6
		if(GLOB.clockcult_vitality >= damage_healed)
			GLOB.clockcult_vitality -= damage_healed

			living_target.revive(HEAL_ALL)

			// Try to grab the target's ghost. If they don't come back, poll ghosts
			if(living_target.mind)
				living_target.mind.grab_ghost(TRUE)
			else
				var/datum/poll_config/config = new()
				config.question = "Do you want to play as a [living_target.name], an inactive clock cultist?"
				config.role = /datum/role_preference/roundstart/clock_cultist
				config.check_jobban = ROLE_SERVANT_OF_RATVAR
				config.poll_time = 10 SECONDS
				config.jump_target = living_target
				config.role_name_text = "inactive clock cultist"
				config.alert_pic = living_target

				var/mob/dead/observer/candidate = SSpolling.poll_ghosts_for_target(config, living_target)
				if(candidate)
					living_target.key = candidate.key
					message_admins("[key_name_admin(candidate)] has taken control of ([key_name_admin(living_target)]) to replace an AFK player.")
		else
			visible_message(span_neovgre("\The [src] fails to revive [living_target]!"))
	else
		// Lets try to heal our target
		var/healing_performed = clamp(living_target.maxHealth - living_target.health, 0, 5) * 0.3
		if(GLOB.clockcult_vitality >= healing_performed)
			GLOB.clockcult_vitality -= healing_performed

			living_target.adjustBruteLoss(-5, FALSE)
			living_target.adjustFireLoss(-5, FALSE)
			living_target.adjustOxyLoss(-5, FALSE)
			living_target.adjustToxLoss(-5, FALSE, TRUE)
			living_target.adjustCloneLoss(-5)

			// Stop bleeding
			if(iscarbon(living_target))
				var/mob/living/carbon/carbon_target = living_target
				carbon_target.suppress_bloodloss(BLEED_SCRATCH)
		else
			visible_message(span_neovgre("\The [src] fails to heal [living_target]!"))
			to_chat(living_target, span_neovgre("There is insufficient vitality to heal your wounds!"))

/*
* Mindless mobs give 10 vitality and real players give 40 vitality
* If the sigil kills the target, it will replace them with a cogscarab
*/
/obj/structure/destructible/clockwork/sigil/vitality/proc/drain_target(mob/living/living_target)
	if(is_convertable_to_clockcult(living_target) && !GLOB.gateway_opening)
		visible_message(span_neovgre("\The [src] refuses to siphon [living_target]'s vitality, their mind has great potential!"))
		return

	living_target.Paralyze(1 SECONDS)

	var/before_cloneloss = living_target.getCloneLoss()
	living_target.adjustCloneLoss(20, TRUE, TRUE)
	if(before_cloneloss == living_target.getCloneLoss())
		visible_message(span_neovgre("\The [src] fails to siphon [living_target]'s spirit!"))
		on_fail()
		return

	playsound(loc, 'sound/magic/clockwork/ratvar_attack.ogg', 40)

	// Replace the target with a cogscarab if the sigil kills them
	if(living_target.stat == DEAD)
		living_target.dust(drop_items = TRUE)

		playsound(loc, 'sound/magic/exit_blood.ogg', 60)

		var/mob/cogger = new /mob/living/simple_animal/drone/cogscarab(get_turf(living_target))
		cogger.key = living_target.key
		if(!cogger.grab_ghost(TRUE))
			//Replace the mob with a shell
			qdel(cogger)
			new /obj/effect/mob_spawn/drone/cogscarab(get_turf(living_target))
		add_servant_of_ratvar(cogger, silent=TRUE)

	// Give vitality
	if(living_target.mind)
		living_target.visible_message(span_neovgre("[living_target] looks weak as the color fades from their body."), span_neovgre("You feel your soul faltering..."))
		GLOB.clockcult_vitality += 40
	else
		GLOB.clockcult_vitality += 10
