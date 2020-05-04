/obj/item/clothing/neck/petcollar/syndie	//For true gamer felinids
	name = "suspicious pet collar"
	desc = "A suspicious looking pet collar designed for inferior species."
	icon_state = "petcollar_syndie"
	flash_protect = 3
	bang_protect = 5
	var/pouncing = FALSE
	var/pounce_nextuse = 0
	var/pounce_cooldown = 50

/obj/item/clothing/neck/petcollar/syndie/equipped(mob/user, slot)
	pouncing = FALSE
	var/mob/living/carbon/human/H = user
	if(!istype(H))	//Give the spell to non-catpeople but make it do something worse
		return
	if(slot == SLOT_NECK)
		H.AddSpell(new /obj/effect/proc_holder/spell/pounce)

/obj/item/clothing/neck/petcollar/syndie/dropped(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	H.RemoveSpell(/obj/effect/proc_holder/spell/pounce)

//================================
//========= Pounce Spell =========
//================================

/obj/effect/proc_holder/spell/pounce
	name = "Pounce"
	desc = "Pounce towards a target."
	school = "felinid"
	charge_type = "recharge"
	charge_max = 100
	clothes_req = FALSE
	invocation = "Nya~"
	invocation_type = "shout"
	range = 20
	action_icon_state = "pounce1"
	var/base_icon_state = "pounce"

/obj/effect/proc_holder/spell/pounce/Click()
	var/mob/living/user = usr
	if(!istype(user))
		return
	var/msg
	if(!can_cast(user))
		msg = "<span class='warning'>You can no longer cast [name]!</span>"
		remove_ranged_ability(msg)
		return
	if(active)
		msg = "<span class='notice'>You are no longer ready to pounce.</span>"
		if(charge_type == "recharge")
			charge_counter = charge_max
			start_recharge()
		remove_ranged_ability(msg)
	else
		msg = "<span class='notice'>You ready yourself to pounce! <B>Left-click to pounce towards a target!</B></span>"
		add_ranged_ability(user, msg, TRUE)

/obj/effect/proc_holder/spell/pounce/update_icon()
	if(!action)
		return
	action.button_icon_state = "[base_icon_state][active]"
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/pounce/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return FALSE
	if(!cast_check(FALSE, ranged_ability_user))
		remove_ranged_ability()
		return FALSE
	var/list/targets = list(target)
	perform(targets, TRUE, user = ranged_ability_user)
	return TRUE

/obj/effect/proc_holder/spell/pounce/cast(list/targets, mob/living/user)
	var/target = targets[1]
	user.throw_at(target, 5, 10)
	var/mob/living/carbon/human/H = user
	if(iscatperson(H))
		user.SetParalyzed(0)	//Cat people are quick and recover faster.
	remove_ranged_ability() //Auto-disable the ability once you run out of bullets.
	charge_counter = 0
	start_recharge()
	return TRUE
