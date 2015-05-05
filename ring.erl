-module(ring).
-export([init/1, make_node/5]).

% We shall create N processes, assign a number x: 0 <= x < N to each process randomly.
% The pairs (process, x) will be placed into a list where each process knows the x of the next process in the list (or the first one if it was the last).

init(N) -> 
	Pid = spawn(ring, make_node, [self(), N-1, 0, 0, random_list(N)]),
	receive
		{spawning, Pid, _} -> io:format("done here~n", [])
		after 2000 -> io:format("timeout~n", [])
	end.

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
	
make_node(From, 0, _, First, L) -> 
	%io:format("input list is ~w~n", [L]),
	From ! {spawning, self(), 'hey'},
	%io:format("Node ~w has neighbour ~w~n", [self(), First]),
	node:process(hd(L), First);

	
make_node(From, N, 0, _, [H|L])	->
	%io:format("process nr. ~w id ~w~n", [N, self()]),
	register(list_to_atom(integer_to_list(H)), spawn(ring, make_node, [self(), N-1, 1, self(), L])),
	receive 
		{spawning, Child, _} -> From ! {spawning, self(), 'hey'}, node:process(H, Child) %io:format("Node ~w has neighbour ~w~n", [self(), Child])
		after 2000 -> io:format("timeout~n", [])
	end;
	
make_node(From, N, _, First, [H|L])	->
	%io:format("process nr. ~w id ~w~n", [N, self()]),
	register(list_to_atom(integer_to_list(H)), spawn(ring, make_node, [self(), N-1, 1, First, L])),
	receive 
		{spawning, Child, _} -> From ! {spawning, self(), 'hey'}, node:process(H, Child) %io:format("Node ~w has neighbour ~w~n", [self(), Child])
		after 2000 -> io:format("timeout~n", [])
	end.
	
% link_ring/2: tells each process in the ring who his neighbor is after giving them all IDs (sequential is fine)
