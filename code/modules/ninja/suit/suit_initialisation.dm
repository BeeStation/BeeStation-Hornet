/obj/item/clothing/suit/space/space_ninja/proc/toggle_on_off()
	if(s_busy)
		to_chat(loc, "[span_userdanger("ERROR")]: You cannot use this function at this time.")
		return FALSE
	if(s_initialized)
		deinitialize()
	else
		ninitialize()
	. = TRUE

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize(delay = s_delay, mob/living/carbon/human/U = loc)
	if(!U.mind)
		return //Not sure how this could happen.
	s_busy = TRUE
	to_chat(U, span_notice("Now initializing..."))
	addtimer(CALLBACK(src, .proc/ninitialize_two, delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize_two(delay, mob/living/carbon/human/U)
	if(!lock_suit(U))//To lock the suit onto wearer.
		s_busy = FALSE
		return
	to_chat(U, span_notice("Securing external locking mechanism...\nNeural-net established."))
	addtimer(CALLBACK(src, .proc/ninitialize_three, delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize_three(delay, mob/living/carbon/human/U)
	to_chat(U, span_notice("Extending neural-net interface...\nNow monitoring brain wave pattern..."))
	addtimer(CALLBACK(src, .proc/ninitialize_four, delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize_four(delay, mob/living/carbon/human/U)
	if(U.stat == DEAD|| U.health <= 0)
		to_chat(U, span_danger("<B>FÄAL ï¿½Rrï¿½R</B>: 344--93#ï¿½&&21 BRï¿½ï¿½N |/|/aVï¿½ PATT$RN <B>RED</B>\nA-A-aBï¿½rTï¿½NG..."))
		unlock_suit()
		s_busy = FALSE
		return
	lockIcons(U)//Check for icons.
	U.regenerate_icons()
	to_chat(U, span_notice("Linking neural-net interface...\nPattern [span_green("<B>GREEN</B>")], continuing operation."))
	addtimer(CALLBACK(src, .proc/ninitialize_five, delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize_five(delay, mob/living/carbon/human/U)
	to_chat(U, span_notice("VOID-shift device status: <B>ONLINE</B>.\nCLOAK-tech device status: <B>ONLINE</B>."))
	addtimer(CALLBACK(src, .proc/ninitialize_six, delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize_six(delay, mob/living/carbon/human/U)
	to_chat(U, span_notice("Primary system status: <B>ONLINE</B>.\nBackup system status: <B>ONLINE</B>.\nCurrent energy capacity: <B>[DisplayEnergy(cell.charge)]</B>."))
	addtimer(CALLBACK(src, .proc/ninitialize_seven, delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize_seven(delay, mob/living/carbon/human/U)
	to_chat(U, span_notice("All systems operational. Welcome to <B>SpiderOS</B>, [U.real_name]."))
	s_initialized = TRUE
	ntick()
	s_busy = FALSE



/obj/item/clothing/suit/space/space_ninja/proc/deinitialize(delay = s_delay)
	if(affecting==loc)
		var/mob/living/carbon/human/U = affecting
		if(alert("Are you certain you wish to remove the suit? This will take time and remove all abilities.",,"Yes","No")=="No")
			return
		s_busy = TRUE
		addtimer(CALLBACK(src, .proc/deinitialize_two, delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize_two(delay, mob/living/carbon/human/U)
	to_chat(U, span_notice("Now de-initializing..."))
	addtimer(CALLBACK(src, .proc/deinitialize_three, delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize_three(delay, mob/living/carbon/human/U)
	to_chat(U, span_notice("Logging off, [U.real_name]. Shutting down <B>SpiderOS</B>."))
	addtimer(CALLBACK(src, .proc/deinitialize_four, delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize_four(delay, mob/living/carbon/human/U)
	to_chat(U, span_notice("Primary system status: <B>OFFLINE</B>.\nBackup system status: <B>OFFLINE</B>."))
	addtimer(CALLBACK(src, .proc/deinitialize_five, delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize_five(delay, mob/living/carbon/human/U)
	to_chat(U, span_notice("VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>."))
	cancel_stealth()//Shutdowns stealth.
	addtimer(CALLBACK(src, .proc/deinitialize_six, delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize_six(delay, mob/living/carbon/human/U)
	to_chat(U, span_notice("Disconnecting neural-net interface... [span_green("<B>Success</B>")]."))
	addtimer(CALLBACK(src, .proc/deinitialize_seven, delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize_seven(delay, mob/living/carbon/human/U)
	to_chat(U, span_notice("Disengaging neural-net interface... [span_green("<B>Success</B>")]."))
	addtimer(CALLBACK(src, .proc/deinitialize_eight, delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize_eight(delay, mob/living/carbon/human/U)
	to_chat(U, span_notice("Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>."))
	unlock_suit()
	U.regenerate_icons()
	s_initialized = FALSE
	s_busy = FALSE
