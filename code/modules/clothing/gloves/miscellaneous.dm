//AURORA
/obj/item/clothing/gloves/cobalt_armchains
	name = "cobalt armchains"
	desc = "A set of luxurious chains intended to be wrapped around long, lanky arms. They don't seem particularly comfortable. They're encrusted with cobalt-blue gems, and made of <b>REAL</b> faux gold."
	icon_state = "cobalt_armchains"
	item_state = "cobalt_armchains"
	worn_icon_state = "cobalt_armchains"
	transfer_prints = TRUE
	undyeable = TRUE
/obj/item/clothing/gloves/emerald_armchains
	name = "emerald armchains"
	desc = "A set of luxurious chains intended to be wrapped around long, lanky arms. They don't seem particularly comfortable. They're encrusted with emerald-green gems, and made of <b>REAL</b> faux gold."
	icon_state = "emerald_armchains"
	item_state = "emerald_armchains"
	worn_icon_state = "emerald_armchains"
	transfer_prints = TRUE
	undyeable = TRUE
/obj/item/clothing/gloves/ruby_armchains
	name = "ruby armchains"
	desc = "A set of luxurious chains intended to be wrapped around long, lanky arms. They don't seem particularly comfortable. They're encrusted with ruby-red gems, and made of <b>REAL</b> faux gold."
	icon_state = "ruby_armchains"
	item_state = "ruby_armchains"
	worn_icon_state = "ruby_armchains"
	transfer_prints = TRUE
	undyeable = TRUE
/obj/item/clothing/gloves/cobalt_bracers
	name = "cobalt bracers"
	desc = "A pair of sturdy and thick decorative bracers, seeming better for fashion than protection. They're encrusted with cobalt-blue gems, and made of <b>REAL</b> faux gold."
	icon_state = "cobalt_bracers"
	item_state = "cobalt_bracers"
	worn_icon_state = "cobalt_bracers"
	transfer_prints = TRUE
	undyeable = TRUE
/obj/item/clothing/gloves/emerald_bracers
	name = "emerald bracers"
	desc = "A pair of sturdy and thick decorative bracers, seeming better for fashion than protection. They're encrusted with emerald-green gems, and made of <b>REAL</b> faux gold."
	icon_state = "emerald_bracers"
	item_state = "emerald_bracers"
	worn_icon_state = "emerald_bracers"
	transfer_prints = TRUE
	undyeable = TRUE
/obj/item/clothing/gloves/ruby_bracers
	name = "ruby bracers"
	desc = "A pair of sturdy and thick decorative bracers, seeming better for fashion than protection. They're encrusted with ruby-red gems, and made of <b>REAL</b> faux gold."
	icon_state = "ruby_bracers"
	item_state = "ruby_bracers"
	worn_icon_state = "ruby_bracers"
	transfer_prints = TRUE
	undyeable = TRUE
/obj/item/clothing/gloves/beaded
	name = "beaded bracelet"
	desc = "Made from loose beads with a center hole and connected by a piece of string or elastic band through said holes."
	icon_state = "beaded"
	item_state = "beaded"
	worn_icon_state = "beaded"
	transfer_prints = TRUE
	undyeable = TRUE
/obj/item/clothing/gloves/bracelet
	name = "bracelet"
	desc = "Made out of some synthetic polymer. Management encourages you to not ask questions."
	icon_state = "bracelet"
	item_state = "bracelet"
	worn_icon_state = "bracelet"
	transfer_prints = TRUE
	undyeable = TRUE
/obj/item/clothing/gloves/watch
	name = "watch"
	desc = "For those who want too much time on their wrists instead."
	icon_state = "watch"
	item_state = "watch"
	worn_icon_state = "watch"
	transfer_prints = TRUE
	undyeable = TRUE
/obj/item/clothing/gloves/watch_silver
	name = "silver watch"
	desc = "It's a GaussIo ZeitMeister, a finely tuned wristwatch encased in silver.."
	icon_state = "watch_silver"
	item_state = "watch_silver"
	worn_icon_state = "watch_silver"
	transfer_prints = TRUE
	undyeable = TRUE
/obj/item/clothing/gloves/watch_gold
	name = "gold watch"
	desc = "It's a GaussIo ZeitMeister, a finely tuned wristwatch encased in <b>REAL</b> faux gold.."
	icon_state = "watch_gold"
	item_state = "watch_gold"
	worn_icon_state = "watch_gold"
	transfer_prints = TRUE
	undyeable = TRUE

//MISC
/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "Plain black gloves without fingertips for the hard working."
	icon_state = "fingerless"
	item_state = "fingerless"
	worn_icon_state = "fingerless"
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
	worn_icon_state = "bracers"
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
	worn_icon_state = "rapid"
	transfer_prints = TRUE
	var/warcry = "AT"

/obj/item/clothing/gloves/rapid/Touch(atom/A, proximity)
	var/mob/living/M = loc
	if(get_dist(A, M) <= 1)
		if(isliving(A) && M.a_intent == INTENT_HARM)
			M.changeNext_move(CLICK_CD_RAPID)
			if(warcry)
				M.say("[warcry]", ignore_spam = TRUE, forced = "north star warcry")

	else if(M.a_intent == INTENT_HARM)
		for(var/mob/living/L in oview(1, M))
			L.attack_hand(M)
			M.changeNext_move(CLICK_CD_RAPID)
			if(warcry)
				M.say("[warcry]", ignore_spam = TRUE, forced = "north star warcry")
			break
	.= FALSE

/obj/item/clothing/gloves/rapid/attack_self(mob/user)
	var/input = stripped_input(user,"What do you want your battlecry to be? Max length of 6 characters.", ,"", 7)
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

/obj/item/clothing/gloves/color/white/magic/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(istype(W, /obj/item/upgradewand))
		var/obj/item/upgradewand/wand = W
		if(!wand.used && range == initial(range))
			wand.used = TRUE
			range = 6
			to_chat(user, "<span_class='notice'>You upgrade the [src] with the [wand].</span>")
			playsound(user, 'sound/weapons/emitter2.ogg', 25, 1, -1)

/obj/item/clothing/gloves/color/white/magic/Touch(atom/A, proximity)
	var/mob/living/M = loc
	if(get_dist(A, M) <= 1)
		return 0
	if(M in viewers(range, A))
		M.visible_message("<span_class ='danger'>[M] waves their hands at [A]</span>", "<span_class ='notice'>You begin manipulating [A].</span>")
		new	/obj/effect/temp_visual/telegloves(A.loc)
		M.changeNext_move(CLICK_CD_MELEE)
		if(do_after_mob(M, A, 8))
			new /obj/effect/temp_visual/telekinesis(M.loc)
			playsound(M, 'sound/weapons/emitter2.ogg', 25, 1, -1)
			A.attack_hand(M)
			return 1

