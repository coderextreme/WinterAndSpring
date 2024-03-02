"tuse strict";

let fs = require("fs");

let LENGTH = 10;

function ProcessJSON(json) {
	let chars = [];
	let timesThrough = 0;
	for (let ch in json) {
		let lines = [];
		let timerout = [];
		//if (timesThrough == 0) {
			// timerout.push("DEF z100sTimer TimeSensor { cycleInterval "+LENGTH+" loop TRUE }");
			// timerout.push("DEF "+ch+"PreludeTimer TimeSensor { cycleInterval 0.005 loop FALSE enabled TRUE }");
			//timerout.push("DEF "+ch+"ActivateSensor ProximitySensor { size 1000000 1000000 1000000 }");
			//timerout.push("ROUTE "+ch+"ActivateSensor.enterTime TO "+ch+"_z100sTimer.startTime");
		//}
		chars.push(ch);
		let chardata = json[ch];
		// lines.push(chardata);
		let charobj = {};
		charobj["timesperchar"] = chardata["TimesPerCharacter"];
		/*
		charobj["timesperchar"].push(LENGTH);
		charobj["timesperchar"].push(LENGTH);
		charobj["timesperchar"].push(LENGTH);
		charobj["timesperchar"].push(LENGTH);
		*/
		charobj["movesperchar"] = chardata["MovesPerCharacter"];
		// These are "standard" animations
		/*
		charobj["movesperchar"].push(ch+"_Pitch01");
		charobj["movesperchar"].push(ch+"_Roll01");
		charobj["movesperchar"].push(ch+"_Kick01");
		charobj["movesperchar"].push(ch+"_Stop01");
		*/
		/*
		let globaltimer = chardata["Global"];
		*/
		// lines.push(chardata["MovesPerCharacter"]);
		// let setMoves = new Set(charobj["movesperchar"]);
		// let sequence = [];
	
		// let movebooleans = [];
		/*
		let globaltimesperchar = [];
		for (let ti in globaltimer) {
			globaltimesperchar.push(globaltimer[ti]) * LENGTH;
			globaltimer[ti] *= LENGTH;  // increase time by an order of magnitude
		}
		*/
		/*
		lines.push("DEF "+ch+"ScalarInterpolator ScalarInterpolator {");
		lines.push("\tkey [ 0.0 1.0 ]"); 
		lines.push("\tkeyValue [ 1.0 0.0 ]"); 
		lines.push("}"); 
		*/
		/*
		lines.push(`DEF convertScript Script {
		  inputOnly SFFloat infloat
		  outputOnly SFBool outbool

		  url "castlescript:
		       function foo(infloat, timestamp)
			 outbool := if (infloat >= 1.0, TRUE, FALSE )
		      "
		}`)
		*/
		/*
		lines.push("DEF "+ch+"ScalarInterpolator ScalarInterpolator {");
		lines.push("\tkey [ "+globaltimer.join(" ")+" ]"); 
		lines.push("\tkeyValue [ "+globaltimesperchar.join(" ")+" ]"); 
		lines.push("}"); 
		lines.push("ROUTE "+ch+"_z100sTimer.fraction_changed TO "+ch+"ScalarInterpolator.set_fraction");
		*/

		/*
		function booleanTranslate(charmove) {
			let movebooleans = chardata[charmove];
			let movedoff = {};
			movedoff[charmove] = true;
			for (let bi in movebooleans) {
				if (movebooleans[bi] === true) {
					movebooleans[bi] = "TRUE";
					movedoff[charmove] = false;
				} else if (movebooleans[bi] === false) {
					movebooleans[bi] = "FALSE";
					movedoff[charmove] = true;
				} else if (movebooleans[bi] === "FALSE") {
					// duplicate computation
				} else if (movebooleans[bi] === "TRUE") {
					// duplicate computation
				} else {
					console.warn(" # Weird boolean in move sequence, setting to FALSE", charmove, movebooleans[bi]);
					movebooleans[bi] = "FALSE";
					movedoff[charmove] = true;
				}
			}
			return movebooleans;
		}
		*/
		function booleanTranslate(charmove) {
			let mpc = charobj["movesperchar"];
			let tpc = charobj["timesperchar"];
			let mpcl = mpc.length;
			let movebooleans = Array.from({length:mpcl}).map(x => "FALSE"); //  booleanTranslate(charmove);
			for (let bi in movebooleans) {
				if (mpc[bi] === charmove) {
					movebooleans[bi] = "TRUE";
				}
			}
			return movebooleans;
		}

		function compressmoves(mpc, tpc) {
			let len = mpc.length;
			let newmpc = [];
			let newtpc = [];
			for (let mvi = 0; mvi < len; mvi++) {
				let charmove = mpc[mvi];
				let acm = mvi;
				let submove = acm;
				let appearingcharmove = charmove+submove;
				let tcm = tpc[acm];

				let nacm = (mvi + 1) % len;
				let ncharmove = mpc[nacm];
				let nsubmove = nacm;
				let nappearingcharmove = ncharmove+nsubmove;
				let ntcm = tpc[nacm];


				let pacm = (mvi - 1 + len) % len;
				let pcharmove = mpc[pacm];
				let psubmove = pacm;
				let pappearingcharmove = pcharmove+psubmove;
				let ptcm = tpc[pacm];
				if (charmove === pcharmove) {
					if (mvi === 0) {
						console.error("mvi === 0", mvi, charmove, pcharmove);
						newmpc.push(charmove);
						newtpc.push(tcm);
					} else if (mvi === 1) {
						console.error("mvi === 1", "Do nothing", mvi, charmove, pcharmove);
					} else if (mvi === 2) {
						console.error("mvi === 2", "Do nothing", mvi, charmove, pcharmove);
					} else if (mvi < len - 1 && mvi > 0) {
						console.error("mvi < len - 1 && mvi > 0", "modify previous", mvi-1, tcm, charmove, pcharmove);
						newtpc[newtpc.length-1] = tcm;
					} else if (mvi === len - 1) {
						console.error("mvi === len - 1", "need two moves at end", mvi-1, tcm, charmove, pcharmove);
						// newtpc[newtpc.length-1] = tcm;
						newmpc.push(charmove);
						newtpc.push(tcm);
					} else {
						console.error("WTF?", mvi, charmove, pcharmove);
					}
				} else {
					newmpc.push(charmove);
					newtpc.push(tcm);
				}
			}
			charobj["movesperchar"] = newmpc;
			charobj["timesperchar"] = newtpc;
		}
		compressmoves(charobj["movesperchar"], charobj["timesperchar"]);

		let len = charobj["movesperchar"].length;
		for (let mvi = 0; mvi < len; mvi++) {
			let charmove = charobj["movesperchar"][mvi];
			let acm = mvi;
			let submove = acm;
			let appearingcharmove = charmove+submove;

			let nacm = (mvi + 1) % len;
			let ncharmove = charobj["movesperchar"][nacm];
			let nsubmove = nacm;
			let nappearingcharmove = ncharmove+nsubmove;

			let pacm = (mvi - 1 + len) % len;
			let pcharmove = charobj["movesperchar"][pacm];
			let psubmove = pacm;
			let pappearingcharmove = pcharmove+psubmove;

			let ctl = charobj["timesperchar"].length;
			// let movebooleans = booleanTranslate(charmove);
			let movebooleans = Array.from({length:ctl}).map(x => "FALSE"); //  booleanTranslate(charmove);
			movebooleans[submove] = "TRUE";
				
			console.log(charmove, JSON.stringify(movebooleans), JSON.stringify(charobj["movesperchar"]), JSON.stringify(charobj["timesperchar"]));
			let cycleInterval = [];
			let current = [];
			let next = [];
			let prev = [];
			for (let cti = 0; cti < ctl; cti++) {
				current.push(charobj["timesperchar"][cti] * LENGTH);
				next.push(charobj["timesperchar"][(cti+1) % ctl] * LENGTH);
				if (movebooleans[cti] === "TRUE") {
					if (cti === ctl - 1) {
						cycleInterval.push(0.01);
					} else {
						cycleInterval.push(next[next.length-1] - current[current.length-1]);
					}
				} else {
					cycleInterval.push(0);
				}
			}
			timerout.push("# DEF "+appearingcharmove+"Timer TimeSensor { cycleInterval "+cycleInterval[mvi]+" loop TRUE enabled TRUE } # "+next[mvi] / LENGTH+" - "+current[mvi] / LENGTH+" = "+ cycleInterval[mvi] / LENGTH+", times "+LENGTH+" is "+cycleInterval[mvi]);

			// Now define when moves are active or not
			lines.push("DEF "+appearingcharmove+"BooleanSequencer BooleanSequencer {");
			if (typeof movebooleans !== 'undefined') {
				lines.push("\tkey [ "+charobj["timesperchar"].join(" ")+" ]"); 
				lines.push("\tkeyValue [ "+movebooleans.join(" ")+" ]"); 
			}
			lines.push("\t# [ "+charobj["movesperchar"].join(" ")+" ]"); 
			lines.push("}"); 
			lines.push("DEF "+appearingcharmove+"SPLITTERBooleanFilter BooleanFilter { }");
			lines.push("DEF "+appearingcharmove+"FINALEBooleanFilter BooleanFilter { }");
			lines.push("DEF "+appearingcharmove+"NEGATERBooleanFilter BooleanFilter { }");
			// lines.push("DEF "+appearingcharmove+"BooleanFilter BooleanFilter { }");
			lines.push("DEF "+appearingcharmove+"OffTimeTrigger TimeTrigger { }");
			lines.push("DEF "+appearingcharmove+"OnTimeTrigger TimeTrigger { }");

			if (mvi === 0) {
				// lines.push("ROUTE Everything_Touch.touchTime TO "+appearingcharmove+"Timer.startTime");
				//lines.push("ROUTE "+ch+"PreludeTimer.cycleTime TO "+appearingcharmove+"Timer.set_startTime");
				// lines.push("ROUTE "+ch+"PreludeTimer.cycleTime TO "+ch+"_z100sTimer.set_startTime");
				// lines.push("ROUTE "+ch+"_z100sTimer.cycleTime TO "+appearingcharmove+"Timer.set_startTime");
				// lines.push("ROUTE "+ch+"_z100sTimer.isActive TO "+ch+"_z100sTimer.set_enabled");
				lines.push("ROUTE "+ch+"_z100sTimer.isActive TO "+appearingcharmove+"SPLITTERBooleanFilter.set_boolean");
			} else if (mvi === len - 1) {
				// turn off animation
				lines.push("ROUTE "+ch+"_z100sTimer.cycleTime TO "+appearingcharmove+"Timer.set_stopTime");
				lines.push("ROUTE "+ch+"_z100sTimer.isActive TO "+appearingcharmove+"Timer.set_enabled");
				lines.push("DEF "+appearingcharmove+"FINALETimeTrigger TimeTrigger { }");
			 	lines.push("ROUTE "+appearingcharmove+"FINALEBooleanFilter.inputFalse TO "+appearingcharmove+"FINALETimeTrigger.set_boolean");
				lines.push("ROUTE "+appearingcharmove+"FINALETimeTrigger.triggerTime TO "+appearingcharmove+"Timer.set_stopTime");
			}
			lines.push("ROUTE "+ch+"_z100sTimer.fraction_changed TO "+appearingcharmove+"BooleanSequencer.set_fraction");
			lines.push("ROUTE "+appearingcharmove+"BooleanSequencer.value_changed TO "+appearingcharmove+"SPLITTERBooleanFilter.set_boolean");
			lines.push("ROUTE "+appearingcharmove+"SPLITTERBooleanFilter.inputTrue TO "+appearingcharmove+"OnTimeTrigger.set_boolean");
			lines.push("ROUTE "+appearingcharmove+"SPLITTERBooleanFilter.inputFalse TO "+appearingcharmove+"OffTimeTrigger.set_boolean");
			lines.push("ROUTE "+appearingcharmove+"SPLITTERBooleanFilter.inputTrue TO "+appearingcharmove+"Timer.set_enabled");
			lines.push("ROUTE "+appearingcharmove+"SPLITTERBooleanFilter.inputFalse TO "+appearingcharmove+"Timer.set_enabled");
			lines.push("ROUTE "+appearingcharmove+"OffTimeTrigger.triggerTime TO "+appearingcharmove+"Timer.set_stopTime");
			lines.push("ROUTE "+appearingcharmove+"OnTimeTrigger.triggerTime TO "+appearingcharmove+"Timer.set_startTime");
		}
		lines.push("###########################################################################################");
		for (let mvi = 0; mvi < len; mvi++) {
			let charmove = charobj["movesperchar"][mvi];
			let acm = mvi;
			let submove = acm;
			let appearingcharmove = charmove+submove;

			let nacm = (mvi + 1) % len;
			let ncharmove = charobj["movesperchar"][nacm];
			let nsubmove = nacm;
			let nappearingcharmove = ncharmove+nsubmove;

			let pacm = (mvi - 1 + len) % len;
			let pcharmove = charobj["movesperchar"][pacm];
			let psubmove = pacm;
			let pappearingcharmove = pcharmove+psubmove;

			lines.push("ROUTE "+appearingcharmove+"Timer.stopTime TO "+nappearingcharmove+"Timer.set_startTime");
			// lines.push("ROUTE "+appearingcharmove+"Timer.cycleTime TO "+nappearingcharmove+"Timer.startTime");
			lines.push("ROUTE "+appearingcharmove+"Timer.isActive TO "+nappearingcharmove+"NEGATERBooleanFilter.set_boolean");
			lines.push("ROUTE "+nappearingcharmove+"NEGATERBooleanFilter.inputNegate TO "+appearingcharmove+"BooleanSequencer.next");
		}
		timesThrough++;
		let str = lines.join("\r\n")+"\r\n";
		fs.writeFileSync("takes."+ch+".txt", str);
		let timersout = timerout.join("\r\n")+"\r\n";
		fs.writeFileSync("takes."+ch+".timers.txt", timersout);
	}
}
//var content = fs.readFileSync(__dirname + '/takes.json').toString();
//var json = JSON.parse(content);
//ProcessJSON(json);

var content = '';
// read content into buffer
process.stdin.resume();
process.stdin.on('data', function(buf) { content += buf.toString(); });

process.stdin.on('end', function() {
	var json = JSON.parse(content);
	ProcessJSON(json);
});
