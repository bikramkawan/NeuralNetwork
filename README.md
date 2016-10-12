# NeuralNetwork

Acess Demo from here :  http://bit.ly/1U9DtcH
<br>
This is the part for the fullfilment of my Master Thesis - "Neural Network Time Series Prediction of Ship Motion" 
<br>The App is not fully working in github.Matlab should be run in background. Inorder to run in localhost, download all repo. Rename index.html to index.php. Your computer should be loaded with Matlab. I am using Mac version of Matlab. So if your machine is windows the matlab calling from php should be modified i.e. inside "Matlab" Folder.
<br><br>The Demo video is uploaded in https://www.youtube.com/watch?v=vXMjaXEnPBQ
<br><br>The webpage is written in PHP, CSS and HTML. User are allowed to upload CSV or txt file dataset from the frontend. It is then stored in local sever. The information of user input from webpage is stored in JSON data structure. AJAX request is sent to the server once user has finished submitting information. Then message is displayed in frontend for user saying JSON file is created. Matlab is called by PHP file script to execute m-file (Matlab script file) by the use of command line execution function. The necessary information for Matlab script is obtained from the JSON file with information submitted by user. The Matlab runs silently in background and the result is stored in JSON format after the completion of Matlab process. The plotting library Plot.ly uses the JSON file created by Matlab to plot the results. Ship simulation of motion is performed using webGL with the coordinates generate by Matlab in JSON.

