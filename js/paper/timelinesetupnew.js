

// Author URL: http://bikramkawan.com.np
// Email : bikramkawan@gmail.com
// Version: 18.03.2016

 // load data via an ajax request. When the data is in, load the timeline
 

var Surge,Sway,Yaw;
var minvalues=[],maxvalues=[];
var arraydata1=[];
var trainingdatarange,testingdatarange;
var trainingandtestidjson=[];
var filter=0;
var ajaxresult=0;
 $(document).ready(function(){

$.getJSON('Matlab/timeline/minmaxvalues.json', function (data1) {


for (var i = 0;i<data1.minmaxrange.minvalues.length ;  i++) 
{
  minvalues.push(data1.minmaxrange.minvalues[i]);
  maxvalues.push(data1.minmaxrange.maxvalues[i]);
  $("#t"+i).html("["+minvalues[i]+","+maxvalues[i]+"]");
};
  
});


   $(document).ajaxStart(function(){
        $("#wait").css("display", "block");
    });
    $(document).ajaxComplete(function(){
        $("#wait").css("display", "none");
    });

  $('#timebutton').click(function() {

  filter=1;
  trainingandtestidjson=[];
   filtertimelinejson=[];
//Readings from  User filter inputs    
Surge= $('#Surge').val();
Sway= $('#Sway').val();
Yaw= $('#Yawvelocity').val();
Rollvelocity= $('#Rollvelocity').val();
Pitchvelocity= $('#Pitchvelocity').val();
Positioneast= $('#Positioneast').val();
Positionnorth= $('#Positionnorth').val();
Heading= $('#Heading').val();
Roll= $('#Roll').val();
Pitch= $('#Pitch').val();


alert("Filter Data Recorded Succesfully");

 item = {}
        item ["Surge"] = Surge;
        item ["Sway"] = Sway;
        item ["Yaw"] = Yaw;
        item ["Rollvelocity"] = Rollvelocity;
        item ["Pitchvelocity"] = Pitchvelocity;
        item ["Positioneast"] = Positioneast;
        item ["Positionnorth"] = Positionnorth;
        item ["Heading"] = Heading;
        item ["Roll"] = Roll;
        item ["Pitch"] = Pitch;



        filtertimelinejson.push(item);
 console.log(item); 


//Training Id and Testing id
 
 trainingid= $('#trainingdatarange').val();
  testingid= $('#testingdatarange').val();
  trainmethod = 0 //For choosing divided data set
   
    trainingandtestid={};
    trainingandtestid["trainingid"]=trainingid;
    trainingandtestid["testingid"]=testingid;
    trainingandtestid["trainmethod"]=trainmethod;

    trainingandtestidjson.push(trainingandtestid);




//Timeline Filter Data
  $.ajax({
    
    url: 'Matlab/timeline/generatetimeline.php',
   data:{ filtertimelinejson: filtertimelinejson,trainingandtestidjson: trainingandtestidjson},
    method:'GET',
   
    success: function (data) {
      // hide the "loading..." message
      alert("Time Line Data Succesfully Created by Matlab")
  console.log(data);


  
    },
    error: function (err) {
      console.log('Error', err);
      if (err.status === 0) {
        alert('Failed to load data/basic.json.\nPlease run this example on a server.');
      }
      else {
        alert('Failed to load data/basic.json.');
      }
    }
  });

 

  }); // End for creating filter json




 //For Ploting time line 

$('#plottimeline').click(function() {

//Ajax Call for Generating JSON and Matlab Call
  $.ajax({
    url:'Matlab/timeline/timelinejsondata.json',
    type:'HEAD',
    error: function()
    {
        //file not exists
    alert("Matlab is processing Time-Line Data");
    },
    success: function()
    {
         alert("Matlab successfully generates Time-Line Data");
    }
});



var filename;

if (filter==0)

{

  filename="Matlab/timeline/timelinejsondata1.json";
}
else {
  filename ="Matlab/timeline/timelinejsondata.json"
}

$.getJSON(filename, function (data2) {


  document.getElementById('loading').style.display = 'none';

      // DOM element where the Timeline will be attached
      var container = document.getElementById('visualization');
      console.log(data2);
  
      var array  = data2;

for (var i = 0;i<data2.timelinejsondata.id.length;i++) {
item1 = {};
item1 ["id"] = data2.timelinejsondata.id[i];
item1 ["content"] = ""+data2.timelinejsondata.content[i]+"";
item1 ["start"] = data2.timelinejsondata.start[i];
item1 ["end"] = data2.timelinejsondata.end[i];
 arraydata1.push(item1);
};
      
console.log(arraydata1);
      // Create a DataSet (allows two way data-binding)
      var items = new vis.DataSet(array);

     
      // Configuration for the Timeline
      var options = {
           throttleRedraw:1,
           autoResize:false
      };


      // Create a Timeline
      var timeline = new vis.Timeline(container, arraydata1, options);



});




});
//End for ploting time line


// For Feeding Item number to the Neural Network



  $('#btn').click(function() {

  trainingandtestidjson=[];
 trainingid= $('#trainingdatarange').val();
  testingid= $('#testingdatarange').val();
  trainmethod = 1 //For choosing divided data set
   
    trainingandtestid={};
    trainingandtestid["trainingid"]=trainingid;
    trainingandtestid["testingid"]=testingid;
    trainingandtestid["trainmethod"]=trainmethod;

    trainingandtestidjson.push(trainingandtestid);

      alert("Training ="+trainingid+"  and Testing="+testingid);



      $.ajax({
    
    url: 'Matlab/timeline/trainingandtestidjson.php',
   data:{ trainingandtestidjson: trainingandtestidjson},
    method:'GET',
   
    success: function (data) {
      // hide the "loading..." message
      alert(" Training and Testing Data  Succesfully Recorded by Matlab For Modeling")



  
    },
    error: function (err) {
      console.log('Error', err);
      if (err.status === 0) {
        alert('Failed to load data/basic.json.\nPlease run this example on a server.');
      }
      else {
        alert('Failed to load data/basic.json.');
      }
    }
  });

    });



//Endof feeding item number 





    });