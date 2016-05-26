
// Author URL: http://bikramkawan.com.np
// Email : bikramkawan@gmail.com
// Version: 18.03.2016



var Rval=[];
var Pval=[];
var corval_Y;
var ylabel;
var corrindex_X=[];
var Rval1_y=[],Pval1_y=[],Rval2_y=[],Pval2_y=[],Rval3_y=[],Pval3_y=[],Rval4_y=[],Pval4_y=[],Rval5_y=[],Pval5_y=[];
var Rval6_y=[],Pval6_y=[],Rval7_y=[],Pval7_y=[],Rval8_y=[],Pval8_y=[],Rval9_y=[],Pval9_y=[],Rval10_y=[],Pval10_y=[];
var yval2=[];
var xvalues=["Surge Velocity[m/s]","Sway Velocity[m/s]","Yaw Velocity[deg/s]","Roll Velocity[deg/s]","Pitch Velocity[deg/s]","Position East[m]","Position North[m]","Heading[deg]","Roll[deg]","Pitch[deg]"]
var index_xvalue=[];

$(document).ready(function(){


//Block for Generating JSON Data
   $(document).ajaxStart(function(){
        $("#wait").css("display", "block");
    });
    $(document).ajaxComplete(function(){
        $("#wait").css("display", "none");
    });

  $('#generatecorrdata').click(function() {



  $.ajax({
    
    url: 'Matlab/correlation/generatecorrdata.php',
   data:{ cleaningid: cleaningid},
    method:'GET',
   
    success: function (data) {
      // hide the "loading..." message
      alert("Correlation Process was successfully done by Matlab")
	
  
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

  });

//Block For preparation for selecting variables to show correlation data.

$('#corrx').change(function() {
    attribute=($(this).val());

 corval_Y = $(this).children(":selected").attr("id");



});


//Block For Plot Bar Chart

$('#corrbar').click(function () {


  //Block for Muliple Parameters Filterd
  $('#multiple :selected').each(function(i, sel){ 

//    console.log( $(sel).val()); 
    corrindex_X.push(parseFloat($(sel).val()));


});



   $.ajax({
    url:'Matlab/correlation/corrdata.json',
    type:'HEAD',
    error: function()
    {
        //file not exists
    alert("Matlab is processing Correlation Data");
    },
    success: function()
    {
         alert("Matlab successfully generates Correlation Data");
    }
});
 //Plot for Bar Chart Continues
  $.getJSON('Matlab/correlation/corrdata.json', function (data) {
  
 // console.log(data);
   // console.log(data.corrdata.R[0][9])

   
for (var i = 0; i <data.corrdata.P.length; i++) {
    
  for (var j = 0; j <data.corrdata.P.length; j++)
  {


  Rval.push((data.corrdata.R[i][j]));
  Pval.push((data.corrdata.P[i][j]));


   }
 // timeseries.push(parseFloat(data.heading[i][2]));
//console.log(Rval);
  
};

//Data splitted for all attributes
//1.  surge_vel[m/s], 
// 2.  sway_vel[m/s],
// 3.  yaw_vel[deg/s], 
// 4.  roll_vel[deg/s], 
// 5.  pitch_vel[deg/s], 
// 6.  pos_x[m],   (Position East)
// 7.   pos_y[m],   (Position North)
// 8.  heading[deg], 
// 9.  roll[deg], 
// 10. pitch[deg],

//Slice Value
s0=0;s1=10;s2=20;s3=30;s4=40;s5=50;s6=60;s7=70;s8=80;s9=90;s10=100;


Rval1= Rval.slice(s0,s1);                 Pval1= Pval.slice(s0,s1);
Rval2= Rval.slice(s1,s2);                 Pval2= Pval.slice(s1,s2);
Rval3= Rval.slice(s2,s3);                 Pval3= Pval.slice(s2,s3);
Rval4= Rval.slice(s3,s4);                 Pval4= Pval.slice(s3,s4);               
Rval5= Rval.slice(s4,s5);                 Pval5= Pval.slice(s4,s5);
Rval6= Rval.slice(s5,s6);                 Pval6= Pval.slice(s5,s6);
Rval7= Rval.slice(s6,s7);                 Pval7= Pval.slice(s6,s7);
Rval8= Rval.slice(s7,s8);                 Pval8= Pval.slice(s7,s8);
Rval9= Rval.slice(s8,s9);                 Pval9= Pval.slice(s8,s9);
Rval10= Rval.slice(s9,s10);               Pval10=Pval.slice(s9,s10);

//console.log(Rval1[9]);





 //Making Ready for Data for Plot Function 

 //If Case 1 = Surge Velocity 
if(corval_Y==1) { 

    var plotdatay1=[],plotdatay2=[],index_xvalue=[];

    for (var k = 0; k <corrindex_X.length; k++)
  {
    Rval1_y.push(Rval1[corrindex_X[k]]); 
    Pval1_y.push(Pval1[corrindex_X[k]]); 
    index_xvalue.push(xvalues[corrindex_X[k]]);  }

 
  plotdatay1 = Rval1_y;      plotdatay2 = Pval1_y;  
  
    ylabel = "Surge Velocity"; 
  }

// Case 2 = Sway Velocity 
if(corval_Y==2) 
{ 
    var plotdatay1=[],plotdatay2=[],index_xvalue=[];

  for (var k = 0; k <corrindex_X.length; k++)
  {
    Rval2_y.push(Rval2[corrindex_X[k]]); 
    Pval2_y.push(Pval2[corrindex_X[k]]); 
    index_xvalue.push(xvalues[corrindex_X[k]]);  
  }
  plotdatay1 = Rval2_y;      plotdatay2 = Pval2_y;

   ylabel = "Sway Velocity";  

}

// Case 3 = Yaw Velocity 
if(corval_Y==3) 
{ 
    var plotdatay1=[],plotdatay2=[],index_xvalue=[];

  for (var k = 0; k <corrindex_X.length; k++)
  {
    Rval3_y.push(Rval3[corrindex_X[k]]); 
    Pval3_y.push(Pval3[corrindex_X[k]]); 
    index_xvalue.push(xvalues[corrindex_X[k]]);  
  }
  plotdatay1 = Rval3_y;      plotdatay2 = Pval3_y; 

     ylabel = "Yaw Velocity";  

}
 

 // Case 4 = Roll  Velocity 
if(corval_Y==4) 
{ 
   var plotdatay1=[],plotdatay2=[],index_xvalue=[];

  for (var k = 0; k <corrindex_X.length; k++)
  {
    Rval4_y.push(Rval4[corrindex_X[k]]); 
    Pval4_y.push(Pval4[corrindex_X[k]]); 
    index_xvalue.push(xvalues[corrindex_X[k]]);  
  }
  plotdatay1 = Rval4_y;      plotdatay2 = Pval4_y; 

     ylabel = "Roll Velocity";  

}  


 // Case 5 = Pitch Velocity 
if(corval_Y==5) 
{ 
    var plotdatay1=[],plotdatay2=[],index_xvalue=[];

  for (var k = 0; k <corrindex_X.length; k++)
  {
    Rval5_y.push(Rval5[corrindex_X[k]]); 
    Pval5_y.push(Pval5[corrindex_X[k]]); 
    index_xvalue.push(xvalues[corrindex_X[k]]);  
  }
  plotdatay1 = Rval5_y;      plotdatay2 = Pval5_y; 

     ylabel = "Pitch Velocity";  

}   

 // Case 6 = Position East
if(corval_Y==6) 
{ 
    var plotdatay1=[],plotdatay2=[],index_xvalue=[];

  for (var k = 0; k <corrindex_X.length; k++)
  {
    Rval6_y.push(Rval6[corrindex_X[k]]); 
    Pval6_y.push(Pval6[corrindex_X[k]]); 
    index_xvalue.push(xvalues[corrindex_X[k]]);  
  }
  plotdatay1 = Rval6_y;      plotdatay2 = Pval6_y; 

     ylabel = "Position East";  

}   

 // Case 7 = Position North
if(corval_Y==7) 
{ 
    var plotdatay1=[],plotdatay2=[],index_xvalue=[];

  for (var k = 0; k <corrindex_X.length; k++)
  {
    Rval7_y.push(Rval7[corrindex_X[k]]); 
    Pval7_y.push(Pval7[corrindex_X[k]]); 
    index_xvalue.push(xvalues[corrindex_X[k]]);  
  }
  plotdatay1 = Rval7_y;      plotdatay2 = Pval7_y; 

   ylabel = "Position North";  

}   


 // Case 8 = Heading 
if(corval_Y==8) 
{ 
  var plotdatay1=[],plotdatay2=[],index_xvalue=[];

  for (var k = 0; k <corrindex_X.length; k++)
  {
    Rval8_y.push(Rval8[corrindex_X[k]]); 
    Pval8_y.push(Pval8[corrindex_X[k]]); 
    index_xvalue.push(xvalues[corrindex_X[k]]);  
  }
  plotdatay1 = Rval8_y;      plotdatay2 = Pval8_y; 

    ylabel = "Heading";  

}  

 // Case 9 = Roll
if(corval_Y==9) 
{ 
    var plotdatay1=[],plotdatay2=[],index_xvalue=[];

  for (var k = 0; k <corrindex_X.length; k++)
  {
    Rval9_y.push(Rval9[corrindex_X[k]]); 
    Pval9_y.push(Pval9[corrindex_X[k]]); 
    index_xvalue.push(xvalues[corrindex_X[k]]);  
  }
  plotdatay1 = Rval9_y;      plotdatay2 = Pval9_y; 

   ylabel = "Roll";  

}  

 // Case 10= Pitch  
if(corval_Y==10) 
{ 
    var plotdatay1=[],plotdatay2=[],index_xvalue=[];

  for (var k = 0; k <corrindex_X.length; k++)
  {
    Rval10_y.push(Rval10[corrindex_X[k]]); 
    Pval10_y.push(Pval10[corrindex_X[k]]); 
    index_xvalue.push(xvalues[corrindex_X[k]]);  
  }
  plotdatay1 = Rval10_y;      plotdatay2 = Pval10_y; 

   ylabel = "Pitch";  

}  




console.log(plotdatay1);
console.log(plotdatay2);
//Plot Function Data Starts here
var R = {
  x: index_xvalue,
  y: plotdatay1,
  name: 'R',
  type: 'bar'
};

var P = {
x: index_xvalue,
  y: plotdatay2,
  name: 'P',
  type: 'bar'
};

var data = [R, P];

var layout = {yaxis: 
              {title: ylabel},
              barmode: 'group'};


Plotly.newPlot('corrchartarea', data,layout);


  });

});






    });
