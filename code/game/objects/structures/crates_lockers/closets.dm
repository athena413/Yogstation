GLOBAL_LIST_EMPTY(lockers)

/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "generic"
	density = TRUE
	var/icon_door = null
	var/icon_door_override = FALSE //override to have open overlay use icon different to its base's
	var/secure = FALSE //secure locker or not, also used if overriding a non-secure locker with a secure door overlay to add fancy lights
	var/opened = FALSE
	var/welded = FALSE
	var/locked = FALSE
	var/large = TRUE
	var/wall_mounted = 0 //never solid (You can always pass over it)
	max_integrity = 200
	integrity_failure = 50
	armor = list(MELEE = 20, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 70, ACID = 60)
	var/breakout_time = 1200
	var/message_cooldown
	var/can_weld_shut = TRUE
	var/open_flags = 0
	var/dense_when_open = FALSE //if it's dense when open or not
	var/max_mob_size = MOB_SIZE_HUMAN //Biggest mob_size accepted by the container
	var/mob_storage_capacity = 3 // how many human sized mob/living can fit together inside a closet.
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate then open it in a populated area to crash clients.
	var/cutting_tool = /obj/item/weldingtool
	var/open_sound = 'sound/machines/click.ogg'
	var/close_sound = 'sound/machines/click.ogg'
	var/material_drop = /obj/item/stack/sheet/metal
	var/material_drop_amount = 2
	var/delivery_icon = "deliverycloset" //which icon to use when packagewrapped. null to be unwrappable.
	var/anchorable = TRUE
	var/icon_welded = "welded"
	/// Protection against weather that being inside of it provides.
	var/list/weather_protection = null
	/// How close being inside of the thing provides complete pressure safety. Must be between 0 and 1!
	contents_pressure_protection = 0
	/// How insulated the thing is, for the purposes of calculating body temperature. Must be between 0 and 1!
	contents_thermal_insulation = 0
	var/notreallyacloset = FALSE // It is genuinely a closet
	var/datum/gas_mixture/air_contents
	var/airtight_when_welded = TRUE
	var/airtight_when_closed = FALSE
	var/obj/effect/overlay/closet_door/door_obj
	var/is_animating_door = FALSE
	var/door_anim_squish = 0.12
	var/door_anim_angle = 136
	var/door_hinge_x = -6.5
	var/door_anim_time = 2.5 // set to 0 to make the door not animate at all

/obj/structure/closet/Initialize(mapload)
	. = ..()

	if(mapload && !opened)		// if closed, any item at the crate's loc is put in the contents
		. = INITIALIZE_HINT_LATELOAD

	update_icon()
	PopulateContents()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_MAGICALLY_UNLOCKED = PROC_REF(on_magic_unlock),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	GLOB.lockers += src

/obj/structure/closet/LateInitialize()
	. = ..()

	take_contents()

//USE THIS TO FILL IT, NOT INITIALIZE OR NEW
/obj/structure/closet/proc/PopulateContents()
	return

/obj/structure/closet/Destroy()
	dump_contents()
	GLOB.lockers -= src
	return ..()

/obj/structure/closet/update_icon()
	cut_overlays()
	if(!opened)
		layer = OBJ_LAYER
		if(!is_animating_door)
			if(icon_door)
				add_overlay("[icon_door]_door")
			else
				add_overlay("[icon_state]_door")
			if(welded)
				add_overlay(icon_welded)
			if(secure && !broken)
				if(locked)
					add_overlay("locked")
				else
					add_overlay("unlocked")

	else
		layer = BELOW_OBJ_LAYER
		if(!is_animating_door)
			if(icon_door_override)
				add_overlay("[icon_door]_open")
			else
				add_overlay("[icon_state]_open")

/obj/structure/closet/proc/animate_door(closing = FALSE)
	if(!door_anim_time)
		return
	if(!door_obj) door_obj = new
	vis_contents |= door_obj
	door_obj.icon = icon
	door_obj.icon_state = "[icon_door || icon_state]_door"
	is_animating_door = TRUE
	var/num_steps = door_anim_time / world.tick_lag
	for(var/I in 0 to num_steps)
		var/angle = door_anim_angle * (closing ? 1 - (I/num_steps) : (I/num_steps))
		var/matrix/M = get_door_transform(angle)
		var/door_state = angle >= 90 ? "[icon_door_override ? icon_door : icon_state]_back" : "[icon_door || icon_state]_door"
		var/door_layer = angle >= 90 ? FLOAT_LAYER : ABOVE_MOB_LAYER

		if(I == 0)
			door_obj.transform = M
			door_obj.icon_state = door_state
			door_obj.layer = door_layer
		else if(I == 1)
			animate(door_obj, transform = M, icon_state = door_state, layer = door_layer, time = world.tick_lag, flags = ANIMATION_END_NOW)
		else
			animate(transform = M, icon_state = door_state, layer = door_layer, time = world.tick_lag)
	addtimer(CALLBACK(src, PROC_REF(end_door_animation)),door_anim_time,TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/structure/closet/proc/end_door_animation()
	is_animating_door = FALSE
	vis_contents -= door_obj
	update_icon()

/obj/structure/closet/proc/get_door_transform(angle)
	var/matrix/M = matrix()
	M.Translate(-door_hinge_x, 0)
	M.Multiply(matrix(cos(angle), 0, 0, -sin(angle) * door_anim_squish, 1, 0))
	M.Translate(door_hinge_x, 0)
	return M

/obj/structure/closet/examine(mob/user)
	.=..()
	if(notreallyacloset) // Yogs -- Fixes bodybags complaining they can be welded together
		return . // Yogs
	if(welded)
		. += span_notice("It's welded shut.")
	if(anchored)
		. += span_notice("It is <b>bolted</b> to the ground.")
	if(opened)
		. += span_notice("The parts are <b>welded</b> together.")
	else if(secure && !opened)
		. += span_notice("Alt-click to [locked ? "unlock" : "lock"].")
	if(isliving(user))
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_SKITTISH))
			. += span_notice("Ctrl-Shift-click [src] to jump inside.")

/obj/structure/closet/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(wall_mounted)
		return TRUE

/obj/structure/closet/proc/can_open(mob/living/user)
	if(welded || locked)
		return FALSE

	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		if(L.anchored || (open_flags & HORIZONTAL_LID) && L.mob_size > MOB_SIZE_TINY && L.density)
			if(user)
				to_chat(user, span_danger("There's something large on top of [src], preventing it from opening.") )
			return FALSE
	return TRUE

/obj/structure/closet/proc/can_close(mob/living/user)
	var/turf/T = get_turf(src)
	for(var/obj/structure/closet/closet in T)
		if(closet != src && !closet.wall_mounted)
			return FALSE
	for(var/mob/living/L in T)
		if(L.anchored || (open_flags & HORIZONTAL_LID) && L.mob_size > MOB_SIZE_TINY && L.density)
			if(user)
				to_chat(user, span_danger("There's something too large in [src], preventing it from closing."))
			return FALSE
	return TRUE

/obj/structure/closet/proc/dump_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in src)
		AM.forceMove(L)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(AM, dir)
	if(throwing)
		throwing.finalize(FALSE)

/obj/structure/closet/proc/take_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in L)
		if(AM != src && insert(AM) == -1) // limit reached
			break

/obj/structure/closet/proc/open(mob/living/user)
	if(opened || !can_open(user))
		return
	playsound(loc, open_sound, 15, 1, -3)
	opened = TRUE
	if(!dense_when_open)
		density = FALSE
	climb_time *= 0.5 //it's faster to climb onto an open thing
	dump_contents()
	animate_door(FALSE)
	update_icon()
	update_airtightness()
	return 1

/obj/structure/closet/proc/insert(atom/movable/AM)
	if(contents.len >= storage_capacity)
		return -1
	if(insertion_allowed(AM))
		AM.forceMove(src)
		return TRUE
	else
		return FALSE

/obj/structure/closet/proc/insertion_allowed(atom/movable/AM)
	if(ismob(AM))
		if(!isliving(AM)) //let's not put ghosts or camera mobs inside closets...
			return FALSE
		var/mob/living/L = AM
		if(L.anchored || L.buckled || L.incorporeal_move || L.has_buckled_mobs())
			return FALSE
		if(L.mob_size > MOB_SIZE_TINY) // Tiny mobs are treated as items.
			if((open_flags & HORIZONTAL_HOLD) && L.density)
				return FALSE
			if(L.mob_size > max_mob_size)
				return FALSE
			var/mobs_stored = 0
			for(var/mob/living/M in contents)
				if(++mobs_stored >= mob_storage_capacity)
					return FALSE
		L.stop_pulling()

	else if(istype(AM, /obj/structure/closet))
		return FALSE
	else if(isobj(AM))
		if((!(open_flags & ALLOW_DENSE) && AM.density) || AM.anchored || AM.has_buckled_mobs())
			return FALSE
		else if(isitem(AM) && !HAS_TRAIT(AM, TRAIT_NODROP))
			return TRUE
		else if(!(open_flags & ALLOW_OBJECTS) && !istype(AM, /obj/effect/dummy/chameleon))
			return FALSE
	else
		return FALSE

	return TRUE

/obj/structure/closet/proc/close(mob/living/user)
	if(!opened || !can_close(user))
		return FALSE
	take_contents()
	playsound(loc, close_sound, 15, 1, -3)
	climb_time = initial(climb_time)
	opened = FALSE
	density = TRUE
	animate_door(TRUE)
	update_icon()
	update_airtightness()
	close_storage(user)
	return TRUE

/obj/structure/closet/proc/toggle(mob/living/user)
	if(opened)
		return close(user)
	else
		return open(user)

/obj/structure/closet/proc/close_storage(mob/living/user)
	for(var/obj/object in contents)
		var/datum/component/storage/closeall = object.GetComponent(/datum/component/storage)
		if(closeall)
			closeall.close_all()

/obj/structure/closet/deconstruct(disassembled = TRUE)
	if(ispath(material_drop) && material_drop_amount && !(flags_1 & NODECONSTRUCT_1))
		new material_drop(loc, material_drop_amount)
	qdel(src)

/obj/structure/closet/obj_break(damage_flag)
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		bust_open()

/obj/structure/closet/attackby(obj/item/W, mob/user, params)
	if(user in src)
		return
	if(src.tool_interact(W,user))
		return 1 // No afterattack
	else
		return ..()

/obj/structure/closet/proc/tool_interact(obj/item/W, mob/user)//returns TRUE if attackBy call shouldnt be continued (because tool was used/closet was of wrong type), FALSE if otherwise
	. = TRUE
	if(opened)
		if(user.a_intent == INTENT_HARM)
			return FALSE
		if(istype(W, cutting_tool))
			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return

				to_chat(user, span_notice("You begin cutting \the [src] apart..."))
				if(W.use_tool(src, user, 40, volume=50))
					if(!opened)
						return
					user.visible_message(span_notice("[user] slices apart \the [src]."),
									span_notice("You cut \the [src] apart with \the [W]."),
									span_italics("You hear welding."))
					deconstruct(TRUE)
				return
			else // for example cardboard box is cut with wirecutters
				user.visible_message(span_notice("[user] cut apart \the [src]."), \
									span_notice("You cut \the [src] apart with \the [W]."))
				deconstruct(TRUE)
				return
		if(user.transferItemToLoc(W, drop_location())) // so we put in unlit welder too
			return
	else if(W.tool_behaviour == TOOL_WELDER && can_weld_shut)
		if(!W.tool_start_check(user, amount=0))
			return

		to_chat(user, span_notice("You begin [welded ? "unwelding":"welding"] \the [src]..."))
		if(W.use_tool(src, user, 40, volume=50))
			if(opened)
				return
			welded = !welded
			after_weld(welded)
			update_airtightness()
			user.visible_message(span_notice("[user] [welded ? "welds shut" : "unwelded"] \the [src]."),
							span_notice("You [welded ? "weld" : "unwelded"] \the [src] with \the [W]."),
							span_italics("You hear welding."))
			update_icon()
	else if(W.tool_behaviour == TOOL_WRENCH && anchorable)
		if(isinspace() && !anchored)
			return
		setAnchored(!anchored)
		W.play_tool_sound(src, 75)
		user.visible_message(span_notice("[user] [anchored ? "anchored" : "unanchored"] \the [src] [anchored ? "to" : "from"] the ground."), \
						span_notice("You [anchored ? "anchored" : "unanchored"] \the [src] [anchored ? "to" : "from"] the ground."), \
						span_italics("You hear a ratchet."))
	else if(user.a_intent != INTENT_HARM)
		var/item_is_id = W.GetID()
		if(!item_is_id && !(W.item_flags & NOBLUDGEON))
			return FALSE
		if(item_is_id || !toggle(user))
			togglelock(user)
	else
		return FALSE

/obj/structure/closet/proc/after_weld(weld_state)
	return

/obj/structure/closet/MouseDrop_T(atom/movable/O, mob/living/user)
	if(!istype(O) || O.anchored || istype(O, /atom/movable/screen))
		return
	if(!istype(user) || user.incapacitated() || !(user.mobility_flags & MOBILITY_STAND))
		return
	if(!Adjacent(user) || !user.Adjacent(O))
		return
	if(user == O) //try to climb onto it
		return ..()
	if(!opened)
		return
	if(!isturf(O.loc))
		return

	var/actuallyismob = 0
	if(isliving(O))
		actuallyismob = 1
	else if(!isitem(O))
		return
	var/turf/T = get_turf(src)
	var/list/targets = list(O, src)
	add_fingerprint(user)
	user.visible_message(span_warning("[user] [actuallyismob ? "tries to ":""]stuff [O] into [src]."), \
				 	 	span_warning("You [actuallyismob ? "try to ":""]stuff [O] into [src]."), \
				 	 	span_italics("You hear clanging."))
	if(actuallyismob)
		if(do_after_mob(user, targets, 40))
			user.visible_message(span_notice("[user] stuffs [O] into [src]."), \
							 	 span_notice("You stuff [O] into [src]."), \
							 	 span_italics("You hear a loud metal bang."))
			var/mob/living/L = O
			if(!issilicon(L))
				L.Paralyze(40)
			if(istype(src, /obj/structure/closet/supplypod/extractionpod))
				O.forceMove(src)
			else
				O.forceMove(T)
				close()
	else
		O.forceMove(T)
	return 1

/obj/structure/closet/relaymove(mob/user)
	if(user.stat || !isturf(loc) || !isliving(user))
		return
	if(locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, span_warning("[src]'s door won't budge!"))
		return
	container_resist(user)

/obj/structure/closet/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!(user.mobility_flags & MOBILITY_STAND) && get_dist(src, user) > 0)
		return
	if((user.mind?.has_martialart(MARTIALART_BUSTERSTYLE)) && (user.a_intent == INTENT_GRAB))
		return //buster arm shit since trying to pick up an open locker just stuffs you in it
	if(!toggle(user))
		togglelock(user)

/obj/structure/closet/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/closet/attack_robot(mob/user)
	if(user.Adjacent(src))
		return attack_hand(user)

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user)
	return attack_hand(user)

/obj/structure/closet/verb/verb_toggleopen()
	set src in view(1)
	set category = "Object"
	set name = "Toggle Open"

	if(!usr.canUseTopic(src, BE_CLOSE) || !isturf(loc))
		return

	if(iscarbon(usr) || issilicon(usr) || isdrone(usr))
		return toggle(usr)
	else
		to_chat(usr, span_warning("This mob type can't use this verb."))

// Objects that try to exit a locker by stepping were doing so successfully,
// and due to an oversight in turf/Enter() were going through walls.  That
// should be independently resolved, but this is also an interesting twist.
/obj/structure/closet/Exit(atom/movable/AM)
	open()
	if(AM.loc == src)
		return 0
	return 1

/obj/structure/closet/container_resist(mob/living/user)
	if(opened)
		return
	if(ismovable(loc))
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		var/atom/movable/AM = loc
		AM.relay_container_resist(user, src)
		return
	if(!welded && !locked)
		open()
		return

	//okay, so the closet is either welded or locked... resist!!!
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_warning("[src] begins to shake violently!"), \
		span_notice("You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(breakout_time)].)"), \
		span_italics("You hear banging from [src]."))
	if(do_after(user, (breakout_time), src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || opened || (!locked && !welded) )
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting
		user.visible_message(span_danger("[user] successfully broke out of [src]!"),
							span_notice("You successfully break out of [src]!"))
		bust_open()
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, span_warning("You fail to break out of [src]!"))

/obj/structure/closet/proc/bust_open()
	welded = FALSE //applies to all lockers
	locked = FALSE //applies to critter crates and secure lockers only
	broken = TRUE //applies to secure lockers only
	open()

/obj/structure/closet/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, BE_CLOSE) || !isturf(loc))
		return
	if(opened || !secure)
		return
	else
		togglelock(user)

/obj/structure/closet/CtrlShiftClick(mob/living/user)
	if(!HAS_TRAIT(user, TRAIT_SKITTISH))
		return ..()
	if(!user.canUseTopic(src, BE_CLOSE) || !isturf(user.loc))
		return
	dive_into(user)

/obj/structure/closet/proc/togglelock(mob/living/user, silent)
	if(secure && !broken)
		if(allowed(user))
			if(iscarbon(user))
				add_fingerprint(user)
			locked = !locked
			user.visible_message(span_notice("[user] [locked ? null : "un"]locks [src]."),
							span_notice("You [locked ? null : "un"]lock [src]."))
			update_icon()
		else if(!silent)
			to_chat(user, span_notice("Access Denied"))
	else if(secure && broken)
		to_chat(user, span_warning("\The [src] is broken!"))

/obj/structure/closet/emag_act(mob/user)
	if(secure && !broken)
		user.visible_message(span_warning("Sparks fly from [src]!"),
						span_warning("You scramble [src]'s lock, breaking it open!"),
						span_italics("You hear a faint electrical spark."))
		playsound(src, "sparks", 50, 1)
		broken = TRUE
		locked = FALSE
		update_icon()

/obj/structure/closet/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 1)

/obj/structure/closet/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if (!(. & EMP_PROTECT_CONTENTS))
		for(var/obj/O in src)
			O.emp_act(severity)
	if(secure && !broken && !(. & EMP_PROTECT_SELF))
		if(prob(50 / severity))
			locked = !locked
			update_icon()
		if(prob(20 / severity) && !opened)
			if(!locked)
				open()
			else
				req_access = list()
				req_access += pick(get_all_accesses())

/obj/structure/closet/contents_explosion(severity, target)
	for(var/thing in contents)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += thing
		CHECK_TICK

/obj/structure/closet/singularity_act()
	dump_contents()
	..()

/obj/structure/closet/AllowDrop()
	return TRUE


/obj/structure/closet/return_temperature()
	return

/obj/structure/closet/proc/dive_into(mob/living/user)
	var/turf/T1 = get_turf(user)
	var/turf/T2 = get_turf(src)
	if(!opened)
		if(locked)
			togglelock(user, TRUE)
		if(!open(user))
			to_chat(user, span_warning("It won't budge!"))
			return
	step_towards(user, T2)
	T1 = get_turf(user)
	if(T1 == T2)
		user.resting = TRUE //so people can jump into crates without slamming the lid on their head
		if(!close(user))
			to_chat(user, span_warning("You can't get [src] to close!"))
			user.resting = FALSE
			return
		user.resting = FALSE
		togglelock(user)
		T1.visible_message(span_warning("[user] dives into [src]!"))

/obj/structure/closet/proc/update_airtightness()
	var/is_airtight = FALSE
	if(airtight_when_closed && !opened)
		is_airtight = TRUE
	if(airtight_when_welded && welded)
		is_airtight = TRUE
	// okay so this might create/delete gases but the alternative is extra work and/or unnecessary spacewind from welding lockers.
	// basically we're simulating the air being displaced without actually having the air be displaced.
	// speaking of we should really add a way to displace air. Canisters are really big and they really ought to displace air. Alas it doesnt exist
	// so instead I have to violate conservation of energy. Not that this game already doesn't.
	if(is_airtight && !air_contents)
		air_contents = new(500)
		var/datum/gas_mixture/loc_air = loc?.return_air()
		if(loc_air)
			air_contents.copy_from(loc_air)
			air_contents.remove_ratio((1 - (air_contents.return_volume() / loc_air.return_volume()))) // and thus we have just magically created new gases....
	else if(!is_airtight && air_contents)
		var/datum/gas_mixture/loc_air = loc?.return_air()
		if(loc_air) // remember that air we created earlier? Now it's getting deleted! I mean it's still going on the turf....
			var/remove_amount = (loc_air.total_moles() + air_contents.total_moles()) * air_contents.return_volume() / (loc_air.return_volume() + air_contents.return_volume())
			loc.assume_air(air_contents)
			loc.remove_air(remove_amount)
			loc.air_update_turf()
		air_contents = null

/obj/structure/closet/return_air()
	if(welded)
		return air_contents
	return ..()

/obj/structure/closet/assume_air(datum/gas_mixture/giver)
	if(air_contents)
		return air_contents.merge(giver)
	return ..()

/obj/structure/closet/remove_air(amount)
	if(air_contents)
		return air_contents.remove(amount)
	return ..()

/obj/structure/closet/return_temperature()
	if(air_contents)
		return air_contents.return_temperature()
	return ..()

/obj/structure/closet/CanAStarPass(ID, dir, caller)
	if(can_open(caller) || allowed(caller))
		return TRUE
	. = ..()
	
	/// Signal proc for [COMSIG_ATOM_MAGICALLY_UNLOCKED]. Unlock and open up when we get knock casted.
/obj/structure/closet/proc/on_magic_unlock(datum/source, datum/action/cooldown/spell/aoe/knock/spell, mob/living/caster)
	SIGNAL_HANDLER

	locked = FALSE
	INVOKE_ASYNC(src, PROC_REF(open))
