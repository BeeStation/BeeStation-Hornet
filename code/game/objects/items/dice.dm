/obj/item/storage/pill_bottle/dice
	name = "bag of dice"
	desc = "Contains all the luck you'll ever need."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"
	pill_variance = 0

/obj/item/storage/pill_bottle/dice/Initialize(mapload)
	. = ..()
	var/special_die = pick("1","2","fudge","space","00","8bd20","4dd6","100")
	if(special_die == "1")
		new /obj/item/dice/d1(src)
	if(special_die == "2")
		new /obj/item/dice/d2(src)
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d6(src)
	if(special_die == "fudge")
		new /obj/item/dice/fudge(src)
	if(special_die == "space")
		new /obj/item/dice/d6/space(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	if(special_die == "00")
		new /obj/item/dice/d00(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)
	if(special_die == "8bd20")
		new /obj/item/dice/eightbd20(src)
	if(special_die == "4dd6")
		new /obj/item/dice/fourdd6(src)
	if(special_die == "100")
		new /obj/item/dice/d100(src)

/obj/item/storage/pill_bottle/dice/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is gambling with death! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)

/obj/item/storage/pill_bottle/dice_cup
	name = "dice cup"
	desc = "For rolling several dice at once. A favorite of street urchins."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicecup"
	pill_variance = 0

/obj/item/storage/pill_bottle/dice_cup/attack_self(mob/user)
	var/turf/throw_target = get_step(loc,user.dir) //with telekinesis, throws the direction the user is facing
	for(var/obj/item/dice/die in src)
		die.forceMove(drop_location())
		die.throw_at(throw_target,1,1,user)

/obj/item/dice //depreciated d6, use /obj/item/dice/d6 if you actually want a d6
	name = "die"
	desc = "A die with six sides. Basic and serviceable."
	icon = 'icons/obj/dice.dmi'
	icon_state = "d6"
	w_class = WEIGHT_CLASS_TINY
	var/sides = 6
	var/result = null
	var/list/special_faces = list() //entries should match up to sides var if used
	var/microwave_riggable = TRUE

	var/rigged = DICE_NOT_RIGGED
	var/rigged_value

/obj/item/dice/Initialize(mapload)
	. = ..()
	if(!result)
		result = roll(sides)
	update_icon()

/obj/item/dice/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[result] is face up.</span>"

/obj/item/dice/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is gambling with death! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)

/obj/item/dice/d1
	name = "d1"
	desc = "A die with only one side. Deterministic!"
	icon_state = "d1"
	sides = 1

/obj/item/dice/d2
	name = "d2"
	desc = "A die with two sides. Coins are undignified!"
	icon_state = "d2"
	sides = 2

/obj/item/dice/d4
	name = "d4"
	desc = "A die with four sides. The nerd's caltrop."
	icon_state = "d4"
	sides = 4

/obj/item/dice/d4/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 4)

/obj/item/dice/d6
	name = "d6"

/obj/item/dice/d6/space
	name = "space cube"
	desc = "A die with six sides. 6 TIMES 255 TIMES 255 TILE TOTAL EXISTENCE, SQUARE YOUR MIND OF EDUCATED STUPID: 2 DOES NOT EXIST."
	icon_state = "spaced6"

/obj/item/dice/d6/space/Initialize(mapload)
	. = ..()
	if(prob(10))
		name = "spess cube"

/obj/item/dice/fudge
	name = "fudge die"
	desc = "A die with six sides but only three results. Is this a plus or a minus? Your mind is drawing a blank..."
	sides = 3 //shhh
	icon_state = "fudge"
	special_faces = list("minus","blank","plus")

/obj/item/dice/d8
	name = "d8"
	desc = "A die with eight sides. It feels... lucky."
	icon_state = "d8"
	sides = 8

/obj/item/dice/d10
	name = "d10"
	desc = "A die with ten sides. Useful for percentages."
	icon_state = "d10"
	sides = 10

/obj/item/dice/d00
	name = "d00"
	desc = "A die with ten sides. Works better for d100 rolls than a golf ball."
	icon_state = "d00"
	sides = 10

/obj/item/dice/d12
	name = "d12"
	desc = "A die with twelve sides. There's an air of neglect about it."
	icon_state = "d12"
	sides = 12

/obj/item/dice/d20
	name = "d20"
	desc = "A die with twenty sides. The preferred die to throw at the GM."
	icon_state = "d20"
	sides = 20

/obj/item/dice/d100
	name = "d100"
	desc = "A die with one hundred sides! Probably not fairly weighted..."
	icon_state = "d100"
	w_class = WEIGHT_CLASS_SMALL
	sides = 100

/obj/item/dice/d100/update_icon()
	return

/obj/item/dice/eightbd20
	name = "strange d20"
	desc = "A weird die with raised text printed on the faces. Everything's white on white so reading it is a struggle. What poor design!"
	icon_state = "8bd20"
	sides = 20
	special_faces = list("It is certain","It is decidedly so","Without a doubt","Yes, definitely","You may rely on it","As I see it, yes","Most likely","Outlook good","Yes","Signs point to yes","Reply hazy try again","Ask again later","Better not tell you now","Cannot predict now","Concentrate and ask again","Don't count on it","My reply is no","My sources say no","Outlook not so good","Very doubtful")

/obj/item/dice/eightbd20/update_icon()
	return

/obj/item/dice/fourdd6
	name = "4d d6"
	desc = "A die that exists in four dimensional space. Properly interpreting them can only be done with the help of a mathematician, a physicist, and a priest."
	icon_state = "4dd6"
	sides = 48
	special_faces = list("Cube-Side: 1-1","Cube-Side: 1-2","Cube-Side: 1-3","Cube-Side: 1-4","Cube-Side: 1-5","Cube-Side: 1-6","Cube-Side: 2-1","Cube-Side: 2-2","Cube-Side: 2-3","Cube-Side: 2-4","Cube-Side: 2-5","Cube-Side: 2-6","Cube-Side: 3-1","Cube-Side: 3-2","Cube-Side: 3-3","Cube-Side: 3-4","Cube-Side: 3-5","Cube-Side: 3-6","Cube-Side: 4-1","Cube-Side: 4-2","Cube-Side: 4-3","Cube-Side: 4-4","Cube-Side: 4-5","Cube-Side: 4-6","Cube-Side: 5-1","Cube-Side: 5-2","Cube-Side: 5-3","Cube-Side: 5-4","Cube-Side: 5-5","Cube-Side: 5-6","Cube-Side: 6-1","Cube-Side: 6-2","Cube-Side: 6-3","Cube-Side: 6-4","Cube-Side: 6-5","Cube-Side: 6-6","Cube-Side: 7-1","Cube-Side: 7-2","Cube-Side: 7-3","Cube-Side: 7-4","Cube-Side: 7-5","Cube-Side: 7-6","Cube-Side: 8-1","Cube-Side: 8-2","Cube-Side: 8-3","Cube-Side: 8-4","Cube-Side: 8-5","Cube-Side: 8-6")

/obj/item/dice/fourdd6/update_icon()
	return

/obj/item/dice/attack_self(mob/user)
	diceroll(user)

/obj/item/dice/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/mob/thrown_by = thrownby?.resolve()
	if(thrown_by)
		diceroll(thrown_by)
	return ..()

/obj/item/dice/proc/diceroll(mob/user)
	result = roll(sides)
	if(rigged != DICE_NOT_RIGGED && result != rigged_value)
		if(rigged == DICE_BASICALLY_RIGGED && prob(CLAMP(1/(sides - 1) * 100, 25, 80)))
			result = rigged_value
		else if(rigged == DICE_TOTALLY_RIGGED)
			result = rigged_value

	. = result

	var/fake_result = roll(sides)//Daredevil isn't as good as he used to be
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "NAT 20!"
	else if(sides == 20 && result == 1)
		comment = "Ouch, bad luck."
	update_icon()
	if(initial(icon_state) == "d00")
		result = (result - 1)*10
	if(special_faces.len == sides)
		result = special_faces[result]
	if(user != null) //Dice was rolled in someone's hand
		user.visible_message("[user] has thrown [src]. It lands on [result]. [comment]", \
							 "<span class='notice'>You throw [src]. It lands on [result]. [comment]</span>", \
							 "<span class='italics'>You hear [src] rolling, it sounds like a [fake_result].</span>")
	else if(!src.throwing) //Dice was thrown and is coming to rest
		visible_message("<span class='notice'>[src] rolls to a stop, landing on [result]. [comment]</span>")

/obj/item/dice/update_icon()
	cut_overlays()
	add_overlay("[src.icon_state]-[src.result]")

/obj/item/dice/microwave_act(obj/machinery/microwave/M)
	if(microwave_riggable)
		rigged = DICE_BASICALLY_RIGGED
		rigged_value = result
	..(M)

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
		to_chat(user, "<span class='warning'>The dice is already channeling its power! Be patient!</span>")
		return

	if(!used)
		if(!ishuman(user) || !user.mind || (user.mind in SSticker.mode.wizards))
			to_chat(user, "<span class='warning'>You feel the magic of the dice is restricted to ordinary humans!</span>")
			return

		if(!reusable)
			used = TRUE
		roll_in_progress = TRUE
		var/turf/T = get_turf(src)
		T.visible_message("<span class='userdanger'>[src] flares briefly.</span>")
		addtimer(CALLBACK(src, PROC_REF(effect), user, .), 1 SECONDS)

/obj/item/dice/d20/fate/equipped(mob/user, slot)
	if(!ishuman(user) || !user.mind || (user.mind in SSticker.mode.wizards))
		to_chat(user, "<span class='warning'>You feel the magic of the dice is restricted to ordinary humans! You should leave it alone.</span>")
		user.dropItemToGround(src)


/obj/item/dice/d20/fate/proc/effect(var/mob/living/carbon/human/user,roll)
	var/turf/T = get_turf(src)

	switch(roll)
		if(1)
			//Dust
			T.visible_message("<span class='userdanger'>[user] turns to dust!</span>")
			user.sethellbound()
			user.dust()
		if(2)
			//Death
			T.visible_message("<span class='userdanger'>[user] suddenly dies!</span>")
			user.death()
		if(3)
			//Swarm of creatures
			T.visible_message("<span class='userdanger'>A swarm of creatures surround [user]!</span>")
			for(var/direction in GLOB.alldirs)
				new /mob/living/simple_animal/hostile/netherworld(get_step(get_turf(user),direction))
		if(4)
			//Destroy Equipment
			T.visible_message("<span class='userdanger'>Everything [user] is holding and wearing disappears!</span>")
			for(var/obj/item/I in user)
				if(istype(I, /obj/item/implant))
					continue
				qdel(I)
		if(5)
			//Monkeying
			T.visible_message("<span class='userdanger'>[user] transforms into a monkey!</span>")
			user.monkeyize()
		if(6)
			//Cut speed
			T.visible_message("<span class='userdanger'>[user] starts moving slower!</span>")
			user.add_movespeed_modifier(MOVESPEED_ID_DIE_OF_FATE, update=TRUE, priority=100, multiplicative_slowdown=1)
		if(7)
			//Throw
			T.visible_message("<span class='userdanger'>Unseen forces throw [user]!</span>")
			user.Stun(60)
			user.adjustBruteLoss(50)
			var/throw_dir = pick(GLOB.cardinals)
			var/atom/throw_target = get_edge_target_turf(user, throw_dir)
			user.throw_at(throw_target, 200, 4)
		if(8)
			//Fueltank Explosion
			T.visible_message("<span class='userdanger'>An explosion bursts into existence around [user]!</span>")
			explosion(get_turf(user),-1,0,2, flame_range = 2, magic = TRUE)
		if(9)
			//Cold
			var/datum/disease/D = new /datum/disease/cold()
			T.visible_message("<span class='userdanger'>[user] looks a little under the weather!</span>")
			user.ForceContractDisease(D, FALSE, TRUE)
		if(10)
			//Nothing
			T.visible_message("<span class='userdanger'>Nothing seems to happen.</span>")
		if(11)
			//Cookie
			T.visible_message("<span class='userdanger'>A cookie appears out of thin air!</span>")
			var/obj/item/reagent_containers/food/snacks/cookie/C = new(drop_location())
			do_smoke(0, drop_location())
			C.name = "Cookie of Fate"
		if(12)
			//Healing
			T.visible_message("<span class='userdanger'>[user] looks very healthy!</span>")
			user.revive(full_heal = 1, admin_revive = 1)
		if(13)
			//Mad Dosh
			T.visible_message("<span class='userdanger'>Mad dosh shoots out of [src]!</span>")
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
			T.visible_message("<span class='userdanger'>An impressive gun appears!</span>")
			do_smoke(0, drop_location())
			new /obj/item/gun/ballistic/revolver/mateba(drop_location())
		if(15)
			//Random One-use spellbook
			T.visible_message("<span class='userdanger'>A magical looking book drops to the floor!</span>")
			do_smoke(0, drop_location())
			new /obj/item/book/granter/spell/random(drop_location())
		if(16)
			//Servant & Servant Summon
			T.visible_message("<span class='userdanger'>A Dice Servant appears in a cloud of smoke!</span>")
			var/mob/living/carbon/human/H = new(drop_location())
			do_smoke(0, drop_location())

			H.equipOutfit(/datum/outfit/butler)
			var/datum/mind/servant_mind = new /datum/mind()
			var/datum/antagonist/magic_servant/A = new
			servant_mind.add_antag_datum(A)
			A.setup_master(user)
			servant_mind.transfer_to(H)

			var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [user.real_name] Servant?", ROLE_WIZARD, null, ROLE_WIZARD, 50, H)
			if(LAZYLEN(candidates))
				var/mob/dead/observer/C = pick(candidates)
				message_admins("[ADMIN_LOOKUPFLW(C)] was spawned as Dice Servant")
				H.key = C.key

			var/obj/effect/proc_holder/spell/targeted/summonmob/S = new
			S.target_mob = H
			user.mind.AddSpell(S)

		if(17)
			//Tator Kit
			T.visible_message("<span class='userdanger'>A suspicious box appears!</span>")
			new /obj/item/storage/box/syndie_kit/bundle_A(drop_location())
			do_smoke(0, drop_location())
		if(18)
			//Captain ID
			T.visible_message("<span class='userdanger'>A golden identification card appears!</span>")
			new /obj/item/card/id/captains_spare(drop_location())
			do_smoke(0, drop_location())
		if(19)
			//Instrinct Resistance
			T.visible_message("<span class='userdanger'>[user] looks very robust!</span>")
			user.physiology.brute_mod *= 0.5
			user.physiology.burn_mod *= 0.5

		if(20)
			//Free wizard!
			T.visible_message("<span class='userdanger'>Magic flows out of [src] and into [user]!</span>")
			user.mind.make_Wizard()
	//roll is completed, allow others players to roll the dice
	roll_in_progress = FALSE
