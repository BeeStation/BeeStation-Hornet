/obj/machinery/vending/sticker
	name = "\improper Sticker Vendor"
	desc = "Surprise mechanics!"
	product_ads = "Stick with me!;Be sure to stick around.;Stick to it."
	icon_state = "gacha"
	light_color = LIGHT_COLOR_CYAN
	products = list(/obj/item/sticker_gacha/series_1 = 15)
	refill_canister = /obj/item/vending_refill/sticker
	default_price = 35
	extra_price = 50

/obj/machinery/vending/sticker/Initialize(mapload)
	. = ..()
	fill_sticker_globals()

/obj/item/vending_refill/sticker
	machine_name = "Sticker Vendor"
	icon_state = "refill_smoke"

//You can make this generic if you want to use it elsehwere
/obj/item/sticker_gacha
	name = "sticker gacha ball - series 1"
	desc = "A prize ball. What could be inside!"
	icon = 'icons/obj/sticker.dmi'
	icon_state = "gacha_red"
	w_class = WEIGHT_CLASS_SMALL
	///What series does this gacha pull from
	var/series = STICKER_SERIES_1

/obj/item/sticker_gacha/Initialize(mapload)
	. = ..()
	icon_state = "gacha_[pick("red", "green", "blue")]"

/obj/item/sticker_gacha/interact(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>You begin to pry open [src].</span>")
	if(do_after(user, 2.5 SECONDS, src))
		playsound(user, 'sound/effects/cartoon_pop.ogg', 35, TRUE)
		//Build prize
		user.dropItemToGround(src)
		var/obj/item/sticker/S = pick(GLOB.stickers_by_series["[series]"])
		S = new S(get_turf(src))
		user.put_in_active_hand(S)
		//Dopamine
		playsound(user, 'sound/items/party_horn.ogg', 35, TRUE)
		user.add_emitter(/obj/emitter/confetti, "confetti", 10, lifespan = 15)
		//Kill ourselves
		qdel(src)
	else
		to_chat(user, "<span class='warning'>You fail to pry [src] open.</span>")

/obj/item/sticker_gacha/series_1
	series = STICKER_SERIES_1
