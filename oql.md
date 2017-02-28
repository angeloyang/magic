# print tree objects
function printTree(it, depth) {
	if (it == null) {
		return;
	}

	var nodes = [];
	var span = "";
	for (var i = 0; i < depth; i++) {
		span += "--|";
	}

	if (classof(it.data.conditionUnit).name == 'com.ecwise.common.condition.unit.Condition') {
		nodes.push(span + toHtml(it.data.conditionUnit.field.id.toString()) + '<br />');
	} else {
		nodes.push(span + toHtml(it.data.conditionUnit) + '<br />');
	}	

	depth++;

	var left = it.left;
	if (left) {
		var subNodes = printTree(left, depth);
		for (var i = 0; i < subNodes.length; i++) {
			nodes.push(subNodes[i]);
		}
	}

	var right = it.right;
	if (right) {
		var subNodes = printTree(right, depth);
		for (var i = 0; i < subNodes.length; i++) {
			nodes.push(subNodes[i]);
		}
	}

	return nodes;
}

map(heap.objects('com.ecwise.common.condition.core.ConditionTree'),
		'printTree(it.rootNode, 0)');

