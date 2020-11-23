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
			return
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
	to_chat(heretic, "<span class='notice'>A daemonic seals prevent mortals from reading the [title]... Our magic is stronger!</span>")
	while (do_after(heretic,15 SECONDS, src))
		to_chat(heretic, "<span class='notice'>You start researching the forbidden knowledge...</span>")
		var/datum/antagonist/heretic/cultie = heretic.mind.has_antag_datum(/datum/antagonist/heretic)
		var/chance = rand(1+ cultie.dread*5,100+cultie.dread*10)
		var/successful = TRUE
		switch(chance)
			if (1 to 39)
				to_chat(heretic, "<span class='notice'>The gods look down upon you.</span>")
			if(40 to 54)
				heretic.adjustOrganLoss(ORGAN_SLOT_EYES,5)
				to_chat(heretic, "<span class='warning'>Your eyes bleed...</span>")
			if(40 to 54)
				heretic.adjustOrganLoss(ORGAN_SLOT_EYES,5)
				to_chat(heretic, "<span class='warning'>Your eyes bleed...</span>")
			if(55 to 69)
				heretic.adjustOrganLoss(ORGAN_SLOT_EARS,5)
				to_chat(heretic, "<span class='warning'>A peeping scream disturbs your concentration...</span>")
			if(55 to 69)
				heretic.adjustToxLoss(5)
				to_chat(heretic, "<span class='warning'>Your body feels weaker.</span>")
			if(70 to 79)
				new /mob/living/simple_animal/hostile/netherworld/blankbody(get_turf(src))
				to_chat(heretic, "<span class='warning'>You draw unwanted attention...</span>")
			if(80 to 89)
				cultie.gain_favor(0,TRUE)
				to_chat(heretic, "<span class='warning'>A sense of dread overcomes you...</span>")
			if(90 to 99)
				heretic.adjustOrganLoss(ORGAN_SLOT_BRAIN,5)
				to_chat(heretic, "<span class='warning'>Your sanity decays...</span>")
			else
				heretic.adjustCloneLoss(5)
				to_chat(heretic, "<span class='warning'>Something fights back!</span>")
				successful = FALSE
		//switch case over
		if (successful)
			cultie.gain_favor(1,TRUE)
		to_chat(heretic, "<span class='notice'>Small price to pay, for the forbidden knowledge.</span>")
		heretic.whisper(pick("hypnos","celephalis","azathoth","dagon","yig","ex oblivione","nyarlathotep","nathicana","arcadia","astrophobos"), language = /datum/language/common)