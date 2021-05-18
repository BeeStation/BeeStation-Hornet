
/datum/hud/guardian/New(mob/living/simple_animal/hostile/guardian/owner)
	..()
	var/atom/movable/screen/using

	healths = new /atom/movable/screen/healths/guardian()
	healths.hud = src
	infodisplay += healths

	using = new /atom/movable/screen/guardian/Manifest()
	using.screen_loc = ui_hand_position(2)
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/guardian/Recall()
	using.screen_loc = ui_hand_position(1)
	using.hud = src
	static_inventory += using

	using = new owner.toggle_button_type()
	using.screen_loc = ui_storage1
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/guardian/ToggleLight()
	using.screen_loc = ui_inventory
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/guardian/Communicate()
	using.screen_loc = ui_back
	using.hud = src
	static_inventory += using

/*
/datum/hud/dextrous/guardian/New(mob/living/simple_animal/hostile/guardian/owner) //for a dextrous guardian
	..()
	var/atom/movable/screen/using
	if(istype(owner, /mob/living/simple_animal/hostile/guardian/dextrous))
		var/atom/movable/screen/inventory/inv_box

		inv_box = new /atom/movable/screen/inventory()
		inv_box.name = "internal storage"
		inv_box.icon = ui_style
		inv_box.icon_state = "suit_storage"
		inv_box.screen_loc = ui_id
		inv_box.slot_id = ITEM_SLOT_DEX_STORAGE
		inv_box.hud = src
		static_inventory += inv_box

		using = new /atom/movable/screen/guardian/Communicate()
		using.screen_loc = ui_sstore1
		using.hud = src
		static_inventory += using

	else

		using = new /atom/movable/screen/guardian/Communicate()
		using.screen_loc = ui_id
		using.hud = src
		static_inventory += using

	healths = new /atom/movable/screen/healths/guardian()
	healths.hud = src
	infodisplay += healths

	using = new /atom/movable/screen/guardian/Manifest()
	using.screen_loc = ui_belt
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/guardian/Recall()
	using.screen_loc = ui_back
	using.hud = src
	static_inventory += using

	using = new owner.toggle_button_type()
	using.screen_loc = ui_storage2
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/guardian/ToggleLight()
	using.screen_loc = ui_inventory
	using.hud = src
	static_inventory += using

/datum/hud/dextrous/guardian/persistent_inventory_update()
	if(!mymob)
		return
	if(istype(mymob, /mob/living/simple_animal/hostile/guardian/dextrous))
		var/mob/living/simple_animal/hostile/guardian/dextrous/D = mymob

		if(hud_shown)
			if(D.internal_storage)
				D.internal_storage.screen_loc = ui_id
				D.client.screen += D.internal_storage
		else
			if(D.internal_storage)
				D.internal_storage.screen_loc = null

	..()
*/

/atom/movable/screen/guardian
	icon = 'icons/mob/guardian.dmi'

/atom/movable/screen/guardian/Manifest
	icon_state = "manifest"
	name = "Manifest"
	desc = "Spring forth into battle!"

/atom/movable/screen/guardian/Manifest/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Manifest()


/atom/movable/screen/guardian/Recall
	icon_state = "recall"
	name = "Recall"
	desc = "Return to your user."

/atom/movable/screen/guardian/Recall/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Recall()

/atom/movable/screen/guardian/ToggleMode
	icon_state = "toggle"
	name = "Toggle Mode"
	desc = "Switch between ability modes."

/atom/movable/screen/guardian/ToggleMode/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.ToggleMode()

/atom/movable/screen/guardian/ToggleMode/Inactive
	icon_state = "notoggle" //greyed out so it doesn't look like it'll work

/atom/movable/screen/guardian/ToggleMode/Assassin
	icon_state = "stealth"
	name = "Toggle Stealth"
	desc = "Enter or exit stealth."

/atom/movable/screen/guardian/Communicate
	icon_state = "communicate"
	name = "Communicate"
	desc = "Communicate telepathically with your user."

/atom/movable/screen/guardian/Communicate/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Communicate()


/atom/movable/screen/guardian/ToggleLight
	icon_state = "light"
	name = "Toggle Light"
	desc = "Glow like star dust."

/atom/movable/screen/guardian/ToggleLight/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.ToggleLight()
