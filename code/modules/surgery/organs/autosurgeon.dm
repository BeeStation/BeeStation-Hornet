#define INFINITE_USES -1

/obj/item/autosurgeon
	name = "autosurgeon"
	desc = "A device that automatically inserts an implant or organ into the user without the hassle of extensive surgery. It has a slot to insert implants/organs and a screwdriver slot for removing accidentally added items."
	icon = 'icons/obj/device.dmi'
	icon_state = "autoimplanter"
	item_state = "nothing"
	w_class = WEIGHT_CLASS_SMALL
	var/list/obj/item/organ/storedorgan
	var/organ_type = /obj/item/organ
	var/uses = INFINITE_USES
	var/list/starting_organ

/obj/item/autosurgeon/syndicate
	name = "suspicious autosurgeon"
	icon_state = "syndicate_autoimplanter"

/obj/item/autosurgeon/Initialize(mapload)
	. = ..()
	if(starting_organ)
		storedorgan = list()
		for(var/each in starting_organ)
			insert_organ(new each(src))

/obj/item/autosurgeon/proc/insert_organ(var/obj/item/I)
	storedorgan += I
	I.forceMove(src)

/obj/item/autosurgeon/attack_self(mob/user)//when the object it used...
	if(!uses)
		to_chat(user, "<span class='warning'>[src] has already been used. The tools are dull and won't reactivate.</span>")
		return
	else if(!storedorgan)
		to_chat(user, "<span class='notice'>[src] currently has no implant stored.</span>")
		return
	for(var/obj/item/organ/each in storedorgan)
		each.Insert(user)//insert stored organ into the user
	user.visible_message("<span class='notice'>[user] presses a button on [src], and you hear a short mechanical noise.</span>", "<span class='notice'>You feel a sharp sting as [src] plunges into your body.</span>")
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, 1)
	storedorgan = null
	name = initial(name)
	if(uses != INFINITE_USES)
		uses--
	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/autosurgeon/attack_self_tk(mob/user)
	return //stops TK fuckery

/obj/item/autosurgeon/attackby(obj/item/I, mob/user, params)
	if(istype(I, organ_type))
		if(storedorgan)
			to_chat(user, "<span class='notice'>[src] already has an implant stored.</span>")
			return
		else if(!uses)
			to_chat(user, "<span class='notice'>[src] has already been used up.</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		storedorgan = list(I)
		to_chat(user, "<span class='notice'>You insert the [I] into [src].</span>")
	else
		return ..()

/obj/item/autosurgeon/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(!storedorgan)
		to_chat(user, "<span class='notice'>There's no implant in [src] for you to remove.</span>")
	else
		var/atom/drop_loc = user.drop_location()
		for(var/J in src)
			var/atom/movable/AM = J
			AM.forceMove(drop_loc)

		to_chat(user, "<span class='notice'>You remove the [storedorgan] from [src].</span>")
		I.play_tool_sound(src)
		storedorgan = null
		if(uses != INFINITE_USES)
			uses--
		if(!uses)
			desc = "[initial(desc)] Looks like it's been used up."
	return TRUE

/obj/item/autosurgeon/cmo
	name = "nanotrasen medical autosurgeon"
	desc = "A single use autosurgeon that contains a medical heads-up display augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = list(/obj/item/organ/cyberimp/eyes/hud/medical)

/obj/item/autosurgeon/syndicate/laser_arm
	name = "suspicious autosurgeon (arm-mounted laser implant)"
	desc = "A single use autosurgeon that contains a combat arms-up laser augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = list(/obj/item/organ/cyberimp/arm/gun/laser)

/obj/item/autosurgeon/syndicate/thermal_eyes
	name = "suspicious autosurgeon (Thermal eyes)"
	starting_organ = list(/obj/item/organ/eyes/robotic/thermals)

/obj/item/autosurgeon/syndicate/xray_eyes
	name = "suspicious autosurgeon (X-ray eyes)"
	starting_organ = list(/obj/item/organ/eyes/robotic/xray/syndicate)

/obj/item/autosurgeon/syndicate/anti_stun
	name = "suspicious autosurgeon (CNS Rebooter implant)"
	starting_organ = list(/obj/item/organ/cyberimp/brain/anti_stun/syndicate)

/obj/item/autosurgeon/syndicate/reviver
	name = "suspicious autosurgeon (Reviver implant)"
	starting_organ = list(/obj/item/organ/cyberimp/chest/reviver/syndicate)

/obj/item/autosurgeon/syndicate/esaw_arm
	name = "suspicious autosurgeon (arm-mounted energy saw)"
	desc = "A single use autosurgeon that contains an energy saw arm implant."
	uses = 1
	starting_organ = list(/obj/item/organ/cyberimp/arm/esaw)

/obj/item/autosurgeon/hydraulic_blade
	name = "autosurgeon (hydraulic blade arm)"
	desc = "A single use autosurgeon that contains a retractable combat hydraulic armblade. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = list(/obj/item/organ/cyberimp/arm/hydraulic_blade)

#undef INFINITE_USES
