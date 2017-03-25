% INSERT NAMES AND EMAIL ADDRESSES OF YOUR GROUP MEMBERS:
%
%

#include <incmode>. % built-in incremental mode of clingo

#program base.
% static rules go below
#include "planner.lp".

holds(X, 0) :- init(X).

holds_for_elevator(E, holds(request(R, F), 0)) :- target(E, F),
                                                  holds(at(elevator(E), F), 0),
                                                  holds(request(R, F), 0).

%% The iterative  part
#program step(t).

%% for a non-bidirectional elevator, the direction
%% always stays the same
current_direction(E, D, t) :- current_direction(E, D, t),
                              not bidirectional(E).

%% switch direction if you hit the furthest along floor
current_direction(E, D * -1, t) :- current_direction(E, D, t - 1),
                  							   bidirectional(E),
                  							   holds(at(elevator(E), F1), t),
                  							   furthest_along(E, D, F2, _),
                                   F1 == F2.

%% maintain direction if you still have requests above/below in the
%% current direction
current_direction(E, D, t) :- current_direction(E, D, t - 1),
                              bidirectional(E),
                              holds(at(elevator(E), F1), t),
                              furthest_along(E, D, F2, _),
                              F1 != F2.

%% elevator can only move if it did not perform an action already and
%% if there is no request to be fulfilled
do(elevator(E), move(DIR), t) :- current_direction(E, DIR, t - 1),
                                 holds(at(elevator(E), F), t - 1),
                                 not holds_for_elevator(E, holds(request(_, F), t - 1)).

%% elevator serves if it is on a floor with a request and if this request
%% "belongs" to the elevator
do(elevator(E), serve, t) :- holds(at(elevator(E), F), t - 1),
                             target(E, F),
                             holds_for_elevator(E, holds(request(_, F), t - 1)).

%% mark a floor as served by an elevator
served(E, F, t) :- do(elevator(E), serve, t),
                   holds(at(elevator(E), F), t - 1),
                   target(E, F).

%% make sure a request belongs to an elevator
%% (I know, stupid predicate name)
holds_for_elevator(E, holds(request(R, F), t)) :- target(E, F),
                                                  holds(at(elevator(E), F), t),
                                                  holds(request(R, F), t).

%% update the elevator position after moving
holds(at(elevator(E), F + DIR), t) :- holds(at(elevator(E), F), t - 1),
                                      do(elevator(E), move(DIR), t).

%% stay on the floor if the elevator did not move
%% (meaning it either served or did nothing)
holds(at(elevator(E), F), t) :- holds(at(elevator(E), F), t - 1),
                                not do(elevator(E), move(_), t).

%% carry the requests along if they were not fulfilled on this floor
holds(request(R, F), t) :- holds(at(elevator(E), _), t),
                           holds(request(R, F), t - 1),
                           not served(E, F, t).


#show holds/2.
#show do/3.
%% #show served/3.
%% #show current_direction/3.
%% #show holds_for_elevator/2.
%% #show target/2.
%% #show bidirectional/1.

#program check(t).
%% fulfillment of all requests can, e.g., be checked as follows
%% This is our stopping condition.
:- query(t), holds(request(R, F), t).
