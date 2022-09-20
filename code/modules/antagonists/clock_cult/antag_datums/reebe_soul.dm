/datum/antagonist/servant_of_ratvar/reebe_soul
	name = "Servant of Rat'var (Reebe Soul)"

/datum/antagonist/servant_of_ratvar/reebe_soul/greet()
	if(!owner.current)
		return
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/clockcultalr.ogg', 60, FALSE, pressure_affected = FALSE)
	to_chat(owner.current, "<span class='heavy_brass'><font size='7'>You are the soul of [owner.current]!</font></span>")
	to_chat(owner.current, "<span class='brass'>Your old body in the mortal frame was weak and has perished. \
		Your soul resides on Reebe, a space within the void dedicated to the worship of Rat'Var.</span>")
	to_chat(owner.current, "<span class='brass'>You are not at peace however, Rat'Var has been banished by \
		Nar'Sie and the servants of Rat'Var are slowly being hunted down.</span>")
	to_chat(owner.current, "<span class='brass'>In order to release Rat'var, the Celestial Gateway needs to be activated.</span>")
	to_chat(owner.current, "<span class='brass'>The Eminence has prophecised that a great battle will take place in this location.</span>")
	to_chat(owner.current, "<span class='brass'>\[---------------------]\</span>")
	to_chat(owner.current, "<span class='brass'>You must build protections for the Gateway and provide blessings \
		for the mortal servants of Rat'Var until the gateway can be activated and they can be called back to where they belong.</span>")
	to_chat(owner.current, "<span class='brass'>Your soul may inhabit a clockwork golem to access the mortal plane which \
		requires a mortal servant to first construct it.</span>")
	to_chat(owner.current, "<span class='brass bold'>If your original body is revived, your soul will be forced back into it and will exit Reebe.</span>")
	owner.current.client?.tgui_panel?.give_antagonist_popup("Servant of Rat'Var",
		"You are a soul, existing within Reebe.\n\
		Use the power collected by mortal servants to complete research to further your goals.\n\
		Provide blessings to the believers of your cause.\n\
		Construct defenses in order to serve the oncoming battle fortold by the Eminence.")

/datum/antagonist/servant_of_ratvar/reebe_soul/equip_carbon(mob/living/carbon/H)
	//Convert all items in their inventory to Ratvarian
	var/list/contents = H.get_contents()
	for(var/atom/A in contents)
		A.ratvar_act()
	//Equip them with a slab
	var/obj/item/clockwork/clockwork_slab/slab = new(get_turf(H))
	H.put_in_hands(slab)
	//Remove cuffs
	H.uncuff()

/datum/antagonist/servant_of_ratvar/reebe_soul/apply_innate_effects(mob/living/M)
	. = ..()
	transmit_spell = new()
	transmit_spell.Grant(owner.current)

/datum/antagonist/servant_of_ratvar/reebe_soul/remove_innate_effects(mob/living/M)
	transmit_spell.Remove(transmit_spell.owner)
	. = ..()
