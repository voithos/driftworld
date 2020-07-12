extends Node

enum TYPE {
	PLAYER,
	ENEMY,
	NEUTRAL,
	DEFECTOR,
}

const COLORS = {
	TYPE.PLAYER: Color("14fddf"),
	TYPE.ENEMY: Color("f3415b"),
	TYPE.NEUTRAL: Color("a3cadf"),
	TYPE.DEFECTOR: Color("9800f7"),
}

const ALLIES = {
	TYPE.PLAYER: [],
	TYPE.ENEMY: [TYPE.DEFECTOR],
	TYPE.DEFECTOR: [TYPE.ENEMY],
	TYPE.NEUTRAL: [],
}
