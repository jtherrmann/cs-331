%% take.pro
%% Jake Herrmann
%% 27 April 2019
%%
%% CS 331 Spring 2019
%% Source code for Assignment 7 Exercise D.


%% take(+n, +x, ?e).
%%
%% n is a nonnegative integer, x is a list, and e is a list consisting of the
%% first n items of x, or all of x, if x has fewer than n items.

take(_, [], []).

take(0, _, []).

take(N, [H|T], [H|T2]) :- N > 0, NN is N-1, take(NN, T, T2).
