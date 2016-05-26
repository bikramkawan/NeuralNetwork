
// Author URL: http://bikramkawan.com.np
// Email : bikramkawan@gmail.com
// Version: 18.03.2016

 

 var cleaningid ;
   var xval=[];
var yval=[]; 
var timeseries=[]; 

  $(document).ready(function(){
$('#dataclean').change(function() {
    attribute=($(this).val());
 cleaningid = $(this).children(":selected").attr("id");
   alert("You have selected Phase shifting Correction");


});
  

     $(document).ajaxStart(function(){
        $("#wait").css("display", "block");
    });
    $(document).ajaxComplete(function(){
        $("#wait").css("display", "none");
    });
  $('#cleaning').click(function() {

  
  $.ajax({
    
    url: 'Matlab/datacleaning/generatedatacleaning.php',
   data:{ cleaningid: cleaningid},
    method:'GET',
   
    success: function (data) {
      // hide the "loading..." message
      alert("Data Cleaning was Succesfully done by Matlab")
	var array  = JSON.parse(data);


//   console.log(array.heading.length);
//   console.log(array.heading[0][1]);
//         for (var i = 0; i <array.length; i++) {
    
    
//   parseFloat(xval.push(array[i].0));
//   parseFloat(yval.push(array[i].0));


   
// };
// console.log(xval);
// console.log(yval);
	
    
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



///Plot for Heading Before Correction and After Correction
$('#headingcleaned').click(function () {

  $.ajax({
    url:'Matlab/datacleaning/heading.json',
    type:'HEAD',
    error: function()
    {
        //file not exists
    alert("Matlab is processing Heading Data");
    },
    success: function()
    {
         alert("Matlab successfully generates Heading Data");
    }
});




  $.getJSON('Matlab/datacleaning/heading.json', function (data) {
    console.log(data);

for (var i = 0; i <data.heading.length; i++) {
    
    
  xval.push(parseFloat(data.heading[i][0]));
  yval.push(parseFloat(data.heading[i][1]));
  timeseries.push(parseFloat(data.heading[i][2]));


   
};
console.log((xval));
console.log(yval);

TESTER = document.getElementById('headingcleanedchart');

data =[{
    x: timeseries,
    y: xval,
     name: "Heading Before Correction"}];


    data1 =[{
    x: timeseries,
    y: yval,
    mode: 'lines',
    line: {
     dash: 'dot', 
    color: 'rgb(255, 0, 0)',
    width:2
  },
    name: "Heading After Correction"}];

var layout = {
  xaxis: {
    title: 'Timeseries'
  },
  yaxis: {
    title: 'Heading (degree)'
  
  },
  
    width :600,
    height:500,
  margin: { t: 0 }
  
  
  
};   

Plotly.plot( TESTER, data,layout);
Plotly.plot( TESTER, data1,layout);





  });
});







});



