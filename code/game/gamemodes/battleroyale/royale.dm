/datum/game_mode/battle_royale
    name = "Battle Royale"
    config_tag = "battle_royale"
    report_type = "battle_royale"
    required_players = 1

    announce_span = "notice"
    announce_text = "<b>This goal of this game is to be the only survivor!</b>\n\
        <span class='notice'>Change your loadout in preferences to adjust your starting gear</span>\n\
        <span class='notice'>All jobs have unlimited slots, but mostly only offer different spawn locations</span>\n\
        <span class='notice'>All players start with the same access regardless of where they spawned</span>\n\
        <span class='notice'>Loot drops will periodically rain from the sky in random locations</span>\n\
        <span class='notice'>Random events will keep things spicy from time to time, stay on your toes!</span>\n\
	    <span class='danger'>Mild banter is fine, but don't be toxic to others unless you want to be smited</span>"
    var/mob/winner

/datum/game_mode/battle_royale/post_setup()
    ..()
    GLOB.battle_royale = new()
    GLOB.battle_royale.start()

/datum/game_mode/battle_royale/check_win()
    var/player_list = get_sentient_mobs()
    var/list/active_players = list()

    for(var/mob/player in player_list) //checking for all mobs instead of just humans
        if((!player.client) || (is_centcom_level(player.z)))
            continue
        var/turf/T = get_turf(player)
        if(T.x > 128 + GLOB.battle_royale.radius || T.x < 128 - GLOB.battle_royale.radius || T.y > 128 + GLOB.battle_royale.radius || T.y < 128 - GLOB.battle_royale.radius)
            to_chat(player, "<span class='warning'>You have left the zone!</span>")
            player.gib()
            continue
        if(!SSmapping.level_trait(T.z, ZTRAIT_STATION) && !SSmapping.level_trait(T.z, ZTRAIT_RESERVED))
            to_chat(player, "<span class='warning'>You have somehow left the station!</span>")
            player.gib()
            continue
        active_players += player
        CHECK_TICK
    if(length(active_players) > 1) //There are two or more living players, round continues
        return ..()
    if(length(active_players) == 0) //There are zero living players, round ends in draw
        winner = "draw"
    else if(active_players[1]) //With all other options eliminated, there is only one living player, round ends with them victorious
        winner = active_players[1]
    ..()

/datum/game_mode/battle_royale/check_finished()
    if(winner)
        return TRUE

/datum/game_mode/battle_royale/special_report()
    if(winner == "draw")
        to_chat(world, "<span class='ratvar'><font size=12>Everybody died!</font></span>")
        return "<div class='panel redborder'><span class='redtext big'>Nobody claims victory!</span></div>"
    if(winner?.real_name)
        to_chat(world, "<span class='ratvar'><font size=12>[winner.real_name] claims victory!</font></span>")
        return "<div class='panel redborder'><span class='greentext big'>[winner.real_name] claims victory!</span></div>"
    else
        to_chat(world, "<span class='ratvar'><font size=12>Something is bugged!</font></span>")
        return "<div class='panel redborder'><span class='redtext big'>Winner:([winner]) has an invalid value and couldn't be processed!</span></div>"
