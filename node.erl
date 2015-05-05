-module(node).
-export([elect/3, process/2]).

% Comment A
elect(Initial, Tid, Npid) ->
	Npid!{election, Tid},
	receive
		{election, Ntid} when Ntid =:= Tid -> announce(Tid);
		{election, Ntid} when Ntid > Tid -> relay(Initial, Npid);
		{election, _} ->
			Npid!{election, Tid},
			receive
				{election, Ntid} when Ntid =:= Tid -> announce(Tid);
				{election, Ntid} when Ntid < Tid -> relay(Initial, Npid);
				{election, Ntid} -> elect(Initial, Ntid, Npid)
			end
	end.

announce(Tid) -> Tid.

relay(Initial, Npid) ->
	receive
		{election, Ntid} when Ntid =:= Initial -> announce(Initial);
		{election, Ntid} -> Npid!{election, Ntid}, relay(Initial, Npid)
	end.
	

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

