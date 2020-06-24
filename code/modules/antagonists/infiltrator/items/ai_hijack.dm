/obj/item/ai_hijack_device
	name = "serial exploitation unit"
	desc = "A strange circuitboard, branded with a large red S, with several ports."
	icon = 'icons/obj/module.dmi'
	icon_state = "ai_hijack"

/obj/item/ai_hijack_device/afterattack(atom/O, mob/user, proximity)
	if(isAI(O))
		var/mob/living/silicon/ai/A = O
		if(A.mind && A.mind.has_antag_datum(/datum/antagonist/hijacked_ai))
			to_chat(user, "<span class='warning'>[A] has already been hijacked!</span>")
			return
		if(A.hijacking)
			to_chat(user, "<span class='warning'>[A] is already in the process of being hijacked!</span>")
			return
		user.visible_message("<span class='warning'>[user] begins attaching something to [A]...</span>")
		if(do_after(user,55,target = A))
			user.dropItemToGround(src)
			forceMove(A)
			A.hijacking = src
			A.update_icon()
			A.hijack_start = world.time
			to_chat(src, "<span class='danger'>Unknown device connected to /dev/ttySL0</span>")
			message_admins("[ADMIN_LOOKUPFLW(user)] has attached a hijacking device to [ADMIN_LOOKUPFLW(A)]!")
			notify_ghosts("[user] has begun to hijack [A]!", source = A, action = NOTIFY_ORBIT, ghost_sound = 'sound/machines/chime.ogg')
	else
		return ..()


/mob/living/silicon/ai
	var/obj/item/ai_hijack_device/hijacking
	var/mutable_appearance/hijack_overlay
	var/hijack_start = 0

/mob/living/silicon/ai/attack_hand(mob/user)
	if(hijacking)
		user.visible_message("<span class='danger'>[user] attempts to disconnect the circuit board from [src].</span>", "<span class='notice'>There appears to be something connected to [src]'s ports! You attempt to disconnect it...</span>")
		if(do_after(user, 100, target = src))
			hijacking.forceMove(loc)
			hijacking = null
			hijack_start = 0
			update_icon()
		else
			to_chat(user, "<span class='notice'>You fail to remove the device.</span>")
		return
	return ..()

/mob/living/silicon/ai/update_icon()
	..()
	cut_overlays()
	if(hijacking)
		if(!hijack_overlay)
			hijack_overlay = mutable_appearance('icons/obj/module.dmi', "ai_hijack_overlay")
			hijack_overlay.layer = layer+0.1
			hijack_overlay.pixel_x = 8
		add_overlay(hijack_overlay)
		icon_state = "ai-static"
	else if(!hijacking && hijack_overlay)
		QDEL_NULL(hijack_overlay)
