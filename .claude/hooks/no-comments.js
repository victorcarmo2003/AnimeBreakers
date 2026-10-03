const fs = require("fs");

const input = JSON.parse(fs.readFileSync(0, "utf8") || "{}");
const toolInput = input.tool_input || {};
const filePath = toolInput.file_path || "";

if (!/\.(luau|lua)$/i.test(filePath)) process.exit(0);
if (/[\\/]src[\\/]Modux[\\/]/i.test(filePath)) process.exit(0);
if (/[\\/](Packages|ServerPackages|DevPackages)[\\/]/i.test(filePath)) process.exit(0);

const chunks = [];
if (typeof toolInput.content === "string") chunks.push(toolInput.content);
if (typeof toolInput.new_string === "string") chunks.push(toolInput.new_string);
if (Array.isArray(toolInput.edits)) {
	for (const edit of toolInput.edits) {
		if (edit && typeof edit.new_string === "string") chunks.push(edit.new_string);
	}
}

function findComment(source) {
	let i = 0;
	let line = 1;
	while (i < source.length) {
		const ch = source[i];
		if (ch === "\n") {
			line++;
			i++;
			continue;
		}
		if (ch === "-" && source[i + 1] === "-") {
			const end = source.indexOf("\n", i);
			return { line, text: source.slice(i, end === -1 ? undefined : end).trim() };
		}
		if (ch === '"' || ch === "'" || ch === "`") {
			i++;
			while (i < source.length && source[i] !== ch && source[i] !== "\n") {
				if (source[i] === "\\") i++;
				i++;
			}
			i++;
			continue;
		}
		if (ch === "[") {
			const match = /^\[(=*)\[/.exec(source.slice(i));
			if (match) {
				const close = "]" + match[1] + "]";
				const end = source.indexOf(close, i + match[0].length);
				const stop = end === -1 ? source.length : end + close.length;
				for (let k = i; k < stop; k++) if (source[k] === "\n") line++;
				i = stop;
				continue;
			}
		}
		i++;
	}
	return null;
}

for (const chunk of chunks) {
	const hit = findComment(chunk);
	if (hit) {
		process.stderr.write(
			`Bloqueado: comentário em código Luau (${filePath}, linha ${hit.line} do trecho): "${hit.text}". ` +
				`Regra do projeto (CLAUDE.md / DEC-001): zero comentários e sem --!strict (o .luaurc já força strict). ` +
				`Remova o comentário e use nomes claros; explicação vai para docs/.\n`
		);
		process.exit(2);
	}
}

process.exit(0);
