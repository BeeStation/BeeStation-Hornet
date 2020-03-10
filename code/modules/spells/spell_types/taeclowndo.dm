/obj/effect/proc_holder/spell/targeted/conjure_item/summon_pie
	name = "Summon Creampie"
	desc = "A clown's weapon of choice.  Use this to summon a fresh pie, just waiting to acquaintain itself with someone's face."
	invocation_type = "none"
	include_user = 1
	range = -1
	clothes_req = 0
	item_type = /obj/item/reagent_containers/food/snacks/pie/cream

	charge_max = 30
	cooldown_min = 30
	action_icon = 'icons/obj/food/piecake.dmi'
	action_icon_state = "pie"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/aimed/banana_peel
	name = "Conjure Banana Peel"
	desc = "Make a banana peel appear out of thin air right under someone's feet!"
	charge_type = "recharge"
	charge_max	= 100
	cooldown_min = 100
	clothes_req = 0
	invocation_type = "none"
	range = 7
	selection_type = "view"
	projectile_type = null

	active_msg = "You focus, your mind reaching to the clown dimension, ready to make a peel matrialize wherever you want!"
	deactive_msg = "You relax, the peel remaining right in the \"thin air\" it would appear out of."
	action_icon = 'icons/obj/hydroponics/harvest.dmi'
	base_icon_state = "banana_peel"
	action_icon_state = "banana"


/obj/effect/proc_holder/spell/aimed/banana_peel/cast(list/targets, mob/user = usr)
	var/target = get_turf(targets[1])

	if(get_dist(user,target)>range)
		to_chat(user, "<span class='notice'>\The [target] is too far away!</span>")
		return

	. = ..()
	new /obj/item/grown/bananapeel(target)

/obj/effect/proc_holder/spell/aimed/banana_peel/update_icon()
	if(!action)
		return
	if(active)
		action.button_icon_state = base_icon_state
	else
		action.button_icon_state = action_icon_state

	action.UpdateButtonIcon()
	return
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/targeted/touch/megahonk
	name = "Mega HoNk"
	desc = "This spell channels your inner clown powers, concentrating them into one massive HONK."
	hand_path = /obj/item/melee/touch_attack/megahonk

	charge_max = 100
	clothes_req = 0
	cooldown_min = 100

	action_icon = 'icons/mecha/mecha_equipment.dmi'
	action_icon_state = "mecha_honker"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/targeted/touch/bspie
	name = "Bluespace Banana Pie"
	desc = "An entire body would fit in there!"
	hand_path = /obj/item/melee/touch_attack/bspie

	charge_max = 450
	clothes_req = 0
	cooldown_min = 450

	action_icon = 'icons/obj/food/piecake.dmi'
	action_icon_state = "frostypie"




