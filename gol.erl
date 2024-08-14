-module(gol).
-export([new/2, query/3, print/1, assign/4, demo/0, count_neighbors/3, logic/2, step/3, simulate/1, run/2]).

-record(grid, {height=10, width=10, rows}).
-record(transition, {y, x, state}).

mod(X, Y) when X > 0 -> X rem Y;
mod(X, Y) when X < 0 -> Y + X rem Y;
mod(0, _y) -> 0.

new(Width, Height) ->
	Column = array:new(Height),
	Array2d = array:map(fun(_X,_T) -> 
								array:new([{size, Width},{fixed, true}, {default, empty}]) end, Column),
	#grid{height= Height, width= Width, rows = Array2d}.

print(Grid) ->
	ColumnIndex = lists:seq(0, Grid#grid.width - 1),
	RowIndex = lists:seq(0, Grid#grid.height -1),
	lists:foreach(fun(Y) ->
						  io:format("|"), 
						  lists:foreach(fun(X) ->
												io:format(" ~s |", [draw(query(Grid, Y, X))]) end,
										ColumnIndex),
						  io:format("~n")
				  end,
				  RowIndex).

query(Grid, Y, X) ->
	Row = array:get(mod(Y, Grid#grid.height), Grid#grid.rows),
	array:get(mod(X, Grid#grid.width), Row).

draw(Value) -> 
	case Value of
		empty -> '-';
		alive -> '*'
	end.

assign(Grid, Y, X, State) ->
	Row = array:get(mod(Y, Grid#grid.height), Grid#grid.rows),
	UpdatedRow = array:set(mod(X, Grid#grid.width), State, Row),
	Rows = array:set(mod(Y, Grid#grid.height), UpdatedRow, Grid#grid.rows),
	Grid#grid{rows = Rows}.

demo() ->
	Grid = new(5, 9),
	Grid1 = assign(Grid, 0, 3, alive),
	Grid2 = assign(Grid1, 1,4, alive),
	Grid3 = assign(Grid2, 2,2, alive),
	Grid4 = assign(Grid3, 2,3, alive),
	assign(Grid4, 2, 4, alive).

count_neighbors(Grid, Y, X) ->
	N = query(Grid, Y + 1, X),
	NE = query(Grid, Y + 1, X + 1),
	E = query(Grid, Y, X + 1),
	SE = query(Grid, Y - 1, X + 1),
	S = query(Grid, Y - 1, X),
	SW = query(Grid, Y - 1, X - 1),
	W = query(Grid, Y, X - 1),
	NW = query(Grid, Y + 1, X - 1),
	NeighborStates = [N, NE, E, SE, S, SW, W, NW],
	length(lists:filter(fun(State) -> State == alive end, NeighborStates)).

logic(State, Neighbors) ->
	case State of
		alive -> if
					 Neighbors < 2 -> empty;
					 Neighbors > 3 -> empty;
					 true -> alive
				 end;
		empty -> if
					 Neighbors == 3 -> alive;
					 true -> State
				 end
	end.

step(Grid, Y, X) ->
	State = query(Grid, Y, X),
	Neighbors = count_neighbors(Grid, Y, X),
	NextState = logic(State, Neighbors),
	#transition{y = Y, x = X, state = NextState}.

simulate(Grid) ->
	Rows = array:map(fun(Y, Row) ->
								array:map(fun(X, _Cell) ->
												  Transition = step(Grid, Y, X),
												  Transition#transition.state
										  end, Row)
					 end, Grid#grid.rows),
	Grid#grid{rows = Rows}.

clear() -> 
	io:format("\ec").

run(Grid, N) ->
	clear(),
	UpdatedGrid = simulate(Grid),
	print(UpdatedGrid),
	timer:sleep(1000),
	case N > 0 of
		true -> run(UpdatedGrid, N -1);
		false -> stop()
	end.

stop() ->
	io:format("~n Thanks for playing ~n").
