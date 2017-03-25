% INSERT NAMES AND EMAIL ADDRESSES OF YOUR GROUP MEMBERS:
%
%

#include <incmode>. % built-in incremental mode of clingo

%% #program base. % static rules go below
#include "planner.lp".

holds(X, 0) :- init(X).
%% top_floor(F) :- F = #max{ X : floor(X) }.
%% bottom_floor(F) :- F = #min{ X : floor(X) }.

#program step(t).
%% The iterative  part

%% current_direction(E, D, t) :- current_direction(E, D, t -1),
%%                               not bidirectional(E).
current_direction(E, D, t) :- current_direction(E, D, t - 1),
                              not left_to_do(E, 0, t),
                              furthest_along(E, D, FF, _),
                              holds(at(elevator(E), FE), t - 1),
                              FF != FE.

%% current_direction(E, 1, t) :-  current_direction(E, 1, t - 1),
%%                                 furthest_along(E, 1, FF, _),
%%                                 holds(at(elevator(E), FE), t - 1),
%%                                 FF > FE.

%% current_direction(E, -1, t) :-  current_direction(E, -1, t - 1),
%%                                 furthest_along(E, -1, FF, _),
%%                                 holds(at(elevator(E), FE), t - 1),
%%                                 FF < FE.

current_direction(E, D1 * -1, t) :- current_direction(E, D1, t - 1),
                                    not left_to_do(E, 0, t),
                                    furthest_along(E, D1, FF, _),
                                    holds(at(elevator(E), FE), t - 1),
                                    FF == FE.

do(elevator(E), serve, t) :-  holds(at(elevator(E), F), t - 1),
                              holds(request(_, F), t -1),
                              target(E, F).

%% served(E, F) :- do(elevator(E), serve, t),
%%                 holds(at(elevator(E), F), t).

left_to_do(E, R, t) :- left_to_do(E, R, t -1), not do(elevator(E), serve, t).
left_to_do(E, R - 1, t) :- left_to_do(E, R, t -1), do(elevator(E), serve, t).

%% How do we ensure we stay inside building?
do(elevator(E), move(DIR), t) :- current_direction(E, DIR, t),
                               %% holds(at(elevator(E), F), t - 1),
                               not do(elevator(E), serve, t).

%% do(elevator(E), move(-1), t) :- current_direction(E, down, t),
%%                                 holds(at(elevator(E), F), t - 1),
%%                                 not target(E, F).

holds(at(elevator(E), F + DIR), t) :- holds(at(elevator(E), F), t - 1),
                                      do(elevator(E), move(DIR), t).

holds(at(elevator(E), F), t) :- holds(at(elevator(E), F), t - 1),
                                not do(elevator(E), move(_), t).

%% requests
%% holds(request(R, F), t) :- holds(request(R, F), t - 1),
%%                            target(E, F),
%%                            not do(elevator(E), serve, t).

holds(request(R, F), t) :- holds(request(R, F), t - 1).


#program check(t). % fulfillment of all requests can, e.g., be checked as follows
%% This is our stopping condition.
%% :- query(t), t > 4.
%% :- not holds(at(elevator(1), 3), t), query(t).
%% :- not do(elevator(1), serve, t), query(t).
%% :- holds(request(_, _), t), query(t).
:- query(t), left_to_do(_, R, t), R != 0.

#show holds/2.
#show do/3.
