/obj/item/book/granter/art_of_thievery
	name = "The Art of Thievery"
	desc = "A book that seems to contain a picture by picture guide to pickpocketing people without being noticed."
	icon_state = "art_of_thievery"
	remarks = list("Oh, I'm NOT supposed to fiddle with their pockets...", "Practice with bells on a jumpsuit...", "Wait for the right moment to snag what's unrightfully mine...", "So THAT'S how I keep losing credits...", "Divert their attention with small talk...")

/obj/item/book/granter/art_of_thievery/on_reading_finished(mob/user)
	. = ..()
	to_chat(user, span_notice("You learned how to pickpocket people stealthily."))
	user.log_message("[user] learned how to pickpocket people stealthily.", LOG_ATTACK, color="orange")
	ADD_TRAIT(user, TRAIT_STEALTH_PICKPOCKET, "art_of_thievery")
