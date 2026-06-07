
#define NODESIGN "None"
#define NANOTRASEN "NanotrasenStandard"
#define SYNDI "SyndiSnacks"
#define HEART "Heart"
#define SMILEY "SmileyFace"

/obj/item/storage/box/papersack
	name = "paper sack"
	desc = "A sack neatly crafted out of paper."
	icon = 'icons/obj/storage/paperbag.dmi'
	icon_state = "paperbag_None"
	inhand_icon_state = "paperbag_None"
	resistance_flags = FLAMMABLE
	foldable = null
	var/design = NODESIGN

/obj/item/storage/box/papersack/update_icon_state()
	if(contents.len == 0)
		icon_state = "[inhand_icon_state]"
	else
		icon_state = "[inhand_icon_state]_closed"
	return ..()

/obj/item/storage/box/papersack/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pen))
		//if a pen is used on the sack, dialogue to change its design appears
		if(contents.len)
			to_chat(user, span_warning("You can't modify [src] with items still inside!"))
			return
		var/list/designs = list(NODESIGN, NANOTRASEN, SYNDI, HEART, SMILEY, "Cancel")
		var/switchDesign = input("Select a Design:", "Paper Sack Design", designs[1]) in sort_list(designs)
		if(get_dist(usr, src) > 1)
			to_chat(usr, span_warning("You have moved too far away!"))
			return
		var/choice = designs.Find(switchDesign)
		if(design == designs[choice] || designs[choice] == "Cancel")
			return 0
		to_chat(usr, span_notice("You make some modifications to [src] using your pen."))
		design = designs[choice]
		icon_state = "paperbag_[design]"
		inhand_icon_state = "paperbag_[design]"
		switch(designs[choice])
			if(NODESIGN)
				desc = "A sack neatly crafted out of paper."
			if(NANOTRASEN)
				desc = "A standard Nanotrasen paper lunch sack for loyal employees on the go."
			if(SYNDI)
				desc = "The design on this paper sack is a remnant of the notorious 'SyndieSnacks' program."
			if(HEART)
				desc = "A paper sack with a heart etched onto the side."
			if(SMILEY)
				desc = "A paper sack with a crude smile etched onto the side."
		return 0
	else if(W.get_sharpness())
		if(!contents.len)
			if(inhand_icon_state == "paperbag_None")
				user.show_message(span_notice("You cut eyeholes into [src]."), MSG_VISUAL)
				new /obj/item/clothing/head/costume/papersack(user.loc)
				qdel(src)
				return 0
			else if(inhand_icon_state == "paperbag_SmileyFace")
				user.show_message(span_notice("You cut eyeholes into [src] and modify the design."), MSG_VISUAL)
				new /obj/item/clothing/head/costume/papersack/smiley(user.loc)
				qdel(src)
				return 0
	return ..()

#undef NODESIGN
#undef NANOTRASEN
#undef SYNDI
#undef HEART
#undef SMILEY
