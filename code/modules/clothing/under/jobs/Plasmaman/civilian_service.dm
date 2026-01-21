/obj/item/clothing/under/plasmaman
	name = "plasma envirosuit"
	desc = "A special containment suit that allows plasma-based lifeforms to exist safely in an oxygenated environment, and automatically extinguishes them in a crisis. Despite being airtight, it's not spaceworthy."
	icon_state = "plasmaman"
	inhand_icon_state = "plasmaman"
	icon = 'icons/obj/clothing/under/plasmaman.dmi'
	worn_icon = 'icons/mob/clothing/under/plasmaman.dmi'
	armor_type = /datum/armor/under_plasmaman
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	can_adjust = FALSE
	strip_delay = 80
	resistance_flags = FIRE_PROOF
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 5
	envirosealed = TRUE



/datum/armor/under_plasmaman
	bio = 100
	fire = 95
	acid = 95

/obj/item/clothing/under/plasmaman/examine(mob/user)
	. = ..()
	. += span_notice("There are [extinguishes_left] extinguisher charges left in this suit.")

/obj/item/clothing/under/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.on_fire)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message(span_warning("[H]'s suit automatically extinguishes [H.p_them()]!"),span_warning("Your suit automatically extinguishes you."))
			H.extinguish_mob()
			new /obj/effect/particle_effect/water(get_turf(H))
	return 0

/obj/item/clothing/under/plasmaman/attackby(obj/item/E, mob/user, params)
	..()
	if (istype(E, /obj/item/extinguisher_refill))
		if (extinguishes_left == 5)
			to_chat(user, span_notice("The inbuilt extinguisher is full."))
			return
		else
			extinguishes_left = 5
			to_chat(user, span_notice("You refill the suit's built-in extinguisher, using up the cartridge."))
			qdel(E)
			return

/obj/item/clothing/under/plasmaman/cargo
	name = "cargo plasma envirosuit"
	desc = "A joint envirosuit used by plasmamen quartermasters and cargo techs alike, due to the logistical problems of differenciating the two with the length of their pant legs."
	icon_state = "cargo_envirosuit"
	inhand_icon_state = "cargo_envirosuit"

/obj/item/clothing/under/plasmaman/mailman
	name = "mailman plasma envirosuit"
	desc = "<i>'Special hazardous delivery!'</i>"
	icon_state = "mailman_envirosuit"
	inhand_icon_state = "mailman_envirosuit"

/obj/item/clothing/under/plasmaman/mining
	name = "mining plasma envirosuit"
	desc = "An air-tight khaki suit designed for operations on lavaland by plasmamen."
	icon_state = "explorer_envirosuit"
	inhand_icon_state = "explorer_envirosuit"

/obj/item/clothing/under/plasmaman/chef
	name = "chef's plasma envirosuit"
	desc = "A white plasmaman envirosuit designed for cullinary practices. One might question why a member of a species that doesn't need to eat would become a chef."
	icon_state = "chef_envirosuit"
	inhand_icon_state = "chef_envirosuit"

/obj/item/clothing/under/plasmaman/enviroslacks
	name = "enviroslacks"
	desc = "The pet project of a particularly posh plasmaman, this custom suit was quickly appropriated by Nano-Trasen for it's detectives, lawyers, and bar-tenders alike."
	icon_state = "enviroslacks"
	inhand_icon_state = "enviroslacks"

/obj/item/clothing/under/plasmaman/tux
	name = "envirotux"
	desc = "A flashy suit blended into an envirosuit."
	icon_state = "envirotux"
	inhand_icon_state = "envirotux"

/obj/item/clothing/under/plasmaman/gold //yes, you can sell this for ludicrous mony
	name = "designer envirosuit"
	desc = "A flashy gold-trimmed envirosuit, complete with a suit jacket outerwear. This is a designer model, worth a few thousand credits."
	icon_state = "gold_envirosuit"
	inhand_icon_state = "gold_envirosuit"
	custom_price = 4500

/obj/item/clothing/under/plasmaman/chaplain
	name = "chaplain's plasma envirosuit"
	desc = "An envirosuit specially designed for only the most pious of plasmamen."
	icon_state = "chap_envirosuit"
	inhand_icon_state = "chap_envirosuit"

/obj/item/clothing/under/plasmaman/curator
	name = "curator's plasma envirosuit"
	desc = "Made out of a modified voidsuit, this suit was Nano-Trasen's first solution to the *logistical problems* that come with employing plasmamen. Due to the modifications, the suit is no longer space-worthy. Despite their limitations, these suits are still in used by historian and old-styled plasmamen alike."
	icon_state = "prototype_envirosuit"
	inhand_icon_state = "prototype_envirosuit"

/obj/item/clothing/under/plasmaman/janitor
	name = "janitor's plasma envirosuit"
	desc = "A grey and purple envirosuit designated for plasmamen janitors."
	icon_state = "janitor_envirosuit"
	inhand_icon_state = "janitor_envirosuit"

/obj/item/clothing/under/plasmaman/botany
	name = "botany plasma envirosuit"
	desc = "A green and blue envirosuit designed to protect plasmamen from minor plant-related injuries."
	icon_state = "botany_envirosuit"
	inhand_icon_state = "botany_envirosuit"

/obj/item/clothing/under/plasmaman/command //fun fact, captains uniforms don't get the sec uniform defense buff, pretty stupid
	name = "captains plasma envirosuit"
	desc = "A blue envirosuit with gold trimmings. A suit made for those who demand respect from their subordinates."
	icon_state = "command_envirosuit"
	inhand_icon_state = "command_envirosuit"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/plasmaman/hop
	name = "head of personnel plasma envirosuit"
	desc = "The head of personnels blue envirosuit, complete with red trimmings and adorned with various medals."
	icon_state = "hop_envirosuit"
	inhand_icon_state = "hop_envirosuit"

/obj/item/clothing/under/plasmaman/mime
	name = "mime envirosuit"
	desc = "A black and white envirosuit, your bones may rattle but that won't stop your silent shinanigains!."
	icon_state = "mime_envirosuit"
	inhand_icon_state = "mime_envirosuit"

/obj/item/clothing/under/plasmaman/honk
	name = "Clowns plasma envirosuit"
	desc = "A rainbow colored envirosuit, it reaks of bananas and cheap rubber horns."
	icon_state = "honk_envirosuit"
	inhand_icon_state = "honk_envirosuit"
