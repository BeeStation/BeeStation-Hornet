/obj/item/integrated_electronics/analyzer
	name = "circuit analyzer"
	desc = "A tool that scans assemblies and gives the user a printout to recreate it in a circuit printer."
	icon = 'icons/obj/assemblies/electronic_tools.dmi'
	icon_state = "analyzer"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_SMALL

/obj/item/integrated_electronics/analyzer/afterattack(var/atom/A, var/mob/living/user)
	. = ..()
	if(istype(A, /obj/item/electronic_assembly))
		var/obj/item/electronic_assembly/EA = A
		if(EA.idlock)
			to_chat(user, "<span class='notice'>[A] is currently identity-locked and can't be analyzed.</span>")
			return FALSE

		var/saved = SScircuit.save_electronic_assembly(A)
		if(saved)
			to_chat(user, "<span class='notice'>You scan [A].</span>")
			save_circuit(usr.ckey,saved_data = saved)
		else
			to_chat(user, "<span class='warning'>[A] is not complete enough to be encoded!</span>")

/obj/item/integrated_electronics/analyzer/proc/save_circuit(ckey, filename="circuits.sav", var/saved_data)
	if(!ckey||!saved_data)
		return
	var/path = "data/player_saves/[ckey[1]]/[ckey]/[filename]"

	var/savefile/S = new /savefile(path)
	S << saved_data
