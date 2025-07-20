//==================================//
// !      Sigil of Vitality ! //
//==================================//
/datum/clockcult/scripture/create_structure/sigil_vitality
	name = "Vitality Matrix"
	desc = "Summons a vitality matrix, which drains the life force of non servants, and can be used to heal or revive servants. Requires 2 invokers."
	tip = "Heal and revive dead servants, while draining the health from non servants."
	button_icon_state = "Vitality Matrix"
	power_cost = 300
	invokation_time = 50
	invokation_text = list("My life in your hands.")
	summoned_structure = /obj/structure/destructible/clockwork/sigil/vitality
	cogs_required = 2
	invokers_required = 2
	category = SPELLTYPE_SERVITUDE

//==========Vitality=========
/obj/structure/destructible/clockwork/sigil/vitality
	name = "vitality matrix"
	desc = "A twisting, confusing artifact that drains the unenlightended on contact."
	clockwork_desc = "A beautiful artifact that will drain the life of heretics placed on top of it."
	icon_state = "sigilvitality"
	effect_stand_time = 20
	idle_color = "#5e87c4"
	invokation_color = "#83cbe7"
	pulse_color = "#c761d4"
	fail_color = "#525a80"
	looping = TRUE

/obj/structure/destructible/clockwork/sigil/vitality/can_affect(mob/living/M)
	if(IS_SERVANT_OF_RATVAR(M))
		return TRUE
	if(M.stat == DEAD)
		return FALSE
	var/amc = M.can_block_magic(MAGIC_RESISTANCE_HOLY)
	if(amc)
		return FALSE
	if(HAS_TRAIT(M, TRAIT_NODEATH))
		return FALSE
	if(issilicon(M))
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/sigil/vitality/apply_effects(mob/living/M)
	if(!..())
		return FALSE
	if(IS_SERVANT_OF_RATVAR(M))
		if(M.stat == DEAD)
			var/damage_healed = 20 + ((M.maxHealth - M.health) * 0.6)
			if(GLOB.clockcult_vitality >= damage_healed)
				GLOB.clockcult_vitality -= damage_healed
				M.revive(TRUE, TRUE)
				if(M.mind)
					M.mind.grab_ghost(TRUE)
				else
					var/mob/dead/observer/candidate = SSpolling.poll_ghosts_for_target(
						question = "Do you want to play as a [M.name], an inactive clock cultist?",
						role = /datum/role_preference/roundstart/clock_cultist,
						check_jobban = ROLE_SERVANT_OF_RATVAR,
						poll_time = 10 SECONDS,
						checked_target = M,
						jump_target = M,
						role_name_text = "inactive clock cultist",
						alert_pic = M,
					)
					if(candidate)
						M.key = candidate.key
						message_admins("[key_name_admin(candidate)] has taken control of ([key_name_admin(M)]) to replace an AFK player.")
			else
				visible_message(span_neovgre("\The [src] fails to revive [M]!"))
			return
		var/healing_performed = clamp(M.maxHealth - M.health, 0, 5)	//5 Vitality to heal 5 of all damage types at once
		if(GLOB.clockcult_vitality >= healing_performed * 0.3)
			GLOB.clockcult_vitality -= healing_performed * 0.3
			//Do healing
			M.adjustBruteLoss(-5, FALSE)
			M.adjustFireLoss(-5, FALSE)
			M.adjustOxyLoss(-5, FALSE)
			M.adjustToxLoss(-5, FALSE, TRUE)
			M.adjustCloneLoss(-5)
		else
			visible_message(span_neovgre("\The [src] fails to heal [M]!"), span_neovgre("There is insufficient vitality to heal your wounds!"))
	else
		if(M.can_block_magic(MAGIC_RESISTANCE_HOLY))
			return
		if(is_convertable_to_clockcult(M) && !GLOB.gateway_opening)
			visible_message(span_neovgre("\The [src] refuses to siphon [M]'s vitality, their mind has great potential!"))
			return
		M.Paralyze(10)
		var/before_cloneloss = M.getCloneLoss()
		M.adjustCloneLoss(20, TRUE, TRUE)
		var/after_cloneloss = M.getCloneLoss()
		if(before_cloneloss == after_cloneloss)
			visible_message(span_neovgre("\The [src] fails to siphon [M]'s spirit!"))
			return
		playsound(loc, 'sound/magic/clockwork/ratvar_attack.ogg', 40)
		if(M.stat == DEAD && length(GLOB.servant_spawns))
			M.become_husk()
			M.death()
			playsound(loc, 'sound/magic/exit_blood.ogg', 60)
			to_chat(M, span_neovgre("The last of your life is drained away..."))
			hierophant_message("[M] has had their vitality drained by the [src]!", null, "<span class='inathneq'>")
			var/mob/cogger = new /mob/living/simple_animal/drone/cogscarab(get_turf(M))
			cogger.key = M.key
			if(!cogger.grab_ghost(TRUE))
				//Replace the mob with a shell
				qdel(cogger)
				new /obj/effect/mob_spawn/drone/cogscarab(get_turf(M))
			add_servant_of_ratvar(cogger, silent=TRUE)
			return
		if(M.client)
			M.visible_message(span_neovgre("[M] looks weak as the color fades from their body."), span_neovgre("You feel your soul faltering..."))
			GLOB.clockcult_vitality += 30
		GLOB.clockcult_vitality += 10
