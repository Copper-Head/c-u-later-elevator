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

%% for a non-bidirectional elevator, the direction
%% always stays the same
current_direction(E, D, t) :- current_direction(E, D, t),
                              not bidirectional(E).

current_direction(E, D * -1, t) :- current_direction(E, D, t - 1),
                  							   bidirectional(E),
                  							   holds(at(elevator(E), F1), t),
                  							   furthest_along(E, D, F2, _),
                                   F1 == F2.

current_direction(E, D, t) :- current_direction(E, D, t - 1),
                              bidirectional(E),
                              holds(at(elevator(E), F1), t),
                              furthest_along(E, D, F2, _),
                              F1 != F2.

%% elevator can only move if it did not do an other action
do(elevator(E), move(DIR), t) :- current_direction(E, DIR, t - 1),
                                 holds(at(elevator(E), F1), t - 1),
                                 target(E, F2),
                                 F1 != F2.
                                 %% not do(elevator(E), serve, t).
                                 %% not served(E, F1, t).

do(elevator(E), serve, t) :- holds(at(elevator(E), F), t - 1),
                             target(E, F).

served(E, F, t) :- do(elevator(E), serve, t),
                   holds(at(elevator(E), F), t - 1),
                   target(E, F).

%% holds(at(elevator(1),3),2).
%% holds(request(call(up),1),2).
%% current_direction(1,-1,2).
%% do(elevator(1),serve,2).
%% served(1,3,2).

%% do(elevator(1),move(-1),2).
%% holds(at(elevator(1),2),2).



%% update the elevator position after moving
holds(at(elevator(E), F + DIR), t) :- holds(at(elevator(E), F), t - 1),
                                      do(elevator(E), move(DIR), t).

%% stay on the floor if the elevator served
holds(at(elevator(E), F), t) :- holds(at(elevator(E), F), t - 1),
                                %% served(E, F).
                                do(elevator(E), serve, t).

%% carry the requests along if they were not served on this floor
holds(request(R, F), t) :- holds(at(elevator(E), _), t),
                           holds(request(R, F), t - 1),
                           not served(E, F, t).
%% target(1,3).
%% target(1,1).

%% do(elevator(1),move(1),1).
%% holds(at(elevator(1),3),1).
%% holds(request(call(up),1),1).
%% holds(request(deliver(1),3),1).
%% current_direction(1,-1,1).



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% correct:
%% do(elevator(1),move(1),1).
%% holds(at(elevator(1),3),1).
%% holds(request(call(up),1),1).
%% holds(request(deliver(1),3),1).

%% do(elevator(1),serve,2).
%% holds(at(elevator(1),3),2).
%% holds(request(call(up),1),2).

#show holds/2.
#show do/3.
#show served/3.
#show current_direction/3.

#program check(t). % fulfillment of all requests can, e.g., be checked as follows
%% This is our stopping condition.
%% :- holds(request(_, _), t), query(t).
%% :- do(elevator(E), move(_), t), do(elevator(E), serve, t).

:- query(t), holds(request(R, F), t).
