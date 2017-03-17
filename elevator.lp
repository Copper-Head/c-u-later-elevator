% INSERT NAMES AND EMAIL ADDRESSES OF YOUR GROUP MEMBERS:
%
%

#include <incmode>. % built-in incremental mode of clingo

#show. % output atoms will be declared below

#program base. % static rules go below
%% This is our starting point
a(0, 0).

#program step(t). % actions, effects, and minimization go below
%% This describes how we change state at each step
b(X, t) :- a(X, t-1).
c(X, t) :- b(X, t-1).

%% #show do(A,X,t) : do(A,X,t). % output atoms indicating actions

#program check(t). % fulfillment of all requests can, e.g., be checked as follows
%% This is our stopping condition.
:- not c(_, t), query(t).


%% #show holds(X,t) : holds(X,t). % output atoms indicating states
% :- query(t), holds(request(R,F),t).
