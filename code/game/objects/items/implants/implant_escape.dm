
/obj/item/implant/escape
	name = "tooth implant"
	desc = "Bite into it to fall into a fake death."
	icon_state = "fake_death"
	uses = 3

/obj/item/implant/escape/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Fake Tooth Implant<BR>
				<b>Life:</b> Three uses.<BR>
				<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
				<HR>
				<b>Implant Details:</b> Subjects injected with implant can activate an injection of sneaky cocktails that induce a death-like state.<BR>
				<b>Function:</b> Causes a fake death-like state.<BR>
				<b>Integrity:</b> Implant can only be used three times before reserves are depleted."}
	return dat

/obj/item/implant/escape/activate()
	. = ..()
	to_chat(imp_in, "<span class='notice'>You bite into your fake tooth and suddenly feel dizzy...</span>")

	imp_in.reagents.add_reagent(/datum/reagent/toxin/zombiepowder, 30)
	if(!uses)
		qdel(src)

/obj/item/implanter/escape
	name = "implanter (fake tooth)"
	imp_type = /obj/item/implant/escape

