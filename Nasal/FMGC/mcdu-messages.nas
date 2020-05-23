# A3XX FMGC MCDU Message Generator and Control
# Copyright (c) 2020 Josh Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

var TypeIMessage = {
	new: func(msgText) {
		var msg = { parents: [TypeIMessage] };
		msg.msgText = msgText;
		msg.colour = "wht";
		return msg;
	},
};

var TypeIIMessage = {
	new: func(msgText, colour = "wht", isInhibit = 0) {
		var msg = { parents: [TypeIIMessage] };
		msg.msgText = msgText;
		msg.colour = colour;
		msg.inhibitable = isInhibit;
		return msg;
	},
};

var MessageQueueController = {
	new: func() {
		var msgC = { parents: [MessageQueueController] };
		return msgC;
	},
	messages: std.Vector.new(), # show left to right
	# first in first out
	addNewMsg: func(msg) {
		if (me.messages.size() < 5) {
			if (!me.messages.contains(msg)) {
				me.messages.append(x);
			}
		}
	},
	getNextMsg: func() {
		if (me.messages.size() >= 1) {
			me.messages.pop(0);
		}
	},
	clearQueue: func() {
		me.messages.clear();
	},
};

var scratchpadController = {
	new: func(mcdu) {
		var sp = { parents: [scratchpadController] };
		sp.scratchpad = "";
		sp.scratchpadSave = "";
		sp.scratchpadColour = "wht";
		sp.showTypeIMsg = 0;
		sp.showTypeIIMsg = 0;
		sp.mcdu = mcdu;
		return sp;
	},
	
	addChar: func(character) {
		if (size(me.scratchpad) >= 22) {
			return;
		}
		
		# any shown type ii is hidden
		if (me.showTypeIIMsg) {
			me.clearTypeII();
		}
		
		# any shown type i is hidden
		if (me.showTypeIMsg) {
			me.clearTypeI();
		}
		
		me.scratchpad = me.scratchpad ~ character;
		me.update();
	},
	showTypeI: func(msg) {
		# any shown type ii is hidden
		if (me.showTypeIIMsg) {
			me.clearTypeII();
		}
		
		me.showTypeIMsg = 1;
		
		# save any data entered
		me.scratchpadSave = me.scratchpad;
		
		me.scratchpad = msg.msgText;
		me.scratchpadColour = msg.colour;
		me.update();
	},
	showTypeII: func(msg) {
		# only show if scratchpad empty
		if (me.scratchpad = "") {
			me.showTypeIIMsg = 1;
			me.scratchpad = msg.msgText;
			me.scratchpadColour = msg.colour;
		}
		me.update();
	},
	clearTypeI: func() {
		me.scratchpad = me.scratchpadSave;
		me.scratchpadSave = nil;
		me.showTypeIMsg = 0;
		me.update();
	},
	clearTypeII: func() {
		me.showTypeIIMsg = 0;
		me.empty();
		me.update();
	},
	override: func(str) {
		if (me.scratchpad == "USING COST INDEX N") {
			me.scratchpad = "USING COST INDEX " ~ str;
			me.update();
		}
	},
	empty: func() {
		me.scratchpad = "";
		me.update();
	},
	clear: func() {
		if (me.scratchpad == "CLR") {
			me.empty();
		} elsif (me.showTypeIMsg) {
			me.clearTypeI();
		} elsif (!me.showTypeIIMsg) {
			me.scratchpad = left(me.scratchpad, size(me.scratchpad) - 1);
		} else {
			me.clearTypeII();
		}
		me.update();
	},
	update: func() {	
		if (me.mcdu == 1) {
			canvas_mcdu.MCDU_1.updateScratchpadCall();
		} else {
			canvas_mcdu.MCDU_2.updateScratchpadCall();
		}
	},
};

var MessageController = {
	typeIMessages: std.Vector.new([
		TypeIMessage.new("AOC DISABLED"),TypeIMessage.new("AWY/WPT MISMATCH"),TypeIMessage.new("DIR TO IN PROGRESS"),
		TypeIMessage.new("ENTRY OUT OF RANGE"),TypeIMessage.new("FORMAT ERROR"),TypeIMessage.new("INSERT/ERASE TMPY FIRST"),
		TypeIMessage.new("LIST OF 20 IN USE"),TypeIMessage.new("PILOT ELEMENT RETAINED"),TypeIMessage.new("NOT ALLOWED"),
		TypeIMessage.new("NOT IN DATA BASE"),TypeIMessage.new("ONLY SPD ENTRY ALLOWED"),TypeIMessage.new("REVISION IN PROGRESS"),
		TypeIMessage.new("TMPY F-PLN EXISTS"),TypeIMessage.new("SELECT DESIRED SYSTEM"),TypeIMessage.new("SELECT HDG/TRK FIRST"),
		TypeIMessage.new("USING COST INDEX N"),TypeIMessage.new("WAIT FOR SYSTEM RESPONSE"),
	]),
	typeIIMessages: std.Vector.new([
	
	]),

	getTypeIMsgByText: func(text) {
		return me.getMsgByText(text, me.typeIMessages.vector);
	},
	getTypeIIMsgByText: func(text) {
		return me.getMsgByText(text, me.typeIIMessages.vector);
	},
	getMsgByText: func(text, theVector) {
		foreach (var message; theVector) {
			if (message.msgText = text) {
				return message;
			}
		}
		return nil;
	},
};

var scratchpads = [scratchpadController.new(1), scratchpadController.new(2)];