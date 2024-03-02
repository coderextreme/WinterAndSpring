let Matrix = require("./matrix.js");
let fs = require("fs");

// Apply transforms in X3D JSON to Humanoids
// STDIN,process.stdin -- the skeleton in X3D JSON format
// STDOUT -- Joint centers file

var jointList = [];
var jointMap = {};

let output = [];
const println = function (msg, outputBuffer) {
	if (outputBuffer) {
		outputBuffer.push(msg);
	} else {
		output.push(msg);
	}
}

function convertTransformsToCenters(json) {
	let LDNodeList = [];
	let LDNode = initializeLDNode(json, "X3D");
	LDNodeList.push(LDNode);
	LDNodeList = toNormals(json, LDNodeList, LDNode);
	if (LDNodeList !== null) {
		let lefttransform = new Matrix().identity();
		let righttransform = new Matrix().identity();
		//console.warn("right before", righttransform);
		transformLDNodesToTriangles(LDNodeList[0], lefttransform, righttransform);
		//console.warn("right after", righttransform);
	} else {
		console.error("toNormals failed");
	}
}


function initializeLDNode(json, obj) {
	let LDNode = {};
	LDNode.USE = json[obj]["@USE"];
	LDNode.DEF = json[obj]["@DEF"];
	LDNode.nodeName = obj;
	return LDNode;
}
function findLDNodeInList(use, LDNodeList) {
	if (typeof use !== 'undefined') {
		for (var g in LDNodeList) {
			var LDNode = LDNodeList[g];
			if (LDNode.DEF === use) {
				// console.error("Found USE", use, "returning", LDNode);
				return LDNode;
			}
		}
	}
	return null;
}

function rotateAroundShoulder (LDNode, shoulder) {
	let childCenter = LDNode.center;
	/*
	let shoulderCenter = shoulder.center;
	let childMatrix = new Matrix(LDNode.center);
	let shoulderMatrix = new Matrix(shoulder.center);
	console.error(shoulder.name, shoulderMatrix.toString().trim());
	console.error(LDNode.name, childMatrix.toString().trim());
	// shift LCS to shoulder
	let translateLCSToShoulder = new Matrix(shoulderCenter).negate().translation();
	console.error(LDNode.name, shoulder.name, "LCSToShoulder\n", translateLCSToShoulder.toString());
	**/



	/*if (LDNode.angles["Z"] != 0) {
		LDNode.rotation = Matrix.rotZ(Matrix.degToRad(LDNode.angles["Z"]));
		console.error("Rotation\n", LDNode.rotation.toString());
	}*.



	/*
	// shift shoulder to LCS
	let translateShoulderToLCS = new Matrix(shoulderCenter).translation();
	console.error(LDNode.name, shoulder.name, "ShoulderToLCS\n", translateShoulderToLCS.toString());
	LDNode.partial = translateLCSToShoulder.matmatmult(LDNode.quaternion)
	if (!LDNode.partial) {
		throw new String("Bad computation");
	}
	console.error(LDNode.name, shoulder.name, "partial\n", LDNode.partial.toString());
	LDNode.rotationFromShoulder = LDNode.partial.matmatmult(translateShoulderToLCS);
	console.error(LDNode.name, shoulder.name, "Total\n", LDNode.rotationFromShoulder.toString());
	*/

	return LDNode.rotation;
}

function findShoulder(LDNode) {
	if (!LDNode) {
		return false;
	} else if (!LDNode.name) {
		return false;
	} else if (LDNode.name.endsWith("shoulder")) {
		return LDNode;
	} else if (LDNode.parent) {
		return findShoulder(LDNode.parent);
	} else {
		return false;
	}
}
function toNormals(json, LDNodeList, ParentNode) {
	var LDNode = LDNodeList.length === 0 ? null : LDNodeList[LDNodeList.length-1];
	var nodeDispatchTable = {
		HAnimJoint : function(obj, LDNode) {
			LDNode.kid = true;
			LDNode.geometry = true;
			LDNode.child = "HAnimJoint";
			LDNode.parent = ParentNode;
		},
		Transform : function(obj, LDNode) {
			LDNode.kid = true;
			LDNode.geometry = true;
			LDNode.child = "Transform";
			LDNode.parent = ParentNode;
		}
	}
	var fieldDispatchTable = {
		"@center" : function(obj, LDNode) {
			LDNode.center = new Matrix(...obj);
			console.warn("center is", LDNode.center);
			// go from A pose to I pose
			/*
			let shoulder = findShoulder(LDNode);
			LDNode.angles = { "X": 0, "Y": 0, "Z": 0 };
			if (LDNode.name.startsWith("l_shoulder")) {
				LDNode.angles["Z"] = 40;
			} else if (LDNode.name.startsWith("r_shoulder")) {
				LDNode.angles["Z"] = -40;
			}
			if (shoulder) {
				LDNode.rotation = rotateAroundShoulder(LDNode, shoulder);
			}*/
		},
		"@name" : function(obj, LDNode) {
			LDNode.name = obj;
		},
		"@scale" : function(obj, LDNode) {
			LDNode.scale = new Matrix(...obj).scale();
			// console.error("Scaling", LDNode.scale);
		},
		"@rotation" : function(obj, LDNode) {
			// not used
			LDNode.rotation = new Matrix(...obj);
			LDNode.quaternion = new Matrix(...obj).quaternion();
			console.error("Rotating", LDNode.quaternion);
		},
		"@translation" : function(obj, LDNode) {
			LDNode.translation = new Matrix(...obj).translation();
			// console.error("Translating", LDNode.translation);
		}
	}
	for (var obj in json) {
		if (typeof nodeDispatchTable[obj] !== 'undefined') {
			var LDNode = findLDNodeInList(json[obj]["@USE"], LDNodeList);
			if (LDNode === null) {
				LDNode = initializeLDNode(json, obj);
				LDNodeList.push(LDNode);
				nodeDispatchTable[obj](json[obj], LDNode); // further initialization
			}
			if (LDNode.child) {
				ParentNode[LDNode.child] = LDNode;
			}
			if (LDNode.kid) {
				if (typeof ParentNode.kids === 'undefined') {
					ParentNode.kids = [];
				}
				if (ParentNode !== LDNode) {
					ParentNode.kids.push(LDNode);
				}
			}
		}
		// TODO do center first, before name
		// Assume @name gets processed before @center
		if (typeof fieldDispatchTable[obj] !== 'undefined') {
			fieldDispatchTable[obj](json[obj], LDNode);
		}
		if (typeof json[obj] === 'object') {
			LDNodeList = toNormals(json[obj], LDNodeList, LDNode);
		}
	}
	return LDNodeList;
}

function trim(axis, number, multiLine, unit, pad) {
	let backupNum = number;
	try {
		number = parseFloat(number).toFixed(4).replace(/0*$/, "").replace(/\.$/, "");
	} catch (e) {
		console.error(e);
		number = backupNum;
	}
	pad = pad && number >=  0 ? " ": "";
	number += isNaN(number) ? " (Not a number)" : "";
	if (multiLine) {
		number = [axis+":"+pad, number, unit].join(" ");
	}
	return number;
}

function printRotation(prefix, radians, multiLine, unit, pad, fn) {
	let angle = radians;
	// console.error("oops", prefix, radians);
	try {
		angle = parseFloat(angle);
		//angle = Matrix.degToRad(angle);
		let x = fn(angle);
		if (isNaN(x)) {
			console.error("NaN, 1, guys", angle, fn);
			throw "Problems with " + fn + " in printRotation, detail:" + angle;
		}
		angle = Matrix.radToDeg(angle);
		angle = angle.toFixed(4).replace(/0*$/, "").replace(/\.$/, "");
	} catch (e) {
		console.error(e);
		unit = "radians";
		angle = radians;
		try {
			angle = angle.toFixed(4).replace(/0*$/, "").replace(/\.$/, "");
		} catch (f) {
			console.error(f);
		}
	}
	return trim(prefix, angle, multiLine, unit, pad).trim();
}

function printJoint(LDNode, origpoint, point, outputBuffer, what) {
	// console.error(LDNode.name);
	console.error("Original", what, origpoint.toString())
	console.error("Final", what, point.toString());

	if (!outputBuffer) {
		outputBuffer = output;
	}

	var multiLine = true;
	if (typeof LDNode.name === 'undefined') {
		if (typeof LDNode.DEF === 'undefined') {
			console.error("This node needs a name or a DEF, bailing", LDNode);
			return false;
		} else {
			LDNode.name = LDNode.DEF;
			if (!LDNode.name.startsWith("Toddler_")) {
				LDNode.DEF = "Toddler_"+LDNode.DEF
			}
		}
	}
	println(LDNode.name, outputBuffer);
	if (multiLine) {
		println("Location", outputBuffer);
	}
	let pad = point[0] < 0 || point[1] < 0 || point[2] < 0;
	println(([
		trim("X", point[0], multiLine, "m", pad),
		trim("Y", point[1], multiLine, "m", pad),
		trim("Z", point[2], multiLine, "m", pad)]).join(multiLine ? "\r\n" : ","), outputBuffer);
	if (multiLine) {
		println("", outputBuffer);
		// point = LDNode.angles;
		/*
		println("ROTATION", outputBuffer);
		point = LDNode.rotation
		let axes = ["X", "Y", "Z"];
		if (!point) {
			point = { "X": 0, "Y": 0, "Z": 0 };
		} else {
			point = { "X": point[0], "Y": point[1], "Z": point[2] };
		}
		pad = point[0] < 0 || point[1] < 0 || point[2] < 0;
		for (let i = 0; i < 3; i++) {
			console.log(printRotation(axes[i], point[axes[i]], multiLine, "°", pad, Math.asin));
		}
		*/
		println("____________________________________", outputBuffer);
		println("", outputBuffer);
	}
	return true;
}

function transformLDNodesToTriangles(LDNode, parentLeftTransform, parentRightTransform) {
	let dispatchTable = {
		HAnimJoint: function(LDNode, lefttransform, righttransform) {
			let origpoint = LDNode.center;
			if (typeof origpoint === 'undefined') {
				console.error("center is undefined in HAnimJoint dispatchTable.HAnimJoint, DEF:", LDNode.DEF);
				return false;
			} else {
				console.warn("In center", JSON.stringify(LDNode.center));
				console.warn("In point (center)", JSON.stringify(origpoint));
				// TODO, we don't need a transform
				// let point = lefttransform.matvecmult(origpoint.col(3)).vecmatmult(righttransform);
				point = origpoint; // for now
				console.warn("Out center", JSON.stringify(point));
				if (!printJoint(LDNode, origpoint, point, output, "center")) {
					console.error("Failed to print HAnimJoin joint to output", LDNode);
				}

				let jointData = [];
				if (!printJoint(LDNode, origpoint, point, jointData, "translation")) {
					console.error("Failed to print HAnimJoint jointData", LDNode);
				} else {
					jointMap[LDNode.name] = jointData;
					console.warn("here's jointData", LDNode.name, jointData);
				}

				// TODO assign transformed center to LDNode.
				if (typeof LDNode.name === 'undefined') {
					LDNode.name = LDNode.DEF;
				}
			}
			return true;
		},
		Transform: function(LDNode, lefttransform, righttransform) {
			let origtrans = LDNode.translation;
			if (typeof origtrans === 'undefined') {
				console.error("translation is undefined in Transform dispatchTable.Transform, DEF:", LDNode.DEF);
				return false;
			} else {
				console.warn("Start");
				console.warn("---left", JSON.stringify(lefttransform));
				console.warn("---In translation", JSON.stringify(origtrans.col(3)));
				let trans = lefttransform.matvecmult(origtrans.col(3)).vecmatmult(righttransform);
				console.warn("---right", JSON.stringify(righttransform));
				console.warn("---Out translation", JSON.stringify(trans));
				// TODO, don't assign to center now
				// LDNode.center = trans;
				// console.warn("---normalized is", trans.normalize());
				if (!printJoint(LDNode, origtrans.col(3), trans, output, "translation")) {
					console.error("Failed to print Transform joint to output", LDNode);
				}
				console.warn("End");

				let jointData = [];
				if (!printJoint(LDNode, origtrans.col(3), trans, jointData, "translation")) {
					console.error("Failed to print Transform joint to jointData", LDNode);
				} else {
					jointMap[LDNode.name] = jointData;
					console.warn("here's jointData", LDNode.name, jointData);
				}
				if (typeof LDNode.name === 'undefined') {
					LDNode.name = LDNode.DEF;
				}
			}
			return true;
		}
	};
	for (var k in LDNode.kids) {
		let CNode = LDNode.kids[k];
		// console.warn(CNode.DEF, LDNode.DEF, "starting loop before copy 2", parentRightTransform);
		let lefttransform = parentLeftTransform.copy();
		let righttransform = parentRightTransform.copy();
		//console.warn(CNode.DEF, LDNode.DEF, "ending loop after copy 2", righttransform);

		if (CNode.translation) {
			lefttransform = lefttransform.matmatmult(CNode.translation);
		}
		if (CNode.rotation) {
			// using quaternion TODO
			//lefttransform = lefttransform.matmatmult(CNode.rotation);
		}
		if (CNode.quaternion) {
			lefttransform = lefttransform.matmatmult(CNode.quaternion);
			//console.warn(CNode.DEF, LDNode.DEF, "quaternion before 2", righttransform);
			//console.warn(CNode.DEF, LDNode.DEF, "CNode.quaternion before 4", CNode.quaternion);
			let copy = CNode.quaternion.copy();
			//console.warn(CNode.DEF, LDNode.DEF, "CNode.quaternion middle 4", CNode.quaternion);
			let invquaternion = copy.invertquaternion();
			//console.warn(CNode.DEF, LDNode.DEF, "invquaternion before 5", invquaternion);
			righttransform  = invquaternion.matmatmult(righttransform);
			//console.warn(CNode.DEF, LDNode.DEF, "invquaternion after 5", invquaternion);
			//console.warn(CNode.DEF, LDNode.DEF, "CNode.quaternion after 4", CNode.quaternion);
			//console.warn(CNode.DEF, LDNode.DEF, "quaternion after 2", righttransform);
		}
		if (CNode.scale) {
			lefttransform = lefttransform.matmatmult(new Matrix(CNode.scale));
		}
		// console.error("Scale transform", transform);
		// only print out geometry
		//console.warn(CNode.DEF, LDNode.DEF, "right before 1", righttransform);
		if (CNode.geometry) {
			//console.warn(CNode.DEF, LDNode.DEF, "geometry before 3", righttransform);
			if (!dispatchTable[CNode.nodeName](CNode, lefttransform, righttransform)) {
				console.warn(CNode.nodeName, "had no effect on transform");
			}
			//console.warn(CNode.DEF, LDNode.DEF, "geometry after 3", righttransform);
		}
		transformLDNodesToTriangles(CNode, lefttransform, righttransform);
		//console.warn(CNode.DEF, LDNode.DEF, "right after 1", righttransform);
	}
}

function readJoints() {
	let data = fs.readFileSync(__dirname + '/InputDir73/7_3_WEIGHTS.txt').toString();

	let lines = data.split(/[\r\n]+/);
	// console.error(lines);

	for (let l in lines) {
		let line = lines[l];
		// console.error(line);
		if (line.startsWith("<") && line.endsWith(">")) {
			let joint = line.substring(1, line.length-1)
			// console.error("Found joint:", joint);
			if (typeof joint === 'undefined') {
				console.error("Undefined joint");
			} else {
				jointList.push(joint);
			}
		}

	}
}

function convertTransformsToHAnimJoint() {
	let data = fs.readFileSync(__dirname + '/InputDir73/lily 7_3_animate.wrl').toString();


	let lines = data.split(/[\r\n]+/);
	// console.error(lines);

	for (let l in lines) {
		let line = lines[l];
		// console.error(line);
		if (line.indexOf("Transform") > 0) {
			let words = line.trim().split(/[ \t]+/);
			if (words[0] === "DEF") {
				joint = words[1];
				// words[1] = "Toddler_"+joint;
				// lines[l] = lines[l].replace(joint, words[1]);
				if (typeof jointMap[joint] !== 'undefined') {
					if (words[2] === "Transform") {
						lines[l] = lines[l].replace("Transform", "HAnimJoint");
					}
				}
			}
		}
	}
	data = lines.join("\r\n")+"\r\n";
	fs.writeFileSync(__dirname + '/ProcessDir73/lily 7_3_animate.x3dv', data);
}

var content = '';
// var content = fs.readFileSync(__dirname + '/InputDir73/lily 7_3_animate.x3dj').toString();


process.stdin.resume();
process.stdin.on('data', function(buf) { content += buf.toString(); });
process.stdin.on('end', function() {
    println('Joint Location');
    println("____________________________________");
    convertTransformsToCenters(JSON.parse(content));
    readJoints();
    console.log(output.join("\r\n")+"\r\n");
    for (let j in jointList) {
	let joint = jointList[j];
	/*
	if (typeof jointMap[joint+"translation"] === 'undefined') {
		console.error("Bad joint translation", joint, "--No data");
	}
	if (typeof jointMap[joint+"center"] === 'undefined') {
		console.error("Bad joint center", joint, "--No data");
	}
	*/
	if (typeof jointMap[joint] === 'undefined') {
		console.error("Bad joint", joint, "--No data");
    		console.warn(jointMap);
	}
    }
    // convertTransformsToHAnimJoint(); // SEE haveTransformDEFaddName.pl
});
module.exports = convertTransformsToCenters;
