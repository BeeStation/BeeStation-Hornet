
/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "Plain black gloves without fingertips for the hard working."
	icon_state = "fingerless"
	inhand_icon_state = "fingerless"
	worn_icon_state = "fingerless"
	strip_delay = 40
	equip_delay_other = 20
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	custom_price = 10
	undyeable = TRUE
	clothing_traits = list(TRAIT_FINGERPRINT_PASSTHROUGH)

/obj/item/clothing/gloves/botanic_leather
	name = "botanist's leather gloves"
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin.  They're also quite warm."
	icon_state = "leather"
	inhand_icon_state = "ggloves"
	worn_icon_state = "ggloves"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor_type = /datum/armor/gloves_botanic_leather
	clothing_flags = THICKMATERIAL


/datum/armor/gloves_botanic_leather
	bio = 50
	fire = 70
	acid = 30

/obj/item/clothing/gloves/combat
	name = "combat gloves"
	desc = "These tactical gloves are fireproof and shock resistant."
	icon_state = "cgloves"
	inhand_icon_state = "combatgloves"
	worn_icon_state = "combatgloves"
	siemens_coefficient = 0
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor_type = /datum/armor/gloves_combat
	clothing_flags = THICKMATERIAL
	custom_price = 150
	trade_flags = TRADE_CONTRABAND

/datum/armor/gloves_combat
	bio = 90
	fire = 80
	acid = 50
	stamina = 20
	bleed = 10

/obj/item/clothing/gloves/bracer
	name = "bone bracers"
	desc = "For when you're expecting to get slapped on the wrist. Offers modest protection to your arms."
	icon_state = "bracers"
	inhand_icon_state = "bracers"
	worn_icon_state = "bracers"
	strip_delay = 40
	equip_delay_other = 20
	body_parts_covered = ARMS
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor_type = /datum/armor/gloves_bracer
	clothing_traits = list(TRAIT_FINGERPRINT_PASSTHROUGH)


/datum/armor/gloves_bracer
	melee = 15
	bullet = 35
	laser = 35
	energy = 20
	bomb = 35
	bio = 35
	stamina = 20
	bleed = 20

/obj/item/clothing/gloves/rapid
	name = "Gloves of the North Star"
	desc = "Just looking at these fills you with an urge to beat the shit out of people."
	icon_state = "rapid"
	inhand_icon_state = "rapid"
	worn_icon_state = "rapid"
	item_flags = ISWEAPON
	clothing_traits = list(TRAIT_FINGERPRINT_PASSTHROUGH)

/obj/item/clothing/gloves/rapid/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/punchcooldown)

/obj/item/clothing/gloves/color/white/magic
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"
	inhand_icon_state = "wgloves"
	var/range = 3

/obj/item/clothing/gloves/color/white/magic/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(istype(W, /obj/item/upgradewand))
		var/obj/item/upgradewand/wand = W
		if(!wand.used && range == initial(range))
			wand.used = TRUE
			range = 6
			to_chat(user, span_notice("You upgrade the [src] with the [wand]."))
			playsound(user, 'sound/weapons/emitter2.ogg', 25, 1, -1)

/obj/item/clothing/gloves/color/white/magic/Touch(atom/A, proximity)
	var/mob/living/user = loc
	if(get_dist(A, user) <= 1 )
		return FALSE
	if(user in viewers(range, A))
		user.visible_message(span_danger("[user] waves their hands at [A]"), span_notice("You begin manipulating [A]."))
		new	/obj/effect/temp_visual/telegloves(A.loc)
		user.changeNext_move(CLICK_CD_MELEE)
		if(do_after(user, 0.8 SECONDS, A))
			new /obj/effect/temp_visual/telekinesis(user.loc)
			playsound(user, 'sound/weapons/emitter2.ogg', 25, 1, -1)
			A.attack_hand(user)
			return TRUE

/obj/item/clothing/gloves/artifact_pinchers
	name = "anti-tactile pinchers"
	desc = "Used for the fine manipulation and examination of artifacts."
	icon_state = "pincher"
	inhand_icon_state = "pincher"
	worn_icon_state = "pincher"
	actions_types = list(/datum/action/item_action/artifact_pincher_mode)
	var/safety = FALSE

/obj/item/clothing/gloves/artifact_pinchers/Initialize(mapload)
	. = ..()
	var/datum/component/anti_artifact/A = AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100, ITEM_SLOT_GLOVES)
	A?.override = !safety

/datum/action/item_action/artifact_pincher_mode
	name = "Toggle Safety"
	background_icon = null

/datum/action/item_action/artifact_pincher_mode/on_activate(mob/user, atom/target)
	. = ..()
	var/obj/item/clothing/gloves/artifact_pinchers/pinchy = target
	if(istype(pinchy))
		pinchy.safety = !pinchy.safety
		var/datum/component/anti_artifact/A = pinchy.GetComponent(/datum/component/anti_artifact)
		A?.override = !pinchy.safety
		update_buttons()

/datum/action/item_action/artifact_pincher_mode/update_button(atom/movable/screen/movable/action_button/button, status_only = FALSE, force = FALSE)
	if(..()) //button available
		var/obj/item/clothing/gloves/artifact_pinchers/pinchy = master
		if(istype(pinchy))
			button.color = (pinchy.safety ? "#0f0" : "#fff")

/obj/item/clothing/gloves/translocation_ring
	name = "ring of translocation"
	desc = "A ring that allows the wearer to swap places with another person they can see."
	icon_state = "ring"
	inhand_icon_state = "ring"
	actions_types = list(/datum/action/spell/pointed/swap_places)

/obj/item/clothing/gloves/translocation_ring/item_action_slot_check(slot, mob/user)
	return slot == ITEM_SLOT_GLOVES
