-module(node).
-export([elect/3, process/2]).

% Comment A
elect(Initial, Tid, Npid) ->
	io:format("Node ~w has value ~w ~n", [Initial, Tid]),
	Npid!{election, Tid},
	receive
		{election, Ntid} when Ntid =:= Tid -> announce(Tid);
		{election, Ntid} when Ntid > Tid -> relay(Initial, Npid);
		{election, _} ->
			Npid!{election, Tid},
			io:format("Node ~w gets message~n", [Initial]),
			receive
				{election, Ntid} when Ntid =:= Tid -> announce(Tid);
				{election, Ntid} when Ntid < Tid -> relay(Initial, Npid);
				{election, Ntid} -> elect(Initial, Ntid, Npid)
			end
	end.

elect1(Initial, Tid, Npid) ->
	io:format("Node ~w has value ~w ~n", [Initial, Tid]),
	Npid!{election, Tid},
	receive 
		{election, A} -> elect2(Initial, Tid, Npid, A)
	end.
elect2(_, Tid, _, A) when A =:= Tid -> 
	announce(Tid);
elect2(Initial, Tid, Npid, A) when A > Tid ->
	relay(Initial, Npid);
elect2(Initial, Tid, Npid, _) ->
	Npid ! {election, Tid},
	receive
		{election, Ntid} when Ntid =:= Tid -> announce(Tid);
		{election, Ntid} when Ntid < Tid -> relay(Initial, Npid);
		{election, Ntid} -> elect1(Initial, Ntid, Npid)
	end.
	

	
announce(Tid) -> io:format("I'm the leader ~w~n", [Tid]), Tid.

relay(Initial, Npid) ->
	io:format("Node ~w is passive ~n", [Initial]),
	receive
		{election, Ntid} when Ntid =:= Initial -> announce(Initial);
		{election, Ntid} -> Npid!{election, Ntid}, relay(Initial, Npid)
	end.
	

process(Tid, N) -> io:format("Node ID ~w self: ~w neighbour ~w ~n", [Tid, self(), N]),
	elect1(Tid, Tid, N).

% Comment B

forward(Self, Neighbor, Origin, Msg) when Self =/= Origin -> 
	Neighbor ! {Origin, Msg};
forward(Self, _, Origin, _) -> ok.

