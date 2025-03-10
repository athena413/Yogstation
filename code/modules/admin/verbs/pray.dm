/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."), confidential=TRUE)
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return
	log_prayer("[src.key]/([src.name]): [msg]")
	if(usr.client)
		if(usr.client.prefs.muted & MUTE_PRAY)
			to_chat(usr, span_danger("You cannot pray (muted)."), confidential=TRUE)
			return
		if(src.client.handle_spam_prevention(msg,MUTE_PRAY))
			return

	var/mutable_appearance/cross = mutable_appearance('icons/obj/storage.dmi', "bible")
	var/font_color = "purple"
	var/prayer_type = "PRAYER"
	var/deity
	if(usr.job == "Chaplain")
		cross.icon_state = "kingyellow"
		font_color = "blue"
		prayer_type = "CHAPLAIN PRAYER"
		if(GLOB.deity)
			deity = GLOB.deity
	else if(iscultist(usr))
		cross.icon_state = "tome"
		font_color = "red"
		prayer_type = "CULTIST PRAYER"
		deity = "Nar'sie"
	else if(isliving(usr))
		var/mob/living/L = usr
		if(HAS_TRAIT(L, TRAIT_SPIRITUAL))
			cross.icon_state = "holylight"
			font_color = "blue"
			prayer_type = "SPIRITUAL PRAYER"

	var/msg_tmp = msg
	msg = span_adminnotice("[icon2html(cross, GLOB.permissions.admins)]<b><font color=[font_color]>[prayer_type][deity ? " (to [deity])" : ""]: </font>[ADMIN_FULLMONTY(src)] [ADMIN_SC(src)]:</b> [msg]")

	for(var/client/C in GLOB.permissions.admins)
		if(C.prefs.chat_toggles & CHAT_PRAYER)
			to_chat(C, msg, confidential=TRUE)
			if(C.prefs.toggles & SOUND_PRAYERS)
				if(usr.job == "Chaplain")
					SEND_SOUND(C, sound('sound/effects/pray.ogg'))
	to_chat(usr, span_info("You pray to the gods: \"[msg_tmp]\""), confidential=TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Prayer") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	//log_admin("HELP: [key_name(src)]: [msg]")

/// Used by communications consoles to message CentCom
/proc/message_centcom(text, mob/sender)
	var/msg = copytext_char(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = span_adminnotice("<b><font color=orange>CENTCOM:</font>[ADMIN_FULLMONTY(sender)] [ADMIN_CENTCOM_REPLY(sender)]:</b> [msg]")
	to_chat(GLOB.permissions.admins, msg, confidential = TRUE)
	for(var/obj/machinery/computer/communications/console in GLOB.machines)
		console.override_cooldown()

/// Used by communications consoles to message the Syndicate
/proc/message_syndicate(text, mob/sender)
	var/msg = copytext_char(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = span_adminnotice("<b><font color=crimson>SYNDICATE:</font>[ADMIN_FULLMONTY(sender)] [ADMIN_SYNDICATE_REPLY(sender)]:</b> [msg]")
	to_chat(GLOB.permissions.admins, msg, confidential = TRUE)
	for(var/obj/machinery/computer/communications/console in GLOB.machines)
		console.override_cooldown()

/// Used by the red phone to message the Syndicate
/// Specifies CENTCOM/SYNDICATE: to indicate both receive the message
/proc/message_redphone_syndicate(text, mob/sender)
	var/msg = copytext_char(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = span_adminnotice("<b><font color=orange>CENTCOM</font>/<font color=crimson>SYNDICATE:</font>[ADMIN_FULLMONTY(sender)] [ADMIN_SYNDICATE_REPLY(sender)]:</b> [msg]")
	to_chat(GLOB.permissions.admins, msg, confidential = TRUE)
	for(var/obj/machinery/computer/communications/console in GLOB.machines)
		console.override_cooldown()

/// Used by communications consoles to request the nuclear launch codes
/proc/nuke_request(text, mob/sender)
	var/msg = copytext_char(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = span_adminnotice("<b><font color=orange>NUKE CODE REQUEST:</font>[ADMIN_FULLMONTY(sender)] [ADMIN_CENTCOM_REPLY(sender)] [ADMIN_SET_SD_CODE] [ADMIN_SET_BC_CODE]:</b> [msg]")
	to_chat(GLOB.permissions.admins, msg, confidential = TRUE)
	for(var/obj/machinery/computer/communications/console in GLOB.machines)
		console.override_cooldown()

/proc/Clown_announce(text , mob/Sender)
	var/msg = copytext_char(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = span_adminnotice("<b><font color=violet>CLOWN PLANET:</font>[ADMIN_FULLMONTY(Sender)] [ADMIN_SYNDICATE_REPLY(Sender)]:</b> [msg]")
	to_chat(GLOB.permissions.admins, msg, confidential=TRUE)
	for(var/obj/machinery/computer/communications/C in GLOB.machines)
		C.override_cooldown()
