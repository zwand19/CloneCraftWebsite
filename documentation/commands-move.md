## Move Command

***

Commands your minion to move in a certain direction

*commandName* : **move**

*minionId* : **required**

*params* :

- direction *(string)* - the cardinal direction you want your minion to move. Must be one of the following (case-insensitive):
   - "N"
   - "S"
   - "E"
   - "W"

*example* :
```javascript
{ 
	commandName: 'move', 
	minionId: 8, 
	params: { direction: 'N' }
}
```