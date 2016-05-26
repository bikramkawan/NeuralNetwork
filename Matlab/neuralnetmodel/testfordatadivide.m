
%function neuralnetmodeling()

clear;
addpath('../jsonlab');

%% Importing Raw Data 
datasetfilename=loadjson(['../datasetfilename.json']);

data=load(strcat('../',datasetfilename{1,1}));

data=data(:,2:11);          % Complete Shrinked Data

surge_vel= data(:,1);       % Surge_ Velocity
sway_vel=data(:,2);         % sway Velocity
yaw_vel=data(:,3);          % Yaw Veloctiy
roll_vel=data(:,4);         % Roll Velocity    
pitch_vel=data(:,5);        %Pitch Velocity
pos_east = data(:,6);       %Position East 
pos_north= data(:,7);       % Position North
heading= data(:,8);         %Heading
roll = data(:,9);           %Roll
pitch = data(:,10);         %Pitch 

actualtrajectory=[];
neuraloutputjson=[];
heading=[];    
%% Reading JSON files 
%JSON File with settings for inputs and outpus.
datajson=loadjson(['' filesep 'neuraljsonObj.json']);

inputfromjson = datajson{1,1}.neuralinputs;
hiddenlayerfromjson = datajson{1,1}.hiddenlayer;
outputfromjson = datajson{1,1}.neuraloutputs;

%% Data Setup For Neural Network.
%Preparing for Inputs and Outputs for NEural network
inputs=[];
for i=1:length(inputfromjson)
    
 indexforcol = inputfromjson{1,i}   
 inputs = [inputs data(:,str2num(indexforcol))];

end


% Output
outputs=[];
for i=1:length(outputfromjson)
    
 indexforcol1 = outputfromjson{1,i};   
 outputs = [outputs data(:,str2num(indexforcol1))];

end


%%  Neural Networks Block

% Solve an Autoregression Problem with External Input with a NARX Neural Network

% This script assumes these variables are defined:
%
%   inputs - input time series.
%   targets - feedback time series.


inputs=inputs;  %Actual Inputs for Neural Network

targets =outputs; %Actual Targets fro Neural Network


%Filter Data Example
%surge_vel_new=(surge_vel(surge_vel>2.1 & surge_vel<6));


% X = tonndata(inputs,false,false);
% T = tonndata(targets,false,false);

% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
%trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

% Create a Nonlinear Autoregressive Network with External Input
% inputDelays = 1:2;
% feedbackDelays = 1:2;
% hiddenLayerSize = 10;
% net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open',trainFcn);

% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer
% states. Using PREPARETS allows you to keep your original time series data
% unchanged, while easily customizing it for networks with differing
% numbers of delays, with open loop or closed loop feedback modes.
%[x,xi,ai,t] = preparets(net,X,{},T);


%% Setup Division of Data for Training, Validation, Testing

indexid=loadjson(['' filesep 'trainingandtestidjson.json']);
tmptimelineresult = loadjson(['' filesep 'resultjson.json']);
timelineresult=tmptimelineresult.resultjson.indexresult;
trainingid = str2num(indexid{1,1}.trainingid);
testingid = str2num(indexid{1,1}.testingid);
dividingmethod= str2num(indexid{1,1}.trainmethod);

%dividingmethod == 1 means nn will split the data according to the index of
%timeline
if(dividingmethod==1)

  trainInd=timelineresult(trainingid,1):timelineresult(trainingid,2);
  valInd=timelineresult(1,1):timelineresult(end,2);
  testInd=timelineresult(testingid,1):timelineresult(testingid,2);
  dividing ='true';
  
  for k=testInd(1):testInd(end)
      actualtrajectory=[actualtrajectory;data(k,6) data(k,7)];
       heading=[heading;data(k,8)];
       neuraloutputjson=[neuraloutputjson;data(k,6) data(k,7)];
   end
  
end


%dividingmethod == 1 means nn will not split the data according to the
%index of timeline and use random algorithm.

if(dividingmethod~=1)
   net.divideParam.trainRatio = 10/100;
   net.divideParam.valRatio = 15/100;
   net.divideParam.testRatio = 15/100;
   random='true';
   
actualtrajectory=[pos_east pos_north];
actualtrajectory=actualtrajectory(1:2000,:);
neuraloutputjson=actualtrajectory;
 heading=[heading(1:2000)];
end

%}
%% Default settings fro data divisiion.

%{
net.divideFcn = 'divideind';
  trainInd=3000:6000;
  valInd=7000:8000;
  testInd=1:2000;
  
  
  net.divideParam.trainInd= trainInd;
  net.divideParam.valInd= valInd;
  net.divideParam.testInd=testInd;
  
  %% Default  Data Dividing
   net.divideParam.trainRatio = 10/100;
   net.divideParam.valRatio = 15/100;
   net.divideParam.testRatio = 15/100;


%}


% Train the Network
%[net,tr] = train(net,x,t,xi,ai);

% Test the Network
% y = net(x,xi,ai);
% e = gsubtract(t,y);
% performance = perform(net,t,y)

% View the Network
%view(net);

% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
%figure, plotresponse(t,y)
%figure, ploterrcorr(e)
%figure, plotinerrcorr(x,e)

% Closed Loop Network
% Use this network to do multi-step prediction.
% The function CLOSELOOP replaces the feedback input with a direct
% connection from the outout layer.
% netc = closeloop(net);
% netc.name = [net.name ' - Closed Loop'];
% %view(netc);
% [xc,xic,aic,tc] = preparets(netc,X,{},T);
% yc = netc(xc,xic,aic);
% closedLoopPerformance = perform(net,tc,yc)

% Step-Ahead Prediction Network
% For some applications it helps to get the prediction a timestep early.
% The original network returns predicted y(t+1) at the same time it is
% given y(t+1). For some applications such as decision making, it would
% help to have predicted y(t+1) once y(t) is available, but before the
% actual y(t+1) occurs. The network can be made to return its output a
% timestep early by removing one delay so that its minimal tap delay is now
% 0 instead of 1. The new network returns the same outputs as the original
% network, but outputs are shifted left one timestep.
% nets = removedelay(net);
% nets.name = [net.name ' - Predict One Step Ahead'];
% %view(nets);
% [xs,xis,ais,ts] = preparets(nets,X,{},T);
% ys = nets(xs,xis,ais);
% stepAheadPerformance = perform(nets,ts,ys)

%% Neural Network Results (Outputs)
% neuraloutput = cell2mat(ys);
% neuraloutput=neuraloutput';
% neuraloutput=neuraloutput(1:2000,:);
% 
% %% Plot for Figure 
% 
% lengthofplot=(1:2000)';
% 
% 
% plot(neuraloutput(lengthofplot,1),neuraloutput(lengthofplot,2));
% 
% hold on 
% plot(actualtrajectory(lengthofplot,1),actualtrajectory(lengthofplot,2));
% legend('Outputs','Inputs');


%% Preparation for Neural Network JSON 

% actualtrajectory=[];
% neuraloutputjson=[];
% for k=testInd(1):testInd(end)
%     actualtrajectory=[actualtrajectory;data(k,6) data(k,7)];
%     neuraloutputjson=[neuraloutputjson;neuraloutput(k,6) neuraloutput(k,7)];
% end
% 



field1 = 'Predicted';
value1 = {neuraloutputjson};
field2 = 'Actual';
value2 = {actualtrajectory};
field3 = 'Heading';
value3 = {heading};

jsondata = struct(field1,value1,field2,value2,field3,value3);
savejson('neuralnetresult',jsondata,'neuralnetresult.json');

