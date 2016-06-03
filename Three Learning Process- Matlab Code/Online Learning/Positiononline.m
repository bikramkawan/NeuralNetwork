% bikramkawan@gmail.com
% Updated 29-May-2016 13:09:37

%% Data Index ( For Old Data set)
% raw_surgevel=data(index:lengthofdata,2); % Surge_ Velocity
% raw_swayvel=data(index:lengthofdata,3); % sway Velocity
% raw_yawvel=data(index:lengthofdata,4); % Yaw Veloctiy
% raw_posx=data(index:lengthofdata,5); %Position East
% raw_posy= data(index:lengthofdata,6); % Position North

%close all, clear all, clc, format compact

% ------- load in the data -------
data =load('../vessel_status_new.txt');
%data =load('../vessel_status_old.txt');
datanorm=data;
% 
trainingstartindex=1;%3000;%1
trainingendindex=length(datanorm);%6000
%trainingendindex=1000;%6000

raw_alldata=datanorm(trainingstartindex:trainingendindex,2:end);

index_posx=6;%6-new, 4-old;  % Position x 
index_posy=7;%7-new,4-old; % Position y
%initialinputzeros=zeros(9,21);
inputs_data=raw_alldata;
%inputs_data=[initialinputzeros;inputs_data];

targets_data=[inputs_data(:,index_posx) inputs_data(:,index_posy)];

networkresults=[];
nmse=[];
%%
inputs = tonndata(inputs_data,false,false);
targets = tonndata(targets_data,false,false);

% Choose a Training Function

trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

% Create a Nonlinear Autoregressive Network with External Input
inputDelays = 1:2;
feedbackDelays = 1:2;
hiddenLayerSize = 10;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open',trainFcn);
net.inputs{1}.processFcns{2}='mapstd'; % Z score before training
net.outputs{2}.processFcns{2}='mapstd'; % Reverse Zscore outputs

% Setup Division of Data for Training, Validation, Testing
net.divideFcn='divideblock';
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;
net.trainParam.showCommandLine = false;
net.trainParam.showWindow = false;
X=[];
T=[];
train_out=[];

pasttime=19;
startindex=20;
timespent=[];
networkresults=targets(:,startindex-pasttime:startindex);
wb=[];
bestnumepoch=[];
track_gradient=[];
track_mu=[];
track_tr=[];
%%
for j=startindex:length(inputs)
  tic;
    X=inputs(:,j-pasttime:j);
    T=targets(:,j-pasttime:j);
  train_out=[train_out T];
[x,xi,ai,t] = preparets(net,X,{},T);
% Train the Network
[net,tr] = train(net,x,t,xi,ai);
net.IW{1};
wb = [wb getwb(net)];
j;
% Test the Network
y = net(x,xi,ai);
% e = gsubtract(t,y);
% performance = perform(net,t,y);


% Step-Ahead Prediction Network

nets = removedelay(net);
nets.name = [net.name ' - Predict One Step Ahead'];
%view(nets)
[xs,xis,ais,ts] = preparets(nets,X,{},T);
ys = nets(xs,xis,ais);
stepAheadPerformance = perform(nets,ts,ys);
nmse=[nmse;stepAheadPerformance];
networkresults=[networkresults ys(:,end)];

 e = gsubtract(ts,ys);
 performance = perform(net,ts,ys);

%  ypred=cell2mat(networkresults);
%  ypred=ypred';
%  plot(targets_data(startindex:end,1),targets_data(startindex:end,2),ypred(startindex:end,1),ypred(startindex:end,2),'o');
%  legend('Targets','Predicted'); 
%  drawnow
tmptime=toc;
timespent=[timespent;tmptime];
bestnumepoch=[bestnumepoch;tr.num_epochs];
track_gradient=[track_gradient tr.gradient];
%track_mu=[track_mu tr.mu];
track_tr=[track_tr;tr];
end
%% Plot trajectory
figure(1)
 ypred=cell2mat(networkresults);
 ypred=ypred';
 ypred=medfilt1(ypred,45);
 plot(targets_data(startindex:end,1),targets_data(startindex:end,2),'r',ypred(startindex:end,1),ypred(startindex:end,2),'--','LineWidth',1.5);
xlabel({'Position East [m]'},'FontSize',15);
ylabel({'Position North [m]'},'FontSize',15);
legend({'Desired Trajectory','Predicted Trajectory'},'FontSize',13); 
title({'Online Prediction of  Trajectory'},'FontSize',15);
 
%% Time spent
figure(2)
%plot(timespent);
plot(medfilt1(timespent,3));
hold on 
plot(medfilt1(timespent,20),'r','LineWidth',2);
xlabel({'Sequence of Data'},'FontSize',15);
ylabel({'Time spent in seconds'},'FontSize',15);
legend({'Actual Time per sequence','Average Time per sequence'},'FontSize',13);
title({'Time spent on Online Prediction of Trajectory '},'FontSize',15);

%% MSE
figure(3)
%plot(nmse);
plot(medfilt1(nmse,8));
hold on 
plot(medfilt1(nmse,20),'r','LineWidth',2);
xlabel({'Sequence of Data'},'FontSize',15);
ylabel({'MSE'},'FontSize',15);
title({'MSE of Online Prediction of Trajectory'},'FontSize',15);
%% Min gradient
mingrad=[];
for i=1:length(track_tr)
    mingrad =[mingrad; min(track_tr(i).gradient)];
        
end

%% Plot min gradient
figure(4)
  plot(medfilt1(mingrad,10));
  hold on
  plot(medfilt1(mingrad,20),'r','LineWidth',2);
   xlabel({'Sequence of Data'},'FontSize',15);
ylabel({'minimum gradient of each sequence'},'FontSize',15);
legend({'Actual minimum gradient per sequence','Average minimum gradient per sequence'},'FontSize',13);

title({'Min gradient for Online Prediction of Trajectory'},'FontSize',15);
 

 %% Epoch Spent
 figure(5)
 %plot(bestnumepoch);
  plot(medfilt1(bestnumepoch,3));
  hold on
  plot(medfilt1(bestnumepoch,20),'r','LineWidth',2);
   xlabel({'Sequence of Data'},'FontSize',15);
ylabel({'Epochs of each sequence'},'FontSize',15);
legend({'Actual Epochs per sequence','Average Epochs  per sequence'},'FontSize',13);

title({'Epochs for Online Prediction of Trajectory'},'FontSize',15);

%%  Save Information
 meannmse=mean(nmse)
    meanmingrad=mean(mingrad)
    meanepoch=floor(mean(bestnumepoch))
    totaltime=sum(timespent)
        meantimeepoch=mean(timespent)
netoutput.timespent=timespent;
netoutput.nmse=nmse;
netoutput.bestnumepoch=bestnumepoch;
netoutput.track_gradient=track_gradient;
netoutput.track_mu=track_mu;
netoutput.track_tr=track_tr;
%net.ypred1=ypred1;
%netoutput.yout=yout;
%netoutput.net=net;
%netoutput.e=e;
%netoutput.tr=tr;
netoutput.networkresults=networkresults;
attrname='Trajectory';
youtname=strcat(attrname,'--');
timenow=datetime;
trajfilename=strcat(youtname,datestr(datetime));
trajfilename=strcat('Outputs/',trajfilename);
save(trajfilename,'-struct','netoutput');