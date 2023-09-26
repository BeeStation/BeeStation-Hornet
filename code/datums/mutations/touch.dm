/datum/mutation/shock
	name = "Shock Touch"
	desc = "A mutation that allows the user to store accumulated bioelectric and static charge, consciously discharging it upon others with no harm to themselves."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	power = /obj/effect/proc_holder/spell/targeted/touch/shock
	instability = 30
	locked = TRUE

/obj/effect/proc_holder/spell/targeted/touch/shock
	name = "Shock Touch"
	desc = "Channel electricity to your hand to shock people with."
	drawmessage = "You channel electricity into your hand."
	dropmessage = "You let the electricity from your hand dissipate."
	hand_path = /obj/item/melee/touch_attack/shock
	charge_max = 100
	clothes_req = FALSE
	action_icon_state = "zap"

/obj/item/melee/touch_attack/shock
	name = "\improper shock touch"
	desc = "This is kind of like when you rub your feet on a shag rug so you can zap your friends, only a lot less safe."
	catchphrase = null
	on_use_sound = 'sound/weapons/zapbang.ogg'
	icon_state = "zapper"
	item_state = "zapper"

/obj/item/melee/touch_attack/shock/afterattack(atom/target, mob/living/carbon/user, proximity)
	user.Beam(target, icon_state="lightning[rand(1,12)]", time=5, maxdistance = 32)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.electrocute_act(15, user, 1, FALSE, FALSE, FALSE, FALSE, FALSE))//doesnt stun. never let this stun
			C.dropItemToGround(C.get_active_held_item())
			C.dropItemToGround(C.get_inactive_held_item())
			C.confused += 15
			C.visible_message("<span class='danger'>[user] electrocutes [target]!</span>","<span class='userdanger'>[user] electrocutes you!</span>")
			use_charge(user)
			return ..()
		else
			user.visible_message("<span class='warning'>[user] fails to electrocute [target]!</span>")
			use_charge(user)
			return ..()
	else if(isliving(target))
		var/mob/living/L = target
		L.electrocute_act(15, user, 1, FALSE, FALSE, FALSE, FALSE)
		L.visible_message("<span class='danger'>[user] electrocutes [target]!</span>","<span class='userdanger'>[user] electrocutes you!</span>")
		use_charge(user)
		return ..()
	else
		to_chat(user,"<span class='warning'>The electricity doesn't seem to affect [target]...</span>")
		use_charge(user)
		return ..()
