var fs = require('fs');
var app = require('express')();
var http = require('http').Server(app);
var { spawn } = require('child_process');
var io = require('socket.io')(http);

app.get('/', function(req, res){
	res.sendFile(__dirname + '/board.html');
});

app.get('/style.css', function(req, res){
	res.sendFile(__dirname + '/style.css');
});

app.get('/script.js', function(req, res){
	res.sendFile(__dirname + '/script.js');
});

class Party {
	
	constructor(socket) {
		
		var self = this;
		
		self.socket = socket;
		
		self.state = "NOT_STARTED";
		
		self.buffer = "";		
		
		if(fs.existsSync('ReversoMerged.pl')) {
			self.process = spawn('swipl', ['ReversoMerged.pl']);				
		} else {
			self.process = spawn('swipl', ['../ReversoMerged.pl']);
		}
				
		self.process.on('exit', (code) => {
			self.setState("DEAD");
		});
		
		self.process.stdout.on('data', (data) => {
			
			self.buffer += data.toString();
			
			self.parseBuffer();
		});	

		self.process.stderr.on('data', (data) => { 
		
			if(data.toString().indexOf("Welcome to SWI-Prolog") != -1) {
				self.setState("READY_TO_START");
			}
		});

		self.socket.on('app', function(message){
								
			switch(message.command) {
			
				case "start":
				
					self.start(message.content);
				
					break;				
					
				case "play":
				
					self.playMove(message.content);
				
					break;					
								
			}			
			
		});
	}
	
	start (setting) {
		
		var self = this;
		
		if(self.state != "READY_TO_START")
			return;	
		
		var option = "_";
		
		if(setting.player1 == "mcts50") {
			setting.player1 = "mcts";
			option = 50;
		}
		
		if(setting.player2 == "mcts50") {
			setting.player2 = "mcts";
			option = 50;
		}
		
		console.log('New party :', setting.player1, 'vs', setting.player2);
		
		self.process.stdin.write('init(x, '+setting.player1+', '+setting.player2+', '+option+').\n');
		
		self.setState("STARTED");		
		
	}
	
	setState (newState) {
		
		var self = this;
		
		self.state = newState;
		
		self.socket.emit('app', {"command" : "state." + newState});
	}
	
	playMove(move) {
		
		var self = this;
		
		self.process.stdin.write(move + ".\r\n");		
		
	}
	
	parseBoard (rawBoard) {

		var lines = rawBoard.split("\r\n");
		
		var board = [];
		
		for(var j = 0; j < 8; j++) {
			board[j] = [];
		}
		
		for(var j = 0; j < lines.length && j < 8; j++) {
			
			var line = lines[j];
			
			for(var i = 0; i < 8; i++) {
				board[j][i] = "NO";		
			
				if(line[i] == "x") {
					board[j][i] = "BLACK";	
				}
				
				if(line[i] == "o") {
					board[j][i] = "WHITE";	
				}		
				
			}
			
		}
		
		return board;
		
	}
	
	parsePlayable (rawPlayable) {
		
		return rawPlayable.split("\r\n")[1].trim().split(" ");
		
	}
	
	parseBuffer() {
		
		var self = this;				
		
		var matchBoard = self.buffer.match(/([xo\?]{8}\r\n){8}/);
		
		var matchPlayable = self.buffer.match(/Playable index : \r\n[ 0-9]*\r\n/);
		
		var parseKind = null;
		
		
		if(matchPlayable && !matchBoard) {
			
			parseKind = "Playable";
			
		} else if(!matchPlayable && matchBoard) {
			
			parseKind = "Board";
			
		} else if(matchPlayable && matchBoard) {
			
			if(matchPlayable.index < matchBoard.index) {
			
				parseKind = "Playable";
			
			} else {
				
				parseKind = "Board";
				
			}
						
		}

		if(parseKind == "Board") {
			
			self.buffer = self.buffer.substr(matchBoard.index + matchBoard[0].length);								
					
			self.socket.emit('app', {
				'command' : 'update',
				'content' : {
					"kind" : "board",
					"content" : self.parseBoard(matchBoard[0])
					}
				}
			);				
				
			
		} else if(parseKind == "Playable") {					

			self.buffer = self.buffer.substr(matchPlayable.index + matchPlayable[0].length);								

			self.socket.emit('app', {
				'command' : 'update',
				'content' : {
					"kind" : "playable",
					"content" : self.parsePlayable(matchPlayable[0])
					}
				}
			);			
			
		}
		
		if(parseKind != null) {		
			
			self.parseBuffer();
			
		}
		
	}

	
};

io.on('connection', function(socket){
	
	new Party(socket);
	
});
    

http.listen(5000, function(){
  console.log('Game server listening on port 5000');
});