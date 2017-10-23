## Mine Command

***

Commands your minion to mine at a certain location

*commandName* : **mine**

*minionId* : **required**

*params* :

- x *(int)* - the x coordinate of the cell you want your minion to mine. 
- y *(int)* - the y coordinate of the cell you want your minion to mine.

*example* :
```javascript
{ 
	commandName: 'mine', 
	minionId: 13, 
	params: { x: 45, y: 11 }
}
```