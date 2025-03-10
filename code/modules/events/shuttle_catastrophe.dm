/datum/round_event_control/shuttle_catastrophe
	name = "Shuttle Catastrophe"
	typepath = /datum/round_event/shuttle_catastrophe
	weight = 10
	max_occurrences = 1
	max_alert = SEC_LEVEL_DELTA

/datum/round_event_control/shuttle_catastrophe/canSpawnEvent(players, gamemode)
	if(!is_centcom_level(SSshuttle.emergency.z) || (SSshuttle.emergency.name == "Build Your Own Shuttle") || (SSshuttle.emergency.name == "Build Your Own Shuttle, Jr.") || (SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL || SSshuttle.emergency.mode == SHUTTLE_DOCKED || SSshuttle.emergency.mode == SHUTTLE_STRANDED))
		return FALSE // don't undo manual player engineering, it also would unload people and ghost them, there's just a lot of problems
	return ..()


/datum/round_event/shuttle_catastrophe
	var/datum/map_template/shuttle/new_shuttle
	var/list/datum/map_template/shuttle/blacklisted_shuttles = list(/datum/map_template/shuttle/emergency/arena, /datum/map_template/shuttle/emergency/construction,
	/datum/map_template/shuttle/emergency/construction/small, /datum/map_template/shuttle/emergency/discoinferno, /datum/map_template/shuttle/emergency/meteor)
/datum/round_event/shuttle_catastrophe/announce(fake)
	var/cause = pick("was attacked by [syndicate_name()] Operatives", "mysteriously teleported away", "had its refuelling crew mutiny",
		"was found with its engines stolen", "\[REDACTED\]", "flew into the sunset, and melted", "fell into a black hole",
		"was stolen by the Clown Planet", "had its shuttle inspector put the shuttle in reverse instead of park, causing the shuttle to crash into the hangar")

	priority_announce("Your emergency shuttle [cause]. Your replacement shuttle will be the [new_shuttle.name] until further notice.", "CentCom Spacecraft Engineering")

/datum/round_event/shuttle_catastrophe/setup()
	var/list/valid_shuttle_templates = list()
	for(var/shuttle_id in SSmapping.shuttle_templates)
		var/datum/map_template/shuttle/template = SSmapping.shuttle_templates[shuttle_id]
		if(template.credit_cost < INFINITY) //if we could get it from the emagged communications console, it's cool for us to get it here
			if (!(template in blacklisted_shuttles))
				valid_shuttle_templates += template
	new_shuttle = pick(valid_shuttle_templates)

/datum/round_event/shuttle_catastrophe/start()
	SSshuttle.shuttle_purchased = SHUTTLEPURCHASE_FORCED
	SSshuttle.unload_preview()
	SSshuttle.load_template(new_shuttle)
	SSshuttle.existing_shuttle = SSshuttle.emergency
	SSshuttle.emergency.name = new_shuttle.name
	SSshuttle.action_load(new_shuttle)
	log_game("Shuttle Catastrophe set a new shuttle, [new_shuttle.name].")
