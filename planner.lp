%% New attempt at finding a global plan
%% Currently can only handle planning for one elevator

needy_floor(F) :- init(request(_, F)).

only_one_elevator :- NE = #count { E : agent(elevator(E))}, NE == 1.

%% Deliver requests are automatically added as targets for the corresponding elevators.
target(E, F) :- agent(elevator(E)), init(request(deliver(E), F)).
target(E, F) :- agent(elevator(E)), needy_floor(F), only_one_elevator.
%% The remaining "needy floors" are considered "free"...
free_call(F) :- needy_floor(F), not init(request(deliver(_), F)).
%% ... since each elevator is free to choose as targets any subset of them.
{ target(E, F): free_call(F) } :- agent(elevator(E)), not only_one_elevator.
%% However, every "free call" must be served.
:- free_call(F), not target(_, F).

%% provisional
:- agent(elevator(E)), not target(E, _).

%% This counts the number of floors an elevator stops at (serves!).
n_stops(E, N) :- agent(elevator(E)), N = #count{ F : target(E, F) }.

above(E, F) :- init(at(elevator(E), FE)), target(E, F), F > FE.
below(E, F) :- init(at(elevator(E), FE)), target(E, F), F < FE.

furthest_along(E, -1, F, DIST) :- init(at(elevator(E), FE)),
                                  F = #min{ X : below(E, X); X : init(at(elevator(E), X)) },
                                  DIST = |FE - F|.


furthest_along(E, 1, F, DIST) :-  init(at(elevator(E), FE)),
                                  F = #max{ X : above(E, X); X : init(at(elevator(E), X)) },
                                  DIST = |FE - F|.

n_moves(E, TRAVEL_DIST) :-  furthest_along(E, 1, _, D1),
                            furthest_along(E, -1, _, D2),
                            TRAVEL_DIST = D1 * 2 + D2,
                            D1 < D2.

n_moves(E, TRAVEL_DIST) :-  furthest_along(E, 1, _, D1),
                            furthest_along(E, -1, _, D2),
                            TRAVEL_DIST = D2 * 2 + D1,
                            D1 > D2.

n_moves(E, TRAVEL_DIST) :-  furthest_along(E, 1, _, D1),
                            furthest_along(E, -1, _, D2),
                            TRAVEL_DIST = D1 * 2 + D2,
                            D1 == D2.

n_steps(E, STEPS) :-  STEPS = ST + D,
                      n_stops(E, ST),
                      n_moves(E, D),
                      agent(elevator(E)).

el_step(1..N) :- n_steps(_, N).
%% slowest_guy(1..STEPS) :- STEPS = #max{ S : n_steps(_, S) }.
%% score(1..TOTAL_STEPS) :-
%% slowest_guy(ST),
                          %% TOTAL_STEPS = #sum { X, E : n_steps(E, X), agent(elevator(E)) }.

%% We couldn't figure out how to optimize two objectives so for now we are only
%% minimizing the number of steps performed by the "slowest" elevator
#minimize{ 1,S : el_step(S) }.
%% #minimize{ 1@1,M : score(M) }.

%% Under Construction: oc
%% Some notes
%% priority numbers are in a direct relationship: the bigger the number, the higher the prio
%% We've also noticed that more consistent behavior arises from otpimizing
%% different variables in one predicate rather than optimizing multiple predicates.
%% #minimize{ X, E : n_steps(E, X), agent(elevator(E)) }.
%% #minimize{ SLOWEST@2 : score(SLOWEST, _) }.
%% #minimize{ TS@1: score(_, TS) }.
%% #minimize{ SLOWEST : score(SLOWEST, _) }.


%% This is used to prevent elevators from moving once they've served all their targets.
left_to_do(E, N, 0) :- N = #count{F : target(E, F)}, agent(elevator(E)).


current_direction(E, 1, 0) :- bidirectional(E),
                              furthest_along(E, 1, _, DA),
                              furthest_along(E, -1, _, DB),
                              DA <= DB.
current_direction(E, -1, 0) :-  bidirectional(E),
                                furthest_along(E, 1, _, DA),
                                furthest_along(E, -1, _, DB),
                                DA > DB.

bidirectional(E) :- { above(E, _) } > 0, { below(E, _) } > 0, agent(elevator(E)).

current_direction(E, 1, 0) :- above(E, _), not bidirectional(E).
current_direction(E, -1, 0) :- below(E, _), not bidirectional(E).
