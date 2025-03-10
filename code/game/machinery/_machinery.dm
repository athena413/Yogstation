/*
Overview:
   Used to create objects that need a per step proc call.  Default definition of 'Initialize(mapload)'
   stores a reference to src machine in global 'machines list'.  Default definition
   of 'Destroy' removes reference to src machine in global 'machines list'.

Class Variables:
   use_power (num)
      current state of auto power use.
      Possible Values:
         NO_POWER_USE -- no auto power use
         IDLE_POWER_USE -- machine is using power at its idle power level
         ACTIVE_POWER_USE -- machine is using power at its active power level

   active_power_usage (num)
      Value for the amount of power to use when in active power mode

   idle_power_usage (num)
      Value for the amount of power to use when in idle power mode

   power_channel (num)
      What channel to draw from when drawing power for power mode
      Possible Values:
         AREA_USAGE_EQUIP:0 -- Equipment Channel
         AREA_USAGE_LIGHT:2 -- Lighting Channel
         AREA_USAGE_ENVIRON:3 -- Environment Channel

   component_parts (list)
      A list of component parts of machine used by frame based machines.

   stat (bitflag)
      Machine status bit flags.
      Possible bit flags:
         BROKEN -- Machine is broken
         NOPOWER -- No power is being supplied to machine.
         MAINT -- machine is currently under going maintenance.
         EMPED -- temporary broken by EMP pulse

Class Procs:
   Initialize(mapload)                     'game/machinery/machine.dm'

   Destroy()                   'game/machinery/machine.dm'

   auto_use_power()            'game/machinery/machine.dm'
      This proc determines how power mode power is deducted by the machine.
      'auto_use_power()' is called by the 'master_controller' game_controller every
      tick.

      Return Value:
         return:1 -- if object is powered
         return:0 -- if object is not powered.

      Default definition uses 'use_power', 'power_channel', 'active_power_usage',
      'idle_power_usage', 'powered()', and 'use_power()' implement behavior.

   powered(chan = AREA_USAGE_EQUIP)         'modules/power/power.dm'
      Checks to see if area that contains the object has power available for power
      channel given in 'chan'.

   use_power(amount, chan=AREA_USAGE_EQUIP)   'modules/power/power.dm'
      Deducts 'amount' from the power channel 'chan' of the area that contains the object.

   power_change()               'modules/power/power.dm'
      Called by the area that contains the object when ever that area under goes a
      power state change (area runs out of power, or area channel is turned off).

   RefreshParts()               'game/machinery/machine.dm'
      Called to refresh the variables in the machine that are contributed to by parts
      contained in the component_parts list. (example: glass and material amounts for
      the autolathe)

      Default definition does nothing.

   process()                  'game/machinery/machine.dm'
      Called by the 'machinery subsystem' once per machinery tick for each machine that is listed in its 'machines' list.

   process_atmos()
      Called by the 'air subsystem' once per atmos tick for each machine that is listed in its 'atmos_machines' list.

   is_operational()
		Returns 0 if the machine is unpowered, broken or undergoing maintenance, something else if not

	Compiled by Aygar
*/

/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	desc = "Some kind of machine."
	verb_say = "beeps"
	verb_yell = "blares"
	pressure_resistance = 15
	max_integrity = 200
	layer = BELOW_OBJ_LAYER //keeps shit coming out of the machine from ending up underneath it.

	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT

	var/stat = 0
	var/use_power = IDLE_POWER_USE
		//0 = dont run the auto
		//1 = run auto, use idle
		//2 = run auto, use active
	var/idle_power_usage = 0
	var/active_power_usage = 0
	var/power_channel = AREA_USAGE_EQUIP
		//AREA_USAGE_EQUIP, AREA_USAGE_ENVIRON or AREA_USAGE_LIGHT
	var/wire_compatible = FALSE

	var/list/component_parts = null //list of all the parts used to build it, if made from certain kinds of frames.
	var/works_with_rped_anyways = FALSE //whether it has special RPED behavior despite not having component parts
	var/panel_open = FALSE
	var/state_open = FALSE
	var/critical_machine = FALSE //If this machine is critical to station operation and should have the area be excempted from power failures.
	var/list/occupant_typecache //if set, turned into typecache in Initialize, other wise, defaults to mob/living typecache
	var/atom/movable/occupant = null
	var/speed_process = FALSE // Process as fast as possible?
	var/obj/item/circuitboard/circuit // Circuit to be created and inserted when the machinery is created

	/// What subsystem this machine will use, which is generally SSmachines or SSfastprocess. By default all machinery use SSmachines. This fires a machine's process() roughly every 2 seconds.
	var/subsystem_type = /datum/controller/subsystem/machines

	var/interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_SET_MACHINE
	var/fair_market_price = 69
	var/market_verb = "Customer"
	var/payment_department = ACCOUNT_ENG
	/// For storing and overriding ui id
	var/tgui_id // ID of TGUI interface
	var/climbable = FALSE
	var/climb_time = 20
	var/climb_stun = 20
	var/mob/living/machineclimber

/obj/machinery/Initialize(mapload)
	if(!armor)
		armor = list(MELEE = 25, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 70)
	. = ..()
	GLOB.machines += src

	if(ispath(circuit, /obj/item/circuitboard))
		circuit = new circuit
		circuit.apply_default_parts(src)

	if(!speed_process)
		START_PROCESSING(SSmachines, src)
	else
		START_PROCESSING(SSfastprocess, src)

	if (occupant_typecache)
		occupant_typecache = typecacheof(occupant_typecache)

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/LateInitialize()
	. = ..()
	power_change()
	RegisterSignal(src, COMSIG_ENTER_AREA, PROC_REF(power_change))

/obj/machinery/Destroy()
	GLOB.machines.Remove(src)
	if(!speed_process)
		STOP_PROCESSING(SSmachines, src)
	else
		STOP_PROCESSING(SSfastprocess, src)
	dropContents()
	if(length(component_parts))
		for(var/atom/A in component_parts)
			qdel(A)
		component_parts.Cut()
	return ..()

/obj/machinery/proc/locate_machinery()
	return

/obj/machinery/process()//If you dont use process or power why are you here
	return PROCESS_KILL

/obj/machinery/proc/process_atmos()//If you dont use process why are you here
	return PROCESS_KILL

/obj/machinery/emp_act(severity)
	. = ..()
	if(use_power && !stat && !(. & EMP_PROTECT_SELF))
		use_power(7500/severity)
		new /obj/effect/temp_visual/emp(loc)

/obj/machinery/proc/open_machine(drop = TRUE)
	state_open = TRUE
	density = FALSE
	if(drop)
		dropContents()
	update_icon()
	updateUsrDialog()

/obj/machinery/proc/dropContents(list/subset = null)
	var/turf/T = get_turf(src)
	for(var/atom/movable/A in contents)
		if(subset && !(A in subset))
			continue
		A.forceMove(T)
		if(isliving(A))
			var/mob/living/L = A
			L.update_mobility()
	occupant = null

/obj/machinery/proc/can_be_occupant(atom/movable/am)
	return occupant_typecache ? is_type_in_typecache(am, occupant_typecache) : isliving(am)

/obj/machinery/proc/close_machine(atom/movable/target = null)
	state_open = FALSE
	density = TRUE
	if(!target)
		for(var/am in loc)
			if (!(can_be_occupant(am)))
				continue
			var/atom/movable/AM = am
			if(AM.has_buckled_mobs())
				continue
			if(isliving(AM))
				var/mob/living/L = am
				if(L.buckled || L.mob_size >= MOB_SIZE_LARGE)
					continue
			target = am

	var/mob/living/mobtarget = target
	if(target && !target.has_buckled_mobs() && (!isliving(target) || !mobtarget.buckled))
		occupant = target
		target.forceMove(src)
	updateUsrDialog()
	update_icon()

/obj/machinery/proc/auto_use_power()
	if(!powered(power_channel))
		return 0
	if(use_power == 1)
		use_power(idle_power_usage,power_channel)
	else if(use_power >= 2)
		use_power(active_power_usage,power_channel)
	return 1

/obj/machinery/proc/is_operational()
	return !(stat & (NOPOWER|BROKEN|MAINT))

/obj/machinery/can_interact(mob/user)
	if((stat & (NOPOWER|BROKEN)) && !(interaction_flags_machine & INTERACT_MACHINE_OFFLINE)) // Check if the machine is broken, and if we can still interact with it if so
		return FALSE

	//if(SEND_SIGNAL(user, COMSIG_TRY_USE_MACHINE, src) & COMPONENT_CANT_USE_MACHINE_INTERACT)
	//	return FALSE


	if(IsAdminGhost(user))
		return TRUE //the Gods have unlimited power and do not care for things such as range or blindness

	if(!isliving(user))
		return FALSE //no ghosts allowed, sorry

	var/is_dextrous = FALSE
	if(isanimal(user))
		var/mob/living/simple_animal/user_as_animal = user
		if (user_as_animal.dextrous)
			is_dextrous = TRUE

	if(!issilicon(user) && !is_dextrous && !user.can_hold_items())
		return FALSE //spiders gtfo

	if(issilicon(user)) // If we are a silicon, make sure the machine allows silicons to interact with it
		if(!(interaction_flags_machine & INTERACT_MACHINE_ALLOW_SILICON))
			return FALSE

		if(panel_open && !(interaction_flags_machine & INTERACT_MACHINE_OPEN) && !(interaction_flags_machine & INTERACT_MACHINE_OPEN_SILICON))
			return FALSE

		return user.can_interact_with(src) //AIs don't care about petty mortal concerns like needing to be next to a machine to use it, but borgs do care somewhat

	. = ..()
	if(!.)
		return FALSE

	if(panel_open && !(interaction_flags_machine & INTERACT_MACHINE_OPEN))
		return FALSE

	if(interaction_flags_machine & INTERACT_MACHINE_REQUIRES_SILICON) //if the user was a silicon, we'd have returned out earlier, so the user must not be a silicon
		return FALSE


	var/mob/living/L = user
	if(is_species(L, /datum/species/lizard/ashwalker))
		return FALSE // ashwalkers cant use modern machines

	var/mob/living/carbon/H = user
	if(istype(H) && H.has_dna())
		if (H.dna.check_mutation(ACTIVE_HULK))
			to_chat(H, span_warning("HULK NOT NERD. HULK SMASH!!!"))
			return FALSE // hulks cant use machines

		else if(!Adjacent(user) && !H.dna.check_mutation(TK))
			return FALSE // need to be close or have telekinesis

	return TRUE

/obj/machinery/proc/check_nap_violations()
	if(!SSeconomy.full_ancap)
		return TRUE
	if(occupant && !state_open)
		if(ishuman(occupant))
			var/mob/living/carbon/human/H = occupant
			var/obj/item/card/id/I = H.get_idcard(TRUE)
			if(I)
				var/datum/bank_account/insurance = I.registered_account
				if(!insurance)
					say("[market_verb] NAP Violation: No bank account found.")
					nap_violation(occupant)
					return FALSE
				else
					if(!insurance.adjust_money(-fair_market_price))
						say("[market_verb] NAP Violation: Unable to pay.")
						nap_violation(occupant)
						return FALSE
					var/datum/bank_account/D = SSeconomy.get_dep_account(payment_department)
					if(D)
						D.adjust_money(fair_market_price)
			else
				say("[market_verb] NAP Violation: No ID card found.")
				nap_violation(occupant)
				return FALSE
	return TRUE

/obj/machinery/proc/nap_violation(mob/violator)
	return

////////////////////////////////////////////////////////////////////////////////////////////

//Return a non FALSE value to interrupt attack_hand propagation to subtypes.
/obj/machinery/interact(mob/user, special_state)
	if(interaction_flags_machine & INTERACT_MACHINE_SET_MACHINE)
		user.set_machine(src)
	. = ..()

/obj/machinery/ui_act(action, list/params)
	add_fingerprint(usr)
	return ..()

/obj/machinery/Topic(href, href_list)
	..()
	if(!can_interact(usr))
		return 1
	if(!usr.canUseTopic(src))
		return 1
	add_fingerprint(usr)
	return 0

////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/attack_paw(mob/living/user)
	if(user.a_intent != INTENT_HARM)
		return attack_hand(user)
	else
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		user.visible_message(span_danger("[user.name] smashes against \the [src.name] with its paws."), null, null, COMBAT_MESSAGE_RANGE)
		take_damage(4, BRUTE, MELEE, 1)

/obj/machinery/attack_robot(mob/user)
	if(!(interaction_flags_machine & INTERACT_MACHINE_ALLOW_SILICON) && !IsAdminGhost(user))
		return FALSE
	return _try_interact(user)

/obj/machinery/attack_ai(mob/user)
	if(!(interaction_flags_machine & INTERACT_MACHINE_ALLOW_SILICON) && !IsAdminGhost(user))
		return FALSE
	if(iscyborg(user))// For some reason attack_robot doesn't work
		return attack_robot(user)
	else
		return _try_interact(user)

/obj/machinery/_try_interact(mob/user)
	if((interaction_flags_machine & INTERACT_MACHINE_WIRES_IF_OPEN) && panel_open && (attempt_wire_interaction(user) == WIRE_INTERACTION_BLOCK))
		return TRUE
	if((user.mind?.has_martialart(MARTIALART_BUSTERSTYLE)) && (user.a_intent == INTENT_GRAB)) //buster arm shit since it can throw vendors
		return	
	return ..()

/obj/machinery/CheckParts(list/parts_list)
	..()
	RefreshParts()

/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return

/obj/machinery/proc/default_pry_open(obj/item/I)
	. = !(state_open || panel_open || is_operational() || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message(span_notice("[usr] pries open \the [src]."), span_notice("You pry open \the [src]."))
		open_machine()

/obj/machinery/proc/default_deconstruction_crowbar(obj/item/I, ignore_panel = 0)
	. = (panel_open || ignore_panel) && !(flags_1 & NODECONSTRUCT_1) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		deconstruct(TRUE)

/obj/machinery/deconstruct(disassembled = TRUE, force = FALSE)
	if(!(flags_1 & NODECONSTRUCT_1))
		on_deconstruction()
		if(component_parts && component_parts.len)
			if(!force)
				spawn_frame(disassembled)
			for(var/obj/item/I in component_parts)
				I.forceMove(loc)
			component_parts.Cut()
	qdel(src)

/obj/machinery/proc/spawn_frame(disassembled)
	var/obj/structure/frame/machine/M = new /obj/structure/frame/machine(loc)
	. = M
	M.setAnchored(anchored)
	if(!disassembled)
		M.obj_integrity = M.max_integrity * 0.5 //the frame is already half broken
	transfer_fingerprints_to(M)
	M.state = 2
	M.icon_state = "box_1"

/obj/machinery/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags_1 & NODECONSTRUCT_1))
		stat |= BROKEN
		SEND_SIGNAL(src, COMSIG_MACHINERY_BROKEN, damage_flag)
		update_icon()
		return TRUE
	return FALSE

/obj/machinery/contents_explosion(severity, target)
	if(occupant)
		occupant.ex_act(severity, target)

/obj/machinery/handle_atom_del(atom/A)
	if(A == occupant)
		occupant = null
		update_icon()
		updateUsrDialog()

/obj/machinery/proc/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	if(!(flags_1 & NODECONSTRUCT_1) && I.tool_behaviour == TOOL_SCREWDRIVER)
		I.play_tool_sound(src, 50)
		if(!panel_open)
			panel_open = TRUE
			icon_state = icon_state_open
			to_chat(user, span_notice("You open the maintenance hatch of [src]."))
		else
			panel_open = FALSE
			icon_state = icon_state_closed
			to_chat(user, span_notice("You close the maintenance hatch of [src]."))
		return 1
	return 0

/obj/machinery/proc/default_change_direction_wrench(mob/user, obj/item/I)
	if(panel_open && I.tool_behaviour == TOOL_WRENCH)
		I.play_tool_sound(src, 50)
		setDir(turn(dir,-90))
		to_chat(user, span_notice("You rotate [src]."))
		return 1
	return 0

/obj/proc/can_be_unfasten_wrench(mob/user, silent) //if we can unwrench this object; returns SUCCESSFUL_UNFASTEN and FAILED_UNFASTEN, which are both TRUE, or CANT_UNFASTEN, which isn't.
	if(!(isfloorturf(loc) || istype(loc, /turf/open/indestructible)) && !anchored)
		to_chat(user, span_warning("[src] needs to be on the floor to be secured!"))
		return FAILED_UNFASTEN
	return SUCCESSFUL_UNFASTEN

/obj/proc/default_unfasten_wrench(mob/user, obj/item/I, time = 20) //try to unwrench an object in a WONDERFUL DYNAMIC WAY
	if(!(flags_1 & NODECONSTRUCT_1) && I.tool_behaviour == TOOL_WRENCH)
		var/can_be_unfasten = can_be_unfasten_wrench(user)
		if(!can_be_unfasten || can_be_unfasten == FAILED_UNFASTEN)
			return can_be_unfasten
		if(time)
			to_chat(user, span_notice("You begin [anchored ? "un" : ""]securing [src]..."))
		I.play_tool_sound(src, 50)
		var/prev_anchored = anchored
		//as long as we're the same anchored state and we're either on a floor or are anchored, toggle our anchored state
		if(I.use_tool(src, user, time, extra_checks = CALLBACK(src, PROC_REF(unfasten_wrench_check), prev_anchored, user)))
			to_chat(user, span_notice("You [anchored ? "un" : ""]secure [src]."))
			setAnchored(!anchored)
			playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
			return SUCCESSFUL_UNFASTEN
		return FAILED_UNFASTEN
	return CANT_UNFASTEN

/obj/proc/unfasten_wrench_check(prev_anchored, mob/user) //for the do_after, this checks if unfastening conditions are still valid
	if(anchored != prev_anchored)
		return FALSE
	if(can_be_unfasten_wrench(user, TRUE) != SUCCESSFUL_UNFASTEN) //if we aren't explicitly successful, cancel the fuck out
		return FALSE
	return TRUE

/obj/machinery/proc/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	if(!istype(W))
		return FALSE
	if((flags_1 & NODECONSTRUCT_1) && !W.works_from_distance)
		return FALSE
	var/shouldplaysound = 0
	if(component_parts)
		if(panel_open || W.works_from_distance)
			var/obj/item/circuitboard/machine/CB = locate(/obj/item/circuitboard/machine) in component_parts
			var/P
			if(W.works_from_distance)
				to_chat(user, display_parts(user))
			for(var/obj/item/A in component_parts)
				for(var/D in CB.req_components)
					if(ispath(A.type, D))
						P = D
						break
				for(var/obj/item/B in W.contents)
					if(istype(B, P) && istype(A, P))
						//won't replace beakers if they have reagents in them to prevent funny explosions
						if(istype(B,/obj/item/reagent_containers) && length(B.reagents?.reagent_list)) 
							continue
						// If it's a corrupt or rigged cell, attempting to send it through Bluespace could have unforeseen consequences.
						if(istype(B, /obj/item/stock_parts/cell) && W.works_from_distance)
							var/obj/item/stock_parts/cell/checked_cell = B
							// If it's rigged, max the charge. Then explode it.
							if(checked_cell.rigged)
								checked_cell.charge = checked_cell.maxcharge
								checked_cell.explode()
						if(B.get_part_rating() > A.get_part_rating())
							if(istype(B,/obj/item/stack)) //conveniently this will mean A is also a stack and I will kill the first person to prove me wrong
								var/obj/item/stack/SA = A
								var/obj/item/stack/SB = B
								var/used_amt = SA.get_amount()
								if(!SB.use(used_amt))
									continue //if we don't have the exact amount to replace we don't
								var/obj/item/stack/SN = new SB.merge_type(null,used_amt)
								component_parts += SN
							else
								if(SEND_SIGNAL(W, COMSIG_TRY_STORAGE_TAKE, B, src))
									component_parts += B
									B.moveToNullspace()
							SEND_SIGNAL(W, COMSIG_TRY_STORAGE_INSERT, A, null, null, TRUE)
							component_parts -= A
							to_chat(user, span_notice("[capitalize(A.name)] replaced with [B.name]."))
							shouldplaysound = 1 //Only play the sound when parts are actually replaced!
							break
			RefreshParts()
		else
			to_chat(user, display_parts(user))
		if(shouldplaysound)
			W.play_rped_sound()
		return TRUE
	return FALSE

/obj/machinery/proc/display_parts(mob/user)
	. = list()
	. += span_notice("It contains the following parts:")
	for(var/obj/item/C in component_parts)
		. += span_notice("[icon2html(C, user)] \A [C].")
	. = jointext(., "")

/obj/machinery/examine(mob/user)
	. = ..()
	if(stat & BROKEN)
		. += span_notice("It looks broken and non-functional.")
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			. += span_warning("It's on fire!")
		var/healthpercent = (obj_integrity/max_integrity) * 100
		switch(healthpercent)
			if(50 to 99)
				. += "It looks slightly damaged."
			if(25 to 50)
				. += "It appears heavily damaged."
			if(0 to 25)
				. += span_warning("It's falling apart!")
	if(user.research_scanner && component_parts)
		. += display_parts(user, TRUE)

//called on machinery construction (i.e from frame to machinery) but not on initialization
/obj/machinery/proc/on_construction()
	return

//called on deconstruction before the final deletion
/obj/machinery/proc/on_deconstruction()
	return

/obj/machinery/proc/can_be_overridden()
	. = 1

/obj/machinery/tesla_act(power, tesla_flags, shocked_objects)
	..()
	if((tesla_flags & TESLA_MACHINE_EXPLOSIVE) && !(resistance_flags & INDESTRUCTIBLE))
		if(prob(60))
			ex_act(EXPLODE_DEVASTATE)
		else if (prob(50))
			explosion(src, 1, 2, 4, flame_range = 2, adminlog = FALSE, smoke = FALSE)
	if(tesla_flags & TESLA_OBJ_DAMAGE)
		take_damage(power/2000, BURN, ENERGY)
		if(prob(40))
			emp_act(EMP_LIGHT)

/obj/machinery/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if (AM == occupant)
		occupant = null

/obj/machinery/proc/adjust_item_drop_location(atom/movable/AM)	// Adjust item drop location to a 3x3 grid inside the tile, returns slot id from 0 to 8
	var/md5 = md5(AM.name)										// Oh, and it's deterministic too. A specific item will always drop from the same slot.
	for (var/i in 1 to 32)
		. += hex2num(md5[i])
	. = . % 9
	AM.pixel_x = -8 + ((.%3)*8)
	AM.pixel_y = -8 + (round( . / 3)*8)

/obj/machinery/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && (mover.pass_flags & PASSMACHINES))
		return TRUE

/obj/machinery/proc/end_processing()
	var/datum/controller/subsystem/processing/subsystem = locate(subsystem_type) in Master.subsystems
	STOP_PROCESSING(subsystem, src)

/obj/machinery/proc/begin_processing()
	var/datum/controller/subsystem/processing/subsystem = locate(subsystem_type) in Master.subsystems
	START_PROCESSING(subsystem, src)

/obj/machinery/rust_heretic_act()
	take_damage(500, BRUTE, MELEE, 1)

/obj/machinery/MouseDrop_T(atom/movable/O, mob/user)
	. = ..()
	if(!climbable)
		return
	if(user == O && iscarbon(O))
		var/mob/living/carbon/C = O
		if(C.mobility_flags & MOBILITY_MOVE)
			climb_machine(user)
			return
	if(!istype(O, /obj/item) || user.get_active_held_item() != O)
		return
	if(iscyborg(user))
		return
	if(!user.dropItemToGround(O))
		return
	if (O.loc != src.loc)
		step(O, get_dir(O, src))

/obj/machinery/proc/do_climb(atom/movable/A)
	if(climbable)
		density = FALSE
		. = step(A,get_dir(A,src.loc))
		density = TRUE

/obj/machinery/proc/climb_machine(mob/living/user)
	src.add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] starts climbing onto [src].</span>", \
								"<span class='notice'>You start climbing onto [src]...</span>")
	var/adjusted_climb_time = climb_time
	if(user.restrained()) //climbing takes twice as long when restrained.
		adjusted_climb_time *= 2
	if(isalien(user))
		adjusted_climb_time *= 0.25 //aliens are terrifyingly fast
	if(HAS_TRAIT(user, TRAIT_FREERUNNING)) //do you have any idea how fast I am???
		adjusted_climb_time *= 0.8
	machineclimber = user
	if(do_mob(user, user, adjusted_climb_time))
		if(src.loc) //Checking if structure has been destroyed
			if(do_climb(user))
				user.visible_message("<span class='warning'>[user] climbs onto [src].</span>", \
									"<span class='notice'>You climb onto [src].</span>")
				log_combat(user, src, "climbed onto")
				if(climb_stun)
					var/mob/living/carbon/human/H = user
					var/wagging = FALSE
					if(H && H.dna.species.is_wagging_tail())
						wagging = TRUE
					user.Stun(climb_stun)
					if(wagging)
						H.dna.species.start_wagging_tail(H)
				. = 1
			else
				to_chat(user, "<span class='warning'>You fail to climb onto [src].</span>")
	machineclimber = null

/obj/machinery/CanAStarPass(ID, dir, caller)
	. = ..()
	if(climbable)
		return TRUE
	if(can_be_occupant(caller))
		return TRUE

	
