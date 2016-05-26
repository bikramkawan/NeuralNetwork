
// Author URL: http://bikramkawan.com.np
// Email : bikramkawan@gmail.com
// Version: 18.03.2016


$(document).ready(function(){
$("#showdata1").click(function(){
 
      fromdate1 = $("#fromdate").val();
      todate1 = $("#todate").val();
 

   $.ajax({
        data:"fromdate="+fromdate1+"&todate="+todate1+"&action=showcomment",
       // type='text',   
                      
        method:'GET',
        url:'ajaxhelper/googlechart.php',
        success:function(res){
              
   //$(".results").html(res);
        //  console.log(res);
          drawChart(res)
              return true;


        },
       error:function(e){

        alert("Ajax failed");
        return false;
       }

 
   });



});
});
   
 $(function(){
        //$("#to").datepicker({ dateFormat: 'yy-mm-dd' });

        $("#fromdate").datepicker({ dateFormat: 'yy-mm-dd' }).bind("change",function(){
          var fromdate = $(this).val();
         
                
            })
        $("#todate").datepicker({ dateFormat: 'yy-mm-dd' }).bind("change",function(){
          var todate = $(this).val();
          
         
                
            })

    } );



// End of Date range selection 


//Google Chart Function call Start 

   // Load the Visualization API and the piechart package.
    google.load('visualization', '1', {'packages':['corechart']});

    // Set a callback to run when the Google Visualization API is loaded.
   google.setOnLoadCallback(drawChart);

    function drawChart(res) {
     // alert (res);
      // var jsonData = $.ajax({
      // url: "graphplotajax.php",
      // dataType:"json",
      // async: false
      // }).responseText;
      
      var array  = JSON.parse(res);
     // console.log(array);

      // Create our data table out of JSON data loaded from server.
     
      var data = new google.visualization.DataTable(array);
      //console.log(data);
      
      var view = new google.visualization.DataView(data);
  
       view.setColumns([0,1]);
        console.log (view);
       var view1 = new google.visualization.DataView(data);
       view1.setColumns([2,3]);
         console.log (view1);

       var joinedData = google.visualization.data.join(view, view1, 'full', [[0, 0]], [[1,1]]);
   

      var chart = new google.visualization.LineChart(document.getElementById('chart'));

    //      chart.draw(joinedData,{
    //     height: 300,
    //     width: 500,
    //     backgroundColor: { fill:'transparent' },
    //     title:"Target Data vs Output Data",
    //     hAxis: {
    //                 title: "Longitude"
                    
    //             },
    //       vAxis: {
    //                 title: "Latitude "
                    
    //             },
    //     interpolateNulls: true
    // });
 

  var options = {
   
      width:600,
      height:500,

        
        title:"Target Data vs Output Data",
        hAxis: {
                    title: "Longitude"
                    
                },
          vAxis: {
                    title: "Latitude "
                    
                },
           
        interpolateNulls: true,
    explorer: {
      maxZoomOut:2,
      keepInBounds: true
    } 

  };





      chart.draw(joinedData, options);
    }


    // End  Google Chart Load





