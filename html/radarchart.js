const outlineWidth = 2;
const fontFamily = "Verdana";
const tickWidth = 4;

function toDegrees(rad) {
	return (rad / Math.PI) * 180;
}

function hexToRgb(hex) {
	if (hex[0] === "#") hex = hex.substring(1);
	var rgb = parseInt(hex, 16);
	return {
		r: (rgb >> 16) & 255,
		g: (rgb >> 8) & 255,
		b: rgb & 255,
	};
}

function hexToRgbaExpression(hex, alpha) {
	var rgb = hexToRgb(hex);
	return (
		"rgba(" +
		rgb.r.toString() +
		"," +
		rgb.g.toString() +
		"," +
		rgb.b.toString() +
		"," +
		alpha.toString() +
		")"
	);
}

function createAndAppendSVGElement(container, type, props) {
	let element = document.createElementNS("http://www.w3.org/2000/svg", type);
	for (let key in props) {
		element.setAttribute(key, props[key]);
	}
	container.appendChild(element);
	return element;
}

function drawRadarChart(id, data) {
	const radarContainer = document.getElementById(id);
	data.width = data.width || radarContainer.width.baseVal.value || 400;
	data.height = data.height || radarContainer.height.baseVal.value || 400;
	data.fontSize = data.width / 12;
	data.values = data.values.map(function (value) {
		return Math.min(value, data.stages.length);
	});
	drawPolygon(radarContainer, data);
	drawRadar(radarContainer, data);
}

function drawPolygon(container, data) {
	let midX = data.width / 2;
	let midY = data.height / 2;

	let radarSize = data.width / 3;
	let stepSize = radarSize / (data.stages.length + 1);

	let coords = "";
	let count = data.values.length;
	let angle = Math.PI / 2;
	let points = [];
	for (let i = 0; i < count; i++) {
		let dir = {
			x: Math.cos(angle),
			y: -Math.sin(angle),
		};
		angle = angle - (Math.PI * 2) / count;
		let offset = {
			x: dir.x * stepSize * data.values[i],
			y: dir.y * stepSize * data.values[i],
		};
		let point = {
			x: midX + offset.x,
			y: midY + offset.y,
		};
		if (i !== 0) {
			coords = coords + " ";
		}
		points.push(point);
		coords = coords + point.x.toString() + "," + point.y.toString();
	}

	createAndAppendSVGElement(container, "polygon", {
		points: coords,
		fill: hexToRgbaExpression(data.color, 0.5), //makes fill transparent
		stroke: data.color,
		"stroke-width": outlineWidth.toString(),
	});
}

function drawRadar(container, data) {
	let midX = data.width / 2;
	let midY = data.height / 2;
	let radarSize = data.width / 3;
	let stepSize = radarSize / (data.stages.length + 1);

	createAndAppendSVGElement(container, "circle", {
		cx: midX.toString(),
		cy: midY.toString(),
		r: radarSize.toString(),
		stroke: data.color,
		fill: "rgba(255, 255, 255, 0)", //invisible fill
	});

	createAndAppendSVGElement(container, "circle", {
		cx: midX.toString(),
		cy: midY.toString(),
		r: (data.width / 2).toString(),
		stroke: data.color,
		fill: "rgba(255, 255, 255, 0)", //invisible fill
	});

	let axesCount = data.axes.length;
	let angle = Math.PI / 2;
	for (let i = 0; i < axesCount; i++) {
		let dir = {
			x: Math.cos(angle),
			y: -Math.sin(angle),
		};
		let valueOffset = {
			x: dir.x * (radarSize + data.fontSize * 0.75),
			y: dir.y * (radarSize + data.fontSize * 0.75),
		};
		let keyOffset = {
			x: dir.x * (radarSize + data.fontSize * 1.5),
			y: dir.y * (radarSize + data.fontSize * 1.5),
		};
		let valuePoint = {
			x: midX + valueOffset.x,
			y: midY + valueOffset.y,
		};
		let keyPoint = {
			x: midX + keyOffset.x,
			y: midY + keyOffset.y,
		};

		let valueText = createAndAppendSVGElement(container, "text", {
			x: valuePoint.x.toString(),
			y: valuePoint.y.toString(),
			fill: data.color,
			stroke: "black",
			"stroke-width": "0.1",
			"font-family": fontFamily,
			"font-size": data.fontSize.toString(),
			"text-anchor": "middle",
			"dominant-baseline": "middle",
		});
		valueText.textContent = data.stages[data.values[i] - 1];

		let rotation = -toDegrees(angle - Math.PI / 2) % 360;
		if (rotation > 90 && rotation < 270) {
			rotation += 180;
		}
		let rounding = 180 / data.axes.length;

		let keyText = document.createElementNS(
			"http://www.w3.org/2000/svg",
			"text"
		);
		keyText.setAttribute(
			"transform",
			"rotate(" +
				Math.round(Math.ceil(rotation / rounding) * rounding) +
				" " +
				keyPoint.x.toString() +
				" " +
				keyPoint.y.toString() +
				")"
		);
		keyText.textContent = data.axes[i];
		keyText.setAttribute("text-anchor", "middle");
		keyText.setAttribute("dominant-baseline", "middle");
		keyText.setAttribute("x", keyPoint.x.toString());
		keyText.setAttribute("y", keyPoint.y.toString());
		keyText.setAttribute("stroke", "black");
		keyText.setAttribute("stroke-width", "0.1");
		keyText.setAttribute("fill", data.color);
		keyText.setAttribute("font-family", fontFamily);
		keyText.setAttribute(
			"font-size",
			Math.round(data.fontSize / 2.5).toString()
		);
		container.appendChild(keyText);

		let lineOffset = {
			x: dir.x * radarSize,
			y: dir.y * radarSize,
		};
		let linePoint = {
			x: midX + lineOffset.x,
			y: midY + lineOffset.y,
		};

		let line = document.createElementNS(
			"http://www.w3.org/2000/svg",
			"line"
		);
		line.setAttribute("x1", midX.toString());
		line.setAttribute("y1", midY.toString());
		line.setAttribute("x2", linePoint.x.toString());
		line.setAttribute("y2", linePoint.y.toString());
		line.setAttribute("stroke", data.color);
		container.appendChild(line);

		for (let j = 1; j <= data.stages.length; j++) {
			let mid = {
				x: midX + dir.x * stepSize * j,
				y: midY + dir.y * stepSize * j,
			};
			let perpendicularAngle = angle - Math.PI / 2;
			let perpendicularDir = {
				x: Math.cos(perpendicularAngle),
				y: -Math.sin(perpendicularAngle),
			};
			let p1 = {
				x: mid.x - perpendicularDir.x * tickWidth,
				y: mid.y - perpendicularDir.y * tickWidth,
			};
			let p2 = {
				//x: 2 * mid.x - p1.x, // mirror first point
				//y: 2 * mid.y - p1.y  // relative to middle
				x: mid.x + perpendicularDir.x * tickWidth,
				y: mid.y + perpendicularDir.y * tickWidth,
			};

			let tick = document.createElementNS(
				"http://www.w3.org/2000/svg",
				"line"
			);
			tick.setAttribute("x1", p1.x.toString());
			tick.setAttribute("y1", p1.y.toString());
			tick.setAttribute("x2", p2.x.toString());
			tick.setAttribute("y2", p2.y.toString());
			tick.setAttribute("stroke", data.color);
			container.appendChild(tick);

			if (i === 0) {
				let stageText = document.createElementNS(
					"http://www.w3.org/2000/svg",
					"text"
				);
				stageText.textContent = data.stages[j - 1];
				//stageText.setAttribute("text-anchor", "middle")
				//stageText.setAttribute("dominant-baseline", "middle")
				stageText.setAttribute("x", (p2.x + tickWidth).toString());
				stageText.setAttribute("y", p2.y.toString());
				stageText.setAttribute("stroke", "black");
				stageText.setAttribute("stroke-width", "0.1");
				stageText.setAttribute("fill", data.color);
				stageText.setAttribute(
					"font-size",
					(data.fontSize / 3).toString()
				);
				stageText.setAttribute("font-family", fontFamily);
				container.appendChild(stageText);
			}
		}

		angle = angle - (2 * Math.PI) / axesCount;
	}
}
