
// Author URL: http://bikramkawan.com.np
// Email : bikramkawan@gmail.com
// Version: 18.03.2016


 var id ;

  $(document).ready(function(){
$('#plotdata').change(function() {
    attribute=($(this).val());
 id = $(this).children(":selected").attr("id");
    alert(id);


});



 fromdate2 = $("#fromdate2").val();
todate2 = $("#todate2").val();
 



});
$(document).ready(function(){
$("#showplot").click(function(){
      alert(attribute+"  "+ fromdate2+" "+ todate2);
 
     
   //    console.log(speedlimit1);

   $.ajax({
        data:"fromdate2="+fromdate2+"&todate2="+todate2+"&attribute="+attribute+"&action=showcomment",
       // type='text',   
                      
        method:'GET',
        url:'ajaxhelper/plotwholedata.php',
        success:function(res1){
              
   //$(".results").html(res);
          drawChart(res1)
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

        $("#fromdate2").datepicker({ dateFormat: 'yy-mm-dd' }).bind("change",function(){
          var fromdate2 = $(this).val();
         
                
            })
        $("#todate2").datepicker({ dateFormat: 'yy-mm-dd' }).bind("change",function(){
          var todate2 = $(this).val();
          
         
                
            })

    } );



// End of Date range selection 


//Google Chart Function call Start 

   // Load the Visualization API and the piechart package.
    google.load('visualization', '1', {'packages':['corechart']});

    // Set a callback to run when the Google Visualization API is loaded.
    google.setOnLoadCallback(drawChart);

    function drawChart(res1) {
 
      // console.log(jsonData);
      var array  = JSON.parse(res1);
      // Create our data table out of JSON data loaded from server.
      console.log(array);
      var data = new google.visualization.DataTable(array);
      var options = {
           title: attribute,
          is3D: 'true',
          curveType: 'function',
          width: 600,
          height: 450,

      hAxis:    {
  title: 'Time',
  titleTextStyle: {
    color: '#FF0000'
  }
},
      vAxis:    {
  title: id,
  titleTextStyle: {
    color: '#FF0000'
  }
}
        };
      // Instantiate and draw our chart, passing in some options.
      // Do not forget to check your div ID
      var chart = new google.visualization.LineChart(document.getElementById('wholechart'));
      chart.draw(data, options);
    }
    // End  Google Chart Load