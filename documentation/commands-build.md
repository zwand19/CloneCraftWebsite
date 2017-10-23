## Build Lesser/Greater Minion

***

Commands your base to create a minion

*commandName* : **build lesser** or **build greater**

*minionId* : **set to null**

*params* :

- x *(int)* - the x coordinate of the cell you want your minion to spawn. 
- y *(int)* - the y coordinate of the cell you want your minion to spawn.
- stats *(object)*
    - d *(int)* - the number of stat points allocated towards attack damage
    - r *(int)* - the number of stat points allocated towards attack range
    - h *(int)* - the number of stat points allocated towards health
    - m *(int)* - the number of stat points allocated towards mining
    - s *(int)* - the number of stat points allocated towards speed
    - v *(int)* - the number of stat points allocated towards vision

*example* :
```javascript
{ 
	commandName: 'build greater', 
	minionId: null,
	params: { x: 3, y: 18, stats: { d: 2, r: 3, h: 1, s: 10, m: 1, v: 2 }
}
```