db = require("monk")("localhost:3001/meteor").get('corpus');
rl = require("readline").createInterface({input: process.stdin});

counts = 0;

rl.on('line', function(line){
	data = JSON.parse(line);
	data.category = process.argv[2];
	data.status = "unchecked";
	db.insert(data,function(){counts++});
});

rl.on('close',function(){
	setTimeout(function(){
		console.log("inserted "+counts);
		process.exit();
	},4000); // Async is brain fucking, I just wait for 4s
})
