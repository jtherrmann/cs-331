%% TODO says true / gives solution but then says no

take(_, [], []).

take(0, _, []).

take(N, [H|T], [H|T2]) :- N > 0, NN is N-1, take(NN, T, T2).
