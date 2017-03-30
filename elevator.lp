% INSERT NAMES AND EMAIL ADDRESSES OF YOUR GROUP MEMBERS:
%
%

#include <incmode>. % built-in incremental mode of clingo
#show.

#program base.
% static rules go below
#include "planner.lp".

holds(X, 0) :- init(X).


%% The iterative  part
#program step(t).


do(elevator(E), serve, t) :- serve_at(E, F, t),
holds(at(elevator(E), F), t - 1).

do(elevator(E), move(DIR), t) :- current_direction(E, DIR, t),
not serve_at(E, _, t).


%% update the elevator position after moving
holds(at(elevator(E), F + DIR), t) :- holds(at(elevator(E), F), t - 1),
                                      do(elevator(E), move(DIR), t).

%% stay on the floor if the elevator did not move
%% (meaning it either served or did nothing)
holds(at(elevator(E), F), t) :- holds(at(elevator(E), F), t - 1),
                                not do(elevator(E), move(_), t).

%% carry the requests along if they were not fulfilled at this time point
%% by an elevator that had them as targets.
holds(request(call(D), F), t) :-  holds(request(call(D), F), t - 1),
                                  target(E, F),
                                   not serve_at(E, F, t).

holds(request(deliver(E), F), t) :- holds(request(deliver(E), F), t - 1),
                                     target(E, F),
                                     not serve_at(E, F, t).

#show do(A,X,t) : do(A,X,t).
%% #show holds(X,t) : holds(X,t).
%% #show holds/2.
%% #show do/3.
%% #show served/3.
%% #show current_direction/3.
%% #show stop_needed/2.
%% #show target/2.

#program check(t).
%% fulfillment of all requests can, e.g., be checked as follows
%% This is our stopping condition.
:- query(t), holds(request(_, _), t).

#show holds(X,t) : holds(X,t).
