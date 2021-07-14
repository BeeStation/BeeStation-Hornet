// **********************
//  DETECTIVE SPYGLASSES
// **********************

/obj/item/clothing/glasses/sunglasses/spy
	desc = "Made by Nerd. Co's infiltration and surveillance department. Upon closer inspection, there's a small screen in each lens."
	actions_types = list(/datum/action/item_action/activate_remote_view)
	var/datum/spybug/linked_bug

/obj/item/clothing/glasses/sunglasses/spy/proc/show_to_user(mob/user)//this is the meat of it. most of the map_popup usage is in this.
	if(!user?.client)
		return
	if(!linked_bug)
		user.audible_message("<span class='warning'>Spybug destroyed or no longer functional!</span>")
	if("spypopup_map" in user.client.screen_maps) //alright, the popup this object uses is already IN use, so the window is open. no point in doing any other work here, so we're good.
		return
	user.client.setup_popup("spypopup", 3, 3, 2)
	user.client.register_map_obj(linked_bug.cam_screen)
	for(var/plane in linked_bug.cam_plane_masters)
		user.client.register_map_obj(plane)
	linked_bug.update_view()

/obj/item/clothing/glasses/sunglasses/spy/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_EYES))
		user.client.close_popup("spypopup")

/obj/item/clothing/glasses/sunglasses/spy/dropped(mob/user)
	. = ..()
	user.client.close_popup("spypopup")

/obj/item/clothing/glasses/sunglasses/spy/ui_action_click(mob/user)
	show_to_user(user)

/obj/item/clothing/glasses/sunglasses/spy/item_action_slot_check(slot)
	return slot & ITEM_SLOT_EYES

/obj/item/clothing/glasses/sunglasses/spy/Destroy()
	if(linked_bug)
		qdel(linked_bug)
	return ..()

// *******************
//  DETECTIVE SPYÅPEN
// *******************

/obj/item/pen/spy_bug
	var/datum/spybug/bug
	desc = "An advanced piece of espionage equipment in the shape of a pen. It has a built in 360 degree camera for all your \"admirable\" needs. Microphone not included."

/obj/item/pen/spy_bug/Initialize()
	..()
	bug = new (src)

/obj/item/pen/spy_bug/Destroy()
	qdel(bug)
	return ..()

// **************
//  SPYGLASS KIT
// **************

//it needs to be linked, hence a kit.
/obj/item/storage/box/rxglasses/spyglasskit
	name = "spyglass kit"
	desc = "this box contains <i>cool</i> nerd glasses; with built-in displays to view a linked camera."

/obj/item/storage/box/rxglasses/spyglasskit/PopulateContents()
	//fluff
	new /obj/item/paper/fluff/nerddocs(src)
	//items
	var/obj/item/clothing/accessory/pocketprotector/protector = new (src)
	var/obj/item/pen/spy_bug/newbug = new(protector)
	var/obj/item/clothing/glasses/sunglasses/spy/newglasses = new(src)
	//datum
	var/datum/spybug/spy_bug_component = newbug.bug
	spy_bug_component.link_spyglasses_to_spybug(newglasses,newbug)

/obj/item/paper/fluff/nerddocs
	name = "Espionage For Dummies"
	color = "#FFFF00"
	desc = "An eye gougingly yellow pamphlet with a badly designed image of a detective on it. the subtext says \" The Latest Way To Violate Privacy Guidelines!\" "
	info = @{"
Thank you for your purchase of the Nerd Co SpySpeks <small>tm</small>, this paper will be your quick-start guide to violating the privacy of your crewmates in three easy steps!<br><br>Step One: Nerd Co SpySpeks <small>tm</small> upon your face. <br>
Step Two: Place the included "ProfitProtektor <small>tm</small>" camera assembly in a place of your choosing - make sure to make heavy use of it's inconspicous design!
Step Three: Press the "Activate Remote View" Button on the side of your SpySpeks <small>tm</small> to open a movable camera display in the corner of your vision, it's just that easy!<br><br><br><center><b>TROUBLESHOOTING</b><br></center>
My SpySpeks <small>tm</small> Make a shrill beep while attempting to use!
A shrill beep coming from your SpySpeks means that they can't connect to the included ProfitProtektor <small>tm</small>, please make sure your ProfitProtektor is still active, and functional!
	"}

// **********************
//  CHAMELEON SPYGLASSES
// **********************

/obj/item/clothing/glasses/sunglasses/spy/chameleon
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/glasses/sunglasses/spy/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/glasses
	chameleon_action.chameleon_name = "Glasses"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/glasses/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/glasses/sunglasses/spy/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

// **************
//  NINJA SPYBUG
// **************

/obj/item/throwing_star/spy_bug
	var/datum/spybug/bug

/obj/item/throwing_star/spy_bug/Initialize()
	..()
	bug = new (src)

/obj/item/throwing_star/spy_bug/Destroy()
	qdel(bug)
	return ..()
