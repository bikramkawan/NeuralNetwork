
// Author URL: http://bikramkawan.com.np
// Email : bikramkawan@gmail.com
// Version: 18.03.2016



$(document).ready(function(){
  var xval=[];
var yval=[];            
var xval1=[];
var yval1=[];  
$("#showdata1").click(function(){
 
      fromdate1 = $("#fromdate").val();
      todate1 = $("#todate").val();
 

   $.ajax({
        data:"fromdate="+fromdate1+"&todate="+todate1+"&action=showcomment",
       // type='text',   
                      
        method:'GET',
        url:'ajaxhelper/nnresultplot.php',
        success:function(res){
                    var array  = JSON.parse(res);
   //$(".results").html(res);
        //  console.log(res);
         console.log(array);
  console.log(array[i].X);
        for (var i = 0; i <array.length; i++) {
    

    
        
    
  parseFloat(xval.push(array[i].X));
  parseFloat(yval.push(array[i].Z));
  parseFloat(xval1.push(array[i].X1));
  parseFloat(yval1.push(array[i].Z1));

   
};
console.log(xval);
console.log(yval);

TESTER = document.getElementById('chart');

data =[{
    x: xval,
    y: yval,
     name: "Actual trajectory"}];

    data1 =[{
    x: xval1,
    y: yval1,
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

Plotly.plot( TESTER, data,layout);
Plotly.plot( TESTER, data1,layout);

              return true;


        },
       error:function(e){

        alert("Ajax failed");
        return false;
       }

 
   });



});
});









// $(document).ready(function(){

//   $("#showdata1").click(function(){
          
                        
//    $.ajax({
//        // data:"fromdate="+fromdate1+"&todate="+todate1+"&action=showcomment",
//        // type='text',   
                      
//         method:'GET',
//         url:'ajaxhelper/nnresultplot.php',
//         success:function(res){
//         var array  = JSON.parse(res);
//         console.log(array);       
//   for (var i = 0; i <array.length; i++) {
    

    
        
    
//    parseFloat(xval.push(array[i].X));
//     parseFloat(yval.push(array[i].Z));
//      parseFloat(xval1.push(array[i].X1));
//     parseFloat(yval1.push(array[i].Z1));

   
// };
// console.log(xval);
// console.log(yval);

// TESTER = document.getElementById('chart');

// data =[{
//     x: xval,
//     y: yval}];

//     data1 =[{
//     x: xval1,
//     y: yval1}];
// var layout = {
//   xaxis: {
//     title: 'Position North'
//   },
//   yaxis: {
//     title: 'Position East'
  
//   },
//   margin: { t: 0 }
  
// };   

// Plotly.plot( TESTER, data,layout);
// Plotly.plot( TESTER, data1,layout);

   






//    //$(".results").html(res);
//         //  console.log(res);
//          // drawChart(res)
//               return true;


//         },
//        error:function(e){

//         alert("Ajax failed");
//         return false;
//        }
//    });
 
//    });




// });
   
 $(function(){
        //$("#to").datepicker({ dateFormat: 'yy-mm-dd' });

        $("#fromdate").datepicker({ dateFormat: 'yy-mm-dd' }).bind("change",function(){
          var fromdate = $(this).val();
         
                
            })
        $("#todate").datepicker({ dateFormat: 'yy-mm-dd' }).bind("change",function(){
          var todate = $(this).val();
          
         
                
            })

    } );


