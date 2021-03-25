/obj/item/integrated_electronics/analyzer
	name = "circuit analyzer"
	desc = "This tool can scan an assembly and save it for later recreation in a personal data cloud."
	icon = 'icons/obj/assemblies/electronic_tools.dmi'
	icon_state = "analyzer"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_SMALL
	var/debug = FALSE

/obj/item/integrated_electronics/analyzer/afterattack(var/atom/A, var/mob/living/user)
	. = ..()
	if(istype(A, /obj/item/electronic_assembly))
		var/obj/item/electronic_assembly/EA = A
		if(debug)
			if(EA.idlock)
				to_chat(user, "<span class='notice'>[A] is currently identity-locked and can't be analyzed.</span>")
				return FALSE
			var/saved = "[A.name] analyzed! On circuit printers with cloning enabled, you may use the code below to clone the circuit:<br><br><code>[json_encode(SScircuit.save_electronic_assembly(A))]</code>"
			if(saved)
				to_chat(user, "<span class='notice'>You scan [A].</span>")
				user << browse(saved, "window=circuit_scan;size=500x600;border=1;can_resize=1;can_close=1;can_minimize=1")
			else
				to_chat(user, "<span class='warning'>[A] is not complete enough to be encoded!</span>")
			if(EA.idlock)
				to_chat(user, "<span class='notice'>[A] is currently identity-locked and can't be analyzed.</span>")
				return FALSE
		else
			var/saved = SScircuit.save_electronic_assembly(A)
			if(saved)
				to_chat(user, "<span class='notice'>You scan [A].</span>")
				save_circuit(usr.ckey,saved_data = saved)
			else
				to_chat(user, "<span class='warning'>[A] is not complete enough to be encoded!</span>")

/obj/item/integrated_electronics/analyzer/proc/save_circuit(ckey, var/saved_data)
	if(!ckey||!saved_data)
		return
	var/cname = input(usr,"Please Input a name for your circuit.","Name?") as text
	if(cname == null)
		to_chat(usr, "<span class='notice'>The Circuit has no individual name yet please name it before scanning.</span>")
		return
	var/path = "data/player_saves/[ckey[1]]/[ckey]/circuits.sav"
	var/savefile/S = new /savefile(path)
	var/circuit_list
	S >> circuit_list
	if(length(circuit_list) >= 20)
		var/override_circuit = input(usr,"You reached the max number of circuits choose a circuit to override.","Choose") as null|anything in circuit_list
		if(override_circuit == null)
			to_chat(usr, "<span class='notice'>You do not override the circuit.</span>")
			return
		if(alert(usr, "Warning this will override the old circuit.", "Do you still want to do continue?", "Abort", "Proceed") == "Abort")
			to_chat(usr, "<span class='notice'>You do not override the circuit.</span>")
			return
		circuit_list -= override_circuit
	if(!islist(circuit_list))
		circuit_list = new/list()
	if(circuit_list[cname])
		if(alert(usr, "Warning this will override the old circuit with the same name.", "Do you still want to do continue this?", "Abort", "Proceed") == "Abort")
			to_chat(usr, "<span class='notice'>You do not override the circuit.</span>")
			return
	circuit_list[cname] = saved_data
	S << circuit_list

/obj/item/integrated_electronics/analyzer/debug
	name = "circuit analyzer debug"
	desc = "This tool can scan an assembly and generate a string necessary to recreate it in a circuit printer."
	icon = 'icons/obj/assemblies/electronic_tools.dmi'
	icon_state = "analyzer"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_SMALL
	debug = TRUE
