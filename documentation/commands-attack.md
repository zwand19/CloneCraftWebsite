### Attack command

***

commands your minion to attack a certain cell

*commandName* : **attack**

*minionId* : **required**

*params* :

- x *(int)* - the x coordinate of the cell you want to attack
- y *(int)* - the y coordinate of the cell you want to attack

*example* :
```javascript
{ 
	commandName: 'attack', 
	minionId: 4, 
	params: { x: 5, y: 11 }
}
```