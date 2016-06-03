% bikramkawan@gmail.com
% Updated 29-May-2016 13:09:37

%% Initializing
% raw_surgevel=data(index:lengthofdata,2); % Surge_ Velocity
% raw_swayvel=data(index:lengthofdata,3); % sway Velocity
% raw_yawvel=data(index:lengthofdata,4); % Yaw Veloctiy
% raw_posx=data(index:lengthofdata,5); %Position East
% raw_posy= data(index:lengthofdata,6); % Position North
% 

tic
close all, clear all, clc, format compact

% ------- load in the data -------
data =load('../vessel_status_old.txt');
%data =load('../vessel_status_new.txt');
datanorm=data;%zscore(data);
trainingstartindex=1;%3000;%1
trainingendindex=1900;%6000


testingstartindex=1;%2000;
testingendindex=1900;%4000;


raw_alldata=datanorm(trainingstartindex:trainingendindex,2:end);

index_posx=6; % Position x 
index_posy=7; % Position y
inputs_data=raw_alldata;
targets_data=[inputs_data(:,index_posx) inputs_data(:,index_posy)];

testing_data=datanorm(testingstartindex:testingendindex,2:end);
testing_target=[testing_data(:,index_posx) testing_data(:,index_posy)];

networkresults=[];
%%
inputs = tonndata(inputs_data,false,false);
targets = tonndata(targets_data,false,false);
test_in = tonndata(testing_data,false,false);
test_target = tonndata(testing_target,false,false);
% Choose a Training Function

trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.
%trainFcn = 'trainbr';  % Levenberg-Marquardt backpropagation.


% Create a Nonlinear Autoregressive Network with External Input
inputDelays = 1:2;
feedbackDelays = 1:2;
hiddenLayerSize = 10;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open',trainFcn);
% net.trainParam.epochs=1000;
% net.trainParam.mu=1
net.inputs{1}.processFcns{2}='mapstd';
net.outputs{2}.processFcns{2}='mapstd';

% Prepare the Data for Training and Simulation
% Setup Division of Data for Training, Validation, Testing
% net.divideFcn='divideind';
% [trainInd,valInd,testInd]=divideind(8000,1:5000,5001:6000,6001:8000);
%   net.divideParam.trainInd= trainInd;
%   net.divideParam.valInd= valInd;
%   net.divideParam.testInd=testInd;
net.divideFcn='divideblock';
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

net.trainParam.showCommandLine = false;
net.trainParam.showWindow = false;
X=inputs;
T=targets;


[x,xi,ai,t] = preparets(net,X,{},T);
% Train the Network
[net,tr] = train(net,x,t,xi,ai);

% Test the Network
y = net(x,xi,ai);

[x1,xi1,ai1,t1] = preparets(net,test_in,{},test_target);
yout=net(x1,xi1,ai1);

timespent=toc;

%%
e = gsubtract(t1,yout);
performance = perform(net,t1,yout)
plotregression(t1,yout)

% Step-Ahead Prediction Network

nets = removedelay(net);
nets.name = [net.name ' - Predict One Step Ahead'];
%view(nets)
[xs,xis,ais,ts] = preparets(nets,X,{},T);
ys = nets(xs,xis,ais);
stepAheadPerformance = perform(nets,ts,ys);
%networkresults=[networkresults ys(:,end)];

figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
%figure, plotresponse(t,y)
%figure, ploterrcorr(e)
%figure, plotinerrcorr(x,e)




trainid1=tr.trainInd(1);
trainidend=tr.trainInd(end);
testid1=tr.testInd(1);
testidend=tr.testInd(end);
%% Save Data 
netoutput.timespent=timespent;
netoutput.performance=performance;
netoutput.yout=yout;
netoutput.net=net;
netoutput.e=e;
netoutput.tr=tr;
netoutput.t1=t1;

youtname='Trajectory--';
timenow=datetime;
trajfilename=strcat(youtname,datestr(datetime));
trajfilename=strcat('Outputs/',trajfilename);
save(trajfilename,'-struct','netoutput');


trainednetworkname='Net__';
netfilename=strcat(trainednetworkname,datestr(datetime));
netfilename=strcat('Outputs/',netfilename);
save(netfilename,'net');

%%
figure(1)
plot(raw_alldata(:,index_posx),raw_alldata(:,index_posy),'r','LineWidth',1.5);
xlabel({'Position East[m]'},'FontSize',15);
ylabel({'Position North[m]'},'FontSize',15);
legend({'Training Trajectory'},'FontSize',15); 
title({'Offline Training Trajectory'},'FontSize',15);


figure(2)
ypred=cell2mat(yout);
 ypred=ypred';
 %ypred=ypred(2:end,:);
 %ypred=medfilt1(ypred,20);
plot(ypred(:,1),ypred(:,2),'--',testing_target(:,1),testing_target(:,2),'r','LineWidth',1.5);
xlabel({'Position East[m]'},'FontSize',15);
ylabel({'Position North[m]'},'FontSize',15);
legend({'Predicted Trajectory','Desired Trajectory'},'FontSize',15); 
title('Offline Prediction of  Trajectory');
save('ypred.mat','ypred')

