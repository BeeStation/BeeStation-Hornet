//==================================//
// !      Sigil of Vitality ! //
//==================================//
/datum/clockcult/scripture/create_structure/sigil_vitality
	name = "Vitality Matrix"
	desc = "Summons a vitality matrix, which drains the life force of non servants, and can be used to heal or revive servants. Requires 2 invokers."
	tip = "Heal and revive dead servants, while draining the health from non servants."
	button_icon_state = "Sigil of Vitality"
	power_cost = 400
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
	if(is_servant_of_ratvar(M))
		return TRUE
	if(M.stat == DEAD)
		return FALSE
	var/amc = M.anti_magic_check()
	if(amc)
		return FALSE
	if(HAS_TRAIT(M, TRAIT_NODEATH))
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/sigil/vitality/apply_effects(mob/living/M)
	if(!..())
		return FALSE
	if(is_servant_of_ratvar(M))
		if(M.stat == DEAD)
			var/damage_healed = 20 + ((M.maxHealth - M.health) * 0.6)
			if(GLOB.clockcult_vitality >= damage_healed)
				GLOB.clockcult_vitality -= damage_healed
				M.revive(TRUE, TRUE)
				if(M.mind)
					M.mind.grab_ghost(TRUE)
				else
					var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [M.name], an inactive clock cultist?", ROLE_SERVANT_OF_RATVAR, null, ROLE_SERVANT_OF_RATVAR, 50, M)
					if(LAZYLEN(candidates))
						var/mob/dead/observer/C = pick(candidates)
						message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(M)]) to replace an AFK player.")
						M.key = C.key
			else
				visible_message("<span class='neovgre'>\The [src] fails to revive [M]!</span>")
			return
		var/healing_performed = CLAMP(M.maxHealth - M.health, 0, 5)	//5 Vitality to heal 5 of all damage types at once
		if(GLOB.clockcult_vitality >= healing_performed * 0.3)
			GLOB.clockcult_vitality -= healing_performed * 0.3
			//Do healing
			M.adjustBruteLoss(-5, FALSE)
			M.adjustFireLoss(-5, FALSE)
			M.adjustOxyLoss(-5, FALSE)
			M.adjustToxLoss(-5, FALSE)
			M.adjustCloneLoss(-5)
		else
			visible_message("<span class='neovgre'>\The [src] fails to heal [M]!</span>", "<span class='neovgre'>There is insufficient vitality to heal your wounds!</span>")
	else
		if(M.anti_magic_check())
			return
		M.Paralyze(10)
		M.adjustCloneLoss(20)
		playsound(loc, 'sound/magic/clockwork/ratvar_attack.ogg', 40)
		if(M.stat == DEAD)
			M.become_husk()
			M.death()
			playsound(loc, 'sound/magic/exit_blood.ogg', 60)
			to_chat(M, "<span class='neovgre'>The last of your life is drained away...</span>")
			hierophant_message("[M] has had their vitality drained by the [src]!", null, "<span class='inathneq'>")
			return
		if(M.client)
			M.visible_message("<span class='neovgre'>[src] looks weak as the color fades from their body.</span>", "<span class='neovgre'>You feel your soul faltering...</span>")
			GLOB.clockcult_vitality += 30
		GLOB.clockcult_vitality += 10
