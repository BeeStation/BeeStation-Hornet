
/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "Plain black gloves without fingertips for the hard working."
	icon_state = "fingerless"
	worn_icon_state = "fingerless"
	item_state = "fingerless"
	transfer_prints = TRUE
	strip_delay = 40
	equip_delay_other = 20
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	custom_price = 10
	undyeable = TRUE

/obj/item/clothing/gloves/botanic_leather
	name = "botanist's leather gloves"
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin.  They're also quite warm."
	icon_state = "leather"
	item_state = "ggloves"
	worn_icon_state = "ggloves"
	permeability_coefficient = 0.9
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 30, "stamina" = 0)

/obj/item/clothing/gloves/combat
	name = "combat gloves"
	desc = "These tactical gloves are fireproof and shock resistant."
	icon_state = "cgloves"
	item_state = "combatgloves"
	worn_icon_state = "combatgloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 50, "stamina" = 20)

/obj/item/clothing/gloves/bracer
	name = "bone bracers"
	desc = "For when you're expecting to get slapped on the wrist. Offers modest protection to your arms."
	icon_state = "bracers"
	item_state = "bracers"
	transfer_prints = TRUE
	strip_delay = 40
	equip_delay_other = 20
	body_parts_covered = ARMS
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list("melee" = 15, "bullet" = 35, "laser" = 35, "energy" = 20, "bomb" = 35, "bio" = 35, "rad" = 35, "fire" = 0, "acid" = 0, "stamina" = 20)

/obj/item/clothing/gloves/rapid
	name = "Gloves of the North Star"
	desc = "Just looking at these fills you with an urge to beat the shit out of people."
	icon_state = "rapid"
	item_state = "rapid"
	transfer_prints = TRUE
	var/warcry = "AT"

/obj/item/clothing/gloves/rapid/Touch(atom/target, proximity)
	var/mob/living/user = loc
	if(get_dist(target, user) <= 1)
		if(isliving(target) && user.a_intent == INTENT_HARM)
			user.changeNext_move(CLICK_CD_RAPID)
			if(warcry)
				user.say("[warcry]", ignore_spam = TRUE, forced = "north star warcry")

	else if(user.a_intent == INTENT_HARM)
		for(var/mob/living/living_target in oview(1, user))
			living_target.attack_hand(user)
			user.changeNext_move(CLICK_CD_RAPID)
			if(warcry)
				user.say("[warcry]", ignore_spam = TRUE, forced = "north star warcry")
			break
	.= FALSE

/obj/item/clothing/gloves/rapid/attack_self(mob/user)
	var/input = stripped_input(user,"What do you want your battlecry to be? Max length of 7 characters.", ,"", 8) //monkestation edit *scream
	if(input == "*me") //If they try to do a *me emote it will stop the attack to prompt them for an emote then they can walk away and enter the emote for a punch from far away
		to_chat(user, "<span class='warning'>Invalid battlecry, please use another. Battlecry cannot contain *me.</span>")
	else if(CHAT_FILTER_CHECK(input))
		to_chat(user, "<span class='warning'>Invalid battlecry, please use another. Battlecry contains prohibited word(s).</span>")
	else if(input)
		warcry = input

/obj/item/clothing/gloves/color/white/magic
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"
	item_state = "wgloves"
	var/range = 3

/obj/item/clothing/gloves/color/white/magic/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(istype(attacking_item, /obj/item/upgradewand))
		var/obj/item/upgradewand/wand = attacking_item
		if(!wand.used)
			wand.used = TRUE
			range += 3
			to_chat(user, "<span_class='notice'>You upgrade the [src] with the [wand].</span>")
			playsound(user, 'sound/weapons/emitter2.ogg', 25, 1, -1)

/obj/item/clothing/gloves/color/white/magic/Touch(atom/target, proximity)
	var/mob/living/user = loc
	if(get_dist(target, user) <= 1)
		return FALSE
	if(istype(target, /obj/structure))
		return FALSE
	if(user in viewers(range, target))
		user.visible_message("<span_class ='danger'>[user] waves their hands at [target]</span>", "<span_class ='notice'>You begin manipulating [target].</span>")
		new	/obj/effect/temp_visual/telegloves(target.loc)
		user.changeNext_move(CLICK_CD_MELEE)
		if(do_after_mob(user, target, 8))
			new /obj/effect/temp_visual/telekinesis(user.loc)
			playsound(user, 'sound/weapons/emitter2.ogg', 25, 1, -1)
			target.attack_hand(user)
			return TRUE

