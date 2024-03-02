var Matrix = require("./matrix.js");
var fs = require("fs");

// Apply transforms in X3D JSON to Humanoids
// STDIN,process.stdin -- the skeleton in X3D JSON format
// STDOUT -- Joint centers file

function convertJsonToCenters(json) {
	let LDNodeList = [];
	let LDNode = initializeLDNode(json, "X3D");
	LDNodeList.push(LDNode);
	LDNodeList = toNormals(json, LDNodeList, LDNode);
	if (LDNodeList !== null) {
		let lefttransform = new Matrix(1, 1, 1, 1).translation();
		let output = [];
		let righttransform = new Matrix(1, 1, 1, 1).translation();
		transformLDNodesToTriangles(LDNodeList[0], output, lefttransform, righttransform);
		// return output.join("\r\n")+"\r\n";
	} else {
		console.error("toNormals failed");
		return null;
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



	if (LDNode.angles["Z"] != 0) {
		LDNode.rotation = Matrix.rotZ(Matrix.degToRad(LDNode.angles["Z"]));
		console.error("Rotation\n", LDNode.rotation.toString());
	}



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
		}
	}
	var fieldDispatchTable = {
		"@center" : function(obj, LDNode) {
			LDNode.center = new Matrix(...obj);
			// go from A pose to I pose
			let shoulder = findShoulder(LDNode);
			LDNode.angles = { "X": 0, "Y": 0, "Z": 0 };
			if (LDNode.name.startsWith("l_shoulder")) {
				LDNode.angles["Z"] = 40;
			} else if (LDNode.name.startsWith("r_shoulder")) {
				LDNode.angles["Z"] = -40;
			}
			if (shoulder) {
				LDNode.rotation = rotateAroundShoulder(LDNode, shoulder);
			}
		},
		"@name" : function(obj, LDNode) {
			LDNode.name = obj;
		},
		"@scale" : function(obj, LDNode) {
			LDNode.scale = new Matrix(...obj).scale();
			// console.error("Scaling", LDNode.scale);
		},
		"@rotation" : function(obj, LDNode) {
			LDNode.quaternion = new Matrix(...obj).quaternion();
			// console.error("Rotating", LDNode.quaternion);
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
		console.log(e);
		number = backupNum;
	}
	pad = pad && number >=  0 ? " ": "";
	number += isNaN(number) ? " (Not a number)" : "";
	if (multiLine) {
		number = [axis+":"+pad, number, unit+"\r"].join(" ");
	}
	return number;
}

function printRotation(prefix, radians, multiLine, unit, pad, fn) {
	let angle = radians;
	// console.error("oops", prefix, radians);
	try {
		angle = parseFloat(angle);
		angle = Matrix.degToRad(angle);
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

function printJoint(LDNode, origpoint, point, output) {
	/*
	console.error(LDNode.name);
	console.error("Original point", origpoint.toString())
	console.error("Final    point", point.toString());
	*/

	var multiLine = true;
	output.push(LDNode.name);
	if (multiLine) {
		output.push("Location");
	}
	let pad = point[0] < 0 || point[1] < 0 || point[2] < 0;
	output.push([
		trim("X", point[0], multiLine, "m", pad),
		trim("Y", point[1], multiLine, "m", pad),
		trim("Z", point[2], multiLine, "m", pad)].join(multiLine ? "\r\n" : ","));
	if (multiLine) {
		output.push("");
		output.push("ROTATION");
		point = LDNode.angles;
		let axes = ["X", "Y", "Z"];
		if (!point) {
			point = { "X": 0, "Y": 0, "Z": 0 };
		}
		pad = point[0] < 0 || point[1] < 0 || point[2] < 0;
		for (let i = 0; i < 3; i++) {
			output.push(printRotation(axes[i], point[axes[i]], multiLine, "°", pad, Math.asin));
		}
		output.push("____________________________________");
		output.push("");
	}
}

function transformLDNodesToTriangles(LDNode, output, parentTransform, righttransform) {
	var dispatchTable = {
		HAnimJoint: function(LDNode, output, lefttransform, righttransform) {
			var origpoint = LDNode.center;
			var point = lefttransform.copy().matvecmult(origpoint).vecmatmult(righttransform);
			printJoint(LDNode,
				origpoint,
				point,
				output);
			var jointData = [];
			printJoint(LDNode,
				origpoint,
				point,
				jointData);
			jointMap[LDNode.name] = jointData; // should be in order of joint
		}
	};
	for (var k in LDNode.kids) {
		var CNode = LDNode.kids[k];
		var lefttransform = parentTransform.copy();

		if (CNode.translation) {
			lefttransform = lefttransform.matmatmult(CNode.translation);
		}
		if (CNode.rotation) {
			lefttransform = lefttransform.matmatmult(CNode.rotation);
		}
		if (CNode.quaternion) {
			/*
			lefttransform = lefttransform.matmatmult(CNode.quaternion);
			righttransform  = new Matrix(CNode.quaternion).invertquaternion().matmatmult(righttransform);
			*/
		}
		if (CNode.scale) {
			lefttransform = lefttransform.matmatmult(new Matrix(CNode.scale));
		}
		// console.error("Scale transform", transform);
		// only print out geometry
		if (CNode.geometry) {
			dispatchTable[CNode.nodeName](CNode, output, lefttransform, righttransform);
		}
		transformLDNodesToTriangles(CNode, output, lefttransform, righttransform);
	}
}

var jointList = [];
var jointMap = {};

function readCenters() {
	let data = fs.readFileSync(__dirname + '/InputDir/lily_6_1_joint_rotate.txt').toString();

	var lines = data.split(/[\r\n]+/);
	// console.error(lines);

	for (var l in lines) {
		var line = lines[l];
		// console.error(line);
		if (line.startsWith("X:") ||
			line.startsWith("Y:") ||
			line.startsWith("Z:") ||
			line.startsWith("ROTATION") ||
			line.startsWith("Joint Location") ||
			line.startsWith("Location") ||
			line.startsWith("_____") ||
			line.length === 0) {
			// console.error("Found bad:", line);
		} else {
			// console.error("Found joint:", line);
			jointList.push(line);
		}

	}
}

var content = '';
process.stdin.resume();
process.stdin.on('data', function(buf) { content += buf.toString(); });
process.stdin.on('end', function() {
    convertJsonToCenters(JSON.parse(content));
    console.log('Joint Location');
    console.log("____________________________________");
    readCenters();
    for (var j in jointList) {
	    var joint = jointList[j];
	    var data = jointMap[joint].join("\r\n");
	    console.log(data);
    }
});
module.exports = convertJsonToCenters;
