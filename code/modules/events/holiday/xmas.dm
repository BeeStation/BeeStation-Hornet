/obj/item/toy/xmas_cracker
	name = "xmas cracker"
	icon = 'icons/obj/christmas.dmi'
	icon_state = "cracker"
	desc = "Directions for use: Requires two people, one to pull each end."
	var/cracked = 0

/obj/item/toy/xmas_cracker/attack(mob/target, mob/user)
	if( !cracked && ishuman(target) && (target.stat == CONSCIOUS) && !target.get_active_held_item() )
		target.visible_message("[user] and [target] pop \an [src]! *pop*", span_notice("You pull \an [src] with [target]! *pop*"), span_italics("You hear a pop."))
		var/obj/item/paper/joke_paper = new /obj/item/paper(user.loc)
		joke_paper.name = "[pick("awful","terrible","unfunny")] joke"
		joke_paper.add_raw_text(pick("What did one snowman say to the other?\n\n<i>'Is it me or can you smell carrots?'</i>",
			"Why couldn't the snowman get laid?\n\n<i>He was frigid!</i>",
			"Where are santa's helpers educated?\n\n<i>Nowhere, they're ELF-taught.</i>",
			"What happened to the man who stole advent calanders?\n\n<i>He got 25 days.</i>",
			"What does Santa get when he gets stuck in a chimney?\n\n<i>Claus-trophobia.</i>",
			"Where do you find chili beans?\n\n<i>The north pole.</i>",
			"What do you get from eating tree decorations?\n\n<i>Tinsilitis!</i>",
			"What do snowmen wear on their heads?\n\n<i>Ice caps!</i>",
			"Why is Christmas just like life on ss13?\n\n<i>You do all the work and the fat guy gets all the credit.</i>",
			"Why doesn't Santa have any children?\n\n<i>Because he only comes down the chimney.</i>"))
		joke_paper.update_appearance()
		new /obj/item/clothing/head/costume/festive(target.loc)
		user.update_icons()
		cracked = 1
		icon_state = "cracker1"
		var/obj/item/toy/xmas_cracker/other_half = new /obj/item/toy/xmas_cracker(target)
		other_half.cracked = 1
		other_half.icon_state = "cracker2"
		target.put_in_active_hand(other_half)
		playsound(user, 'sound/effects/snap.ogg', 50, 1)
		return TRUE
	return ..()

/obj/item/clothing/head/costume/festive
	name = "festive paper hat"
	icon_state = "xmashat"
	desc = "A crappy paper hat that you are REQUIRED to wear."
	flags_inv = 0
	armor_type = /datum/armor/none

/obj/item/clothing/head/costume/festive/Initialize(mapload)
	//Merry christmas
	if(CHRISTMAS in SSevents.holidays)
		armor_type = /datum/armor/festivehat_christmas
	else if(FESTIVE_SEASON in SSevents.holidays)
		armor_type = /datum/armor/festivehat_december
	return ..()

/datum/armor/festivehat_christmas
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	bomb = 30
	fire = 30
	acid = 30

/datum/armor/festivehat_december
	melee = 20
	bullet = 20
	laser = 20
	energy = 20
	bomb = 20
	fire = 20
	acid = 20


/obj/effect/spawner/xmastree
	name = "christmas tree spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x2"
	layer = FLY_LAYER

	var/festive_tree = /obj/structure/flora/tree/pine/xmas
	var/christmas_tree = /obj/structure/flora/tree/pine/xmas/presents

/obj/effect/spawner/xmastree/Initialize(mapload)
	. = ..()
	if((CHRISTMAS in SSevents.holidays) && christmas_tree)
		new christmas_tree(get_turf(src))
	else if((FESTIVE_SEASON in SSevents.holidays) && festive_tree)
		new festive_tree(get_turf(src))

/obj/effect/spawner/xmastree/rdrod
	name = "festivus pole spawner"
	festive_tree = /obj/structure/festivus
	christmas_tree = null

/datum/round_event_control/santa
	name = "Vist by Santa"
	holidayID = CHRISTMAS
	typepath = /datum/round_event/santa
	weight = 20
	max_occurrences = 1
	earliest_start = 30 MINUTES

/datum/round_event/santa
	var/mob/living/carbon/human/santa //who is our santa?

/datum/round_event/santa/announce(fake)
	priority_announce("Santa is coming to town!", "Unknown Transmission", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/santa/start()
	var/datum/poll_config/config = new()
	config.question = "Santa is coming to town! Do you want to be Santa?"
	config.poll_time = 15 SECONDS
	config.role_name_text = "santa"
	config.alert_pic = /obj/item/clothing/head/costume/santa
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(config)

	if(candidate)
		santa = new(pick(GLOB.blobstart))
		santa.key = candidate.key
		santa.mind.add_antag_datum(/datum/antagonist/santa)
