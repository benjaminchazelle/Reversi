
board = [];

playable = [];

whiteCount = 0;
blackCount = 0;

TwoHumanPlayer = false;
blackPlay = true;

function refresh() {

	whiteCount = 0;
	blackCount = 0;

	for(var j = 0; j < 8; j++) {
		for(var i = 0; i < 8; i++) {
			var n = j*8 + i;
			var _case = document.getElementById('case_'+n);
			var pion = document.getElementById('pion_'+n);
			
			_case.classList.remove("playable");

			if(heapBoard.length == 0 && playable.indexOf(n+"") != -1) {
				_case.classList.add("playable");
				
			}	
									
			switch(board[j][i]) {
				case "NO":
					pion.setAttribute("class", "no pion");
					break;
				case "BLACK":
					blackCount++;
					pion.style.display = "block";
					setTimeout(function (pion) {pion.setAttribute("class", "black pion")}, 20, pion);
					
					break;
				case "WHITE":
					whiteCount++;
					pion.style.display = "block";
					setTimeout(function (pion) {pion.setAttribute("class", "white pion")}, 20, pion);
					break;
			}
		}
		boardHtml += "</tr>";
	}
	
	document.getElementById("count").innerHTML = "Black " + blackCount + " - White " + whiteCount;
}

function playMove(id) {

	var coord = id.split("_");
	
	var i = coord[1]%8;
	var j = (coord[1]-i)/8;
	
	var n = coord[1];
	
	var _case = document.getElementById('case_'+n);	

	if(_case.classList.contains("playable")) {

		board[j][i] = blackPlay ? "BLACK" : "WHITE";
		
		if(TwoHumanPlayer) {
			blackPlay = !blackPlay;
		}
		
		socket.emit('app', {command : "play", content : n});
		
		playable = [];
		
		refresh();
	}
}



boardHtml = "";

for(var j = 0; j < 8; j++) {
	board[j] = [];
	boardHtml += "<tr>";
	for(var i = 0; i < 8; i++) {
		board[j][i] = "NO";
		var n = j*8 + i;
		boardHtml += '<td onclick="playMove(\'pion_'+n+'\', this)"><div class="case" id="case_'+n+'"><div style="display:none;" id="pion_'+n+'"  class="no pion"></div></div></td>';
	}
	boardHtml += "</tr>";
}
document.getElementById("board").innerHTML = boardHtml;

var socket = io();

heapBoard = [];

function start () {

	var player1 = document.getElementById("player1").value;
	var player2 = document.getElementById("player2").value;

	socket.emit('app', {
		command : 'start',
		content : {
			'player1' : player1,
			'player2' : player2,
		}
	});
	
	if(player1 == "human" && player2 == "human") {
		TwoHumanPlayer = true;
	}
	
	document.getElementById("game").style.display = "";
	document.getElementById("beginning").style.display = "none";
	
}

socket.on('app', function(message){

	switch(message.command) {
	
		case "state.READY_TO_START":
		
			document.getElementById("loading").style.display = "none";
			
			document.getElementById("beginning").style.display = "";	
			
			document.getElementById("fight").onclick = start;											
			
			setInterval(function () {
				if(heapBoard.length) {
				
					board = heapBoard.shift();
					
					var spans = document.querySelectorAll("#title span");				
					
					var span = spans.item(Math.floor(Math.random() * spans.length));
					
					if(span.classList.contains("reverted")) {
						span.classList.remove("reverted");
					} else {
						span.classList.add("reverted");
					}					
					
					refresh();
				}			
			}, 1000);			
		
			break;
			
		case "state.DEAD":
		
			alert("SWIPL est mort")
		
			break;				
			
		case "update":
		
			if(message.content.kind == "board") {
				heapBoard.push(message.content.content);				
				
			} else {
				playable = message.content.content;
			}		
		
			break;
		
	}

});  