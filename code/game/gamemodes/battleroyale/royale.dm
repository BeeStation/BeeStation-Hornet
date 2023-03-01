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
    var/winner

/datum/game_mode/battle_royale/check_win()
    var/player_list = get_sentient_mobs()
    var/list/active_players = list()

    for(var/mob/player in player_list) //checking for all mobs instead of just humans
        if((!player.client) || (is_centcom_level(player.z)))
            continue
        active_players += player
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
