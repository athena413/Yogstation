/obj/item/tome
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister-looking cover."
	icon = 'icons/obj/library.dmi'
	icon_state ="tome"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/melee/cultblade/dagger
	name = "ritual dagger"
	desc = "A strange dagger said to be used by sinister groups for \"preparing\" a corpse before sacrificing it to their dark gods."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "cultdagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	w_class = WEIGHT_CLASS_SMALL
	force = 15
	throwforce = 25
	wound_bonus = -10
	bare_wound_bonus = 20
	armour_penetration = 35
	actions_types = list(/datum/action/item_action/cult_dagger)

/obj/item/melee/cultblade/dagger/Initialize(mapload)
	. = ..()
	var/image/I = image(icon = 'icons/effects/blood.dmi' , icon_state = null, loc = src)
	I.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_dagger", I)

/obj/item/melee/cultblade
	name = "eldritch longsword"
	desc = "A sword humming with unholy energy. It glows with a dim red light."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "cultblade"
	item_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	throwforce = 10
	wound_bonus = -80
	bare_wound_bonus = 30
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "rended")

/obj/item/melee/cultblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 40, 100)

/obj/item/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!iscultist(user))
		user.Paralyze(100)
		user.dropItemToGround(src, TRUE)
		user.visible_message(span_warning("A powerful force shoves [user] away from [target]!"), \
							 span_cultlarge("\"You shouldn't play with sharp things. You'll poke someone's eye out.\""))
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(rand(force/2, force), BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		else
			user.adjustBruteLoss(rand(force/2,force))
		return
	..()

/obj/item/melee/cultblade/ghost
	name = "eldritch sword"
	force = 19 //can't break normal airlocks
	item_flags = NEEDS_PERMIT | DROPDEL
	flags_1 = NONE

/obj/item/melee/cultblade/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/melee/cultblade/pickup(mob/living/user)
	..()
	if(!iscultist(user))
		if(!is_servant_of_ratvar(user))
			to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
		else
			to_chat(user, span_cultlarge("\"One of Ratvar's toys is trying to play with things [user.p_they()] shouldn't. Cute.\""))
			to_chat(user, span_userdanger("A horrible force yanks at your arm!"))
			user.emote("scream")
			user.apply_damage(30, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
			user.dropItemToGround(src)

/obj/item/twohanded/required/cult_bastard
	name = "bloody bastard sword"
	desc = "An enormous sword used by Nar'sien cultists to rapidly harvest the souls of non-believers."
	w_class = WEIGHT_CLASS_HUGE
	block_chance = 50
	throwforce = 20
	force = 35
	armour_penetration = 45
	throw_speed = 1
	throw_range = 3
	sharpness = SHARP_EDGED
	light_color = "#ff0000"
	light_system = MOVABLE_LIGHT
	light_range = 4
	attack_verb = list("cleaved", "slashed", "torn", "hacked", "ripped", "diced", "carved")
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "cultbastard"
	item_state = "cultbastard"
	hitsound = 'sound/weapons/bladeslice.ogg'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	actions_types = list()
	item_flags = SLOWS_WHILE_IN_HAND
	var/datum/action/innate/dash/cult/jaunt
	var/datum/action/innate/cult/spin2win/linked_action
	var/spinning = FALSE
	var/spin_cooldown = 25 SECONDS
	var/dash_toggled = TRUE

/obj/item/twohanded/required/cult_bastard/Initialize(mapload)
	. = ..()
	jaunt = new(src)
	linked_action = new(src)
	AddComponent(/datum/component/butchering, 50, 80)

/obj/item/twohanded/required/cult_bastard/examine(mob/user)
	. = ..()
	if(contents.len)
		. += "<b>There are [contents.len] souls trapped within the sword's core.</b>"
	else
		. += "The sword appears to be quite lifeless."

/obj/item/twohanded/required/cult_bastard/can_be_pulled(user)
	return FALSE

/obj/item/twohanded/required/cult_bastard/attack_self(mob/user)
	dash_toggled = !dash_toggled
	if(dash_toggled)
		to_chat(loc, span_notice("You raise [src] and prepare to jaunt with it."))
	else
		to_chat(loc, span_notice("You lower [src] and prepare to swing it normally."))

/obj/item/twohanded/required/cult_bastard/pickup(mob/living/user)
	. = ..()
	if(!iscultist(user))
		if(!is_servant_of_ratvar(user))
			to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
			force = 5
			return
		else
			to_chat(user, span_cultlarge("\"One of Ratvar's toys is trying to play with things [user.p_they()] shouldn't. Cute.\""))
			to_chat(user, span_userdanger("A horrible force yanks at your arm!"))
			user.emote("scream")
			user.apply_damage(30, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
			user.dropItemToGround(src, TRUE)
			user.Paralyze(50)
			return
	force = initial(force)
	jaunt.Grant(user, src)
	linked_action.Grant(user, src)
	user.update_icons()

/obj/item/twohanded/required/cult_bastard/dropped(mob/user)
	. = ..()
	linked_action.Remove(user)
	jaunt.Remove(user)
	user.update_icons()

/obj/item/twohanded/required/cult_bastard/IsReflect()
	if(spinning)
		playsound(src, pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg'), 100, 1)
		return TRUE
	else
		..()

/obj/item/twohanded/required/cult_bastard/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(prob(final_block_chance))
		if(attack_type == PROJECTILE_ATTACK)
			owner.visible_message(span_danger("[owner] deflects [attack_text] with [src]!"))
			playsound(src, pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg'), 100, 1)
			return TRUE
		else
			playsound(src, 'sound/weapons/parry.ogg', 75, 1)
			owner.visible_message(span_danger("[owner] parries [attack_text] with [src]!"))
			return TRUE
	return FALSE

/obj/item/twohanded/required/cult_bastard/afterattack(atom/target, mob/user, proximity, click_parameters)
	. = ..()
	if(dash_toggled && !proximity)
		jaunt.Teleport(user, target)
		return
	if(proximity)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.stat != CONSCIOUS)
				var/obj/item/soulstone/SS = new /obj/item/soulstone(src)
				SS.attack(H, user)
				if(!LAZYLEN(SS.contents))
					qdel(SS)
		if(istype(target, /obj/structure/constructshell) && contents.len)
			var/obj/item/soulstone/SS = contents[1]
			if(istype(SS))
				SS.transfer_soul("CONSTRUCT",target,user)
				qdel(SS)

/datum/action/innate/dash/cult
	name = "Rend the Veil"
	desc = "Use the sword to shear open the flimsy fabric of this reality and teleport to your target."
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "phaseshift"
	dash_sound = 'sound/magic/enter_blood.ogg'
	recharge_sound = 'sound/magic/exit_blood.ogg'
	beam_effect = "sendbeam"
	phasein = /obj/effect/temp_visual/dir_setting/cult/phase
	phaseout = /obj/effect/temp_visual/dir_setting/cult/phase/out

/datum/action/innate/dash/cult/IsAvailable(feedback = FALSE)
	if(iscultist(holder) && current_charges)
		return TRUE
	else
		return FALSE



/datum/action/innate/cult/spin2win
	name = "Geometer's Fury"
	desc = "You draw on the power of the sword's ancient runes, spinning it wildly around you as you become immune to most attacks."
	background_icon_state = "bg_demon"
	button_icon_state = "sintouch"
	var/cooldown = 0
	var/mob/living/carbon/human/holder
	var/obj/item/twohanded/required/cult_bastard/sword

/datum/action/innate/cult/spin2win/Grant(mob/user, obj/bastard)
	. = ..()
	sword = bastard
	holder = user

/datum/action/innate/cult/spin2win/IsAvailable(feedback = FALSE)
	if(iscultist(holder) && cooldown <= world.time)
		return TRUE
	else
		return FALSE

/datum/action/innate/cult/spin2win/Activate()
	cooldown = world.time + sword.spin_cooldown
	holder.changeNext_move(50)
	holder.apply_status_effect(/datum/status_effect/sword_spin)
	sword.spinning = TRUE
	sword.block_chance = 100
	sword.slowdown += 1.5
	addtimer(CALLBACK(src, PROC_REF(stop_spinning)), 50)
	holder.update_mob_action_buttons()

/datum/action/innate/cult/spin2win/proc/stop_spinning()
	sword.spinning = FALSE
	sword.block_chance = 50
	sword.slowdown -= 1.5
	sleep(sword.spin_cooldown)
	holder.update_mob_action_buttons()

/obj/item/restraints/legcuffs/bola/cult
	name = "nar'sien bola"
	desc = "A strong bola, bound with dark magic that allows it to pass harmlessly through Nar'sien cultists. Throw it to trip and slow your victim."
	icon_state = "bola_cult"
	item_state = "bola_cult"
	breakouttime = 60
	immobilize = 20

/obj/item/restraints/legcuffs/bola/cult/pickup(mob/living/user)
	. = ..()
	if(!iscultist(user))
		to_chat(user, span_warning("The bola seems to take on a life of its own!"))
		throw_impact(user)

/obj/item/restraints/legcuffs/bola/cult/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(iscultist(hit_atom))
		return
	. = ..()


/obj/item/clothing/head/culthood
	name = "ancient cultist hood"
	icon_state = "culthood"
	desc = "A torn, dust-caked hood. Strange letters line the inside."
	flags_inv = HIDEHAIR|HIDEEARS
	flags_cover = HEADCOVERSEYES
	armor = list(MELEE = 40, BULLET = 30, LASER = 40,ENERGY = 20, BOMB = 25, BIO = 10, RAD = 0, FIRE = 10, ACID = 10)
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT

/obj/item/clothing/suit/cultrobes
	name = "ancient cultist robes"
	desc = "A ragged, dusty set of robes. Strange letters line the inside."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list(MELEE = 40, BULLET = 30, LASER = 40,ENERGY = 20, BOMB = 25, BIO = 10, RAD = 0, FIRE = 10, ACID = 10)
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	mutantrace_variation = MUTANTRACE_VARIATION


/obj/item/clothing/head/culthood/alt
	name = "cultist hood"
	desc = "An armored hood worn by the followers of Nar'sie."
	icon_state = "cult_hoodalt"
	item_state = "cult_hoodalt"

/obj/item/clothing/head/culthood/alt/ghost
	item_flags = DROPDEL

/obj/item/clothing/head/culthood/alt/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/suit/cultrobes/alt
	name = "cultist robes"
	desc = "An armored set of robes worn by the followers of Nar'sie."
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"

/obj/item/clothing/suit/cultrobes/alt/ghost
	item_flags = DROPDEL

/obj/item/clothing/suit/cultrobes/alt/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)


/obj/item/clothing/head/magus
	name = "magus helm"
	icon_state = "magus"
	item_state = "magus"
	desc = "A helm worn by the followers of Nar'sie."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEARS|HIDEEYES
	armor = list(MELEE = 30, BULLET = 30, LASER = 30,ENERGY = 20, BOMB = 0, BIO = 0, RAD = 0, FIRE = 10, ACID = 10)
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar'sie."
	icon_state = "magusred"
	item_state = "magusred"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list(MELEE = 50, BULLET = 30, LASER = 50,ENERGY = 20, BOMB = 25, BIO = 10, RAD = 0, FIRE = 10, ACID = 10)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/head/helmet/space/hardsuit/cult
	name = "\improper Nar'sien hardened helmet"
	desc = "A heavily-armored helmet worn by warriors of the Nar'sien cult. It can withstand hard vacuum."
	icon_state = "cult_helmet"
	item_state = "cult_helmet"
	armor = list(MELEE = 60, BULLET = 50, LASER = 30,ENERGY = 15, BOMB = 30, BIO = 30, RAD = 30, FIRE = 40, ACID = 75)
	light_system = NO_LIGHT_SUPPORT
	actions_types = list()

/obj/item/clothing/suit/space/hardsuit/cult
	name = "\improper Nar'sien hardened armor"
	icon_state = "cult_armor"
	item_state = "cult_armor"
	desc = "A heavily-armored exosuit worn by warriors of the Nar'sien cult. It can withstand hard vacuum."
	w_class = WEIGHT_CLASS_BULKY
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade, /obj/item/tank/internals/)
	armor = list(MELEE = 70, BULLET = 50, LASER = 30,ENERGY = 15, BOMB = 30, BIO = 30, RAD = 30, FIRE = 40, ACID = 75)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/cult

/obj/item/sharpener/cult
	name = "eldritch whetstone"
	desc = "A block, empowered by dark magic. Sharp weapons will be enhanced when used on the stone."
	icon_state = "cult_sharpener"
	used = 0
	increment = 5
	max = 40
	prefix = "darkened"

/obj/item/sharpener/cult/update_icon()
	icon_state = "cult_sharpener[used ? "_used" : ""]"

/obj/item/clothing/suit/hooded/cultrobes/cult_shield
	name = "empowered cultist armor"
	desc = "Empowered garb which creates a powerful shield around the user."
	icon_state = "cult_armor"
	item_state = "cult_armor"
	w_class = WEIGHT_CLASS_BULKY
	armor = list(MELEE = 50, BULLET = 40, LASER = 50,ENERGY = 30, BOMB = 50, BIO = 30, RAD = 30, FIRE = 50, ACID = 60)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	var/current_charges = 3
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie

/obj/item/clothing/head/hooded/cult_hoodie
	name = "empowered cultist armor"
	desc = "Empowered garb which creates a powerful shield around the user."
	icon_state = "cult_hoodalt"
	armor = list(MELEE = 50, BULLET = 40, LASER = 50,ENERGY = 30, BOMB = 50, BIO = 30, RAD = 30, FIRE = 50, ACID = 50)
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/equipped(mob/living/user, slot)
	..()
	if(!iscultist(user))
		if(!is_servant_of_ratvar(user))
			to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
			to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
			user.dropItemToGround(src, TRUE)
			user.adjust_dizzy(3 SECONDS)
			user.Paralyze(100)
		else
			to_chat(user, span_cultlarge("\"Trying to use things you don't own is bad, you know.\""))
			to_chat(user, span_userdanger("The armor squeezes at your body!"))
			user.emote("scream")
			user.adjustBruteLoss(25)
			user.dropItemToGround(src, TRUE)

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(current_charges)
		owner.visible_message(span_danger("\The [attack_text] is deflected in a burst of blood-red sparks!"))
		current_charges--
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		if(!current_charges)
			owner.visible_message(span_danger("The runed shield around [owner] suddenly disappears!"))
			owner.update_inv_wear_suit()
		return 1
	return 0

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/worn_overlays(isinhands)
	. = list()
	if(!isinhands && current_charges)
		. += mutable_appearance('icons/effects/cult_effects.dmi', "shield-cult", MOB_LAYER + 0.01)

/obj/item/clothing/suit/hooded/cultrobes/berserker
	name = "flagellant's robes"
	desc = "Blood-soaked robes infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor = list(MELEE = -45, BULLET = -45, LASER = -45,ENERGY = -45, BOMB = -45, BIO = -45, RAD = -45, FIRE = 0, ACID = 0)
	slowdown = -0.6
	hoodtype = /obj/item/clothing/head/hooded/berserkerhood

/obj/item/clothing/head/hooded/berserkerhood
	name = "flagellant's robes"
	desc = "Blood-soaked garb infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage."
	icon_state = "culthood"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	armor = list(MELEE = -50, BULLET = -50, LASER = -50, ENERGY = -50, BOMB = -50, BIO = -50, RAD = -50, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/hooded/cultrobes/berserker/equipped(mob/living/user, slot)
	..()
	if(!iscultist(user))
		if(!is_servant_of_ratvar(user))
			to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
			to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
			user.dropItemToGround(src, TRUE)
			user.adjust_dizzy(30)
			user.Paralyze(100)
		else
			to_chat(user, span_cultlarge("\"Trying to use things you don't own is bad, you know.\""))
			to_chat(user, span_userdanger("The robes squeeze at your body!"))
			user.emote("scream")
			user.adjustBruteLoss(25)
			user.dropItemToGround(src, TRUE)

/obj/item/clothing/glasses/hud/health/night/cultblind
	desc = "may Nar'sie guide you through the darkness and shield you from the light."
	name = "zealot's blindfold"
	icon_state = "blindfold"
	item_state = "blindfold"
	flash_protect = 1

/obj/item/clothing/glasses/hud/health/night/cultblind/equipped(mob/living/user, slot)
	..()
	if(!iscultist(user))
		to_chat(user, span_cultlarge("\"You want to be blind, do you?\""))
		user.dropItemToGround(src, TRUE)
		user.adjust_dizzy(30)
		user.Paralyze(100)
		user.blind_eyes(30)

/obj/item/reagent_containers/glass/beaker/unholywater
	name = "flask of unholy water"
	desc = "Toxic to nonbelievers; reinvigorating to the faithful - this flask may be sipped or thrown."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	color = "#333333"
	list_reagents = list(/datum/reagent/fuel/unholywater = 50)

GLOBAL_VAR_INIT(curselimit, 0)

/obj/item/shuttle_curse
	name = "cursed orb"
	desc = "You peer within this smokey orb and glimpse terrible fates befalling the escape shuttle."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shuttlecurse"

/obj/item/shuttle_curse/attack_self(mob/living/user)
	if(!iscultist(user))
		user.dropItemToGround(src, TRUE)
		user.Paralyze(100)
		to_chat(user, span_warning("A powerful force shoves you away from [src]!"))
		return
	if(GLOB.curselimit >= 2)
		to_chat(user, span_notice("We have exhausted our ability to curse the shuttle."))
		return
	if(locate(/obj/singularity/narsie) in GLOB.poi_list)
		to_chat(user, span_warning("Nar'sie is already on this plane, there is no delaying the end of all things."))
		return

	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/cursetime = 1800
		var/timer = SSshuttle.emergency.timeLeft(1) + cursetime
		var/security_num = seclevel2num(get_security_level())
		var/set_coefficient = 1
		switch(security_num)
			if(SEC_LEVEL_GREEN)
				set_coefficient = 2
			if(SEC_LEVEL_BLUE)
				set_coefficient = 1
			else
				set_coefficient = 0.5
		var/surplus = timer - (SSshuttle.emergencyCallTime * set_coefficient)
		SSshuttle.emergency.setTimer(timer)
		if(surplus > 0)
			SSshuttle.block_recall(surplus)
		to_chat(user, span_danger("You shatter the orb! A dark essence spirals into the air, then disappears."))
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 50, 1)
		qdel(src)
		sleep(2 SECONDS)
		var/curses = list("A fuel technician just slit his own throat and begged for death.",
			"The shuttle's navigation programming was replaced by a file containing just two words: IT COMES.",
			"The shuttle's custodian was found washing the windows with their own blood.",
			"A shuttle engineer began screaming 'DEATH IS NOT THE END' and ripped out wires until an arc flash seared off her flesh.",
			"A shuttle inspector started laughing madly over the radio and then threw herself into an engine turbine.",
			"The shuttle dispatcher was found dead with bloody symbols carved into their flesh.",
			"The shuttle's transponder is emitting the encoded message 'FEAR THE OLD BLOOD' in lieu of its assigned identification signal.")
		var/message = pick_n_take(curses)
		message += " The shuttle will be delayed by three minutes."
		priority_announce("[message]", "System Failure", 'sound/misc/notice1.ogg')
		GLOB.curselimit++

/obj/item/cult_shift
	name = "veil shifter"
	desc = "This relic instantly teleports you, and anything you're pulling, forward by a moderate distance."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shifter"
	var/uses = 4

/obj/item/cult_shift/examine(mob/user)
	. = ..()
	if(uses)
		. += span_cult("It has [uses] use\s remaining.")
	else
		. += span_cult("It seems drained.")

/obj/item/cult_shift/proc/handle_teleport_grab(turf/T, mob/user)
	var/mob/living/carbon/C = user
	if(C.pulling)
		var/atom/movable/pulled = C.pulling
		do_teleport(pulled, T, channel = TELEPORT_CHANNEL_CULT)
		. = pulled

/obj/item/cult_shift/attack_self(mob/user)
	if(!uses || !iscarbon(user))
		to_chat(user, span_warning("\The [src] is dull and unmoving in your hands."))
		return
	if(!iscultist(user))
		user.dropItemToGround(src, TRUE)
		step(src, pick(GLOB.alldirs))
		to_chat(user, span_warning("\The [src] flickers out of your hands, your connection to this dimension is too strong!"))
		return

	var/mob/living/carbon/C = user
	var/turf/mobloc = get_turf(C)
	var/turf/destination = get_teleport_loc(mobloc,C,9,1,3,1,0,1)

	if(destination)
		uses--
		if(uses <= 0)
			icon_state ="shifter_drained"
		playsound(mobloc, "sparks", 50, 1)
		new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, C.dir)

		var/atom/movable/pulled = handle_teleport_grab(destination, C)
		if(do_teleport(C, destination, channel = TELEPORT_CHANNEL_CULT))
			if(pulled)
				C.start_pulling(pulled) //forcemove resets pulls, so we need to re-pull
			new /obj/effect/temp_visual/dir_setting/cult/phase(destination, C.dir)
			playsound(destination, 'sound/effects/phasein.ogg', 25, 1)
			playsound(destination, "sparks", 50, 1)

	else
		to_chat(C, span_danger("The veil cannot be torn here!"))

/obj/item/flashlight/flare/culttorch
	name = "void torch"
	desc = "Used by veteran cultists to instantly transport items to their needful brethren."
	w_class = WEIGHT_CLASS_SMALL
	light_range = 1
	icon_state = "torch"
	item_state = "torch"
	color = "#ff0000"
	on_damage = 15
	slot_flags = null
	on = TRUE
	var/charges = 5

/obj/item/flashlight/flare/culttorch/afterattack(atom/movable/A, mob/user, proximity)
	if(!proximity)
		return
	if(!iscultist(user))
		to_chat(user, "That doesn't seem to do anything useful.")
		return

	if(istype(A, /obj/item))

		var/list/cultists = list()
		for(var/datum/mind/M in SSticker.mode.cult)
			if(M.current && M.current.stat != DEAD)
				cultists |= M.current
		var/mob/living/cultist_to_receive = input(user, "Who do you wish to call to [src]?", "Followers of the Geometer") as null|anything in (cultists - user)
		if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
			return
		if(!cultist_to_receive)
			to_chat(user, "<span class='cult italic'>You require a destination!</span>")
			log_game("Void torch failed - no target")
			return
		if(cultist_to_receive.stat == DEAD)
			to_chat(user, "<span class='cult italic'>[cultist_to_receive] has died!</span>")
			log_game("Void torch failed  - target died")
			return
		if(!iscultist(cultist_to_receive))
			to_chat(user, "<span class='cult italic'>[cultist_to_receive] is not a follower of the Geometer!</span>")
			log_game("Void torch failed - target was deconverted")
			return
		if(A in user.get_all_contents())
			to_chat(user, "<span class='cult italic'>[A] must be on a surface in order to teleport it!</span>")
			return
		to_chat(user, "<span class='cult italic'>You ignite [A] with \the [src], turning it to ash, but through the torch's flames you see that [A] has reached [cultist_to_receive]!</span>")
		cultist_to_receive.put_in_hands(A)
		charges--
		to_chat(user, "\The [src] now has [charges] charge\s.")
		if(charges == 0)
			qdel(src)

	else
		..()
		to_chat(user, span_warning("\The [src] can only transport items!"))


/obj/item/twohanded/cult_spear
	name = "blood halberd"
	desc = "A sickening spear composed entirely of crystallized blood."
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "bloodspear0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	slot_flags = 0
	force = 12
	force_wielded = 16
	throwforce = 35
	throw_speed = 2
	armour_penetration = 20
	weapon_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 1, DAMAGE_LOW = 2, DAMAGE_HIGH = 5)
	wielded_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0.4, ENCUMBRANCE_TIME = 5, REACH = 2, DAMAGE_LOW = 2, DAMAGE_HIGH = 5)
	attack_verb = list("attacked", "impaled", "stabbed", "torn", "gored")
	sharpness = SHARP_POINTY
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/datum/action/innate/cult/spear/spear_act

/obj/item/twohanded/cult_spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 100, 90)

/obj/item/twohanded/cult_spear/Destroy()
	if(spear_act)
		qdel(spear_act)
	..()

/obj/item/twohanded/cult_spear/update_icon()
	icon_state = "bloodspear[wielded]"

/obj/item/twohanded/cult_spear/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(iscultist(L))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			if(L.put_in_active_hand(src))
				L.visible_message(span_warning("[L] catches [src] out of the air!"))
			else
				L.visible_message(span_warning("[src] bounces off of [L], as if repelled by an unseen force!"))
		else if(!..())
			if(!L.anti_magic_check())
				if(is_servant_of_ratvar(L))
					L.Paralyze(20)
				else
					L.Paralyze(10)
			break_spear(T)
	else
		..()

/obj/item/twohanded/cult_spear/proc/break_spear(turf/T)
	if(src)
		if(!T)
			T = get_turf(src)
		if(T)
			T.visible_message(span_warning("[src] shatters and melts back into blood!"))
			new /obj/effect/temp_visual/cult/sparks(T)
			new /obj/effect/decal/cleanable/blood/splatter(T)
			playsound(T, 'sound/effects/glassbr3.ogg', 100)
	qdel(src)

/datum/action/innate/cult/spear
	name = "Bloody Bond"
	desc = "Call the blood spear back to your hand!"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	button_icon_state = "bloodspear"
	default_button_position = "6:157,4:-2"
	var/obj/item/twohanded/cult_spear/spear
	var/cooldown = 0

/datum/action/innate/cult/spear/Grant(mob/user, obj/blood_spear)
	. = ..()
	spear = blood_spear

/datum/action/innate/cult/spear/Activate()
	if(owner == spear.loc || cooldown > world.time)
		return
	var/ST = get_turf(spear)
	var/OT = get_turf(owner)
	if(get_dist(OT, ST) > 20)
		to_chat(owner,span_cult("The spear is too far away!"))
	else
		cooldown = world.time + 20
		if(isliving(spear.loc))
			var/mob/living/L = spear.loc
			L.dropItemToGround(spear)
			L.visible_message(span_warning("An unseen force pulls the blood spear from [L]'s hands!"))
		spear.throw_at(owner, 20, 2, owner)


/obj/item/gun/ballistic/rifle/boltaction/enchanted/arcane_barrage/blood
	name = "blood bolt barrage"
	desc = "Blood for blood."
	color = "#ff0000"
	guns_left = 24
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	fire_sound = 'sound/magic/wand_teleport.ogg'


/obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage/blood

/obj/item/ammo_casing/magic/arcane_barrage/blood
	projectile_type = /obj/item/projectile/magic/arcane_barrage/blood
	firing_effect_type = /obj/effect/temp_visual/cult/sparks

/obj/item/projectile/magic/arcane_barrage/blood
	name = "blood bolt"
	icon_state = "mini_leaper"
	nondirectional_sprite = TRUE
	damage_type = BRUTE
	impact_effect_type = /obj/effect/temp_visual/dir_setting/bloodsplatter
	damage = 20
	armour_penetration = 0

/obj/item/projectile/magic/arcane_barrage/blood/Bump(atom/target)
	var/turf/T = get_turf(target)
	playsound(T, 'sound/effects/splat.ogg', 50, TRUE)
	if(iscultist(target))
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.stat != DEAD)
				H.reagents.add_reagent(/datum/reagent/fuel/unholywater, 4)
		if(isshade(target) || isconstruct(target))
			var/mob/living/simple_animal/M = target
			if(M.health+5 < M.maxHealth)
				M.adjustHealth(-5)
		new /obj/effect/temp_visual/cult/sparks(T)
		qdel(src)
	else
		..()

/obj/item/blood_beam
	name = "\improper magical aura"
	desc = "Sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/wizard.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/charging = FALSE
	var/firing = FALSE
	var/angle

/obj/item/blood_beam/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)


/obj/item/blood_beam/afterattack(atom/A, mob/living/user, flag, params)
	. = ..()
	if(firing || charging)
		return
	var/C = user.client
	if(ishuman(user) && C)
		angle = mouse_angle_from_client(C)
	else
		qdel(src)
		return
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(charge), user)
	if(do_after(user, 9 SECONDS, user))
		firing = TRUE
		INVOKE_ASYNC(src, PROC_REF(pewpew), user, params)
		var/obj/structure/emergency_shield/invoker/N = new(user.loc)
		if(do_after(user, 9 SECONDS, user))
			user.Paralyze(40)
			to_chat(user, "<span class='cult italic'>You have exhausted the power of this spell!</span>")
		firing = FALSE
		if(N)
			qdel(N)
		qdel(src)
	charging = FALSE

/obj/item/blood_beam/proc/charge(mob/user)
	var/obj/O
	playsound(src, 'sound/magic/lightning_chargeup.ogg', 100, 1)
	for(var/i in 1 to 12)
		if(!charging)
			break
		if(i > 1)
			sleep(1.5 SECONDS)
		if(i < 4)
			O = new /obj/effect/temp_visual/cult/rune_spawn/rune1/inner(user.loc, 30, "#ff0000")
		else
			O = new /obj/effect/temp_visual/cult/rune_spawn/rune5(user.loc, 30, "#ff0000")
			new /obj/effect/temp_visual/dir_setting/cult/phase/out(user.loc, user.dir)
	if(O)
		qdel(O)

/obj/item/blood_beam/proc/pewpew(mob/user, params)
	var/turf/targets_from = get_turf(src)
	var/spread = 40
	var/second = FALSE
	var/set_angle = angle
	for(var/i in 1 to 12)
		if(second)
			set_angle = angle - spread
			spread -= 8
		else
			sleep(1.5 SECONDS)
			set_angle = angle + spread
		second = !second //Handles beam firing in pairs
		if(!firing)
			break
		playsound(src, 'sound/magic/exit_blood.ogg', 75, 1)
		new /obj/effect/temp_visual/dir_setting/cult/phase(user.loc, user.dir)
		var/turf/temp_target = get_turf_in_angle(set_angle, targets_from, 40)
		for(var/turf/T in getline(targets_from,temp_target))
			if (locate(/obj/effect/blessing, T))
				temp_target = T
				playsound(T, 'sound/machines/clockcult/ark_damage.ogg', 50, 1)
				new /obj/effect/temp_visual/at_shield(T, T)
				break
			T.narsie_act(TRUE, TRUE)
			for(var/mob/living/target in T.contents)
				if(iscultist(target))
					new /obj/effect/temp_visual/cult/sparks(T)
					if(ishuman(target))
						var/mob/living/carbon/human/H = target
						if(H.stat != DEAD)
							H.reagents.add_reagent(/datum/reagent/fuel/unholywater, 7)
					if(isshade(target) || isconstruct(target))
						var/mob/living/simple_animal/M = target
						if(M.health+15 < M.maxHealth)
							M.adjustHealth(-15)
						else
							M.health = M.maxHealth
				else
					var/mob/living/L = target
					if(L.density)
						L.Paralyze(20)
						L.adjustBruteLoss(45)
						playsound(L, 'sound/hallucinations/wail.ogg', 50, 1)
						L.emote("scream")
		var/datum/beam/current_beam = new(user,temp_target,time=7,beam_icon_state="blood_beam",btype=/obj/effect/ebeam/blood)
		INVOKE_ASYNC(current_beam, TYPE_PROC_REF(/datum/beam, Start))


/obj/effect/ebeam/blood
	name = "blood beam"

/obj/item/shield/mirror
	name = "mirror shield"
	desc = "An infamous shield used by Nar'sien sects to confuse and disorient their enemies. Its edges are weighted for use as a throwing weapon - capable of disabling multiple foes with preternatural accuracy."
	icon_state = "mirror_shield" // eshield1 for expanded
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	force = 5
	throwforce = 15
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("bumped", "prodded")
	hitsound = 'sound/weapons/smash.ogg'
	var/illusions = 5

/obj/item/shield/mirror/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(iscultist(owner))
		if(istype(hitby, /obj/item/projectile))
			var/obj/item/projectile/P = hitby
			if(P.damage_type == BRUTE || P.damage_type == BURN)
				if(P.damage >= 30)
					var/turf/T = get_turf(owner)
					T.visible_message(span_warning("The sheer force from [P] shatters the mirror shield!"))
					new /obj/effect/temp_visual/cult/sparks(T)
					playsound(T, 'sound/effects/glassbr3.ogg', 100)
					owner.Paralyze(25)
					qdel(src)
					return FALSE
			if(P.reflectable & REFLECT_NORMAL)
				return FALSE //To avoid reflection chance double-dipping with block chance
		. = ..()
		if(.)
			if(illusions > 0)
				playsound(src, 'sound/weapons/parry.ogg', 100, 1)
				illusions--
				addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/shield/mirror, readd)), 450)
				if(prob(60))
					var/mob/living/simple_animal/hostile/illusion/M = new(owner.loc)
					M.faction = list("cult")
					M.Copy_Parent(owner, 70, 10, 5)
					M.move_to_delay = owner.movement_delay()
				else
					var/mob/living/simple_animal/hostile/illusion/escape/E = new(owner.loc)
					E.Copy_Parent(owner, 70, 10)
					E.GiveTarget(owner)
					E.Goto(owner, owner.movement_delay(), E.minimum_distance)
			else
				var/turf/T = get_turf(owner)
				T.visible_message(span_warning("[src] shatters as it blocks [hitby]!"))
				new /obj/effect/temp_visual/cult/sparks(T)
				qdel(src)
			return TRUE

	else
		if(prob(50))
			var/mob/living/simple_animal/hostile/illusion/H = new(owner.loc)
			H.Copy_Parent(owner, 100, 20, 5)
			H.faction = list("cult")
			H.GiveTarget(owner)
			H.move_to_delay = owner.movement_delay()
			to_chat(owner, span_danger("<b>[src] betrays you!</b>"))
		return FALSE

/obj/item/shield/mirror/proc/readd()
	illusions++
	if(illusions == initial(illusions) && isliving(loc))
		var/mob/living/holder = loc
		to_chat(holder, "<span class='cult italic'>The shield's illusions are back at full strength!</span>")

/obj/item/shield/mirror/IsReflect()
	return prob(block_chance)

/obj/item/shield/mirror/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	var/datum/thrownthing/D = throwingdatum
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(iscultist(L))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			if(L.put_in_active_hand(src))
				L.visible_message(span_warning("[L] catches [src] out of the air!"))
			else
				L.visible_message(span_warning("[src] bounces off of [L], as if repelled by an unseen force!"))
		else if(!..())
			if(!L.anti_magic_check())
				if(L.buckled)
					L.buckled.unbuckle_mob(L)

				if(is_servant_of_ratvar(L))
					L.Knockdown(60)
				else
					L.Knockdown(30)
				if(D?.thrower)
					for(var/mob/living/Next in orange(2, T))
						if(!Next.density || iscultist(Next))
							continue
						throw_at(Next, 3, 1, D.thrower)
						return
					throw_at(D.thrower, 7, 1, null)
	else
		..()
