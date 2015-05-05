-module(node).
-export([process/2]).

% Comment A

process(Tid, N) -> 
	receive
		{elect} -> 
			elect(Tid, N);
		{election, T} ->
			% missing if
			N ! Tid,
			elect2(Tid, N, T);
		{Sender, Msg} ->
			forward(Tid, N, Sender, Msg)
	end.

% Comment B

forward(Self, Neighbor, Origin, Msg) when Self =/= Origin -> 
	Neighbor ! {Origin, Msg};
forward(Self, _, Origin, _) -> ok.

