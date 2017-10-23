## Hand Off Command

***

Commands your minion to hand off the gold it is carrying to another minion

*commandName* : **hand off**

*minionId* : **required**

*params* :

- minionId *(int)* - the id of the minion you are trying to hand off your resources to. 

*example* :
```javascript
{
	commandName: 'hand off', 
	minionId: 2, 
	params: { minionId: 7 }
}
```