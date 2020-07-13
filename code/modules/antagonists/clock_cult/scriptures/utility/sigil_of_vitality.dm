//==================================//
// !      Sigil of Vitality - WIP VERY BROKEN     ! //
//==================================//
/datum/clockcult/scripture/create_structure/sigil_vitality
	name = "Vitality Matrix"
	desc = "Summons a vitality matrix, which drains the life force of non servants, and can be used to heal or revive servants."
	tip = "Heal and revive dead servants, while draining the health from non servants."
	button_icon_state = "Sigil of Vitality"
	power_cost = 400
	invokation_time = 50
	invokation_text = list("My life in your hands.")
	summoned_structure = /obj/structure/destructible/clockwork/sigil/vitality
	cogs_required = 2
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
			var/damage_healed = 20 + M.maxHealth - M.health
			if(GLOB.clockcult_vitality >= damage_healed)
				GLOB.clockcult_vitality -= damage_healed
				M.revive(TRUE)
				addtimer(CALLBACK(src, .proc/try_restart, M), 5)
			else
				visible_message("<span class='neovgre'>\The [src] fails to revive [M]!</span>")
			return
		if(M.health == M.maxHealth)
			addtimer(CALLBACK(src, .proc/try_restart, M), 5)
			return
		var/healing_performed = CLAMP(M.maxHealth - M.health, 0, 5)	//5 Vitality to heal 5 of all damage types at once
		if(GLOB.clockcult_vitality >= healing_performed)
			GLOB.clockcult_vitality -= healing_performed
			//Do healing
			M.adjustBruteLoss(-5, FALSE)
			M.adjustFireLoss(-5, FALSE)
			M.adjustOxyLoss(-5, FALSE)
			M.adjustToxLoss(-5, FALSE)
			M.adjustCloneLoss(-5)
			addtimer(CALLBACK(src, .proc/try_restart, M), 5)
		else
			visible_message("<span class='neovgre'>\The [src] fails to heal [M]!</span>", "<span class='neovgre'>There is insufficient vitality to heal your wounds!</span>")
	else
		M.Paralyze(10)
		M.adjustCloneLoss(20)
		playsound(loc, 'sound/magic/clockwork/ratvar_attack.ogg', 40)
		if(M.health <= 0)
			M.become_husk()
			M.death()
			playsound(loc, 'sound/magic/exit_blood.ogg', 60)
			to_chat(M, "<span class='neovgre'>The last of your life is drained away...</span>")
			hierophant_message("[M] has had their vitality drained by the [src]!", null, "<span class='inathneq'>")
			return
		addtimer(CALLBACK(src, .proc/try_restart, M), 5)
		if(M.client)
			M.visible_message("<span class='neovgre'>[src] looks weak as the color fades from their body.</span>", "<span class='neovgre'>You feel your soul faltering...</span>")
			GLOB.clockcult_vitality += 15
		GLOB.clockcult_vitality += 5

/obj/structure/destructible/clockwork/sigil/vitality/proc/try_restart(mob/living/M)
	if(!active_timer)
		currently_affecting = M
		active_timer = addtimer(CALLBACK(src, .proc/apply_effects, M), effect_stand_time, TIMER_UNIQUE | TIMER_STOPPABLE)
		animate(src, color=invokation_color, alpha=120, effect_stand_time)
