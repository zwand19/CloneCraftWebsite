Rules =
	base:
		goldPerTurn:					5					# the gold generated per turn by the base
		size:							3					# the width and height of the base
		startingGold:					200					# the starting gold of the base
		startingHealth:					120					# the starting health of the base
		vision:							5					# the vision of the base, extends from the bases edges
	building:
		costOfLesserMinion:				50					# the cost of building a lesser minion
		costOfGreaterMinion:			100					# the cost of building a greater minion
		lesserMinionStats:				10					# the amount of stat points a lesser minion gets
		greaterMinionStats:				19					# the amount of stat points a greater minion gets
	map: 'square'
	maps:
		square:
			resourcesPerQuadrant:		26
			sideBuffer:					8
			quadrantSize:				20
		standard:
			distanceBetweenBases:		27					# the distance between the inner edges of the two bases
			height:						21					# the height of the board
			resourcesPerTeam:			30					# the number of resources behind each teams base
			sideBuffer:					8					# the number of cells between the outer edge of the base and the edge of the board
	minion:
		damage:
			base:						2 					# base damage
			max:						5					# most stat points that can be allocated to the property
			per:						1					# amount gained per stat point
		health:
			base:						7
			max:						15
			per:						2
		mining:
			base:						20
			max:						10
			per:						8
		range:
			base:						2
			max:						5
			per:						1
		speed:
			base:						2
			max:						10
			per:						.5
		vision:
			base:						2
			max:						8
			per:						1
	maxRounds:							200					# the maximum number of rounds a game can run
	resources:
		minDistanceFromBase:			3					# the minimum number of cells away from a base that a resource can be placed
	teamMaxMinions:						15					# the maximum number of minions a team can have
		
module.exports = Rules