/obj/item/clothing/under/rank/cargo/quartermaster
	name = "quartermaster's jumpsuit"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"
	item_state = "qm"

/obj/item/clothing/under/rank/cargo/quartermaster/skirt
	name = "quartermaster's jumpskirt"
	desc = "It's a jumpskirt worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm_skirt"
	item_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/cargo/quartermaster/turtleneck
	name = "quartermaster's turtleneck"
	desc = "A snug turtleneck sweater worn by the Quartermaster, characterized by the expensive-looking pair of suit pants."
	icon_state = "qmturtle"
	item_state = "qmturtle"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE

/obj/item/clothing/under/rank/cargo/quartermaster/turtleneck/skirt
	name = "quartermaster's turtleneck skirt"
	desc = "A snug turtleneck sweater worn by the Quartermaster, as shown by the elegant double-lining of its silk skirt."
	icon_state = "qmturtle_skirt"
	item_state = "qmturtle_skirt"
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/cargo/tech
	name = "cargo technician's jumpsuit"
	desc = "Shooooorts! They're comfy and easy to wear!"
	icon_state = "cargo"
	item_state = "cargo"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations = DIGITIGRADE_VARIATION
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/cargo/tech/skirt
	name = "cargo technician's jumpskirt"
	desc = "Skiiiiirts! They're comfy and easy to wear!"
	icon_state = "cargo_skirt"
	item_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/cargo/miner
	desc = "It's a snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	name = "shaft miner's jumpsuit"
	icon_state = "miner"
	item_state = "miner"

/obj/item/clothing/under/rank/cargo/miner/lavaland
	desc = "A green uniform for operating in hazardous environments."
	name = "shaft miner's jumpsuit"
	icon_state = "explorer"
	item_state = "explorer"
	can_adjust = FALSE

/obj/item/clothing/under/rank/cargo/exploration
	name = "exploration uniform"
	desc = "A robust uniform used by exploration teams."
	icon_state = "curator"
	item_state = "curator"
	can_adjust = FALSE

/obj/item/clothing/under/misc/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	item_state = "b_suit"

/obj/item/clothing/under/misc/mailman/skirt
	name = "mailman's jumpskirt"
	desc = "<i>'Special delivery!'</i> Beware of spacewind."
	icon_state = "mailman_skirt"
	item_state = "b_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/misc/mailman/syndicate
	name = "counterfeit mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i> This one allows you to create your own mail!"
	actions_types = list(/datum/action/item_action/make_new_mail_package)
	var/tailored = FALSE

/obj/item/clothing/under/misc/mailman/syndicate/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(I.tool_behaviour == TOOL_WIRECUTTER && !tailored)
		to_chat(user,"<span class='notice'>You cut off the pants of [src], turning it into a jumpskirt!</span>")
		var/obj/item/stack/sheet/cotton/cloth/C = new(get_turf(user))
		C.amount = 1
		user.put_in_hands(C)
		tailored = TRUE
		name = "counterfeit mailman's jumpskirt"
		desc = "<i>'Special delivery!'</i> Beware of spacewind. This one allows you to create your own mail!"
		icon_state = "mailman_skirt"
		item_state = "b_suit"
		body_parts_covered = CHEST|GROIN|ARMS
		can_adjust = FALSE
		fitted = FEMALE_UNIFORM_TOP
		supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON
		update_appearance()
		user.update_inv_w_uniform()
		return 1
	if(istype(I, /obj/item/stack/sheet/cotton/cloth) && tailored)
		var/obj/item/stack/sheet/cotton/cloth/C = I
		C.use(1)
		to_chat(user, "<span class='notice'>You sew back some cloth to [src], turning it into a jumpsuit!</span>")
		tailored = FALSE
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		body_parts_covered = initial(body_parts_covered)
		can_adjust = initial(can_adjust)
		fitted = initial(fitted)
		supports_variations = initial(supports_variations)
		update_appearance()
		user.update_inv_w_uniform()
		return 1

/obj/item/clothing/under/misc/mailman/syndicate/examine(mob/user)
	. = ..()
	if(tailored)
		. += "\n<span class='notice'>It can be tailored with some cloth.</span>"
	else
		. += "\n<span class='notice'>It can be tailored with some scissors.</span>"

