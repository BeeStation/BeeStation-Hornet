/datum/action/changeling/teratoma
	name = "Birth Teratoma"
	desc = "Our form divides, creating an egg that will soon hatch into a living tumor, fixated on causing mayhem"
	helptext = "The tumor will not be loyal to us or our cause. Costs two changeling absorptions"
	button_icon_state = "spread_infestation"
	chemical_cost = 60
	dna_cost = 2
	req_absorbs = 3

//Makes a single egg, which hatches into a reskinned monkey with an objective to cause chaos after some time. 
/datum/action/changeling/teratoma/sting_action(mob/user)
	..()
	new /obj/effect/gibspawner/generic(user.loc)
	var/obj/effect/mob_spawn/teratomamonkey/teratoma = new(user.loc)
	user.visible_message("<span class='warning'>[teratoma] explodes out of [user]'s body in a shower of gore!</span>",
				"<span class='userdanger'>You expel a clump of flesh, which will soon become a vile creature bent on causing chaos.</span>")
	teratoma.flavour_text = {"
	<b>You are a living teratoma, birthed from an inhuman host. Your purpose is to cause chaos and misery for the beings inhabiting this station.
	"}
	return TRUE