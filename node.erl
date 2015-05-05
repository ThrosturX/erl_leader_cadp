-module(node).
-export([]).

% Comment A

% Comment B

forward(Self, Neighbor, Origin, Msg) when Self =/= Origin -> 
	Neighbor ! {Origin, Msg};
forward(Self, _, Origin, _) -> ok.

