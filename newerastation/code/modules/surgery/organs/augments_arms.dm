/obj/item/organ/cyberimp/arm/toolset/abductor
	name = "abductor integrated toolset implant"
	desc = "A powerful version of the regular toolset, designed to be installed on subject's arm. Contains advanced versions of every tool and more!"
	contents = newlist(/obj/item/screwdriver/abductor, /obj/item/wrench/abductor, /obj/item/weldingtool/abductor,
		/obj/item/crowbar/abductor, /obj/item/wirecutters/abductor, /obj/item/multitool/abductor,
		/obj/item/analyzer, /obj/item/pipe_dispenser, /obj/item/construction/rcd/combat/admin,
		/obj/item/twohanded/rcl/pre_loaded, /obj/item/construction/rld, /obj/item/shuttle_creator,
		/obj/item/lightreplacer)

/obj/item/organ/cyberimp/arm/toolset/abductor/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/toolset/abductor/emag_act()
	if(!(locate(/obj/item/gun/energy/laser/instakill) in items_list))
		to_chat(usr, "<span class='notice'>You unlock [src]'s admeme power!</span>")
		items_list += new /obj/item/gun/energy/laser/instakill(src)
		return 1
	return 0
