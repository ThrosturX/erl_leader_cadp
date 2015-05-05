-module(ring).
-export([init/1]).

% We shall create N processes, assign a number x: 0 <= x < N to each process randomly.
% The pairs (process, x) will be placed into a list where each process knows the x of the next process in the list (or the first one if it was the last).


init(N) -> 
	random:seed(now()),
	List = random_list(N),
	create_ring(N, List).

random_list(N) ->
	List = create_list(N),
	Randomized = randomize(List, N).

create_list(N) ->
	create_list(N, []).

create_list(0, L) -> L;
create_list(N, L) ->
	create_list(N-1, [N-1] ++ L).

randomize(T) ->
	L = lists:sort(T),
	X = [M || {_, M} <- L].

randomize(L, N) ->
	R = rand_list(N, []),
	T = lists:zip(R, L),
	randomize(T).

rand_list(0, L) -> L;
rand_list(N, L) ->
	rand_list(N-1, [random:uniform()] ++ L).
	
create_ring(N, L) -> 
	P = ring_processes(N),
	link_ring(P, L).

% Creates N processes, returns them as a list
ring_processes(N) -> 0.

% link_ring/2: tells each process in the ring who his neighbor is after giving them all IDs (sequential is fine)
