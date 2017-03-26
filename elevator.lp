% INSERT NAMES AND EMAIL ADDRESSES OF YOUR GROUP MEMBERS:
%
%

#include <incmode>. % built-in incremental mode of clingo

#program base.
% static rules go below
#include "planner.lp".

holds(X, 0) :- init(X).

stop_needed(E, 0) :-  target(E, F),
                      holds(at(elevator(E), F), 0),
                      holds(request(_, F), 0).

%% The iterative  part
#program step(t).


%% switch direction if you hit the furthest along floor
current_direction(E, D * -1, t) :- current_direction(E, D, t - 1),
                  							   holds(at(elevator(E), F1), t),
                  							   furthest_along(E, D, F2, _),
                                   F1 == F2.

%% maintain direction if you still have requests above/below in the
%% current direction
current_direction(E, D, t) :- current_direction(E, D, t - 1),
                              holds(at(elevator(E), F1), t),
                              furthest_along(E, D, F2, _),
                              F1 != F2.

%% elevator can only move if it can't serve any requests on this floor
%% and if it has any more floors to serve.
%% This last restriction is in place for the case of multiple elevators:
%% we want those that are "done" to stop moving even if others still are
do(elevator(E), move(DIR), t) :- current_direction(E, DIR, t - 1),
                                 holds(at(elevator(E), F), t - 1),
                                 not stop_needed(E, t - 1),
                                 not left_to_do(E, 0, t - 1).

%% elevator serves if it is on a floor with a request and if this request
%% "belongs" to the elevator
do(elevator(E), serve, t) :- holds(at(elevator(E), F), t - 1),
                             stop_needed(E, t - 1).

%% mark a floor as served by an elevator
served(E, F, t) :- do(elevator(E), serve, t),
                   holds(at(elevator(E), F), t - 1).

%% Decrement number of "todo" floors for an elevator if it served this turn.
left_to_do(E, N, t) :- left_to_do(E, N, t - 1), not do(elevator(E), serve, t).
left_to_do(E, N - 1, t) :- left_to_do(E, N, t - 1), do(elevator(E), serve, t).

%% make sure a request belongs to an elevator
stop_needed(E, t) :-  target(E, F),
                      holds(at(elevator(E), F), t),
                      holds(request(R, F), t).

%% update the elevator position after moving
holds(at(elevator(E), F + DIR), t) :- holds(at(elevator(E), F), t - 1),
                                      do(elevator(E), move(DIR), t).

%% stay on the floor if the elevator did not move
%% (meaning it either served or did nothing)
holds(at(elevator(E), F), t) :- holds(at(elevator(E), F), t - 1),
                                not do(elevator(E), move(_), t).

%% carry the requests along if they were not fulfilled at this time point
%% by an elevator that had them as targets.
holds(request(R, F), t) :- holds(request(R, F), t - 1),
                           target(E, F),
                           not served(E, F, t).

#show do(A,X,t) : do(A,X,t).
#show holds(X,t) : holds(X,t).
%% #show holds/2.
%% #show do/3.
%% #show served/3.
%% #show current_direction/3.
%% #show stop_needed/2.
%% #show target/2.

#program check(t).
%% fulfillment of all requests can, e.g., be checked as follows
%% This is our stopping condition.
:- query(t), holds(request(R, F), t).
