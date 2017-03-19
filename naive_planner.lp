%% Developing the planner
%% #include "instances/instance-01_3-1.lp".
%% #include "instances/instance-02_3-1.lp".
#include "instances/instance-04_5-2.lp".

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

%% Each needy floor gotta have a path!
needy_floor(F) :- init(request(_, F)).
:- needy_floor(F), not path(_, request(_, F), _, _).

%% Total number of paths cannot be more than requests.
max_order(O) :- O = #count{ T, F : init(request(T, F)) }.
order(1..O) :- max_order(O).
:- { path(_, _, _, _) } > O, max_order(O).

%% One elevator cannot simultaneously handle requests on different floors
%% At first we tried this, but it didn't work, dunno why...
%% :- path(E1, _, O1, _), path(E2, _, O2, _), E1 == E2, O1 == O2.
%% Then we tried this and it worked, but no idea why...
:- agent(elevator(E)), order(O), { path(E, _, O, _) } > 1.


%% Only designated elevators are allowed to take care of deliver requests
:- path(E, request(deliver(E2), _), _, _), E != E2.
:- init(request(deliver(E), F)), not path(E, request(deliver(E), F), _, _).

%% Minimize number of paths
distance_traveled(E, D) :- D = #max{ X : path(E, _, _, X) }, agent(elevator(E)).
total_distance(TD) :- TD = #sum{ D : distance_traveled(_, D) }.
score(STEPS, TD) :- STEPS = #max{ D : distance_traveled(_, D) }, total_distance(TD).

%% first number is the weight (I guess?)
#minimize{ D@2 : score(D, _) }.
#minimize{ STEPS@1 : score(STEPS, D) }.

%% Show commands
#show score/2.
%% #show distance_traveled/2.
%% #show total_distance/1.
#show path/4.
#show init/1.
