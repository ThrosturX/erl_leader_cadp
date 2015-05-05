-module(node).
-export([process/2]).

% Comment A

process(Tid, N) -> io:format("Node ID ~w self: ~w neighbour ~w ~n", [Tid, self(), N]).

% Comment B

forward(Self, Neighbor, Origin, Msg) when Self =/= Origin -> 
	Neighbor ! {Origin, Msg};
forward(Self, _, Origin, _) -> ok.

