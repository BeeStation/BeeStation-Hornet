// Valentine's Day events //
// why are you playing spessmens on valentine's day you wizard //

#define VALENTINE_FILE "valentines.json"

//Assoc list
// Key: Sender
// Value: Receiever
GLOBAL_LIST(valentine_mobs)

// valentine / candy heart distribution //

/datum/round_event_control/valentines
	name = "Valentines!"
	holidayID = VALENTINES
	typepath = /datum/round_event/valentines
	weight = -1							//forces it to be called, regardless of weight
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/valentines
	endWhen = 300

/datum/round_event/valentines/start()
	GLOB.valentine_mobs = list()
	//Blammo
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		H.put_in_hands(new /obj/item/valentine(get_turf(H)))
		var/obj/item/storage/backpack/b = locate() in H.contents
		new /obj/item/reagent_containers/food/snacks/candyheart(b)
		new /obj/item/storage/fancy/heart_box(b)
		to_chat(H, "<span class='clown'>A message appears in your hand, it looks like it has space to write somebody's name on it!</span>")

/datum/round_event/valentines/end()

	//Too late now
	GLOB.valentine_mobs = null

	//Locate all the failures
	var/list/valentines = list()
	for(var/mob/living/M in GLOB.player_list)
		if(!M.stat && M.client && M.mind && !M.mind.has_antag_datum(/datum/antagonist/valentine))
			valentines |= M

	while(valentines.len)
		var/mob/living/L = pick_n_take(valentines)
		if(valentines.len)
			var/mob/living/date = pick_n_take(valentines)

			forge_valentines_objective(L, date)
			forge_valentines_objective(date, L)
		else
			L.mind.add_antag_datum(/datum/antagonist/heartbreaker)

/proc/forge_valentines_objective(mob/living/lover,mob/living/date)
	lover.mind.special_role = "valentine"
	var/datum/antagonist/valentine/V = new
	V.date = date.mind
	lover.mind.add_antag_datum(V) //These really should be teams but i can't be assed to incorporate third wheels right now

/datum/round_event/valentines/announce(fake)
	priority_announce("It's Valentine's Day! Give a valentine to that special someone!")

/obj/item/valentine
	name = "valentine"
	desc = "A Valentine's card! Wonder what it says..."
	icon = 'icons/obj/toy.dmi'
	icon_state = "sc_Ace of Hearts_syndicate" // shut up
	var/message = "A generic message of love or whatever."
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY
	var/mob/target = null
	var/mob/sender = null
	var/used = FALSE

/obj/item/valentine/Initialize()
	. = ..()
	message = pick(strings(VALENTINE_FILE, "valentines"))

/obj/item/valentine/attackby(obj/item/W, mob/user, params)
	..()
	if(!islist(GLOB.valentine_mobs))
		to_chat(user, "<span class='warning'>You feel regret... It's too late now.</span>")
		return
	if(used)
		return
	if(istype(W, /obj/item/pen) || istype(W, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, "<span class='notice'>You scribble illegibly on [src]!</span>")
			return
		//Alright lets see who we are sending this bad boy too.
		//Gets all the people on the z-level, don't want people meta dating nukies *too* hard.
		//Also they only get one chance.
		if(alert(user, "Are you sure you are ready to write your message? You only have one shot!", "Valentines message", "Yes!", "No...") == "No...")
			to_chat(user, "<span class='notice'>You put down the pen thinking about who you want to send the message to.</span>")
			return
		var/turf/user_turf = get_turf(user)
		if(!SSmobs.clients_by_zlevel[user_turf.z])
			to_chat(user, "<span class='warning'>You stop and look around for a moment. Where the hell are you?</span>")
			return
		//No going back now
		var/list/clients_on_level = SSmobs.clients_by_zlevel[user_turf.z]
		var/list/mob_names = list()
		for(var/mob/living/carbon/human/H in clients_on_level)
			if(!H.mind || H == user)
				//Ignore non-humans, they will be handled by the event.
				continue
			mob_names["[H.real_name]"] = H
		if(!LAZYLEN(mob_names))
			to_chat(user, "<span class='warning'>You feel empty and alone.</span>")
			return
		//Pick names
		//At this point the user is shown the names of people on the z-level
		//To prevent metastrats, you can only use this one time.
		var/picked_name = input(user, "Who are you sending it to?", "Valentines Card", null) as null|anything in mob_names
		var/mob/living/carbon/human/picked_human = mob_names[picked_name]
		if(!picked_human || !istype(picked_human))
			to_chat(user, "<span class='notice'>The card vanishes out of your hand! Lets hope they got it...</span>")
			//rip
			qdel(src)
			return
		if(!islist(GLOB.valentine_mobs))
			to_chat(user, "<span class='warning'>You feel regret... It's too late now.</span>")
			used = TRUE
			return
		if(used)
			to_chat(user, "<span class='warning'>The card has already been used!</span>")
			return
		to_chat(user, "<span class='notice'>The card vanishes out of your hand! Lets hope they got it...</span>")
		//List checking
		GLOB.valentine_mobs[user] = picked_human
		if(GLOB.valentine_mobs[picked_human] == user)
			//wow.
			forge_valentines_objective(user, picked_human)
			forge_valentines_objective(picked_human, user)
		//Off it goes!
		//Create a new card to prevent exploiting
		var/obj/item/valentine/new_card = new(get_turf(picked_human))
		new_card.message = message
		new_card.sender = user
		new_card.target = picked_human
		new_card.name = "valentines card from [new_card.sender]"
		new_card.desc = "A Valentine's card! It is addressed to [new_card.target]."
		new_card.used = TRUE
		picked_human.equip_to_appropriate_slot(new_card)
		to_chat(picked_human, "<span class='clown'>A magical card suddenly appears!</span>")
		qdel(src)

/obj/item/valentine/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		if( !(ishuman(user) || isobserver(user) || issilicon(user)) )
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(message)]</BODY></HTML>", "window=[name]")
			onclose(user, "[name]")
		else
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[message]</BODY></HTML>", "window=[name]")
			onclose(user, "[name]")
	else
		. += "<span class='notice'>It is too far away.</span>"

/obj/item/valentine/attack_self(mob/user)
	user.examinate(src)

/obj/item/reagent_containers/food/snacks/candyheart
	name = "candy heart"
	icon = 'icons/obj/holiday_misc.dmi'
	icon_state = "candyheart"
	desc = "A heart-shaped candy that reads: "
	list_reagents = list(/datum/reagent/consumable/sugar = 2)
	junkiness = 5

/obj/item/reagent_containers/food/snacks/candyheart/Initialize()
	. = ..()
	desc = pick(strings(VALENTINE_FILE, "candyhearts"))
	icon_state = pick("candyheart", "candyheart2", "candyheart3", "candyheart4")
