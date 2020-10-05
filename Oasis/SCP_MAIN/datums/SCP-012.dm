GLOBAL_LIST_EMPTY(scp012s)

/obj/item/paper/scp012
	name = "SCP-012"
	icon = 'Oasis/SCP_MAIN//SCP_ICONS/scpmobs/scp012.dmi'
	desc = "<b><span class='warning'><big>SCP-012</big></span></b> - An old paper of handwritten sheet music, titled \"On Mount Golgotha\". It appears to be incomplete and he writing is in a conspicuous blood red."
	anchored = 1
	var/ticks = 0

/obj/item/paper/scp012/examine(mob/user)
	. = ..()

/obj/item/paper/scp012/AltClick(mob/living/carbon/user, obj/item/I)
	to_chat(user, "<span class='notice'>You cant fold [src] into the shape of a plane!</span>")
	return

/obj/item/paper/scp012/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	GLOB.scp012s += src

/obj/item/paper/scp012/Destroy()
	STOP_PROCESSING(SSobj, src)
	GLOB.scp012s -= src
	return ..()

/obj/item/paper/scp012/process()

	++ticks

	// find a victim in case the last one is gone
	var/mob/living/carbon/human/affecting = null
	for (var/mob/living/carbon/human/H in shuffle(view(3, src)))
		if (can_affect(H))
			affecting = H
			break

	// we're done here
	if (!affecting)
		return

	// make the victim come towards us
	if (!(affecting in view(1, src)))
		affecting.Move(get_step(affecting, get_dir(affecting, src)))
		affecting.visible_message("<span class = \"notice\">[affecting] is drawn towards \"[name]\"!")

	// do fun stuff
	if (affecting in view(1, src))
		if (affecting.health <= 10)
			affecting.whisper("Its impossible to complete this...")
			affecting.visible_message("<span class = \"danger\"><em>[affecting] bites their tongue and smears their bleeding face on \"[name]\", attempting to write musical notes!")
			affecting.bleed_rate += 500
			affecting.emote("scream")

		// once every 10 seconds
		if (!(ticks % 10))
			affecting.visible_message("<span class = \"danger\"><em>[affecting] rips into their own flesh and covers their hands in blood!</em></span>")
			affecting.emote("scream")
			affecting.adjustBruteLoss(15)
			affecting.bleed_rate += 10
		// once every 5 seconds
		else if (!(ticks % 5) && affecting.getBruteLoss())
			affecting.whisper(pick("It must be finished","This music will be magnificent","I have to finish this..."))
			affecting.visible_message("<span class = \"warning\">[affecting] smears blood on \"[name]\", writing musical notes...")
		// otherwise
		else if (prob(20))
			if (prob(50))
				affecting.visible_message("<span class = \"notice\">[affecting] looks at \"[name]\" and sighs dejectedly.</span>")
			else
				affecting.visible_message("<span class = \"notice\">[affecting] looks at \"[name]\" and cries.</span>")

/obj/item/paper/proc/can_affect(var/mob/living/carbon/human/H)
	return H.stat == CONSCIOUS && !H.eye_blind && !istype(H.glasses, /obj/item/clothing/glasses/blindfold)
