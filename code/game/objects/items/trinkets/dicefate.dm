
/obj/item/dice/d20/fate
	name = "\improper Die of Fate"
	desc = "A die with twenty sides. You can feel unearthly energies radiating from it. Using this might be VERY risky."
	icon_state = "d20"
	sides = 20
	microwave_riggable = FALSE
	var/reusable = TRUE
	var/used = FALSE
	var/roll_in_progress = FALSE

/obj/item/dice/d20/fate/stealth
	name = "d20"
	desc = "A die with twenty sides. The preferred die to throw at the GM."

/obj/item/dice/d20/fate/one_use
	reusable = FALSE

/obj/item/dice/d20/fate/one_use/stealth
	name = "d20"
	desc = "A die with twenty sides. The preferred die to throw at the GM."

/obj/item/dice/d20/fate/cursed
	name = "cursed Die of Fate"
	desc = "A die with twenty sides. You feel that rolling this is a REALLY bad idea."
	color = "#00BB00"

	rigged = DICE_TOTALLY_RIGGED
	rigged_value = 1

/obj/item/dice/d20/fate/diceroll(mob/user)
	. = ..()
	if(roll_in_progress)
		to_chat(user, span_warning("The dice is already channeling its power! Be patient!"))
		return

	if(!used)
		if(!ishuman(user) || !user.mind)
			to_chat(user, span_warning("You feel the magic of the dice is restricted to ordinary humans!"))
			return

		if(!reusable)
			used = TRUE
		roll_in_progress = TRUE
		var/turf/T = get_turf(src)
		T.visible_message(span_userdanger("[src] flares briefly."))
		addtimer(CALLBACK(src, PROC_REF(effect), user, .), 1 SECONDS)

/obj/item/dice/d20/fate/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user) || !user.mind)
		to_chat(user, span_warning("You feel the magic of the dice is restricted to ordinary humans! You should leave it alone."))
		user.dropItemToGround(src)


/obj/item/dice/d20/fate/proc/effect(mob/living/carbon/human/user,roll)
	var/turf/T = get_turf(src)

	switch(roll)
		if(1)
			//Dust
			T.visible_message(span_userdanger("[user] turns to dust!"))
			user.sethellbound()
			user.dust()
		if(2)
			//Death
			T.visible_message(span_userdanger("[user] suddenly dies!"))
			user.death()
		if(3)
			//Swarm of creatures
			T.visible_message(span_userdanger("A swarm of creatures surround [user]!"))
			for(var/direction in GLOB.alldirs)
				new /mob/living/simple_animal/hostile/netherworld(get_step(get_turf(user),direction))
		if(4)
			//Destroy Equipment
			T.visible_message(span_userdanger("Everything [user] is holding and wearing disappears!"))
			for(var/obj/item/I in user)
				if(istype(I, /obj/item/implant))
					continue
				qdel(I)
		if(5)
			//Monkeying
			T.visible_message(span_userdanger("[user] transforms into a monkey!"))
			user.monkeyize()
		if(6)
			//Cut speed
			T.visible_message(span_userdanger("[user] starts moving slower!"))
			user.add_movespeed_modifier(/datum/movespeed_modifier/die_of_fate)
		if(7)
			//Throw
			T.visible_message(span_userdanger("Unseen forces throw [user]!"))
			user.Stun(60)
			user.adjustBruteLoss(50)
			var/throw_dir = pick(GLOB.cardinals)
			var/atom/throw_target = get_edge_target_turf(user, throw_dir)
			user.throw_at(throw_target, 200, 4)
		if(8)
			//Fueltank Explosion
			T.visible_message(span_userdanger("An explosion bursts into existence around [user]!"))
			explosion(get_turf(user),-1,0,2, flame_range = 2, magic = TRUE)
		if(9)
			//Cold
			var/datum/disease/D = new /datum/disease/cold()
			T.visible_message(span_userdanger("[user] looks a little under the weather!"))
			user.ForceContractDisease(D, FALSE, TRUE)
		if(10)
			//Nothing
			T.visible_message(span_userdanger("Nothing seems to happen."))
		if(11)
			//Cookie
			T.visible_message(span_userdanger("A cookie appears out of thin air!"))
			var/obj/item/food/cookie/C = new(drop_location())
			do_smoke(0, drop_location())
			C.name = "Cookie of Fate"
		if(12)
			//Healing
			T.visible_message(span_userdanger("[user] looks very healthy!"))
			user.revive(ADMIN_HEAL_ALL)
		if(13)
			//Mad Dosh
			T.visible_message(span_userdanger("Mad dosh shoots out of [src]!"))
			var/turf/Start = get_turf(src)
			for(var/direction in GLOB.alldirs)
				var/turf/dirturf = get_step(Start,direction)
				if(rand(0,1))
					new /obj/item/stack/spacecash/c1000(dirturf)
				else
					var/obj/item/storage/bag/money/M = new(dirturf)
					for(var/i in 1 to rand(5,50))
						new /obj/item/coin/gold(M)
		if(14)
			//Free Gun
			T.visible_message(span_userdanger("An impressive gun appears!"))
			do_smoke(0, drop_location())
			new /obj/item/gun/ballistic/revolver/mateba(drop_location())
		if(15)
			//Random One-use spellbook
			T.visible_message(span_userdanger("A magical looking book drops to the floor!"))
			do_smoke(0, drop_location())
			new /obj/item/book/granter/action/spell/random(drop_location())
		if(16)
			//Servant & Servant Summon
			T.visible_message(span_userdanger("A Dice Servant appears in a cloud of smoke!"))
			var/mob/living/carbon/human/H = new(drop_location())
			do_smoke(0, drop_location())

			H.equipOutfit(/datum/outfit/butler)
			var/datum/mind/servant_mind = new /datum/mind()
			var/datum/antagonist/magic_servant/A = new
			servant_mind.add_antag_datum(A)
			A.setup_master(user)
			servant_mind.transfer_to(H)

			var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(
				role = ROLE_WIZARD,
				poll_time = 15 SECONDS,
				jump_target = H,
				role_name_text = "[user.real_name] magical servant?",
				alert_pic = H,
			)
			if(candidate)
				H.key = candidate.key
				message_admins("[ADMIN_LOOKUPFLW(candidate)] was spawned as Dice Servant")

			var/datum/action/spell/summonmob/S = new
			S.target_mob = H
			S.Grant(user)

		if(17)
			//Tator Kit
			T.visible_message(span_userdanger("A suspicious box appears!"))
			new /obj/item/storage/box/syndie_kit/bundle_A(drop_location())
			do_smoke(0, drop_location())
		if(18)
			//Captain ID
			T.visible_message(span_userdanger("A golden identification card appears!"))
			new /obj/item/card/id/captains_spare(drop_location())
			do_smoke(0, drop_location())
		if(19)
			//Instrinct Resistance
			T.visible_message(span_userdanger("[user] looks very robust!"))
			user.physiology.brute_mod *= 0.5
			user.physiology.burn_mod *= 0.5

		if(20)
			//Free wizard!
			T.visible_message(span_userdanger("Magic flows out of [src] and into [user]!"))
			user.mind.add_antag_datum(/datum/antagonist/wizard)
	//roll is completed, allow others players to roll the dice
	roll_in_progress = FALSE

/datum/outfit/butler
	name = "Butler"
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/hats/bowler
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/white

/datum/action/spell/summonmob
	name = "Summon Servant"
	desc = "This spell can be used to call your servant, whenever you need it."
	cooldown_time = 30 SECONDS
	invocation = "JE VES"
	invocation_type = INVOCATION_WHISPER

	var/mob/living/target_mob
	button_icon_state = "summons"

/datum/action/spell/summonmob/on_cast(mob/user, atom/target)
	. = ..()

	if(!target_mob)
		return
	var/turf/Start = get_turf(owner)
	for(var/direction in GLOB.alldirs)
		var/turf/T = get_step(Start,direction)
		if(!T.density)
			target_mob.Move(T)
