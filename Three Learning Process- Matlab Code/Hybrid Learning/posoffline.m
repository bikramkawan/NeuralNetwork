% bikramkawan@gmail.com
% Updated 29-May-2016 13:09:37
%% Initializing
% raw_surgevel=data(index:lengthofdata,2); % Surge_ Velocity
% raw_swayvel=data(index:lengthofdata,3); % sway Velocity
% raw_yawvel=data(index:lengthofdata,4); % Yaw Veloctiy
% raw_posx=data(index:lengthofdata,5); %Position East
% raw_posy= data(index:lengthofdata,6); % Position North
% 
% %raw_alldata=[raw_surgevel raw_swayvel raw_yawvel raw_posx raw_posy];%[raw_posx raw_posy];
tic
close all, clear all, clc, format compact

% ------- load in the data -------
%data =load('../vessel_status_old.txt');
data =load('../vessel_status_new.txt');

datanorm=data; %zscore(data);
trainingstartindex=1;%3000;%1
trainingendindex=length(datanorm);%6000


testingstartindex=1;%2000;
testingendindex=1100;%length(datanorm);%4000;


raw_alldata=datanorm(trainingstartindex:trainingendindex,2:end);

index_posx=6;%6-new, 4-old; 
index_posy=7;%7-new,4-old;
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

% Create a Nonlinear Autoregressive Network with External Input
inputDelays = 1:2;
feedbackDelays = 1:2;
hiddenLayerSize = 10;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open',trainFcn);
net.inputs{1}.processFcns{2}='mapstd';
net.outputs{2}.processFcns{2}='mapstd';

% Prepare the Data for Training and Simulation



% Setup Division of Data for Training, Validation, Testing
% net.divideFcn='divideind';
% [trainInd,valInd,testInd]=divideind(8000,1:5000,5001:6000,6001:8000);
%   net.divideParam.trainInd= trainInd;
%   net.divideParam.valInd= valInd;
%   net.divideParam.testInd=testInd;
% net.divideFcn='divideblock';
% net.divideParam.trainRatio = 70/100;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;

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



ypred=cell2mat(y);
 ypred=ypred';
save('netpos.mat','net');
%%

% figure(1)
% plot(raw_alldata(:,index_posx),raw_alldata(:,index_posy),'r','LineWidth',1.5);
% xlabel('Position East');
% ylabel('Position North');
% legend({'Training Trajectory'},'FontSize',12); 
% title('Training Trajectory');
% [Z,rawmean,rawpastdev]=zscore(data(trainingstartindex:trainingendindex,2:end));
% rawdata=[Z(:,index_posx)*rawpastdev(:,index_posx)+rawmean(:,index_posx) ...
%          Z(:,index_posy)*rawpastdev(:,index_posy)+rawmean(:,index_posy) ]  ;
% plot(rawdata(:,1),rawdata(:,2))     
 

% testrawdata= data(testingstartindex:testingendindex,index_posx+1:index_posy+1);    
%    
%  [Z1,testrawmean,testrawpastdev]=zscore(testrawdata);
%  testtargetrawdata=[ypred(:,1)*testrawpastdev(:,1)+testrawmean(:,1) ...
%          ypred(:,2)*testrawpastdev(:,2)+testrawmean(:,2) ]  ;
% hold on
% plot(raw_alldata(trainid1:trainidend,index_posx),raw_alldata(trainid1:trainidend,index_posy),'b');
% hold on

%plot(raw_alldata(testid1:testidend,index_posx),raw_alldata(testid1:testidend,index_posy),'--','LineWidth',2);
%legend('Complete trajectory','Training ','Testing');
%hold off

figure(2)
plot(ypred(:,1),ypred(:,2),'o',testing_target(:,1),testing_target(:,2),'r','LineWidth',1.5);
xlabel('Position East');
ylabel('Position North');
legend({'Predicted Trajectory','Desired Trajectory'},'FontSize',12); 
title('Prediction of  Trajectory');




%plot(data(from:endof,5),data(from:endof,6));

% figure(3)
% plot(raw_alldata(:,index_posx),raw_alldata(:,index_posy),'r',...
%     raw_alldata(trainid1:trainidend,index_posx),raw_alldata(trainid1:trainidend,index_posy),'k',...
%     raw_alldata(testid1:testidend,index_posx),raw_alldata(testid1:testidend,index_posy),'o');


timespent=toc;