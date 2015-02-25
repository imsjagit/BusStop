var util = require('util');
var Parse = require('parse').Parse;
var fs = require("fs");
var sync = require('synchronize')
var csv = require("fast-csv");

Parse.initialize('c16RZrYs6T08TRQ0BAjLVCYt7xrlEDQkN25jyOWJ','PQLqPbetpTu3lGaVH2bFgbXvTfkX5Of7c469Q613')

var Schedule = Parse.Object.extend('Schedule');
var Driver = Parse.Object.extend('Driver');

var driverQuery = new Parse.Query(Driver);
var driverDict = new Array();
var fileName = ""

//Check for file parameter
if (process.argv < 2){
	util.log("No file name given");
}else{
	fileName = "./" + process.argv[2];	
}

//Step 1: Setup driver objects
var loadDrivers = function(){
	driverQuery.find({
		success: function(drivers){
			for (var i = 0; i < drivers.length; ++i) {
			  var driver = drivers[i]
			  var code = driver.get('code');
		  
		  	  util.log("Driver: " + driver.get('name'));
		  	  
			  driverDict[code] = driver;
			}				
			//Start loading schedules
 		  	loadSchedules()
		},
		error: function(error){
		}
	});
}

// Step 2: Load schedule
var loadSchedules = function(){
	util.log("Start loading schedule") 

	///Read file
	var count = 1;

	var parseSchedules = [];
	
	//Process file
	csv
 	.fromPath(fileName)
 	.on("data", function(data){
 		if(count++ > 0){
 			util.log(data);
 			//Insert data row
			createParseSchedule(data, parseSchedules)
 		}
 	});
}

var createParseSchedule = function(data, parseSchedule){
	var date = new Date(data[0]);
	var job1 = driverDict[data[1]];
	var job2 = driverDict[data[2]];

	if (typeof job1 == 'undefined'){
		job1 = driverDict['nn'];
	}
	if (typeof job2 == 'undefined'){
		job2 = driverDict['nn'];
	}

	var schedule = new Schedule();
	
	schedule.set("date", date); 
	schedule.set("job1", job1); //util.log(util.inspect(job1));
	schedule.set("job2", job2); //util.log(util.inspect(job2));

	schedule.save(null, {
		success: function(newSchedule) {
		// Execute any logic that should take place after the object is saved.
		util.log('New schedule created with objectId: ' + newSchedule.id);
		},
		error: function(newTerm, error) {
		// Execute any logic that should take place if the save fails.
		// error is a Parse.Error with an error code and message.
		util.log('Failed to create new schedule, with error code: ' + error.message);
		}
	});
}

	//Start process
	loadDrivers();
