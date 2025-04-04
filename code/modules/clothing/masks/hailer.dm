
// **** Security gas mask ****

/obj/item/clothing/mask/gas/sechailer
	name = "security gas mask"
	desc = "A standard issue Security gas mask with integrated 'Compli-o-nator 3000' device. Plays over a dozen pre-recorded compliance phrases designed to get scumbags to stand still whilst you tase them. Do not tamper with the device."
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/adjust)
	icon_state = "sechailer"
	item_state = "sechailer"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEFACIALHAIR | HIDEFACE | HIDESNOUT
	w_class = WEIGHT_CLASS_SMALL
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	visor_flags_inv = HIDEFACE | HIDESNOUT
	flags_cover = MASKCOVERSMOUTH | MASKCOVERSEYES
	visor_flags_cover = MASKCOVERSMOUTH | MASKCOVERSEYES
	unique_death = 'sound/voice/sec_death.ogg'
	var/aggressiveness = 2
	var/cooldown_special
	var/recent_uses = 0
	var/broken_hailer = 0
	var/safety = TRUE

/obj/item/clothing/mask/gas/sechailer/spacepol
	name = "spacepol mask"
	desc = "A standard issue gas mask with integrated 'Compli-o-nator 3000' device, created in cooperation with a certain megacorporation. Plays over a dozen pre-recorded compliance phrases designed to get scumbags to stand still whilst you tase them. Do not tamper with the device."

/obj/item/clothing/mask/gas/sechailer/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000."
	actions_types = list(/datum/action/item_action/halt)
	icon_state = "swat"
	item_state = "swat"
	aggressiveness = 3
	flags_inv = HIDEFACIALHAIR | HIDEFACE | HIDEEYES | HIDEEARS | HIDEHAIR | HIDESNOUT
	visor_flags_inv = 0
	armor_type = /datum/armor/sechailer_swat


/datum/armor/sechailer_swat
	melee = 10
	bullet = 5
	laser = 5
	energy = 5
	bio = 50
	fire = 20
	acid = 40
	stamina = 30
	bleed = 30

/obj/item/clothing/mask/gas/sechailer/swat/emagged
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000. This one seems to have the safety toggled off..."
	safety = FALSE

/obj/item/clothing/mask/gas/sechailer/swat/spacepol
	name = "spacepol mask"
	desc = "A close-fitting tactical mask created in cooperation with a certain megacorporation, comes with an especially aggressive Compli-o-nator 3000."
	icon_state = "spacepol"
	item_state = "spacepol"

/obj/item/clothing/mask/gas/sechailer/cyborg
	name = "security hailer"
	desc = "A set of recognizable pre-recorded messages for cyborgs to use when apprehending criminals."
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_idle"
	slot_flags = null
	aggressiveness = 1 //Borgs are nicecurity!
	actions_types = list(/datum/action/item_action/halt)

/obj/item/clothing/mask/gas/sechailer/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	switch(aggressiveness)
		if(1)
			to_chat(user, span_notice("You set the restrictor to the middle position."))
			aggressiveness = 2
		if(2)
			to_chat(user, span_notice("You set the restrictor to the last position."))
			aggressiveness = 3
		if(3)
			to_chat(user, span_notice("You set the restrictor to the first position."))
			aggressiveness = 1
		if(4)
			to_chat(user, span_danger("You adjust the restrictor but nothing happens, probably because it's broken."))
	return TRUE

/obj/item/clothing/mask/gas/sechailer/wirecutter_act(mob/living/user, obj/item/I)
	if(aggressiveness != 4)
		to_chat(user, span_danger("You broke the restrictor!"))
		aggressiveness = 4
	return TRUE

/obj/item/clothing/mask/gas/sechailer/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/halt))
		halt()
	else
		adjustmask(user)

/obj/item/clothing/mask/gas/sechailer/attack_self()
	halt()

/obj/item/clothing/mask/gas/sechailer/should_emag(mob/user)
	return safety && ..()

/obj/item/clothing/mask/gas/sechailer/on_emag(mob/user)
	..()
	safety = FALSE
	to_chat(user, span_warning("You silently fry [src]'s vocal circuit with the cryptographic sequencer."))

/obj/item/clothing/mask/gas/sechailer/verb/halt()
	set category = "Object"
	set name = "HALT"
	set src in usr
	if(!isliving(usr))
		return
	if(!can_use(usr))
		return
	if(broken_hailer)
		to_chat(usr, span_warning("\The [src]'s hailing system is broken."))
		return

	var/phrase = 0	//selects which phrase to use
	var/phrase_text = null
	var/phrase_sound = null


	if(cooldown < world.time - 30) // A cooldown, to stop people being jerks
		recent_uses++
		if(cooldown_special < world.time - 180) //A better cooldown that burns jerks
			recent_uses = initial(recent_uses)

		switch(recent_uses)
			if(3)
				to_chat(usr, span_warning("\The [src] is starting to heat up."))
			if(4)
				to_chat(usr, span_userdanger("\The [src] is heating up dangerously from overuse!"))
			if(5) //overload
				broken_hailer = 1
				to_chat(usr, span_userdanger("\The [src]'s power modulator overloads and breaks."))
				return

		switch(aggressiveness)		// checks if the user has unlocked the restricted phrases
			if(1)
				phrase = rand(1,5)	// set the upper limit as the phrase above the first 'bad cop' phrase, the mask will only play 'nice' phrases
			if(2)
				phrase = rand(1,11)	// default setting, set upper limit to last 'bad cop' phrase. Mask will play good cop and bad cop phrases
			if(3)
				phrase = rand(1,18)	// user has unlocked all phrases, set upper limit to last phrase. The mask will play all phrases
			if(4)
				phrase = rand(12,18)	// user has broke the restrictor, it will now only play shitcurity phrases

		if(!safety)
			phrase_text = "FUCK YOUR CUNT YOU SHIT EATING COCKSTORM AND EAT A DONG FUCKING ASS RAMMING SHIT FUCK EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS OF FUCK AND POO AND SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT."
			phrase_sound = "emag"
		else

			switch(phrase)	//sets the properties of the chosen phrase
				if(1)				// good cop
					phrase_text = "HALT! HALT! HALT!"
					phrase_sound = "halt"
				if(2)
					phrase_text = "Stop in the name of the Law."
					phrase_sound = "bobby"
				if(3)
					phrase_text = "Compliance is in your best interest."
					phrase_sound = "compliance"
				if(4)
					phrase_text = "Prepare for justice!"
					phrase_sound = "justice"
				if(5)
					phrase_text = "Running will only increase your sentence."
					phrase_sound = "running"
				if(6)				// bad cop
					phrase_text = "Don't move, Creep!"
					phrase_sound = "dontmove"
				if(7)
					phrase_text = "Down on the floor, Creep!"
					phrase_sound = "floor"
				if(8)
					phrase_text = "Dead or alive you're coming with me."
					phrase_sound = "robocop"
				if(9)
					phrase_text = "God made today for the crooks we could not catch yesterday."
					phrase_sound = "god"
				if(10)
					phrase_text = "Freeze, Scum Bag!"
					phrase_sound = "freeze"
				if(11)
					phrase_text = "Stop right there, criminal scum!"
					phrase_sound = "imperial"
				if(12)				// LA-PD
					phrase_text = "Stop or I'll bash you."
					phrase_sound = "bash"
				if(13)
					phrase_text = "Go ahead, make my day."
					phrase_sound = "harry"
				if(14)
					phrase_text = "Stop breaking the law, ass hole."
					phrase_sound = "asshole"
				if(15)
					phrase_text = "You have the right to shut the fuck up."
					phrase_sound = "stfu"
				if(16)
					phrase_text = "Shut up crime!"
					phrase_sound = "shutup"
				if(17)
					phrase_text = "Face the wrath of the golden bolt."
					phrase_sound = "super"
				if(18)
					phrase_text = "I am, the LAW!"
					phrase_sound = "dredd"

		usr.audible_message("[usr]'s Compli-o-Nator: <font color='red' size='4'><b>[phrase_text]</b></font>")
		playsound(src.loc, "sound/voice/complionator/[phrase_sound].ogg", 100, 0, 4)
		cooldown = world.time
		cooldown_special = world.time

/datum/action/item_action/halt
	name = "HALT!"

