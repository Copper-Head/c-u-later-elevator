% INSERT NAMES AND EMAIL ADDRESSES OF YOUR GROUP MEMBERS:
% Ilia Kurenkov kurenkov@uni-potsdam.de
% Lisa Raithel lraithel@uni-potsdam.de

#include <incmode>. % built-in incremental mode of clingo
#show.

#program base.
% static rules go below
#include "planner.lp".
%% New attempt at finding a global plan
%% Currently can only handle planning for one elevator

holds(X, 0) :- init(X).

%% The iterative  part
#program step(t).

%% move if there was no target to serve and you're not done
do(elevator(E), move(DIR), t) :- current_direction(E, DIR, t - 1),
                                 holds(at(elevator(E), F), t - 1),
                                 not target(E, F, t - 1),
                                 not left_to_do(E, 0, t).

%% serve if you are on a floor and there is a target for you
do(elevator(E), serve, t) :- holds(at(elevator(E), F), t - 1),
                             target(E, F, t - 1).

%% carry targets along
target(E, F, t) :- target(E, F, t - 1),
                   not served(E, F, t).


%% elevator stays on the same floor if it served
holds(at(elevator(E), F), t) :- do(elevator(E), serve, t),
                                holds(at(elevator(E), F), t - 1).

%% elevator stays on the same floor if it is done
holds(at(elevator(E), F), t) :- left_to_do(E, 0, t),
                                holds(at(elevator(E), F), t - 1).


%% if elevator moves, the new position is one floor up or down
holds(at(elevator(E), F + DIR), t) :- do(elevator(E), move(DIR), t),
                                      holds(at(elevator(E), F), t - 1).

%% mark a floor as served by an elevator
served(E, F, t) :- do(elevator(E), serve, t),
                   holds(at(elevator(E), F), t).

%% carry a request along if there exists a target and it was not served
holds(request(call(DIR), F), t) :- holds(request(call(DIR), F), t - 1),
                                   target(E, F, t - 1),
                                   not served(E, F, t).

holds(request(deliver(E), F), t) :- holds(request(deliver(E), F), t - 1),
                                    target(E, F, t - 1),
                                    not served(E, F, t).

%% decrement the to-do counter if the elevator served a floor
left_to_do(E, N, t) :- left_to_do(E, N, t - 1),
                       not do(elevator(E), serve, t).

left_to_do(E, N - 1, t) :- left_to_do(E, N, t - 1),
                           do(elevator(E), serve, t).


#show do(A,X,t) : do(A,X,t).
%% #show served/3.
%% #show left_to_do/3.
%% #show not_served/3.

%% #show current_direction/3.
%% #show stop_needed/2.
%% #show target/3.

#program check(t).

#show holds(X,t) : holds(X,t).

%% fulfillment of all requests can, e.g., be checked as follows
%% This is our stopping condition.
:- query(t), target(E, F, t).
:- query(t), holds(request(R, F), t).
