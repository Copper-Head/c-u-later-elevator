%% Globally optimal plan is computed here.

%% Assigning Targets
%% ----------------

needy_floor(F) :- init(request(_, F)).

%% This allows us to quickly draw some conclusions about target assignment.
only_one_elevator :- NE = #count { E : agent(elevator(E))}, NE == 1.

%% Deliver requests are automatically added as targets for the corresponding elevators.
target(E, F) :- agent(elevator(E)), init(request(deliver(E), F)).
%% If we only have one elevator we can just assign the remaining requests to it.
target(E, F) :- agent(elevator(E)), needy_floor(F), only_one_elevator.
%% Otherwise the remaining "needy floors" are considered "free"...
free_call(F) :- needy_floor(F), not init(request(deliver(_), F)).
%% ... since each elevator is free to choose as targets any subset of them.
{ target(E, F): free_call(F) } :- agent(elevator(E)), not only_one_elevator.
%% However, as a small optimization we assign a free floor to an elevator if it
%% starts on that floor. This is not proven to be universally optimal!!
target(E, F) :- init(at(elevator(E), FE)), free_call(F), FE == F.
%% Note that every "free call" must be served.
:- free_call(F), not target(_, F).
%% But we don't want to duplicate effort, so...
n_targets(N) :- N = #count{ E, F : target(E, F) }.
%% We only assign as many targets as is absolutely necessary to complete the mission
:-  n_targets(N), DR = #count{ ED, FD : init(request(deliver(ED), FD)) },
    DC = #count{ FC : free_call(FC) },
    N > DR + DC.


%% Quantities to Optimize
%% ----------------------

%% Some helper predicates
direction(1).
direction(-1).

%% this predicate might be redundant but it's useful and cheap for now
request_at_start(E) :- init(at(elevator(E), FE)), target(E, F), FE == F.

%% Create coordinates from elevator to target:
%% Elevator ID, Direction (1 or -1), target floor, absolute distance to said floor
target_coord(E, 1, F, | DIST |) :-
init(at(elevator(E), FE)), target(E, F), DIST = FE - F, DIST < 0.
target_coord(E, -1, F, | DIST |) :-
init(at(elevator(E), FE)), target(E, F), DIST = FE - F, DIST > 0.

%% Get the distance to target furthest along some direction
furthest_along(E, DIR, DIST) :- direction(DIR),
                                init(at(elevator(E), _)),
                                DIST = #max{ D : target_coord(E, DIR, _, D); 0 }.

%% Check if elevator has targets both below and above it.
bidirectional(E) :- { target_coord(E, 1, _, _) } > 0,
                    { target_coord(E, -1, _, _) } > 0,
                    agent(elevator(E)).

%% What about this edge case?
%% no target_coord predicates along direction
initial_direction(E, DIR) :- target_coord(E, DIR, _, _), not bidirectional(E).
initial_direction(E, 1) :- bidirectional(E),
                              furthest_along(E, 1, DA),
                              furthest_along(E, -1, DB),
                              DA <= DB.
initial_direction(E, -1) :-  bidirectional(E),
                                furthest_along(E, 1, DA),
                                furthest_along(E, -1, DB),
                                DA > DB.

%% Count how many moves in total occur on each side (direction)
%% of elevator's starting point. This slightly awkward formulation lets
%% us later calculate at which point in time our elevators should stop.
n_moves(E, DIR, D * 2) :- furthest_along(E, DIR, D),
                          bidirectional(E),
                          initial_direction(E, DIR).

n_moves(E, DIR, D) :- furthest_along(E, DIR, D),
                      bidirectional(E),
                      not initial_direction(E, DIR).

n_moves(E, DIR, D) :- furthest_along(E, DIR, D),
                      not bidirectional(E).

total_n_moves(E, N) :- n_moves(E, 1, NA), n_moves(E, -1, NB), N = NA + NB.


n_serves(E, DIR, N + 1) :-  agent(elevator(E)),
                            request_at_start(E),
                            initial_direction(E, DIR),
                            N = #count{ F : target_coord(E, DIR, F, _) }.

n_serves(E, DIR, N) :-  agent(elevator(E)),
                        direction(DIR),
                        not request_at_start(E),
                        N = #count{ F : target_coord(E, DIR, F, _) }.

n_serves(E, DIR, N) :-  agent(elevator(E)),
                        direction(DIR),
                        request_at_start(E),
                        not initial_direction(E, DIR),
                        N = #count{ F : target_coord(E, DIR, F, _) }.

total_n_serves(E, N) :- n_serves(E, 1, NA), n_serves(E, -1, NB), N = NA + NB.

%% Combine serves and moves to get number of steps, which we then try to minimize.
n_steps(E, STEPS) :-  STEPS = ST + D,
                      total_n_serves(E, ST),
                      total_n_moves(E, D),
                      agent(elevator(E)).

%% Stupid Minimization (I'm sure there's a smarter way...)
%% -------------------------------------------------------
elevator_step(1..N) :- n_steps(_, N).
travel_distance(1..N) :- N = #sum{ X : total_n_moves(_, X) }.
#minimize{ 1@5,S : elevator_step(S) }.
#minimize{ 1@2,T : travel_distance(T) }.

%% Elevator Instructions
%% ---------------------

serve_at(E, F, 1) :-  request_at_start(E),
                      init(at(elevator(E), F)).

serve_at(E, F, T) :-  initial_direction(E, DIR),
                      request_at_start(E),
                      target_coord(E, DIR, F, D),
                      STOPS = #count{ FX, DX : target_coord(E, DIR, FX, DX), DX <= D },
                      T = D + STOPS + 1.

serve_at(E, F, T) :-  initial_direction(E, DIR),
                      not request_at_start(E),
                      target_coord(E, DIR, F, D),
                      STOPS = #count{ FX, DX : target_coord(E, DIR, FX, DX), DX <= D },
                      T = D + STOPS.

serve_at(E, F, T) :-  target_coord(E, DIR, F, D),
                      not initial_direction(E, DIR),
                      n_serves(E, DIR * -1, PREV_STOPS),
                      n_moves(E, DIR * -1, PREV_MOVES),
                      STOPS = #count{ FX, DX : target_coord(E, DIR, FX, DX), DX <= D },
                      T = D + STOPS + PREV_STOPS + PREV_MOVES.

%% For bidirectional elevators we need to know when they switch direction
switch_point(E, STEP) :-  bidirectional(E),
                          initial_direction(E, DIR),
                          furthest_along(E, DIR, DIST),
                          n_serves(E, DIR, STOPS),
                          STEP = STOPS + DIST.

%% These predicates tell an elevator which direction to move in
current_direction(E, DIR, 1..N) :-  initial_direction(E, DIR), not bidirectional(E),
                                    n_steps(E, N).
current_direction(E, DIR, 1..N-1) :-  initial_direction(E, DIR), bidirectional(E),
                                      switch_point(E, N).
current_direction(E, DIR * -1, SW..N-1) :-  initial_direction(E, DIR),
                                            bidirectional(E),
                                            switch_point(E, SW),
                                            n_steps(E, N).
