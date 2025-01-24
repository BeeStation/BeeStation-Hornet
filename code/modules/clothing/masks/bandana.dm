/obj/item/clothing/mask/bandana
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	visor_flags_cover = MASKCOVERSMOUTH
	slot_flags = ITEM_SLOT_MASK
	adjusted_flags = ITEM_SLOT_HEAD
	dying_key = DYE_REGISTRY_BANDANA
	//flags_1 = IS_PLAYER_COLORABLE_1
	name = "bandana"
	desc = "A fine bandana with nanotech lining."
	icon_state = "bandana"
	worn_icon_state = "bandana_worn"
	greyscale_config = /datum/greyscale_config/bandana
	greyscale_config_worn = /datum/greyscale_config/bandana_worn
	var/greyscale_config_up = /datum/greyscale_config/bandana_up
	var/greyscale_config_worn_up = /datum/greyscale_config/bandana_worn_up
	greyscale_colors = "#2e2e2e"

/obj/item/clothing/mask/bandana/attack_self(mob/user)
	if(slot_flags & ITEM_SLOT_NECK)
		to_chat(user, "<span class='warning'>You must undo [src] in order to push it into a hat!</span>")
		return
	adjustmask(user)
	if(greyscale_config == initial(greyscale_config) && greyscale_config_worn == initial(greyscale_config_worn))
		worn_icon_state += "_up"
		undyeable = TRUE
		set_greyscale(
			new_config = greyscale_config_up,
			new_worn_config = greyscale_config_worn_up
		)
	else
		worn_icon_state = initial(worn_icon_state)
		undyeable = initial(undyeable)
		set_greyscale(
			new_config = initial(greyscale_config),
			new_worn_config = initial(greyscale_config_worn)
		)

/obj/item/clothing/mask/bandana/AltClick(mob/user)
	. = ..()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/matrix/widen = matrix()
		if(!user.is_holding(src))
			to_chat(user, "<span class='warning'>You must be holding [src] in order to tie it!</span>")
			return
		if((C.get_item_by_slot(ITEM_SLOT_HEAD == src)) || (C.get_item_by_slot(ITEM_SLOT_MASK) == src))
			to_chat(user, "<span class='warning'>You can't tie [src] while wearing it!</span>")
			return
		if(slot_flags & ITEM_SLOT_HEAD)
			to_chat(user, "<span class='warning'>You must undo [src] before you can tie it into a neckerchief!</span>")
			return
		if(slot_flags & ITEM_SLOT_MASK)
			undyeable = TRUE
			slot_flags = ITEM_SLOT_NECK
			worn_y_offset = -3
			widen.Scale(1.25, 1)
			transform = widen
			user.visible_message("<span class='notice'>[user] ties [src] up like a neckerchief.</span>", "<span class='notice'>You tie [src] up like a neckerchief.</span>")
		else
			undyeable = initial(undyeable)
			slot_flags = initial(slot_flags)
			worn_y_offset = initial(worn_y_offset)
			transform = initial(transform)
			user.visible_message("<span class='notice'>[user] unties the neckerchief.</span>", "<span class='notice'>You untie the neckerchief.</span>")

/obj/item/clothing/mask/bandana/red
	name = "red bandana"
	desc = "A fine red bandana with nanotech lining."
	greyscale_colors = "#A02525"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/blue
	name = "blue bandana"
	desc = "A fine blue bandana with nanotech lining."
	greyscale_colors = "#294A98"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/purple
	name = "purple bandana"
	desc = "A fine purple bandana with nanotech lining."
	greyscale_colors = "#8019a0"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/green
	name = "green bandana"
	desc = "A fine green bandana with nanotech lining."
	greyscale_colors = "#3D9829"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/gold
	name = "gold bandana"
	desc = "A fine gold bandana with nanotech lining."
	greyscale_colors = "#DAC20E"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/orange
	name = "orange bandana"
	desc = "A fine orange bandana with nanotech lining."
	greyscale_colors = "#da930e"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/black
	name = "black bandana"
	desc = "A fine black bandana with nanotech lining."
	greyscale_colors = "#2e2e2e"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/white
	name = "white bandana"
	desc = "A fine white bandana with nanotech lining."
	greyscale_colors = "#DCDCDC"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/durathread
	name = "durathread bandana"
	desc = "A bandana made from durathread, you wish it would provide some protection to its wearer, but it's far too thin..."
	greyscale_colors = "#5c6d80"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/striped
	name = "striped bandana"
	desc = "A fine bandana with nanotech lining and a stripe across."
	icon_state = "bandstriped"
	worn_icon_state = "bandstriped_worn"
	greyscale_config = /datum/greyscale_config/bandstriped
	greyscale_config_worn = /datum/greyscale_config/bandstriped_worn
	greyscale_config_up = /datum/greyscale_config/bandstriped_up
	greyscale_config_worn_up = /datum/greyscale_config/bandstriped_worn_up
	greyscale_colors = "#2e2e2e#C6C6C6"
	undyeable = TRUE

/obj/item/clothing/mask/bandana/striped/black
	name = "striped bandana"
	desc = "A fine black and white bandana with nanotech lining and a stripe across."
	greyscale_colors = "#2e2e2e#C6C6C6"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/striped/security
	name = "striped security bandana"
	desc = "A fine bandana with nanotech lining, a stripe across and security colors."
	greyscale_colors = "#A02525#2e2e2e"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/striped/science
	name = "striped science bandana"
	desc = "A fine bandana with nanotech lining, a stripe across and science colors."
	greyscale_colors = "#DCDCDC#8019a0"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/striped/engineering
	name = "striped engineering bandana"
	desc = "A fine bandana with nanotech lining, a stripe across and engineering colors."
	greyscale_colors = "#dab50e#ec7404"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/striped/medical
	name = "striped medical bandana"
	desc = "A fine bandana with nanotech lining, a stripe across and medical colors."
	greyscale_colors = "#DCDCDC#5995BA"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/striped/cargo
	name = "striped cargo bandana"
	desc = "A fine bandana with nanotech lining, a stripe across and cargo colors."
	greyscale_colors = "#967032#5F350B"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/striped/botany
	name = "striped botany bandana"
	desc = "A fine bandana with nanotech lining, a stripe across and botany colors."
	greyscale_colors = "#3D9829#294A98"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/skull
	name = "skull bandana"
	desc = "A fine bandana with nanotech lining and a skull emblem."
	icon_state = "bandskull"
	worn_icon_state = "bandskull_worn"
	greyscale_config = /datum/greyscale_config/bandskull
	greyscale_config_worn = /datum/greyscale_config/bandskull_worn
	greyscale_config_up = /datum/greyscale_config/bandskull_up
	greyscale_config_worn_up = /datum/greyscale_config/bandskull_worn_up
	greyscale_colors = "#2e2e2e#C6C6C6"
	undyeable = TRUE

/obj/item/clothing/mask/bandana/skull/black
	desc = "A fine black bandana with nanotech lining and a skull emblem."
	greyscale_colors = "#2e2e2e#C6C6C6"
	flags_1 = NONE
