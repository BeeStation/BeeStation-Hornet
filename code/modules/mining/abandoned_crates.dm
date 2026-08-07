//Originally coded by ISaidNo, later modified by Kelenius. Ported from Baystation12.

/obj/structure/closet/crate/secure/loot
	name = "abandoned crate"
	desc = "What could be inside?"
	integrity_failure = 0 //no breaking open the crate
	var/code = null
	var/lastattempt = null
	var/attempts = 10
	var/codelen = 4
	var/qdel_on_open = FALSE
	var/spawned_loot = FALSE
	tamperproof = 90

/obj/structure/closet/crate/secure/loot/Initialize(mapload)
	. = ..()
	var/list/digits = list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	code = ""
	for(var/i in 1 to codelen)
		var/dig = pick(digits)
		code += dig
		digits -= dig  //there are never matching digits in the answer

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/closet/crate/secure/loot/attack_hand(mob/user, list/modifiers)
	if(locked)
		to_chat(user, span_notice("The crate is locked with a Deca-code lock."))
		var/input = capped_input(usr, "Enter [codelen] digits. All digits must be unique.", "Deca-Code Lock")
		if(user.canUseTopic(src, BE_CLOSE) && locked)
			var/list/sanitised = list()
			var/sanitycheck = TRUE
			var/char = ""
			var/length_input = length(input)
			for(var/i = 1, i <= length_input, i += length(char)) //put the guess into a list
				char = input[i]
				sanitised += text2num(char)
			for(var/i in 1 to length(sanitised) - 1) //compare each digit in the guess to all those following it
				for(var/j in i + 1 to length(sanitised))
					if(sanitised[i] == sanitised[j])
						sanitycheck = FALSE //if a digit is repeated, reject the input
			if(input == code)
				if(!spawned_loot)
					spawn_loot()
				tamperproof = 0 // set explosion chance to zero, so we dont accidently hit it with a multitool and instantly die
				togglelock(user)
			else if(!input || !sanitycheck || length(sanitised) != codelen)
				to_chat(user, span_notice("You leave the crate alone."))
			else
				to_chat(user, span_warning("A red light flashes."))
				lastattempt = input
				attempts--
				if(attempts == 0)
					boom(user)
		return

	return ..()

/obj/structure/closet/crate/secure/loot/AltClick(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	return attack_hand(user) //this helps you not blow up so easily by overriding unlocking which results in an immediate boom.

/obj/structure/closet/crate/secure/loot/attackby(obj/item/W, mob/user)
	if(locked)
		if(W.tool_behaviour == TOOL_MULTITOOL)
			to_chat(user, span_notice("DECA-CODE LOCK REPORT:"))
			if(attempts == 1)
				to_chat(user, span_warning("* Anti-Tamper Bomb will activate on next failed access attempt."))
			else
				to_chat(user, span_notice("* Anti-Tamper Bomb will activate after [attempts] failed access attempts."))
			if(lastattempt != null)
				var/bulls = 0 //right position, right number
				var/cows = 0 //wrong position but in the puzzle

				var/lastattempt_char = ""
				var/length_lastattempt = length(lastattempt)
				var/lastattempt_it = 1

				var/code_char = ""
				var/length_code = length(code)
				var/code_it = 1

				while(lastattempt_it <= length_lastattempt && code_it <= length_code) // Go through list and count matches
					lastattempt_char = lastattempt[lastattempt_it]
					code_char = code[code_it]
					if(lastattempt_char == code_char)
						++bulls
					else if(findtext(code, lastattempt_char))
						++cows

					lastattempt_it += length(lastattempt_char)
					code_it += length(code_char)

				to_chat(user, span_notice("Last code attempt, [lastattempt], had [bulls] correct digits at correct positions and [cows] correct digits at incorrect positions."))
			return
	return ..()

/obj/structure/closet/secure/loot/dive_into(mob/living/user)
	if(!locked)
		return ..()
	to_chat(user, span_notice("That seems like a stupid idea."))
	return FALSE

/obj/structure/closet/crate/secure/loot/should_emag(mob/user)
	return locked && ..()

/obj/structure/closet/crate/secure/loot/on_emag(mob/user)
	..()
	if(locked)
		boom(user)
		return
	return ..()

/obj/structure/closet/crate/secure/loot/togglelock(mob/user, silent = FALSE)
	if(!locked)
		. = ..() //Run the normal code.
		if(locked) //Double check if the crate actually locked itself when the normal code ran.
			//reset the anti-tampering, number of attempts and last attempt when the lock is re-enabled.
			tamperproof = initial(tamperproof)
			attempts = initial(attempts)
			lastattempt = null
		return
	if(tamperproof)
		return
	return ..()

/obj/structure/closet/crate/secure/loot/deconstruct(disassembled = TRUE)
	if(locked)
		boom()
		return
	return ..()

/obj/structure/closet/crate/secure/loot/open(mob/living/user, force = FALSE, special_effects)
	. = ..()
	if(qdel_on_open)
		qdel(src)

/obj/structure/closet/crate/secure/loot/proc/spawn_loot()
	var/loot = rand(1,100) //100 different crates with varying chances of spawning
	switch(loot)
		if(1 to 5) //5% chance
			new /obj/item/reagent_containers/cup/glass/bottle/rum(src)
			new /obj/item/food/grown/ambrosia/deus(src)
			new /obj/item/reagent_containers/cup/glass/bottle/whiskey(src)
			new /obj/item/lighter(src)
		if(6 to 10)
			new /obj/item/bedsheet(src)
			new /obj/item/knife/kitchen(src)
			new /obj/item/wirecutters(src)
			new /obj/item/screwdriver(src)
			new /obj/item/weldingtool(src)
			new /obj/item/hatchet(src)
			new /obj/item/crowbar(src)
		if(11 to 15)
			new /obj/item/reagent_containers/cup/beaker/bluespace(src)
		if(16 to 20)
			new /obj/item/stack/ore/diamond(src, 10)
		if(21 to 25)
			for(var/i in 1 to 5)
				new /obj/item/poster/random_contraband(src)
		if(26 to 30)
			for(var/i in 1 to 3)
				new /obj/item/reagent_containers/cup/beaker/noreact(src)
		if(31 to 35)
			new /obj/item/seeds/firelemon(src)
		if(36 to 40)
			new /obj/item/melee/baton(src)
		if(41 to 45)
			new /obj/item/clothing/under/shorts/red(src)
			new /obj/item/clothing/under/shorts/blue(src)
		if(46 to 50)
			new /obj/item/clothing/under/chameleon(src)
			for(var/i in 1 to 7)
				new /obj/item/clothing/neck/tie/horrible(src)
		if(51 to 52) // 2% chance
			new /obj/item/melee/baton(src)
		if(53 to 54)
			new /obj/item/toy/balloon(src)
		if(55 to 56)
			var/newitem = pick(subtypesof(/obj/item/toy/mecha))
			new newitem(src)
		if(57 to 58)
			new /obj/item/toy/balloon/syndicate(src)
		if(59 to 60)
			new /obj/item/borg/upgrade/modkit/aoe/mobs(src)
			new /obj/item/clothing/suit/space(src)
			new /obj/item/clothing/head/helmet/space(src)
		if(61 to 62)
			for(var/i in 1 to 5)
				new /obj/item/clothing/head/costume/kitty(src)
				new /obj/item/clothing/neck/petcollar(src)
		if(63 to 64)
			for(var/i in 1 to rand(4, 7))
				var/newcoin = pick(/obj/item/coin/silver, /obj/item/coin/silver, /obj/item/coin/silver, /obj/item/coin/iron, /obj/item/coin/iron, /obj/item/coin/iron, /obj/item/coin/gold, /obj/item/coin/diamond, /obj/item/coin/plasma, /obj/item/coin/uranium)
				new newcoin(src)
		if(65 to 66)
			new /obj/item/clothing/suit/costume/ianshirt(src)
			new /obj/item/clothing/suit/hooded/ian_costume(src)
		if(67 to 68)
			for(var/i in 1 to rand(4, 7))
				var/newitem = pick(subtypesof(/obj/item/stock_parts) - /obj/item/stock_parts/subspace)
				new newitem(src)
		if(69 to 70)
			new /obj/item/stack/ore/bluespace_crystal(src, 5)
		if(71 to 72)
			new /obj/item/pickaxe/drill(src)
		if(73 to 74)
			new /obj/item/pickaxe/drill/jackhammer(src)
		if(75 to 76)
			new /obj/item/pickaxe/diamond(src)
		if(77 to 78)
			new /obj/item/pickaxe/drill/diamonddrill(src)
		if(79 to 80)
			new /obj/item/cane(src)
			new /obj/item/clothing/head/collectable/tophat(src)
		if(81 to 82)
			new /obj/item/gun/energy/plasmacutter(src)
		if(83 to 84)
			new /obj/item/toy/katana(src)
		if(85 to 86)
			new /obj/item/defibrillator/compact(src)
		if(87) //1% chance
			new /obj/item/weed_extract(src)
		if(88)
			new /obj/item/organ/brain(src)
		if(89)
			new /obj/item/organ/brain/alien(src)
		if(90)
			new /obj/item/organ/heart(src)
		if(91)
			new /obj/item/soulstone/anybody(src)
		if(92)
			new /obj/item/katana(src)
		if(93)
			new /obj/item/dnainjector/xraymut(src)
		if(94)
			new /obj/item/storage/backpack/clown(src)
			new /obj/item/clothing/under/rank/civilian/clown(src)
			new /obj/item/clothing/shoes/clown_shoes(src)
			new /obj/item/modular_computer/tablet/pda/preset/clown(src)
			new /obj/item/clothing/mask/gas/clown_hat(src)
			new /obj/item/bikehorn(src)
			new /obj/item/toy/crayon/rainbow(src)
			new /obj/item/reagent_containers/spray/waterflower(src)
		if(95)
			new /obj/item/clothing/under/rank/civilian/mime(src)
			new /obj/item/clothing/shoes/sneakers/black(src)
			new /obj/item/modular_computer/tablet/pda/preset/mime(src)
			new /obj/item/clothing/gloves/color/white(src)
			new /obj/item/clothing/mask/gas/mime(src)
			new /obj/item/clothing/head/beret(src)
			new /obj/item/clothing/suit/suspenders(src)
			new /obj/item/toy/crayon/mime(src)
			new /obj/item/reagent_containers/cup/glass/bottle/bottleofnothing(src)
		if(96)
			new /obj/item/hand_tele(src)
		if(97)
			new /obj/item/clothing/mask/balaclava
			new /obj/item/gun/ballistic/automatic/pistol(src)
			new /obj/item/ammo_box/magazine/m10mm(src)
		if(98)
			new /obj/item/katana/cursed(src)
		if(99)
			new /obj/item/storage/belt/champion(src)
			new /obj/item/clothing/mask/luchador(src)
		if(100)
			new /obj/item/clothing/head/costume/bearpelt(src)
	spawned_loot = TRUE

/obj/structure/closet/crate/secure/loot/emp_act(severity)
	if(locked)
		boom()
	else
		..()
