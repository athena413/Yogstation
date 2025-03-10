//conveyor2 is pretty much like the original, except it supports corners, but not diverters.
//note that corner pieces transfer stuff clockwise when running forward, and anti-clockwise backwards.

GLOBAL_LIST_EMPTY(conveyors_by_id)
#define MAX_CONVEYOR_ITEMS_MOVE 30
/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_map"
	name = "conveyor belt"
	desc = "A conveyor belt. You can rotate it with a wrench, and reverse it with a screwdriver, or detach it with a crowbar."
	layer = BELOW_OPEN_DOOR_LAYER
	/// The current state of the switch.
	var/operating = 0
	/// This is the default (forward) direction, set by the map dir.
	var/forwards
	/// The opposite of forwards. It's set in a special var for corner belts, which aren't using the opposite direction when in reverse.
	var/backwards
	/// The actual direction to move stuff in.
	var/movedir
	/// The control ID - must match at least one conveyor switch's ID to be useful.
	var/id = ""
	/// Inverts the direction the conveyor belt moves when true.
	var/inverted = FALSE
	/// Are we currently conveying items?
	speed_process = TRUE
	var/conveying = FALSE
	///The time it takes for the converyor to move stuff. Default 1, Lower is faster.
	var/conveytime = 1

/obj/machinery/conveyor/examine(mob/user)
	. = ..()
	if(inverted)
		. += span_notice("It is currently set to go in reverse.")
	. += "\nLeft-click with a <b>wrench</b> to rotate."
	. += "Left-click with a <b>screwdriver</b> to invert its direction."

/obj/machinery/conveyor/centcom_auto
	id = "round_end_belt"


/obj/machinery/conveyor/inverted //Directions inverted so you can use different corner peices.
	icon_state = "conveyor_map_inverted"
	inverted = TRUE

/obj/machinery/conveyor/inverted/Initialize(mapload)
	. = ..()
	if(mapload && !(dir in GLOB.diagonals))
		log_mapping("[src] at [AREACOORD(src)] spawned without using a diagonal dir. Please replace with a normal version.")

// Auto conveyour is always on unless unpowered

/obj/machinery/conveyor/auto/Initialize(mapload, newdir)
	. = ..()
	operating = TRUE
	update_move_direction()

/obj/machinery/conveyor/auto/update()
	. = ..()
	operating = .

// create a conveyor
/obj/machinery/conveyor/Initialize(mapload, newdir, newid)
	. = ..()
	if(newdir)
		setDir(newdir)
	if(newid)
		id = newid
	update_move_direction()
	LAZYADD(GLOB.conveyors_by_id[id], src)

/obj/machinery/conveyor/Destroy()
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	return ..()

/obj/machinery/conveyor/vv_edit_var(var_name, var_value)
	if (var_name == "id")
		// if "id" is varedited, update our list membership
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		. = ..()
		LAZYADD(GLOB.conveyors_by_id[id], src)
	else
		return ..()

/obj/machinery/conveyor/setDir(newdir)
	. = ..()
	update_move_direction()

/obj/machinery/conveyor/proc/update_move_direction()
	switch(dir)
		if(NORTH)
			forwards = NORTH
			backwards = SOUTH
		if(SOUTH)
			forwards = SOUTH
			backwards = NORTH
		if(EAST)
			forwards = EAST
			backwards = WEST
		if(WEST)
			forwards = WEST
			backwards = EAST
		if(NORTHEAST)
			forwards = EAST
			backwards = SOUTH
		if(NORTHWEST)
			forwards = NORTH
			backwards = EAST
		if(SOUTHEAST)
			forwards = SOUTH
			backwards = WEST
		if(SOUTHWEST)
			forwards = WEST
			backwards = NORTH
	if(inverted)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	if(operating == 1)
		movedir = forwards
	else
		movedir = backwards
	update()

/obj/machinery/conveyor/update_icon()
	if(!operating)
		icon_state = "conveyor[inverted ? "-0" : "0"]"
	else
		icon_state = "conveyor[inverted ? -operating : operating]"

/obj/machinery/conveyor/proc/update()
	. = TRUE
	if(stat & NOPOWER)
		operating = FALSE
		. = FALSE
	update_icon()

	// machine process
	// move items to the target location
/obj/machinery/conveyor/process()
	if(!operating || conveying)	//If the conveyor is off or already moving items
		return

	if(!operating)
		return
	use_power(6)
	//get the first 30 items in contents
	var/turf/locturf = loc
	var/list/items = locturf.contents - src - locturf.lighting_object
	if(!LAZYLEN(items))//Dont do anything at all if theres nothing there but the conveyor
		return
	var/list/affecting
	if(length(items) > MAX_CONVEYOR_ITEMS_MOVE)
		affecting = items.Copy(1, MAX_CONVEYOR_ITEMS_MOVE + 1)//Lists start at 1 lol
	else
		affecting = items
	conveying = TRUE

	addtimer(CALLBACK(src, PROC_REF(convey), affecting), conveytime)//Movement effect

/obj/machinery/conveyor/proc/convey(list/affecting)
	for(var/am in affecting)
		if(!ismovable(am))	//This is like a third faster than for(var/atom/movable in affecting)
			continue
		var/atom/movable/movable_thing = am
		//Give this a chance to yield if the server is busy
		stoplag()
		if(QDELETED(movable_thing) || (movable_thing.loc != loc))
			continue
		if(iseffect(movable_thing) || isdead(movable_thing))
			continue
		if(isliving(movable_thing))
			var/mob/living/zoommob = movable_thing
			if((zoommob.movement_type & FLYING) && !zoommob.stat)
				continue
		if(!movable_thing.anchored && movable_thing.has_gravity())
			step(movable_thing, movedir)
	conveying = FALSE

// attack with item, place item on conveyor
/obj/machinery/conveyor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_CROWBAR)
		user.visible_message(span_notice("[user] struggles to pry up \the [src] with \the [I]."), \
		span_notice("You struggle to pry up \the [src] with \the [I]."))
		if(I.use_tool(src, user, 40, volume=40))
			var/obj/item/stack/conveyor/C = new /obj/item/stack/conveyor(loc, 1, TRUE, id)
			transfer_fingerprints_to(C)
			to_chat(user, span_notice("You remove the conveyor belt."))
			qdel(src)

	else if(I.tool_behaviour == TOOL_WRENCH)
		I.play_tool_sound(src)
		setDir(turn(dir,-45))
		update_move_direction()
		to_chat(user, span_notice("You rotate [src]."))

	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		inverted = !inverted
		update_move_direction()
		to_chat(user, span_notice("You set [src]'s direction [inverted ? "backwards" : "back to default"]."))
		update_icon()

	else if(I.tool_behaviour == TOOL_MULTITOOL)
		switch(conveytime)
			if(1)
				conveytime = 0.5
				to_chat(user, span_notice("You set [src]'s speed to double."))
			if(0.5)
				conveytime = 2
				to_chat(user, span_notice("You set [src]'s speed to half."))
			if(2)
				conveytime = 4
				to_chat(user, span_notice("You set [src]'s speed to a quarter."))
			if(4)
				conveytime = 1
				to_chat(user, span_notice("You set [src]'s speed back to default."))

	else if(user.a_intent != INTENT_HARM)
		user.transferItemToLoc(I, drop_location())
	else
		return ..()

// attack with hand, move pulled object onto conveyor
/obj/machinery/conveyor/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.Move_Pulled(src)

/obj/machinery/conveyor/power_change()
	. = ..()
	update()

// the conveyor control switch
//
//

/obj/machinery/conveyor_switch
	name = "conveyor switch"
	desc = "A conveyor control switch. You can switch it to one-way with a wrench, or detach it with a crowbar."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	speed_process = TRUE

	var/position = 0			// 0 off, -1 reverse, 1 forward
	var/last_pos = -1			// last direction setting
	var/operated = 1			// true if just operated
	var/oneway = FALSE			// if the switch only operates the conveyor belts in a single direction.
	var/invert_icon = FALSE		// If the level points the opposite direction when it's turned on.

	var/id = "" 				// must match conveyor IDs to control them

/obj/machinery/conveyor_switch/Initialize(mapload, newid)
	. = ..()
	if (newid)
		id = newid
	update_icon()
	LAZYADD(GLOB.conveyors_by_id[id], src)

/obj/machinery/conveyor_switch/Destroy()
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	. = ..()

/obj/machinery/conveyor_switch/vv_edit_var(var_name, var_value)
	if (var_name == "id")
		// if "id" is varedited, update our list membership
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		. = ..()
		LAZYADD(GLOB.conveyors_by_id[id], src)
	else
		return ..()

// update the icon depending on the position

/obj/machinery/conveyor_switch/update_icon()
	if(position<0)
		if(invert_icon)
			icon_state = "switch-fwd"
		else
			icon_state = "switch-rev"
	else if(position>0)
		if(invert_icon)
			icon_state = "switch-rev"
		else
			icon_state = "switch-fwd"
	else
		icon_state = "switch-off"


// timed process
// if the switch changed, update the linked conveyors

/obj/machinery/conveyor_switch/process()
	if(!operated)
		return
	operated = 0

	for(var/obj/machinery/conveyor/C in GLOB.conveyors_by_id[id])
		C.operating = position
		C.update_move_direction()
		C.update_icon()
		CHECK_TICK

// attack with hand, switch position
/obj/machinery/conveyor_switch/interact(mob/user)
	add_fingerprint(user)
	if(position == 0)
		if(oneway)   //is it a oneway switch
			position = oneway
		else
			if(last_pos < 0)
				position = 1
				last_pos = 0
			else
				position = -1
				last_pos = 0
	else
		last_pos = position
		position = 0

	operated = 1
	update_icon()

	// find any switches with same id as this one, and set their positions to match us
	for(var/obj/machinery/conveyor_switch/S in GLOB.conveyors_by_id[id])
		S.invert_icon = invert_icon
		S.position = position
		S.update_icon()
		CHECK_TICK

/obj/machinery/conveyor_switch/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_CROWBAR)
		var/obj/item/conveyor_switch_construct/C = new/obj/item/conveyor_switch_construct(src.loc)
		C.id = id
		transfer_fingerprints_to(C)
		to_chat(user, span_notice("You detach the conveyor switch."))
		qdel(src)

/obj/machinery/conveyor_switch/wrench_act(mob/living/user, obj/item/I)
	if(position)
		to_chat(user, span_warning("\The [src] must be off before attempting to change it's direction!"))
		return FALSE
	oneway = !oneway
	I.play_tool_sound(src, 75)
	user.visible_message(span_notice("[user] sets \the [src] to [oneway ? "one-way" : "two-way"]."), \
				span_notice("You set \the [src] to [oneway ? "one-way" : "two-way"]."), \
				span_italics("You hear a ratchet."))
	return TRUE

/obj/machinery/conveyor_switch/oneway
	icon_state = "conveyor_switch_oneway"
	desc = "A conveyor control switch. It appears to only go in one direction. you can switch it to two way with a wrench, or detach it with a crowbar."
	oneway = TRUE

/obj/machinery/conveyor_switch/oneway/Initialize(mapload)
	. = ..()
	if((dir == NORTH) || (dir == WEST))
		invert_icon = TRUE

/obj/item/conveyor_switch_construct
	name = "conveyor switch assembly"
	desc = "A conveyor control switch assembly."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	w_class = WEIGHT_CLASS_BULKY
	materials = list(/datum/material/iron = 50)
	var/id = "" //inherited by the switch

/obj/item/conveyor_switch_construct/Initialize(mapload)
	. = ..()
	id = "[rand()]" //this couldn't possibly go wrong

/obj/item/conveyor_switch_construct/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity || user.stat || !isfloorturf(A) || istype(A, /area/shuttle))
		return
	var/found = 0
	for(var/obj/machinery/conveyor/C in view())
		if(C.id == src.id)
			found = 1
			break
	if(!found)
		to_chat(user, "[icon2html(src, user)]<span class=notice>The conveyor switch did not detect any linked conveyor belts in range.</span>")
		return
	var/obj/machinery/conveyor_switch/NC = new/obj/machinery/conveyor_switch(A, id)
	transfer_fingerprints_to(NC)
	qdel(src)

/obj/item/conveyor_switch_construct/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		id = "[rand()]"
		to_chat(user, span_notice("You pulse \the [src]'s connection, randomly generating a new network ID."))

/obj/item/stack/conveyor
	name = "conveyor belt assembly"
	desc = "A conveyor belt assembly."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_construct"
	max_amount = 30
	singular_name = "conveyor belt"
	w_class = WEIGHT_CLASS_BULKY
	materials = list(/datum/material/iron = 1000)
	///id for linking
	var/id = ""

/obj/item/stack/conveyor/Initialize(mapload, new_amount, merge = TRUE, _id)
	. = ..()
	id = _id

/obj/item/stack/conveyor/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity || user.stat || !isfloorturf(A) || istype(A, /area/shuttle))
		return
	var/cdir = get_dir(A, user)
	if(A == user.loc)
		to_chat(user, span_warning("You cannot place a conveyor belt under yourself!"))
		return
	var/obj/machinery/conveyor/C = new/obj/machinery/conveyor(A, cdir, id)
	transfer_fingerprints_to(C)
	use(1)

/obj/item/stack/conveyor/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/conveyor_switch_construct))
		to_chat(user, span_notice("You link the switch to the conveyor belt assembly."))
		var/obj/item/conveyor_switch_construct/C = I
		id = C.id
	if(I.tool_behaviour == TOOL_MULTITOOL)
		id = ""
		to_chat(user, span_notice("You unlink the conveyor belt assembly from any switches it's connected to."))

/obj/item/stack/conveyor/update_weight()
	return FALSE

/obj/item/stack/conveyor/thirty
	amount = 30


/obj/item/paper/guides/conveyor
	name = "paper- 'Nano-it-up U-build series, #9: Build your very own conveyor belt, in SPACE'"
	info = "<h1>Congratulations!</h1><p>You are now the proud owner of the best conveyor set available for space mail order! We at Nano-it-up know you love to prepare your own structures without wasting time, so we have devised a special streamlined assembly procedure that puts all other mail-order products to shame!</p><p>Firstly, you need to link the conveyor switch assembly to each of the conveyor belt assemblies. After doing so, you simply need to install the belt assemblies onto the floor, et voila, belt built. Our special Nano-it-up smart switch will detected any linked assemblies as far as the eye can see! This convenience, you can only have it when you Nano-it-up. Stay nano!</p>"
#undef MAX_CONVEYOR_ITEMS_MOVE
