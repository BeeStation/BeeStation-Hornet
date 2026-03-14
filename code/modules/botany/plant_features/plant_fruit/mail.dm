/*
	Fruit for mail plant
*/
/datum/plant_feature/fruit/mail
	species_name = "littera fructum"
	name = "mail"
	icon_state = "mail"
	fruit_product = /obj/item/mail
	growth_time = PLANT_FRUIT_GROWTH_SLOW
	colour_override = list("#DA0000", "#FF9300", "#FFF200", "#A8E61D", "#00B7EF", "#DA00FF", "#1C1C1C", "#FFFFFF")
	//Possible recipients
	var/list/mail_recipients = list()

/datum/plant_feature/fruit/mail/New(datum/component/plant/_parent)
	. = ..()
	populate_recipients()

/datum/plant_feature/fruit/mail/build_fruit()
	. = ..()
	if(!length(mail_recipients))
		populate_recipients()
	//Fill mail
	var/datum/mind/recipient = pick_n_take(mail_recipients)
	if(!recipient)
		return
	var/obj/item/mail/new_mail = .
	var/list/received_report = list() //Sacrificial lamb
	new_mail.initialize_for_recipient(recipient, received_report)
	qdel(received_report)

/datum/plant_feature/fruit/mail/proc/populate_recipients()
	for(var/mob/living/carbon/human/human in GLOB.player_list)
		// Mail is not routed to anyone who isn't present on the manifest, since how would we know
		// to send their mail here?
		if(!human.mind || !find_record(human.mind.name, GLOB.manifest.general))
			continue
		mail_recipients += human.mind
