
/datum/mood_event/betterhug
	description = "Someone was very nice to me."
	mood_change = 3
	timeout = 4 MINUTES

/datum/mood_event/betterhug/add_effects(mob/friend)
	description = "[friend.name] was very nice to me."

/datum/mood_event/besthug
	description = "Someone is great to be around, they make me feel so happy!"
	mood_change = 5
	timeout = 4 MINUTES

/datum/mood_event/besthug/add_effects(mob/friend)
	description = "[friend.name] is great to be around, [friend.p_they()] makes me feel so happy!"

/datum/mood_event/arcade
	description = "I beat the arcade game!"
	mood_change = 3
	timeout = 8 MINUTES

/datum/mood_event/blessing
	description = "I've been blessed."
	mood_change = 3
	timeout = 8 MINUTES

/datum/mood_event/perform_cpr
	description = "It feels good to save a life."
	mood_change = 6
	timeout = 8 MINUTES

/datum/mood_event/oblivious
	description = "What a lovely day."
	mood_change = 3

/datum/mood_event/jolly
	description = "I feel happy for no particular reason."
	mood_change = 6
	timeout = 2 MINUTES

/datum/mood_event/focused
	description = "I have a goal, and I will reach it, whatever it takes!" //Used for syndies, nukeops etc so they can focus on their goals
	mood_change = 4
	hidden = TRUE

/datum/mood_event/badass_antag
	description = "I'm a fucking badass and everyone around me knows it. Just look at them, they're all fucking shaking at the mere thought of me around."
	mood_change = 7
	hidden = TRUE
	special_screen_obj = "badass_sun"
	special_screen_replace = FALSE

/datum/mood_event/creeping
	description = "The voices have released their hooks on my mind! I feel free again!" //creeps get it when they are around their obsession
	mood_change = 18
	timeout = 3 SECONDS
	hidden = TRUE

/datum/mood_event/revolution
	description = "VIVA LA REVOLUTION!"
	mood_change = 3
	hidden = TRUE

/datum/mood_event/cult
	description = "I have seen the truth, praise the almighty one!"
	mood_change = 10 //maybe being a cultist isn't that bad after all
	hidden = TRUE

/datum/mood_event/determined
	description = "I am determined to keep my friends safe."
	mood_change = 2
	hidden = TRUE

/datum/mood_event/heretics
	description = "THE HIGHER I RISE , THE MORE I SEE."
	mood_change = 10 //maybe being a cultist isn't that bad after all
	hidden = TRUE

/datum/mood_event/hivehost
	description = "Our psyche expands, our influence broadens."
	mood_change = 5
	hidden = TRUE

/datum/mood_event/hiveawakened
	description = "True purpose has been revealed to us, at last!."
	mood_change = 2
	hidden = TRUE

/datum/mood_event/family_heirloom
	description = "My family heirloom is safe with me."
	mood_change = 1

/datum/mood_event/goodmusic
	description = "There is something soothing about this music."
	mood_change = 3
	timeout = 60 SECONDS

/datum/mood_event/chemical_euphoria
	description = "Heh...hehehe...hehe..."
	mood_change = 4

/datum/mood_event/chemical_laughter
	description = "Laughter really is the best medicine! Or is it?"
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/chemical_superlaughter
	description = "*WHEEZE*"
	mood_change = 12
	timeout = 3 MINUTES

/datum/mood_event/religiously_comforted
	description = "I feel comforted by the presence of a holy person."
	mood_change = 3

/datum/mood_event/clownshoes
	description = "The shoes are a clown's legacy, I never want to take them off!"
	mood_change = 5

/datum/mood_event/artgood
	description = "What a thought-provoking piece of art. I'll remember that for a while."
	mood_change = 3
	timeout = 3 MINUTES

/datum/mood_event/artgreat
	description = "That work of art was so great it made me believe in the goodness of humanity. Says a lot in a place like this."
	mood_change = 4
	timeout = 4 MINUTES

/datum/mood_event/sacrifice_good
	description = "The gods are pleased with this offering!"
	mood_change = 5
	timeout = 3 MINUTES

/datum/mood_event/artok
	description = "It's nice to see people are making art around here."
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/artgood
	description = "What a thought-provoking piece of art. I'll remember that for a while."
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/artgreat
	description = "That work of art was so great it made me believe in the goodness of humanity. Says a lot in a place like this."
	mood_change = 6
	timeout = 5 MINUTES

/datum/mood_event/bottle_flip
	description = "The bottle landing like that was satisfying."
	mood_change = 2
	timeout = 3 MINUTES

/datum/mood_event/hope_lavaland
	description = "What a peculiar emblem. It makes me feel hopeful for my future."
	mood_change = 5

/datum/mood_event/holy_consumption
	description = "Truly, that was the food of the Divine!"
	mood_change = 1 // 1 + 5 from it being liked food makes it as good as jolly
	timeout = 3 MINUTES

/datum/mood_event/nanite_happiness
	description = "+++++++HAPPINESS ENHANCEMENT+++++++"
	mood_change = 7

/datum/mood_event/nanite_happiness/add_effects(message)
	description = "+++++++[message]+++++++"

/datum/mood_event/poppy_pin
	description = "I feel proud to show my remembrance of the many who have died to ensure that I have freedom."
	mood_change = 1

/datum/mood_event/sec_black_gloves
	description = "Black gloves look good on me."
	mood_change = 1

/datum/mood_event/assistant_insulated_gloves
	description = "Finally got my hands on a good pair of gloves!"
	mood_change = 1

/datum/mood_event/funny_prank
	description = "That was a funny prank, clown!"
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/toxoplasmosis
	description = "I really like being around cats!"
	mood_change = 2
	timeout = 30 SECONDS

/datum/mood_event/feline_mania
	description = "I'M SO HECKIN CUTE OMIGOSH!"
	mood_change = 5

/datum/mood_event/brain_tumor_mannitol
	description = "Mannitol makes my brain calm down."
	mood_change = 0
	timeout = 30 SECONDS

/datum/mood_event/brain_tumor_mannitol/New(mob/M, param)
	timeout = rand(30,60) SECONDS // makes the timing unreliable on your mood
	..()

/datum/mood_event/flower_worn
	description = "The flower I'm wearing is pretty."
	mood_change = 1

/datum/mood_event/flower_worn/add_effects(obj/item/I)
	description = "The [I.name] I'm wearing is pretty."

/datum/mood_event/flower_crown_worn
	description = "The flower crown on my head is beautiful."
	mood_change = 3

/datum/mood_event/flower_crown_worn/add_effects(obj/item/I)
	description = "The [I.name] on my head is beautiful."

/datum/mood_event/witnessed_starlight
	description = "The starlight emanating from space is so mesmerizing."
	mood_change = 10
	timeout = 10 MINUTES

/datum/mood_event/bigplush
	description = "Holding that big plush was quite nice."
	mood_change = 1
	timeout = 10 SECONDS
