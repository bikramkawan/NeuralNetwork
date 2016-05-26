
// Author URL: http://bikramkawan.com.np
// Email : bikramkawan@gmail.com
// Version: 18.03.2016


 var neuralinputs,hiddenlayer,neuraloutputs=[];
var neuralnetjson=[];
var neuralresult_actual=[],neuralresult_predicted=[],actualresult=[];
var  actualresultx=[], actualresulty=[];
var predictedresultx=[],predictedresulty=[];

var neuralsname =["Surge Velocity","SwayVelocity","Yaw Velocity","Roll Velocity","Pitch Velocity","Position East","Position North","Heading","Roll","Pitch"];

var neuralinputs1=[], neuraloutputs1=[];
$(document).ready(function(){


$('#neuralnetmodel').click(function () {
  neuralinputs=[];
  hiddenlayer ;
 neuraloutputs=[];
  var neuralnameinput=[], neuralnameoutput=[];
  //Read Inputs for Neural Net
  $('#inputs :selected').each(function(i, sel){ 

      neuralinputs.push(parseFloat($(sel).val()));
 
  });


// Hidden Layer 

   hiddenlayer = parseFloat($('#hiddennet').val());


    //Read Output for Neural Net
  $('#outputs :selected').each(function(i, sel){ 
   neuraloutputs.push(parseFloat($(sel).val()));
  });

for (var i =0;i<neuralinputs.length; i++) {
    
  neuralnameinput.push(neuralsname[neuralinputs[i]-1]);
};

for (var i =0;i<neuraloutputs.length; i++) {
    
  neuralnameoutput.push(neuralsname[neuraloutputs[i]-1]);
};

    var nninputs = neuralnameinput;
   var hiddenlayer = $('#hiddenin').val();
   var nntarget =   neuralnameoutput;

   $.ajax({
      type: 'POST',
      url: 'ajaxhelper/neuralsetup.php',
      
      data: { nninputs: neuralnameinput, hiddenlayer: hiddenlayer , nntarget: neuralnameoutput},
      success: function(response) {

        alert("Inputs ="+neuralnameinput+", Hidden ="+hiddenlayer+" Output="+neuralnameoutput);
       
      $.colorbox({html:response,
         scrolling: false,
         preloading: false,});

      }
   });






});





//Read Data  Neural Networks 
$('#neuralnet').click(function () {

neuralinputs=[];
hiddenlayer=2;
neuraloutputs=[];
 // // Read Inputs for Neural Net
  $('#inputs :selected').each(function(i, sel){ 

   neuralinputs.push(parseFloat($(sel).val()));
	});


//Hidden Layer 

 hiddenlayer = parseFloat($('#hiddennet').val());


    //Read Output for Neural Net
  $('#outputs :selected').each(function(i, sel){ 

   neuraloutputs.push(parseFloat($(sel).val()));
	});


console.log(neuralinputs);
 console.log((hiddenlayer));
console.log(neuraloutputs);

    item = {}
        item ["neuralinputs"] = neuralinputs;
        item ["hiddenlayer"] = hiddenlayer;
        item ["neuraloutputs"] = neuraloutputs;

        neuralnetjson.push(item);

//alert(neuralnetjson);
//console.log(neuralnetjson);

//Ajax Call for Generating JSON and Matlab Call

   $(document).ajaxStart(function(){
        $("#wait").css("display", "block");
    });
    $(document).ajaxComplete(function(){
        $("#wait").css("display", "none");
    });
  $.ajax({
    
    url: 'Matlab/neuralnetmodel/generateneuralmodel.php',
   data:{ neuralnetjson: neuralnetjson},
    method:'GET',
   
    success: function (data) {
      // hide the "loading..." message
      alert("Neural Network Algortihm was Succesfully done by Matlab")
	console.log(data);


  
    },
    error: function (err) {
      console.log('Error', err);
      if (err.status === 0) {
        alert('Failed to load json.\nPlease run this example on a server.');
      }
      else {
        alert('Failed to load json.');
      }
    }
  });


})  // End of Making neural net Modeling 


// Preparing for Plot
//Start
$('#nnresult').click(function () {



  $.getJSON('Matlab/neuralnetmodel/neuralnetresult.json', function (data) {
  
console.log(data);

for (var i = 0; i < data.neuralnetresult.Predicted.length; i++) {
    
  
  actualresultx.push(data.neuralnetresult.Actual[i][0]);
  actualresulty.push(data.neuralnetresult.Actual[i][1]);
  
};

for (var i = 0; i < data.neuralnetresult.Predicted.length; i++) {
    
  
  predictedresultx.push(data.neuralnetresult.Predicted[i][0]);
  predictedresulty.push(data.neuralnetresult.Predicted[i][1]);
  
};


console.log(actualresult);
console.log(typeof(actualresultx[0]));
console.log(actualresulty);

data =[{
    x: actualresultx,
    y: actualresulty,
     name: "Actual trajectory"}];

    data1 =[{
    x: predictedresultx,
    y: predictedresulty,
    mode: 'lines',
    line: {
     dash: 'dot', 
    color: 'rgb(255, 0, 0)',
    width:2
  },
    name: "Predictive trajectory"}];
var layout = {
  xaxis: {
    title: 'Position east'
  },
  yaxis: {
    title: 'Position north'
  
  },
  
    width :800,
    height:500,
  margin: { t: 0 }
  
  };   

Plotly.plot( 'chartarea', data,layout);
Plotly.plot( 'chartarea', data1,layout);

}); // End of AJAX Success Call 

});  ///End of PLot





})