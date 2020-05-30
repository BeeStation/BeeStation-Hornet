//yoinked from hippie (infiltrators) -- but edited to work in TG and better.
//new era: fixed most cases of broken helmet sprites, but it still breaks if the disguised hardsuit doesn't have lights
//because the infiltrator hardsuit adds the toggle lights action, which tries to change between nonexistant on and off sprites
//if you know how to fix that... do it. I've tried for about 12 hours total to no avail. Though, I AM dumb. - Trigg

/datum/action/item_action/chameleon/change/update_item(obj/item/picked_item, obj/item/target = src.target) // hippie -- add support for cham hardsuits
	..()
	if(istype(target, /obj/item/clothing/suit/space/hardsuit/infiltration))
		var/obj/item/clothing/suit/space/hardsuit/infiltration/I = target
		var/obj/item/clothing/suit/space/hardsuit/HS = new picked_item
		var/obj/item/clothing/head/helmet/space/hardsuit/HH = new HS.helmettype
		update_item(HS.helmettype, I.head_piece)
		I.head_piece.basestate = initial(HH.basestate)
		I.head_piece.icon_state = initial(HH.icon_state)
		I.head_piece.item_state = initial(HH.item_state)
		I.head_piece.item_color = initial(HH.item_color)

		var/mob/living/M = owner
		if(istype(M))
			M.update_inv_head()
			M.update_action_buttons_icon()

		qdel(HS)
		qdel(HH)
