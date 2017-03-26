%% New attempt at finding a global plan
%% Currently can only handle planning for one elevator

needy_floor(F) :- init(request(_, F)).

%% This will become more complicated later for 2 elevators
target(E, F) :- agent(elevator(E)), needy_floor(F).

%% What about requests on the same floor?
above(E, F) :- init(at(elevator(E), FE)), target(E, F), F > FE.
below(E, F) :- init(at(elevator(E), FE)), target(E, F), F < FE.

furthest_along(E, -1, F, DIST) :- init(at(elevator(E), FE)),
                                  F = #min{ X : below(E, X); X : init(at(elevator(E), X)) },
                                  DIST = |FE - F|.


furthest_along(E, 1, F, DIST) :-  init(at(elevator(E), FE)),
                                  F = #max{ X : above(E, X); X : init(at(elevator(E), X)) },
                                  DIST = |FE - F|.

bidirectional(E) :- { above(E, _) } > 0, { below(E, _) } > 0, agent(elevator(E)).


current_direction(E, 1, 0) :- bidirectional(E),
                              furthest_along(E, 1, _, DA),
                              furthest_along(E, -1, _, DB),
                              DA <= DB.
current_direction(E, -1, 0) :-  bidirectional(E),
                                furthest_along(E, 1, _, DA),
                                furthest_along(E, -1, _, DB),
                                DA > DB.

current_direction(E, 1, 0) :- above(E, _), not bidirectional(E).
current_direction(E, -1, 0) :- below(E, _), not bidirectional(E).


%% #show target/2.
%% #show above/2.
%% #show below/2.
%% #show current_direction/3.
%% #show furthest_along/4.
%% #show furthest_below/3.
%% #show furthest_above/3.
%% #show init/1.
%% #show bidirectional/1.