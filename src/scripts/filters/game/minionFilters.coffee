class MinionFilter
	constructor: () ->
		return (minions, stat) ->
			minionIsTypeOfStat = (minion, stat) ->
				attack = minion.ui.d + minion.ui.r
				if attack is 2 then attack = 1
				switch stat
					when 'attack' then return attack > minion.ui.s && attack > minion.ui.h && attack > minion.ui.m && attack > minion.ui.v
					when 'health' then return minion.ui.h > minion.ui.s && minion.ui.h > attack && minion.ui.h > minion.ui.m && minion.ui.h > minion.ui.v
					when 'speed' then return minion.ui.s > minion.ui.h && minion.ui.s > attack && minion.ui.s > minion.ui.m && minion.ui.s > minion.ui.v
					when 'mining' then return minion.ui.m > minion.ui.s && minion.ui.m > attack && minion.ui.m > minion.ui.h && minion.ui.m > minion.ui.v
					when 'vision' then return minion.ui.v > minion.ui.s && minion.ui.v > attack && minion.ui.v > minion.ui.m && minion.ui.v > minion.ui.h
					when 'none'
						max = Math.max attack, minion.ui.h, minion.ui.s, minion.ui.m, minion.ui.v
						numWithMax = 0
						numWithMax++ if attack is max
						numWithMax++ if minion.ui.h is max
						numWithMax++ if minion.ui.s is max
						numWithMax++ if minion.ui.m is max
						numWithMax++ if minion.ui.v is max
						return numWithMax > 1
				return false
			minionsOfType = []
			for minion in minions
				minionsOfType.push minion if minionIsTypeOfStat(minion, stat)
			return minionsOfType

angular.module('app').filter 'minion', [MinionFilter]