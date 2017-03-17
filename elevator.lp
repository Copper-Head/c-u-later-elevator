% INSERT NAMES AND EMAIL ADDRESSES OF YOUR GROUP MEMBERS:
%
%

#include <incmode>. % built-in incremental mode of clingo

%% #show. % output atoms will be declared below


#program base. % static rules go below
%% This is our starting point

%instances
floor(1).
floor(2).
floor(3).
top_floor(FMAX) :- FMAX = #max{F : floor(F)}.
bottom_floor(FMIN) :- FMIN = #min{F : floor(F)}.
%% Sanity-constraints
:- holds(at(elevator(_), F), _), top_floor(FM), F > FM.
:- holds(at(elevator(_), F), _), bottom_floor(FM), F < FM.

holds(at(elevator(1), 1), 0).
%% do(elevator(1), move(1), 1).
holds(request(call(down), 3), 0).

#program step(t). % actions, effects, and minimization go below
%% This describes how we change state at each step
holds(at(elevator(E), F + 1), t) :- holds(at(elevator(E), F), t - 1),
									do(elevator(E), move(1), t).

%% create new stage if a elevator moved downwards
holds(at(elevator(E), F - 1), t) :- holds(at(elevator(E), F), t - 1),
									do(elevator(E), move(-1), t).

holds(at(elevator(E), F), t) :- holds(at(elevator(E), F), t - 1),
								not do(elevator(E), move(_), t).

%% alternative:
%% if the elevator served on the current floor,
%% create a new fact for the current elevator position
%% holds(at(elevator(E), F), T + 1) :- holds(at(elevator(E), F), T),
%%                                     do(elevator(E), serve, T + 1).

%% create request for current time step if
%% call request was not fulfilled
holds(request(call(D), F1), t) :- holds(request(call(D), F1), t - 1),
                                  not do(elevator(_), serve, t).

do(elevator(E), move(1), t) :- holds(at(elevator(E), F1), t - 1),   % elevator is at floor F1
                               holds(request(call(_), F2), t),  % there is a request from floor 2
                               F1 < F2.%,                         % floor 1 is lower than floor 2
                               %% Y = #max{F : floor(F)},          % the highest floor is Y
                               %% F2 <= Y.                         % floor 2 must be maximal Y

do(elevator(E), serve, t) :- holds(at(elevator(E), F1), t),
                             holds(request(call(_), F2), t - 1),
                             not do(elevator(E), move(_), t),
                             F1 == F2.

%% #show do(A,X,t) : do(A,X,t). % output atoms indicating actions

#program check(t). % fulfillment of all requests can, e.g., be checked as follows
%% This is our stopping condition.
%% :- not holds(at(elevator(1), 3), t), query(t).
%% :- not do(elevator(1), serve, t), query(t).
:- holds(request(call(_), _), t), query(t).
