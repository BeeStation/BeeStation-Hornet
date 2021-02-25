#define PRE_TITLE 1
#define TITLE 2
#define SYLLABLE 3
#define MULTIPLE_SYLLABLE 4
#define SUFFIX 5

/obj/item/book/codex_gigas
	name = "\improper Codex Gigas"
	desc = "A book documenting the nature of devils."
	icon_state ="demonomicon"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	throw_speed = 1
	throw_range = 10
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	author = "Forces beyond your comprehension"
	unique = 1
	title = "the Codex Gigas"
	var/inUse = FALSE
	var/currentName = ""
	var/currentSection = PRE_TITLE

/obj/item/book/codex_gigas/attack_self(mob/user)
	if(!user.can_read(src))
		return FALSE
	if(inUse)
		to_chat(user, "<span class='notice'>Someone else is reading it.</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		if (IS_HERETIC(U))
			do_eldritch_ritual(U)
			return TRUE
		if(U.check_acedia())
			to_chat(user, "<span class='notice'>None of this matters, why are you reading this? You put [title] down.</span>")
			return FALSE
	user.visible_message("[user] opens [title] and begins reading intently.")
	ask_name(user)


/obj/item/book/codex_gigas/proc/perform_research(mob/user, devilName)
	if(!devilName)
		user.visible_message("[user] closes [title] without looking anything up.")
		return
	inUse = TRUE
	var/speed = 300
	var/correctness = 85
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		if(U.job in list("Curator")) // the curator is both faster, and more accurate than normal crew members at research
			speed = 100
			correctness = 100
		correctness -= U.getOrganLoss(ORGAN_SLOT_BRAIN) * 0.5 //Brain damage makes researching hard.
		speed += U.getOrganLoss(ORGAN_SLOT_BRAIN) * 3
	if(do_after(user, speed, 0, user))
		var/usedName = devilName
		if(!prob(correctness))
			usedName += "x"
		var/datum/antagonist/devil/devil = devilInfo(usedName)
		display_devil(devil, user, usedName)
	sleep(10)
	onclose(user, "book")
	inUse = FALSE

/obj/item/book/codex_gigas/proc/display_devil(datum/antagonist/devil/devil, mob/reader, devilName)
	reader << browse("Information on [devilName]<br><br><br>[GLOB.lawlorify[LORE][devil.ban]]<br>[GLOB.lawlorify[LORE][devil.bane]]<br>[GLOB.lawlorify[LORE][devil.obligation]]<br>[GLOB.lawlorify[LORE][devil.banish]]<br>[devil.ascendable?"This devil may ascend given enough souls.":""]", "window=book[window_size != null ? ";size=[window_size]" : ""]")

/obj/item/book/codex_gigas/proc/ask_name(mob/reader)
	ui_interact(reader)

/obj/item/book/codex_gigas/ui_act(action, params)
	if(..())
		return
	if(!action)
		return FALSE
	if(action == "search")
		SStgui.close_uis(src)
		addtimer(CALLBACK(src, .proc/perform_research, usr, currentName), 0)
		currentName = ""
		currentSection = PRE_TITLE
		return FALSE
	else
		currentName += action
	var/oldSection = currentSection
	if(GLOB.devil_pre_title.Find(action))
		currentSection = TITLE
	else if(GLOB.devil_title.Find(action))
		currentSection = SYLLABLE
	else if(GLOB.devil_syllable.Find(action))
		if (currentSection>=SYLLABLE)
			currentSection = MULTIPLE_SYLLABLE
		else
			currentSection = SYLLABLE
	else if(GLOB.devil_suffix.Find(action))
		currentSection = SUFFIX
	return currentSection != oldSection


/obj/item/book/codex_gigas/ui_state(mob/user)
	return GLOB.default_state

/obj/item/book/codex_gigas/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CodexGigas")
		ui.open()

/obj/item/book/codex_gigas/ui_data(mob/user)
	var/list/data = list()
	data["name"]=currentName
	data["currentSection"]=currentSection
	return data

/obj/item/book/codex_gigas/proc/do_eldritch_ritual(mob/living/carbon/human/heretic)
	var/datum/antagonist/heretic/cultie = heretic.mind.has_antag_datum(/datum/antagonist/heretic)	
	to_chat(heretic, "<span class='notice'>You start researching the forbidden knowledge...</span>")		
	while (cultie && do_after(heretic,10 SECONDS, src))
		heretic.whisper(pick("hypnos","celephalis","azathoth","dagon","yig","ex oblivione","nyarlathotep","nathicana","arcadia","astrophobos"), language = /datum/language/common)
		switch(cultie.dread)
			if (1, 2)	//light
				switch(rand(1,3))
					if (1)
						var/conclusion = pick("The gods look down upon you","Some things are not meant to be known","The knowledge comes at a hideous price","A blight upon those who seek the sacred knowledge","Only madness can be found in these pages")
						to_chat(heretic, "<span class='notice'>[conclusion].</span>")
					if (2)
						heretic.adjustToxLoss(2)
						to_chat(heretic, "<span class='notice'>You feel a tingle in your abdomen.</span>")
					if (3)
						heretic.vomit()
						to_chat(heretic, "<span class='notice'>You feel ill.</span>")
			if (3 to 8)	//tragic
				switch(rand(1,4))
					if (1)
						heretic.adjustOrganLoss(ORGAN_SLOT_BRAIN,10)
						to_chat(heretic, "<span class='warning'>You get a sharp headache.</span>")
					if (2)
						heretic.adjustOrganLoss(ORGAN_SLOT_EYES,10)
						to_chat(heretic, "<span class='warning'>Your eyes sting.</span>")
					if (3)
						heretic.adjustOrganLoss(ORGAN_SLOT_EARS,10)
						to_chat(heretic, "<span class='warning'>A shrill scream pains your ears.</span>")
					if (4)
						heretic.adjustToxLoss(10)
						to_chat(heretic, "<span class='warning'>Your abdomen hurts.</span>")
			else			//devastating
				switch(rand(1,6))
					if (1)
						heretic.adjustOrganLoss(ORGAN_SLOT_BRAIN,20)
						to_chat(heretic, "<span class='danger'>You feel a stabbing pain in your head!</span>")
					if (2)
						heretic.adjustOrganLoss(ORGAN_SLOT_HEART,20)
						to_chat(heretic, "<span class='danger'>Your heart burns!</span>")
					if (3)
						heretic.adjustToxLoss(30)
						to_chat(heretic, "<span class='danger'>Your feel a sharp pain in your abdomen!</span>")
					if (4)
						new /mob/living/simple_animal/hostile/netherworld/blankbody(get_turf(src))
						to_chat(heretic, "<span class='danger'>You draw unwanted attention!</span>")
					if (5)
						heretic.adjustCloneLoss(15)
						to_chat(heretic, "<span class='danger'>Your body betrays you!</span>")	
					if (6)
						heretic.adjustOrganLoss(ORGAN_SLOT_EYES,20)
						heretic.adjustOrganLoss(ORGAN_SLOT_EARS,20)
						to_chat(heretic, "<span class='danger'>Your senses decay!</span>")					
		cultie.gain_favor(1,TRUE)
		
