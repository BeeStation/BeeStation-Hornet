/obj/effect/proc_holder/spell/pointed/trigger/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single target."
	school = "transmutation"
	charge_max = 300
	clothes_req = FALSE
	invocation = "STI KALY"
	invocation_type = "whisper"
	message = "<span class='notice'>Your eyes cry out in pain!</span>"
	cooldown_min = 50 //12 deciseconds reduction per rank
	starting_spells = list("/obj/effect/proc_holder/spell/targeted/inflict_handler/blind", "/obj/effect/proc_holder/spell/targeted/genetic/blind")
	ranged_mousepointer = 'icons/effects/blind_target.dmi'
	action_icon_state = "blind"
	base_icon_state = "blind"
	active_msg = "You prepare to blind a target..."

/obj/effect/proc_holder/spell/targeted/inflict_handler/blind
	amt_eye_blind = 10
	amt_eye_blurry = 20
	sound = 'sound/magic/blind.ogg'

/obj/effect/proc_holder/spell/targeted/genetic/blind
	mutations = list(BLINDMUT)
	duration = 300
	charge_max = 400 // needs to be higher than the duration or it'll be permanent
	sound = 'sound/magic/blind.ogg'

/obj/effect/proc_holder/spell/pointed/trigger/blind/intercept_check(mob/user, atom/target)
	if(!..())
		return FALSE
	if(!isliving(target))
		to_chat(user, "<span class='warning'>You can only blind living beings!</span>")
		return FALSE
	return TRUE
