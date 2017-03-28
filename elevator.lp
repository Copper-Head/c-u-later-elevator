% INSERT NAMES AND EMAIL ADDRESSES OF YOUR GROUP MEMBERS:
%
%

#include <incmode>. % built-in incremental mode of clingo
#show.

#program base.
% static rules go below
#include "planner.lp".

holds(X, 0) :- init(X).

start_with(E, move) :- holds(at(elevator(E), F), 0), not target(E, F).
start_with(E, serve) :- holds(at(elevator(E), F), 0), target(E, F).

%% The iterative  part
#program step(t).

first_turn(t) :- t == 1.

%% mark floor as visited after 2 turns.
%% 2 is needed because when we check to see if we should serve, we
%% look at the previous time step.
been_here(E, F, t - 2) :- holds(at(elevator(E), F), t - 2).

%% mark a floor as served by an elevator
served(E, F, t) :- do(elevator(E), serve, t),
                holds(at(elevator(E), F), t).


%% State Transitions
%% init -> move
do(elevator(E), move(DIR), t) :- start_with(E, move),
                                  current_direction(E, DIR, t),
                                  first_turn(t).
%% move -> move
do(elevator(E), move(DIR), t) :- do(elevator(E), move(DIR), t - 1),
                                  current_direction(E, DIR, t),
                                  not target(E, F),
                                  holds(at(elevator(E), F), t - 1).
%% Go past served floors
do(elevator(E), move(DIR), t) :- do(elevator(E), move(DIR), t - 1),
                                  current_direction(E, DIR, t),
                                  target(E, F),
                                  been_here(E, F, _),
                                  holds(at(elevator(E), F), t - 1).
%% serve -> move
do(elevator(E), move(DIR), t) :- do(elevator(E), serve, t - 1),
                                  current_direction(E, DIR, t),
                                  %% todo: think of alternatives!
                                  not done(E, t).

%% init -> serve
do(elevator(E), serve, t) :- start_with(E, serve), first_turn(t).

%% move -> serve
do(elevator(E), serve, t) :- do(elevator(E), move(D), t - 1),
                            not do(elevator(E), serve, t - 1),
                            target(E, F),
                            %% el_step(T),
                            not been_here(E, F, _),
                            %% T < t,
                            holds(at(elevator(E), F), t - 1).

%% done
done(E, t) :- n_steps(E, N), t >= N.

%% update the elevator position after moving
holds(at(elevator(E), F + DIR), t) :- holds(at(elevator(E), F), t - 1),
                                      do(elevator(E), move(DIR), t).

%% stay on the floor if the elevator did not move
%% (meaning it either served or did nothing)
holds(at(elevator(E), F), t) :- holds(at(elevator(E), F), t - 1),
                                do(elevator(E), serve, t).

%% carry the requests along if they were not fulfilled at this time point
%% by an elevator that had them as targets.
holds(request(call(D), F), t) :-  holds(request(call(D), F), t - 1),
                                  target(E, F),
                                   not served(E, F, t).

holds(request(deliver(E), F), t) :- holds(request(deliver(E), F), t - 1),
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
:- query(t), holds(request(_, _), t).
