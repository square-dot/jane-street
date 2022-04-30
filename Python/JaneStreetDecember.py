import numpy as np
import copy

starting_players = ('Aron', 'Barron', 'Caren', 'Darrin')

class Config:
    def __init__(self, round, players, player_shooting):
        self.round = round
        self.players = players
        self.player_shooting = player_shooting

def basic_configurations():
    return [Config(1, ['Aron', 'Barron', 'Caren', 'Darrin'], 'Aron'),
        Config(2, ['Aron', 'Barron', 'Caren', 'Darrin'], 'Barron'),
        Config(3, ['Aron', 'Barron', 'Caren', 'Darrin'], 'Caren'),
        Config(3, ['Aron', 'Caren', 'Darrin'], 'Caren'),
        Config(4, ['Aron', 'Barron', 'Caren', 'Darrin'], 'Darrin'),
        Config(4, ['Aron', 'Caren', 'Darrin'], 'Darrin'),
        Config(4, ['Aron', 'Barron', 'Darrin'], 'Darrin'),
        Config(4, ['Aron', 'Darrin'], 'Darrin'),
        Config(5, ['Aron', 'Barron', 'Caren', 'Darrin'], 'Aron'),
        Config(5, ['Aron', 'Caren', 'Darrin'], 'Aron'),
        Config(5, ['Aron', 'Barron', 'Darrin'], 'Aron'),
        Config(5, ['Aron', 'Barron'], 'Aron'),
        Config(5, ['Aron', 'Caren'], 'Aron'),
        Config(5, ['Aron', 'Darrin'], 'Aron'),
        Config(5, ['Aron'], 'Aron')
        ]

def check_if_plausible_past(configuration, past):
    check1 = (past.round == configuration.round - 1)
    if (check1 == False):
        return False
    check1b = configuration.player_shooting in past.players
    
    if check1b == False:
        return False
    check2 = (set(past.players) == set(configuration.players))
    check3 = (len(past.players) == len(configuration.players) + 1) & (len(list(set(past.players) - set(configuration.players))) == 1)
    check3b = (past.player_shooting in (list(set(past.players) - set(configuration.players))))
    check4 = all([player in past.players for player in configuration.players])
    check5 = (guy_before(configuration.player_shooting, past.players) == past.player_shooting)
    return (check2 | (check3 & check3b)) & check4 & check5

def game(configuration):
    starting_players = ('Aron', 'Barron', 'Caren', 'Darrin') #defining list of players
    
    nr_in_play = len(configuration.players)
    if nr_in_play > 4:
        return 0
    elif configuration.round < 6 & configuration.round > 2 & len(filter(lambda x: (x.round == configuration.round) & (set(x.players) == set(configuration.players)) & (x.player_shooting == configuration.player_shooting))) == 0:
        return 0
    elif configuration.round < 2:
        return 1
    elif 4 - nr_in_play >= configuration.round - 1: #can only start eliminating at round 2 and cannot eliminate more than one player per round
        return 0
    elif nr_in_play == 4:
        res = 1
        for i in range(1, configuration.round):
            res *= i
        return 1 / res

    possible_pasts = []

    if configuration.round < 7:
        possible_pasts = list(filter(lambda x: check_if_plausible_past(configuration, x),
            basic_configurations()))
    else:
        possible_pasts.append(Config(configuration.round - 1, copy.copy(configuration.players), guy_before(configuration.player_shooting, configuration.players)))
        considered_player = guy_before(configuration.player_shooting, list(starting_players)) # considering if player before current is missing
        if considered_player not in configuration.players:
            new_players = copy.copy(configuration.players)
            new_players.insert(configuration.players.index(configuration.player_shooting), considered_player)
            possible_pasts.append(Config(configuration.round - 1, new_players, considered_player))
            considered_player = guy_before(considered_player, list(starting_players)) # considering if player before before current is missing
            if considered_player not in configuration.players:
                new_players = copy.copy(configuration.players)
                new_players.insert(configuration.players.index(configuration.player_shooting), considered_player)
                possible_pasts.append(Config(configuration.round - 1, new_players, considered_player))
                considered_player = guy_before(considered_player, list(starting_players)) # considering if player before before before current is missing
                if considered_player not in configuration.players:
                    new_players = copy.copy(configuration.players)
                    new_players.insert(configuration.players.index(configuration.player_shooting), considered_player)
                    possible_pasts.append(Config(configuration.round - 1, new_players, considered_player))
    tot = 0
    for past in possible_pasts:
        if len(past.players) == nr_in_play:
            tot += game(past) / (configuration.round + nr_in_play - 5)
        else:
            tot += game(past) * (configuration.round + nr_in_play - 5) / (configuration.round + nr_in_play - 4)

    return tot

def guy_before(player, list_of_players):
    if player == list_of_players[0]:
        return list_of_players[-1]
    indx = list_of_players.index(player)
    return list_of_players[indx - 1]

#test with simulation
runs = 10000
results = {'Aron': 0, 'Barron': 0, 'Caren': 0, 'Darrin': 0}

for k in range(0,runs):
    players = ['Aron', 'Barron', 'Caren', 'Darrin']

    i = 0
    best = 1
    while len(players) > 1:
        r = np.random.uniform()
        if r < best:
            best = r
            i += 1
        else:
            players.remove(players[i])
        i %= len(players)
    results[players[0]] += 1

#print results of simulation
tot = 0
for r in results:
    tot += results[r]

pctg = [(results[r] / tot) for r in results]

print("tot = " + str(tot) + "\t" + str(results) + "\t" + str(pctg))
print("done")