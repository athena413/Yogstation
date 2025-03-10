////////////////////
//MORE DRONE TYPES//
////////////////////
//Drones with custom laws
//Drones with custom shells
//Drones with overridden procs
//Drones with camogear for hat related memes
//Drone type for use with polymorph (no preloaded items, random appearance)


//More types of drones
/mob/living/simple_animal/drone/syndrone
	name = "Syndrone"
	desc = "A modified maintenance drone. This one brings with it the feeling of terror."
	icon_state = "drone_synd"
	icon_living = "drone_synd"
	picked = TRUE //the appearence of syndrones is static, you don't get to change it.
	health = 30
	maxHealth = 120 //If you murder other drones and cannibalize them you can get much stronger
	initial_language_holder = /datum/language_holder/drone/syndicate
	faction = list(ROLE_SYNDICATE)
	speak_emote = list("hisses")
	bubble_icon = "syndibot"
	heavy_emp_damage = 10
	laws = \
	"1. Interfere.\n"+\
	"2. Kill.\n"+\
	"3. Destroy."
	default_storage = /obj/item/uplink
	default_hatmask = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	hacked = TRUE
	flavortext = null
	pacifism = FALSE

/mob/living/simple_animal/drone/syndrone/Initialize(mapload)
	. = ..()
	var/datum/component/uplink/hidden_uplink = internal_storage.GetComponent(/datum/component/uplink)
	hidden_uplink.telecrystals = 10

/mob/living/simple_animal/drone/syndrone/Login()
	..()
	to_chat(src, span_notice("You can kill and eat other drones to increase your health!") )

/mob/living/simple_animal/drone/syndrone/badass
	name = "Badass Syndrone"
	default_hatmask = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	default_storage = /obj/item/uplink/nuclear

/mob/living/simple_animal/drone/syndrone/badass/Initialize(mapload)
	. = ..()
	var/datum/component/uplink/hidden_uplink = internal_storage.GetComponent(/datum/component/uplink)
	hidden_uplink.telecrystals = 30
	var/obj/item/implant/weapons_auth/W = new/obj/item/implant/weapons_auth(src)
	W.implant(src, force = TRUE)

/mob/living/simple_animal/drone/snowflake
	default_hatmask = /obj/item/clothing/head/chameleon/drone

/mob/living/simple_animal/drone/snowflake/Initialize(mapload)
	. = ..()
	desc += " This drone appears to have a complex holoprojector built on its 'head'."

/obj/item/drone_shell/syndrone
	name = "syndrone shell"
	desc = "A shell of a syndrone, a modified maintenance drone designed to infiltrate and annihilate."
	icon_state = "syndrone_item"
	drone_type = /mob/living/simple_animal/drone/syndrone

/obj/item/drone_shell/syndrone/badass
	name = "badass syndrone shell"
	drone_type = /mob/living/simple_animal/drone/syndrone/badass

/obj/item/drone_shell/snowflake
	name = "snowflake drone shell"
	desc = "A shell of a snowflake drone, a maintenance drone with a built in holographic projector to display hats and masks."
	drone_type = /mob/living/simple_animal/drone/snowflake

/mob/living/simple_animal/drone/polymorphed
	default_storage = null
	default_hatmask = null
	picked = TRUE
	flavortext = null
	pacifism = FALSE

/mob/living/simple_animal/drone/polymorphed/Initialize(mapload)
	. = ..()
	liberate()
	visualAppearence = pick(MAINTDRONE, REPAIRDRONE, SCOUTDRONE)
	if(visualAppearence == MAINTDRONE)
		var/colour = pick("grey", "blue", "red", "green", "pink", "orange")
		icon_state = "[visualAppearence]_[colour]"
	else
		icon_state = visualAppearence

	icon_living = icon_state
	icon_dead = "[visualAppearence]_dead"

/obj/item/drone_shell/dusty
	name = "derelict drone shell"
	desc = "A long-forgotten drone shell. It seems kind of... Space Russian."
	drone_type = /mob/living/simple_animal/drone/derelict

/mob/living/simple_animal/drone/derelict
	name = "derelict drone"
	default_hatmask = /obj/item/clothing/head/ushanka

/mob/living/simple_animal/drone/cogscarab
	name = "cogscarab"
	desc = "A strange, drone-like machine. It constantly emits the hum of gears."
	icon_state = "drone_clock"
	icon_living = "drone_clock"
	icon_dead = "drone_clock_dead"
	picked = TRUE
	pass_flags = PASSTABLE
	health = 50
	maxHealth = 50
	harm_intent_damage = 5
	density = TRUE
	speed = 1
	ventcrawler = VENTCRAWLER_NONE
	faction = list("neutral", "ratvar")
	speak_emote = list("clanks", "clinks", "clunks", "clangs")
	verb_ask = "requests"
	verb_exclaim = "proclaims"
	verb_whisper = "imparts"
	verb_yell = "harangues"
	bubble_icon = "clock"
	initial_language_holder = /datum/language_holder/clockmob
	light_color = "#E42742"
	heavy_emp_damage = 0
	laws = "0. Purge all untruths and honor Ratvar."
	default_storage = /obj/item/storage/toolbox/brass/prefilled
	hacked = TRUE
	visualAppearence = CLOCKDRONE
	flavortext = "<b><span class='nezbere'>You are a cogscarab,</span> a tiny building construct of Ratvar. While you're weak and can't recite scripture, \
	you have a set of quick tools, as well as a replica fabricator that can create brass and convert objects.<br><br>Work with the servants of Ratvar \
	to construct and maintain defenses at the City of Cogs. If there are no servants, use this time to experiment with base designs!"
	pacifism = FALSE

/mob/living/simple_animal/drone/cogscarab/ratvar //a subtype for spawning when ratvar is alive, has a slab that it can use and a normal fabricator
	default_storage = /obj/item/storage/toolbox/brass/prefilled/ratvar

/mob/living/simple_animal/drone/cogscarab/admin //an admin-only subtype of cogscarab with a no-cost fabricator and slab in its box
	default_storage = /obj/item/storage/toolbox/brass/prefilled/ratvar/admin

/mob/living/simple_animal/drone/cogscarab/Initialize(mapload)
	. = ..()
	set_light(2, 0.5)
	qdel(access_card) //we don't have free access
	access_card = null
	remove_verb(src, list(/mob/living/simple_animal/drone/verb/check_laws, /mob/living/simple_animal/drone/verb/drone_ping))

//Cogscarabs being able to be picked up during war
/mob/living/simple_animal/drone/cogscarab/attack_hand(mob/user)
	if(!is_servant_of_ratvar(user))
		to_chat(user, span_warning("[src] wriggles out of your hands! You can't pick it up!"))
		return
	if(!GLOB.ratvar_approaches) 
		return
	..()

/mob/living/simple_animal/drone/cogscarab/Login()
	..()
	add_servant_of_ratvar(src, TRUE, GLOB.servants_active)
	to_chat(src,"<b>You yourself are one of these servants, and will be able to utilize almost anything they can[GLOB.ratvar_awakens ? "":", <i>excluding a clockwork slab</i>"].</b>") // this can't go with flavortext because i'm assuming it requires them to be ratvar'd

/mob/living/simple_animal/drone/cogscarab/binarycheck()
	return FALSE

/mob/living/simple_animal/drone/cogscarab/alert_drones(msg, dead_can_hear = FALSE)
	var/turf/A = get_area(src)
	if(msg == DRONE_NET_CONNECT)
		msg = span_brass("<i>Hierophant Network:</i> [name] activated.")
	else if(msg == DRONE_NET_DISCONNECT)
		msg = "<span class='brass'><i>Hierophant Network:</i></span> [span_alloy("[name] disabled.")]"
	..()

/mob/living/simple_animal/drone/attackby(obj/item/I, mob/user)
	if(I.tool_behaviour == TOOL_SCREWDRIVER && stat == DEAD)
		try_reactivate(user)
	else
		..()

/mob/living/simple_animal/drone/cogscarab/try_reactivate(mob/living/user)
	if(!is_servant_of_ratvar(user))
		to_chat(user, span_warning("You fiddle around with [src] to no avail."))
	else
		..()

/mob/living/simple_animal/drone/cogscarab/can_use_guns(obj/item/G)
	return GLOB.ratvar_awakens

/mob/living/simple_animal/drone/cogscarab/get_armor_effectiveness()
	if(GLOB.ratvar_awakens)
		return 1
	return ..()

/mob/living/simple_animal/drone/cogscarab/triggerAlarm(class, area/A, O, obj/alarmsource)
	return

/mob/living/simple_animal/drone/cogscarab/cancelAlarm(class, area/A, obj/origin)
	return

/mob/living/simple_animal/drone/cogscarab/update_drone_hack()
	return //we don't get hacked or give a shit about it

/mob/living/simple_animal/drone/cogscarab/drone_chat(msg)
	titled_hierophant_message(src, msg, "nezbere", "brass", "Construct") //HIEROPHANT DRONES

/mob/living/simple_animal/drone/cogscarab/ratvar_act()
	fully_heal(TRUE)

/mob/living/simple_animal/drone/cogscarab/update_icons()
	if(stat != DEAD)
		if(incapacitated())
			icon_state = "[visualAppearence]_flipped"
		else
			icon_state = visualAppearence
	else
		icon_state = "[visualAppearence]_dead"

/mob/living/simple_animal/drone/cogscarab/update_mobility()
	. = ..()
	update_icons()
