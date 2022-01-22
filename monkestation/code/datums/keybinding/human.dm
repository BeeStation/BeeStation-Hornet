//Quick Emote Binds

/datum/keybinding/emote
	category = CATEGORY_EMOTE
	weight = WEIGHT_LIVING

/datum/keybinding/emote/down(client/user)
	. = ..()
	if(ishuman(user.mob))
		var/mob/living/carbon/human/Player = user.mob
		Player.emote(name)
		spawn(10)
			Player.emote_cooling_down = FALSE

/datum/keybinding/emote/fart
	key = "Shift-F"
	name = "fart"
	full_name = "Fart"
	description = "GAS GAS GAS..."
	keybind_signal = COMSIG_KB_EMOTE_QUICK_FART

/datum/keybinding/emote/fart/down(client/user)
	if(ishuman(user.mob) && user.mob.stat == CONSCIOUS)
		var/mob/living/carbon/human/Player = user.mob
		if(!Player.emote_cooling_down)
			Player.emote_cooling_down = TRUE
			..()

/datum/keybinding/emote/scream
	key = "Shift-R"
	name = "scream"
	full_name = "Scream"
	description = "AAAAAAAAaaaaaaaaaAAAAAAAAAA"
	keybind_signal = COMSIG_KB_EMOTE_QUICK_SCREAM

/datum/keybinding/emote/scream/down(client/user)
	if(ishuman(user.mob) && user.mob.stat == CONSCIOUS)
		var/mob/living/carbon/human/Player = user.mob
		if(!Player.emote_cooling_down)
			Player.emote_cooling_down = TRUE
			Player.adjustOxyLoss(5)
			..()

/datum/keybinding/emote/clap
	key = "Unbound"
	name = "clap"
	full_name = "Clap"
	description = "BRAVO, BRAVO!"
	keybind_signal = COMSIG_KB_EMOTE_QUICK_CLAP

/datum/keybinding/emote/clap/down(client/user)
	if(ishuman(user.mob) && user.mob.stat == CONSCIOUS)
		var/mob/living/carbon/human/Player = user.mob
		if(!Player.emote_cooling_down)
			Player.emote_cooling_down = TRUE
			..()

/datum/keybinding/emote/flip
	key = "Unbound"
	name = "flip"
	full_name = "Flip"
	description = "Flip out"
	keybind_signal = COMSIG_KB_EMOTE_QUICK_FLIP

/datum/keybinding/emote/flip/down(client/user)
	if(ishuman(user.mob) && user.mob.stat == CONSCIOUS)
		var/mob/living/carbon/human/Player = user.mob
		if(!Player.emote_cooling_down)
			Player.emote_cooling_down = TRUE
		if(Player.IsStun())
			return
		if(Player.dizziness >= 20)
			Player.vomit()
			return
		Player.dizziness++
		..()

/datum/keybinding/emote/spin
	key = "Unbound"
	name = "spin"
	full_name = "Spin"
	description = "Spin to win"
	keybind_signal = COMSIG_KB_EMOTE_QUICK_SPIN

/datum/keybinding/emote/spin/down(client/user)
	if(ishuman(user.mob) && user.mob.stat == CONSCIOUS)
		var/mob/living/carbon/human/Player = user.mob
		if(!Player.emote_cooling_down)
			Player.emote_cooling_down = TRUE
		if(Player.IsStun())
			return
		if(Player.dizziness >= 20)
			Player.vomit()
			return
		Player.dizziness++
		..()
