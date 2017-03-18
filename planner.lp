
%% Developing the planner
%% #include "instances/instance-01_3-1.lp".
%% #include "instances/instance-02_3-1.lp".
#include "instances/instance-04_5-2.lp".

max_order(O) :- O = #count{ T : init(request(T, F)) }.
order(1..O) :- max_order(O).

#show path/4.

{ path(E, request(TYPE, F), 1, DIST)
    : init(at(elevator(E), EF)),
    DIST=|F - EF| + 1 } 1
    :- init(request(TYPE, F)).

{ path(E, request(TYPEX, F), O + 1, DIST2) }
    :- path(E, request(TYPE, F1), O, DIST1),
    init(request(TYPEX, F)),
    DIST2 = |F1 - F| + 1 + DIST1,
    F1 != F,
    O < OM,
    max_order(OM).

%% Each request can only have one path to it!
:- { path(_, request(TYPE, F), _, _) } > 1, init(request(TYPE, F)).

%% Each request gotta have a path!
:- init(request(TYPE, F)), not path(_, request(TYPE, F), _, _).

%% One elevator cannot simultaneously handle requests on different floors
%% At first we tried this, but it didn't work, dunno why...
%% :- path(E1, _, O1, _), path(E2, _, O2, _), E1 == E2, O1 == O2.
%% Then we tried this and it worked, but no idea why...
:- agent(elevator(E)), order(O), { path(E, _, O, _) } > 1.


%% Only designated elevators are allowed to take care of deliver requests
:- path(E, request(deliver(E2), _), _, _), E != E2.

%% , DIST2 = |F1 - F| + 1 + DIST1

%% Minimize number of paths
%% #minimize{D : path(_, _, _, D) }.
