/obj/item/banhammer
	desc = "A banhammer."
	name = "banhammer"
	icon = 'icons/obj/toy.dmi'
	icon_state = "toyhammer"
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	force = 1
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	attack_verb = list("banned")
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF

/obj/item/banhammer/suicide_act(mob/user)
		user.visible_message(span_suicide("[user] is hitting [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to ban [user.p_them()]self from life."))
		return (BRUTELOSS|FIRELOSS|TOXLOSS|OXYLOSS)
/*
oranges says: This is a meme relating to the english translation of the ss13 russian wiki page on lurkmore.
mrdoombringer sez: and remember kids, if you try and PR a fix for this item's grammar, you are admitting that you are, indeed, a newfriend.
for further reading, please see: https://github.com/tgstation/tgstation/pull/30173 and https://translate.google.com/translate?sl=auto&tl=en&js=y&prev=_t&hl=en&ie=UTF-8&u=%2F%2Flurkmore.to%2FSS13&edit-text=&act=url
*/
/obj/item/banhammer/attack(mob/M, mob/user)
	if(user.zone_selected == BODY_ZONE_HEAD)
		M.visible_message(span_danger("[user] are stroking the head of [M] with a bangammer"), span_userdanger("[user] are stroking the head with a bangammer"), "you hear a bangammer stroking a head");
	else
		M.visible_message(span_danger("[M] has been banned FOR NO REISIN by [user]"), span_userdanger("You have been banned FOR NO REISIN by [user]"), "you hear a banhammer banning someone")
	playsound(loc, 'sound/effects/adminhelp.ogg', 15) //keep it at 15% volume so people don't jump out of their skin too much
	if(user.a_intent != INTENT_HELP)
		return ..(M, user)

/obj/item/sord
	name = "\improper SORD"
	desc = "This thing is so unspeakably shitty you are having a hard time even holding it."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "sord"
	item_state = "sord"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 2
	throwforce = 1
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/sord/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is trying to impale [user.p_them()]self with [src]! It might be a suicide attempt if it weren't so shitty."), \
	span_suicide("You try to impale yourself with [src], but it's USELESS..."))
	return SHAME

/obj/item/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "claymore"
	item_state = "claymore"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 40
	throwforce = 10
	w_class = WEIGHT_CLASS_HUGE
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 50
	sharpness = SHARP_EDGED
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF

/obj/item/claymore/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 40, 105)

/obj/item/claymore/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/claymore/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is falling on [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return(BRUTELOSS)

/obj/item/claymore/ruin
	name = "ancient sword"
	desc = "A cracked and blunted sword, clearly weathered over the ages."
	force = 21
	block_chance = 30

/obj/item/claymore/ruin/excalibur
	name = "Excalibur"
	desc = "A legendary sword passed down through the ages, though it seems to have lost its magic."

/obj/item/claymore/highlander //ALL COMMENTS MADE REGARDING THIS SWORD MUST BE MADE IN ALL CAPS
	desc = "<b><i>THERE CAN BE ONLY ONE, AND IT WILL BE YOU!!!</i></b>\nActivate it in your hand to point to the nearest victim."
	flags_1 = CONDUCT_1
	item_flags = DROPDEL //If this ever happens, it's because you lost an arm
	slot_flags = null
	block_chance = 0 //RNG WON'T HELP YOU NOW, PANSY
	light_range = 3
	attack_verb = list("brutalized", "eviscerated", "disemboweled", "hacked", "carved", "cleaved") //ONLY THE MOST VISCERAL ATTACK VERBS
	var/notches = 0 //HOW MANY PEOPLE HAVE BEEN SLAIN WITH THIS BLADE
	var/obj/item/disk/nuclear/nuke_disk //OUR STORED NUKE DISK

/obj/item/claymore/highlander/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER)
	START_PROCESSING(SSobj, src)

/obj/item/claymore/highlander/Destroy()
	if(nuke_disk)
		nuke_disk.forceMove(get_turf(src))
		nuke_disk.visible_message(span_warning("The nuke disk is vulnerable!"))
		nuke_disk = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/claymore/highlander/process()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		loc.layer = LARGE_MOB_LAYER //NO HIDING BEHIND PLANTS FOR YOU, DICKWEED (HA GET IT, BECAUSE WEEDS ARE PLANTS)
		H.bleedsuppress = TRUE //AND WE WON'T BLEED OUT LIKE COWARDS
	else
		if(!(flags_1 & ADMIN_SPAWNED_1))
			qdel(src)


/obj/item/claymore/highlander/pickup(mob/living/user)
	. = ..()
	to_chat(user, span_notice("The power of Scotland protects you! You are shielded from all stuns and knockdowns."))
	user.add_stun_absorption("highlander", INFINITY, 1, " is protected by the power of Scotland!", "The power of Scotland absorbs the stun!", " is protected by the power of Scotland!")
	user.ignore_slowdown(HIGHLANDER)

/obj/item/claymore/highlander/dropped(mob/living/user)
	. = ..()
	user.unignore_slowdown(HIGHLANDER)

/obj/item/claymore/highlander/examine(mob/user)
	. = ..()
	. += "It has [!notches ? "nothing" : "[notches] notches"] scratched into the blade."
	if(nuke_disk)
		. += span_boldwarning("It's holding the nuke disk!")

/obj/item/claymore/highlander/attack(mob/living/target, mob/living/user)
	. = ..()
	if(!QDELETED(target) && iscarbon(target) && target.stat == DEAD && target.mind && target.mind.special_role == "highlander")
		user.fully_heal() //STEAL THE LIFE OF OUR FALLEN FOES
		add_notch(user)
		target.visible_message(span_warning("[target] crumbles to dust beneath [user]'s blows!"), span_userdanger("As you fall, your body crumbles to dust!"))
		target.dust()

/obj/item/claymore/highlander/attack_self(mob/living/user)
	var/closest_victim
	var/closest_distance = 255
	for(var/mob/living/carbon/human/H in GLOB.player_list - user)
		if(H.client && H.mind.special_role == "highlander" && (!closest_victim || get_dist(user, closest_victim) < closest_distance))
			closest_victim = H
	if(!closest_victim)
		to_chat(user, span_warning("[src] thrums for a moment and falls dark. Perhaps there's nobody nearby."))
		return
	to_chat(user, span_danger("[src] thrums and points to the [dir2text(get_dir(user, closest_victim))]."))

/obj/item/claymore/highlander/IsReflect()
	return 1 //YOU THINK YOUR PUNY LASERS CAN STOP ME?

/obj/item/claymore/highlander/proc/add_notch(mob/living/user) //DYNAMIC CLAYMORE PROGRESSION SYSTEM - THIS IS THE FUTURE
	notches++
	force++
	var/new_name = name
	switch(notches)
		if(1)
			to_chat(user, span_notice("Your first kill - hopefully one of many. You scratch a notch into [src]'s blade."))
			to_chat(user, span_warning("You feel your fallen foe's soul entering your blade, restoring your wounds!"))
			new_name = "notched claymore"
		if(2)
			to_chat(user, span_notice("Another falls before you. Another soul fuses with your own. Another notch in the blade."))
			new_name = "double-notched claymore"
			add_atom_colour(rgb(255, 235, 235), ADMIN_COLOUR_PRIORITY)
		if(3)
			to_chat(user, "[span_notice("You're beginning to")] <span class='danger'><b>relish</b> the <b>thrill</b> of <b>battle.</b></span>")
			new_name = "triple-notched claymore"
			add_atom_colour(rgb(255, 215, 215), ADMIN_COLOUR_PRIORITY)
		if(4)
			to_chat(user, "[span_notice("You've lost count of")] [span_boldannounce("how many you've killed.")]")
			new_name = "many-notched claymore"
			add_atom_colour(rgb(255, 195, 195), ADMIN_COLOUR_PRIORITY)
		if(5)
			to_chat(user, span_boldannounce("Five voices now echo in your mind, cheering the slaughter."))
			new_name = "battle-tested claymore"
			add_atom_colour(rgb(255, 175, 175), ADMIN_COLOUR_PRIORITY)
		if(6)
			to_chat(user, span_boldannounce("Is this what the vikings felt like? Visions of glory fill your head as you slay your sixth foe."))
			new_name = "battle-scarred claymore"
			add_atom_colour(rgb(255, 155, 155), ADMIN_COLOUR_PRIORITY)
		if(7)
			to_chat(user, span_boldannounce("Kill. Butcher. <i>Conquer.</i>"))
			new_name = "vicious claymore"
			add_atom_colour(rgb(255, 135, 135), ADMIN_COLOUR_PRIORITY)
		if(8)
			to_chat(user, span_userdanger("IT NEVER GETS OLD. THE <i>SCREAMING</i>. THE <i>BLOOD</i> AS IT <i>SPRAYS</i> ACROSS YOUR <i>FACE.</i>"))
			new_name = "bloodthirsty claymore"
			add_atom_colour(rgb(255, 115, 115), ADMIN_COLOUR_PRIORITY)
		if(9)
			to_chat(user, span_userdanger("ANOTHER ONE FALLS TO YOUR BLOWS. ANOTHER WEAKLING UNFIT TO LIVE."))
			new_name = "gore-stained claymore"
			add_atom_colour(rgb(255, 95, 95), ADMIN_COLOUR_PRIORITY)
		if(10)
			user.visible_message(span_warning("[user]'s eyes light up with a vengeful fire!"), \
			span_userdanger("YOU FEEL THE POWER OF VALHALLA FLOWING THROUGH YOU! <i>THERE CAN BE ONLY ONE!!!</i>"))
			user.update_icons()
			new_name = "GORE-DRENCHED CLAYMORE OF [pick("THE WHIMSICAL SLAUGHTER", "A THOUSAND SLAUGHTERED CATTLE", "GLORY AND VALHALLA", "ANNIHILATION", "OBLITERATION")]"
			icon_state = "claymore_valhalla"
			item_state = "cultblade"
			remove_atom_colour(ADMIN_COLOUR_PRIORITY)

	name = new_name
	playsound(user, 'sound/items/screwdriver2.ogg', 50, 1)

/obj/item/claymore/bone
	name = "Bone Sword"
	desc = "Jagged pieces of bone are tied to what looks like a goliath's femur."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "bone_sword"
	item_state = "bone_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 15
	throwforce = 10
	armour_penetration = 15
	w_class = WEIGHT_CLASS_BULKY
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "tore", "ripped", "diced", "cut")
	block_chance = 30
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50)

/obj/item/katana
	name = "katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "katana"
	item_state = "katana"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 40
	throwforce = 10
	w_class = WEIGHT_CLASS_HUGE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 50
	sharpness = SHARP_EDGED
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF

/obj/item/katana/basalt
	name = "basalt katana"
	desc = "a katana made out of hardened basalt. Particularly damaging to lavaland fauna. (Activate this item in hand to dodge roll in the direction you're facing)"
	icon_state = "basalt_katana"
	item_state = "basalt_katana"
	force = 18
	block_chance = 20

	var/fauna_damage_bonus = 52
	var/fauna_damage_type = BRUTE
	var/next_roll
	var/roll_dist = 3

/obj/item/katana/basalt/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(isliving(target))
		var/mob/living/L = target
		if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid))
			L.apply_damage(fauna_damage_bonus,fauna_damage_type)
			playsound(L, 'sound/weapons/sear.ogg', 100, 1)

/obj/item/katana/basalt/attack_self(mob/living/user)
	if(world.time > next_roll)
		var/stam_cost = 15
		var/turf/T = get_turf(user)
		if(is_mining_level(T.z))
			stam_cost = 5
		var/turf/landing_turf = get_ranged_target_turf(user, user.dir, roll_dist)
		var/spin_direction = FALSE
		user.adjustStaminaLoss(stam_cost)
		if (user.getStaminaLoss() >= 100)
			user.throw_at(landing_turf, 2, 2)
			user.Paralyze(4 SECONDS)
			user.visible_message(span_notice("[user] collapses on the ground, exhausted!"), span_warning("You're too tired to finish the roll!"))
		else
			playsound(user, 'yogstation/sound/items/dodgeroll.ogg', 50, TRUE)
			user.apply_status_effect(STATUS_EFFECT_DODGING)
			if(user.dir == EAST || user.dir == NORTH)
				spin_direction = TRUE
			passtable_on(user, src)
			user.setMovetype(user.movement_type | FLYING)
			user.safe_throw_at(landing_turf, 4, 1, spin = FALSE)
			user.SpinAnimation(speed = 3, loops = 1, clockwise = spin_direction, segments = 3, parallel = TRUE)
			passtable_off(user, src)
			user.setMovetype(user.movement_type & ~FLYING)
		next_roll = world.time + 1 SECONDS
	else
		to_chat(user, span_notice("You need to catch your breath before you can roll again!"))


/obj/item/katana/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] stomach open with [src]! It looks like [user.p_theyre()] trying to commit seppuku!"))
	return(BRUTELOSS)

/obj/item/katana/cursed
	slot_flags = null

/obj/item/wirerod
	name = "wired rod"
	desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "wiredrod"
	item_state = "rods"
	flags_1 = CONDUCT_1
	force = 9
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/iron=1150, /datum/material/glass=75)
	attack_verb = list("hit", "bludgeoned", "whacked", "bonked")

/obj/item/wirerod/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/shard))
		var/obj/item/twohanded/spear/S = new /obj/item/twohanded/spear

		remove_item_from_storage(user)
		if (!user.transferItemToLoc(I, S))
			return
		S.CheckParts(list(I))
		qdel(src)

		user.put_in_hands(S)
		to_chat(user, span_notice("You fasten the glass shard to the top of the rod with the cable."))

	else if(istype(I, /obj/item/assembly/igniter) && !(HAS_TRAIT(I, TRAIT_NODROP)))
		var/obj/item/melee/baton/cattleprod/P = new /obj/item/melee/baton/cattleprod

		remove_item_from_storage(user)

		to_chat(user, span_notice("You fasten [I] to the top of the rod with the cable."))

		qdel(I)
		qdel(src)

		user.put_in_hands(P)
	else
		return ..()


/obj/item/throwing_star
	name = "throwing star"
	desc = "An ancient weapon still used to this day, due to its ease of lodging itself into its victim's body parts."
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "throwingstar"
	item_state = "eshield0"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	force = 2
	throwforce = 10 //10 + 2 (WEIGHT_CLASS_SMALL) * 4 (EMBEDDED_IMPACT_PAIN_MULTIPLIER) = 18 damage on hit due to guaranteed embedding
	throw_speed = 4
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 100, "embedded_fall_chance" = 0)
	w_class = WEIGHT_CLASS_SMALL
	sharpness = SHARP_POINTY
	materials = list(/datum/material/iron=500, /datum/material/glass=500)
	resistance_flags = FIRE_PROOF

/obj/item/throwing_star/magspear
	name = "magnetic spear"
	desc = "A reusable spear that is typically loaded into kinetic spearguns."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "magspear"
	throwforce = 25 //kills regular carps in one hit
	force = 10
	throw_range = 0 //throwing these invalidates the speargun
	attack_verb = list("stabbed", "ripped", "gored", "impaled")
	embedding = list("embedded_pain_multiplier" = 8, "embed_chance" = 100, "embedded_fall_chance" = 0, "embedded_impact_pain_multiplier" = 15) //55 damage+embed on hit

/obj/item/switchblade
	name = "switchblade"
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "switchblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "A sharp, concealable, spring-loaded knife."
	flags_1 = CONDUCT_1
	force = 3
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5
	throw_speed = 3
	throw_range = 6
	materials = list(/datum/material/iron=12000)
	hitsound = 'sound/weapons/genhit.ogg'
	attack_verb = list("stubbed", "poked")
	resistance_flags = FIRE_PROOF
	var/extended = 0

/obj/item/switchblade/attack_self(mob/user)
	extended = !extended
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 15, 1)
	if(extended)
		force = 20
		w_class = WEIGHT_CLASS_NORMAL
		throwforce = 23
		icon_state = "switchblade_ext"
		attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
		hitsound = 'sound/weapons/bladeslice.ogg'
		sharpness = SHARP_EDGED
	else
		force = 3
		w_class = WEIGHT_CLASS_SMALL
		throwforce = 5
		icon_state = "switchblade"
		attack_verb = list("stubbed", "poked")
		hitsound = 'sound/weapons/genhit.ogg'
		sharpness = SHARP_NONE

/obj/item/switchblade/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] own throat with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS)

/obj/item/switchblade/backstab
	var/nt = FALSE

/obj/item/switchblade/backstab/nt
	nt = TRUE

/obj/item/switchblade/backstab/examine(mob/user)
	. = ..()
	. += span_danger("\The [src] has a [nt ? "Nanotrasen" : "Syndicate"] marking on the blade.")

/obj/item/switchblade/backstab/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/backstabs, 1.75) // 35 damage

/obj/item/phone
	name = "red phone"
	desc = "Should anything ever go wrong..."
	icon_state = "red_phone"
	force = 3
	throwforce = 2
	throw_speed = 3
	throw_range = 4
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("called", "rang")
	hitsound = 'sound/weapons/ring.ogg'

/obj/item/phone/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in user.loc)
		user.visible_message(span_suicide("[user] begins to tie a noose with [src]'s cord! It looks like [user.p_theyre()] trying to commit suicide!"))
	else
		user.visible_message(span_suicide("[user] is strangling [user.p_them()]self with [src]'s cord! It looks like [user.p_theyre()] trying to commit suicide!"))
	return(OXYLOSS)

/obj/item/phone/real
	desc = "A bluespace last resort negotiation tool connected directly to the enemy should anything ever go wrong. Misuse will likely lead to the line being cut or anything else they're capable of. All communication is monitored by Nanotrasen Officials."

/obj/item/phone/real/attack_self(mob/user)
	var/input = stripped_input(usr, "Please choose a message to send. If you are unsure, you can still turn back. This seems very risky.", "Send a message to the enemy.", "")
	if(!input || !(usr in view(1,src)))
		return
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	message_redphone_syndicate(input, usr)
	to_chat(usr, span_danger("Message sent. Pray you made the right choice."))
	usr.log_talk(input, LOG_SAY, tag="Syndicate announcement")
	deadchat_broadcast(" has messaged the Syndicate using the red phone, \"[input]\" at [span_name("[get_area_name(usr, TRUE)]")].", span_name("[usr.real_name]"), usr)

/obj/item/phone/banana
	name = "banana phone"
	desc = "Direct telecommunications line to the Clown Planet. Use for emergencies only!"
	icon_state = "banana_phone"
	force = 3
	throwforce = 2
	throw_speed = 3
	throw_range = 4
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("called", "rang")
	hitsound = 'sound/items/bikehorn.ogg'

/obj/item/phone/banana/attack_self(mob/user)
	var/input = stripped_input(usr, "Please choose a message to send. If you are unsure, you can still turn back.", "Send a message to the Clown Planet.", "")
	if(!input || !(usr in view(1,src)))
		return
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	Clown_announce(input, usr)
	to_chat(usr, span_danger("Message sent. The Clown Planet will judge your message."))
	usr.log_talk(input, LOG_SAY, tag="Clown Planet announcement")
	deadchat_broadcast(" has messaged the Clown Planet using the banana phone, \"[input]\" at [span_name("[get_area_name(usr, TRUE)]")].", span_name("[usr.real_name]"), usr)

/obj/item/cane
	name = "cane"
	desc = "A cane used by a true gentleman. Or a clown."
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "cane"
	item_state = "stick"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	materials = list(/datum/material/iron=50)
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed")

/obj/item/staff
	name = "wizard staff"
	desc = "Apparently a staff used by the wizard."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	force = 3
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	armour_penetration = 100
	attack_verb = list("bludgeoned", "whacked", "disciplined")
	resistance_flags = FLAMMABLE

/obj/item/staff/broom
	name = "broom"
	desc = "Used for sweeping, and flying into the night while cackling. Black cat not included."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "broom"
	resistance_flags = FLAMMABLE

/obj/item/staff/stick
	name = "stick"
	desc = "A great tool to drag someone else's drinks across the bar."
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "cane"
	item_state = "stick"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 3
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ectoplasm
	name = "ectoplasm"
	desc = "Spooky."
	gender = PLURAL
	icon = 'icons/obj/wizard.dmi'
	icon_state = "ectoplasm"

/obj/item/ectoplasm/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is inhaling [src]! It looks like [user.p_theyre()] trying to visit the astral plane!"))
	return (OXYLOSS)

/obj/item/ectoplasm/angelic
	icon = 'icons/obj/wizard.dmi'
	icon_state = "angelplasm"

/obj/item/mounted_chainsaw
	name = "mounted chainsaw"
	desc = "A chainsaw that has replaced your arm."
	icon = 'icons/obj/tools.dmi'
	icon_state = "chainsaw_on"
	item_state = "mounted_chainsaw"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 24
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	sharpness = SHARP_EDGED
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsawhit.ogg'

/obj/item/mounted_chainsaw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/mounted_chainsaw/Destroy()
	var/obj/item/bodypart/part
	new /obj/item/twohanded/required/chainsaw(get_turf(src))
	if(iscarbon(loc))
		var/mob/living/carbon/holder = loc
		var/index = holder.get_held_index_of_item(src)
		if(index)
			part = holder.hand_bodyparts[index]
	. = ..()
	if(part)
		part.drop_limb()

/obj/item/statuebust
	name = "bust"
	desc = "A priceless ancient marble bust, the kind that belongs in a museum." //or you can hit people with it
	icon = 'icons/obj/statue.dmi'
	icon_state = "bust"
	force = 15
	throwforce = 10
	throw_speed = 5
	throw_range = 2
	attack_verb = list("busted")
	var/impressiveness = 45

/obj/item/statuebust/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/art, impressiveness)

/obj/item/statuebust/hippocratic
	name = "hippocrates bust"
	desc = "A bust of the famous Greek physician Hippocrates of Kos, often referred to as the father of western medicine."
	icon_state = "hippocratic"
	impressiveness = 50

/obj/item/tailclub
	name = "tail club"
	desc = "For the beating to death of lizards with their own tails."
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "tailclub"
	force = 14
	throwforce = 1 // why are you throwing a club do you even weapon
	throw_speed = 1
	throw_range = 1
	attack_verb = list("clubbed", "bludgeoned")

/obj/item/melee/chainofcommand/tailwhip
	name = "liz o' nine tails"
	desc = "A whip fashioned from the severed tails of lizards."
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "tailwhip"
	item_flags = NONE

/obj/item/melee/chainofcommand/tailwhip/kitty
	name = "cat o' nine tails"
	desc = "A whip fashioned from the severed tails of cats."
	icon_state = "catwhip"

/obj/item/melee/skateboard
	name = "improvised skateboard"
	desc = "A skateboard. It can be placed on its wheels and ridden, or used as a strong weapon."
	icon = 'icons/obj/toy.dmi'
	icon_state = "skateboard"
	item_state = "skateboard"
	force = 12
	throwforce = 4
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("smacked", "whacked", "slammed", "smashed")
	var/board_item_type = /obj/vehicle/ridden/scooter/skateboard ///The vehicle counterpart for the board

/obj/item/melee/skateboard/attack_self(mob/user)
	var/obj/vehicle/ridden/scooter/skateboard/S = new board_item_type(get_turf(user))//this probably has fucky interactions with telekinesis but for the record it wasnt my fault
	S.buckle_mob(user)
	qdel(src)

/obj/item/melee/skateboard/pro
	name = "skateboard"
	desc = "A RaDSTORMz brand professional skateboard. It looks sturdy and well made."
	icon_state = "skateboard2"
	item_state = "skateboard2"
	board_item_type = /obj/vehicle/ridden/scooter/skateboard/pro
	custom_premium_price = 300

/obj/item/melee/skateboard/hoverboard
	name = "hoverboard"
	desc = "A blast from the past, so retro!"
	icon_state = "hoverboard_red"
	item_state = "hoverboard_red"
	board_item_type = /obj/vehicle/ridden/scooter/skateboard/hoverboard
	custom_premium_price = 2015

/obj/item/melee/skateboard/hoverboard/admin
	name = "\improper Board Of Directors"
	desc = "The engineering complexity of a spaceship concentrated inside of a board. Just as expensive, too."
	icon_state = "hoverboard_nt"
	item_state = "hoverboard_nt"
	board_item_type = /obj/vehicle/ridden/scooter/skateboard/hoverboard/admin

/obj/item/melee/flyswatter
	name = "flyswatter"
	desc = "Useful for killing insects of all sizes."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "flyswatter"
	item_state = "flyswatter"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 1
	throwforce = 1
	attack_verb = list("swatted", "smacked")
	hitsound = 'sound/effects/snap.ogg'
	w_class = WEIGHT_CLASS_SMALL
	//Things in this list will be instantly splatted.  Flyman weakness is handled in the flyman species weakness proc.
	var/list/strong_against

/obj/item/melee/flyswatter/Initialize(mapload)
	. = ..()
	strong_against = typecacheof(list(
					/mob/living/simple_animal/hostile/poison/bees/,
					/mob/living/simple_animal/butterfly,
					/mob/living/simple_animal/cockroach,
					/obj/item/queen_bee
	))


/obj/item/melee/flyswatter/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag)
		if(is_type_in_typecache(target, strong_against))
			new /obj/effect/decal/cleanable/insectguts(target.drop_location())
			to_chat(user, span_warning("You easily splat the [target]."))
			if(istype(target, /mob/living/))
				var/mob/living/bug = target
				bug.death(1)
			else
				qdel(target)

/obj/item/circlegame
	name = "circled hand"
	desc = "If somebody looks at this while it's below your waist, you get to bop them."
	icon_state = "madeyoulook"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT
	attack_verb = list("bopped")

/obj/item/slapper
	name = "slapper"
	desc = "This is how real men fight."
	icon = 'icons/obj/toy.dmi'
	icon_state = "latexballon"
	item_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT
	attack_verb = list("slapped")

/obj/item/slapper/attack(mob/living/M, mob/living/carbon/human/user)
	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		if(L && L.dna && L.dna.species)
			L.dna.species.stop_wagging_tail(M)

	var/slap_volume = 30
	var/hard_slap = FALSE
	if(!HAS_TRAIT(user, TRAIT_PACIFISM) && user.a_intent == INTENT_HARM)
		hard_slap = TRUE
		slap_volume = 60
		force = 2
		..()
		qdel(src) // hurts your hand to slap so hard
	else
		user.do_attack_animation(M)

	if(user.zone_selected == BODY_ZONE_HEAD || user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		user.visible_message("<span class='danger'>[user] slaps [M] in the face[hard_slap ? " really hard" : ""]!</span>",
			"<span class='notice'>You slap [M] in the face[hard_slap ? " really hard" : ""]!</span>",
			"<span class='hear'>You hear a slap.</span>")
	else
		user.visible_message("<span class='danger'>[user] slaps [M][hard_slap ? " really hard" : ""]!</span>",
			"<span class='notice'>You slap [M][hard_slap ? " really hard" : ""]!</span>",
			"<span class='hear'>You hear a slap.</span>")
	playsound(M, 'sound/weapons/slap.ogg', slap_volume, TRUE, -1)
	return TRUE

/obj/item/slapper/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!istype(target, /obj/structure/table))
		return ..()

	var/obj/structure/table/the_table = target

	if(!proximity_flag)
		return

	if(user.a_intent == INTENT_HARM)
		transform = transform.Scale(5) // BIG slap
		if(HAS_TRAIT(user, TRAIT_HULK))
			transform = transform.Scale(2)
			color = COLOR_GREEN
		user.do_attack_animation(the_table)
		//Uncomment if we ever port table slam signals
		//SEND_SIGNAL(user, COMSIG_LIVING_SLAM_TABLE, the_table)
		//SEND_SIGNAL(the_table, COMSIG_TABLE_SLAMMED, user)
		playsound(get_turf(the_table), 'sound/effects/table-slam-hard.ogg', 110, TRUE)
		user.visible_message("<b><span class='danger'>[user] slams [user.p_their()] fist down on [the_table]!</span></b>", "<b><span class='danger'>You slam your fist down on [the_table]!</span></b>")
		transform = null
	else
		user.do_attack_animation(the_table)
		playsound(get_turf(the_table), 'sound/effects/tableslam.ogg', 40, TRUE)
		user.visible_message("<span class='notice'>[user] slaps [user.p_their()] hand on [the_table].</span>", "<span class='notice'>You slap your hand on [the_table].</span>", vision_distance=COMBAT_MESSAGE_RANGE)

/obj/item/proc/can_trigger_gun(mob/living/user)
	if(!user.can_use_guns(src))
		return FALSE
	return TRUE

/obj/item/extendohand
	name = "extendo-hand"
	desc = "Futuristic tech has allowed these classic spring-boxing toys to essentially act as a fully functional hand-operated hand prosthetic."
	icon = 'icons/obj/toy.dmi'
	icon_state = "extendohand"
	item_state = "extendohand"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 0
	throwforce = 5
	weapon_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 2, DAMAGE_LOW = 0, DAMAGE_HIGH = 0)
	var/min_reach = 2

/obj/item/extendohand/acme
	name = "\improper ACME Extendo-Hand"
	desc = "A novelty extendo-hand produced by the ACME corporation. Originally designed to knock out roadrunners."

/obj/item/extendohand/attack(atom/M, mob/living/carbon/human/user)
	var/dist = get_dist(M, user)
	if(dist < min_reach)
		to_chat(user, span_warning("[M] is too close to use [src] on."))
		return
	M.attack_hand(user)

/obj/item/twohanded/required/raisedhands
	name = "raised hands"
	desc = "What are you, French?"
	icon = 'icons/obj/toy.dmi'
	icon_state = "latexballon"
	item_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT

/obj/item/twohanded/required/raisedhands/attack(mob/living/M, mob/living/user)
  return

/obj/item/twohanded/required/raisedhands/dropped(mob/user)
	user.visible_message(span_userdanger(("[user] lowers their hands!")))
	..()
