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

close all, clear all, clc, format compact

% ------- load in the data -------
data =load('../vessel_status_new.txt');
%data =load('../vessel_status_old.txt');
%datanorm=zscore(data);
datanorm=data;
% index=1;%1
% lengthofdata=1000;%6000
% trainingdatasize=900;%4000
% 
% raw_alldata=zscore(data(index:index+lengthofdata-1,2:end));
% 
trainingstartindex=1101;%3000;%1
trainingendindex=length(datanorm);%6000
%trainingendindex=1000;%6000

raw_alldata=datanorm(trainingstartindex:trainingendindex,2:end);
index_posx=6;%6-new, 4-old; 
index_posy=7;%7-new,4-old;
%initialinputzeros=zeros(9,21);
inputs_data=raw_alldata;
%inputs_data=[initialinputzeros;inputs_data];

targets_data=[inputs_data(:,index_posx) inputs_data(:,index_posy)];

networkresults=[];
nmse=[];
%%
inputs = tonndata(inputs_data,false,false);
targets = tonndata(targets_data,false,false);
load('netpos.mat');
%% Choose a Training Function
% 
% trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.
% 
% % Create a Nonlinear Autoregressive Network with External Input
% inputDelays = 1:1;
% feedbackDelays = 1:1;
% hiddenLayerSize = 10;
% 
% 
% %net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open',trainFcn);
% 
% 
% % Prepare the Data for Training and Simulation
% 


% Setup Division of Data for Training, Validation, Testing
% net.divideFcn='divideblock';
% net.divideParam.trainRatio = 70/100;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;
net.trainParam.showCommandLine = false;
net.trainParam.showWindow = false;
X=[];
T=[];
train_out=[];

pasttime=9;
startindex=10;
timespent=[];
bestnumepoch=[];
track_gradient=[];
track_mu=[];
track_tr=[];
networkresults=targets(:,startindex-pasttime:startindex);
wb=[];
for j=startindex:length(inputs)
  tic;
    X=inputs(:,j-pasttime:j);
    T=targets(:,j-pasttime:j);
 
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
    track_mu=[track_mu tr.mu];
    track_tr=[track_tr;tr];
end
%% Plot trajectory
figure(1)
 ypred=cell2mat(networkresults);
 ypred=ypred';
 
  ypred=medfilt1(ypred,10);
 ypred(1,:)=ypred(2,:);

 ypred=[nan(1100,2);ypred];
 
% plot(targets_data(startindex:end,1),targets_data(startindex:end,2),'r')
plot(datanorm(:,index_posx+1),datanorm(:,index_posy+1),'r','LineWidth',1);
 hold on
 offtrainingdata=[datanorm(1:trainingstartindex-1,index_posx+1) datanorm(1:trainingstartindex-1,index_posy+1)];
  offtrainingdata=[offtrainingdata;nan(length(datanorm)-trainingstartindex,2)];
  plot(offtrainingdata(:,1),offtrainingdata(:,2),'b','LineWidth',1);
hold on
 %plot(ypred(startindex:end,1),ypred(startindex:end,2),'--','LineWidth',1.5);
 plot(ypred(:,1),ypred(:,2),'--','LineWidth',1.5);
xlabel({'Position East[m]'},'FontSize',15);
ylabel({'Position North[m]'},'FontSize',15);
legend({'Desired Trajectory','Offline Trained Trajectory','Predicted Trajectory'},'FontSize',12); 
title({'Hybrid Prediction of  Trajectory'},'FontSize',15);
 
%% Time spent
figure(2)
%plot(medfilt1(timespent,5));
plot(timespent);
hold on
plot(medfilt1(timespent,20),'r','LineWidth',2);

xlabel({'Sequence of Data'},'FontSize',15);
ylabel({'Time spent in seconds'},'FontSize',15);
legend({'Actual Time per sequence','Average Time per sequence'},'FontSize',13);
title({'Time spent for Hybrid Prediction of Trajectory'},'FontSize',15);


%% MSE
figure(3)

%plot(nmse);
plot(medfilt1(nmse,25));
%nmse1=medfilt1(nmse,400)
%plot(nmse1);
hold on
%plot(medfilt1(nmse1,50),'r','LineWidth',2);
plot(medfilt1(nmse,50),'r','LineWidth',2);
xlabel({'Sequence of Data'},'FontSize',15);
ylabel({'MSE'},'FontSize',15);
legend({'Actual MSE per sequence','Average MSE per sequence'},'FontSize',13);
title({'MSE for Hybrid Prediction of Trajectory'},'FontSize',15);

%% Minimum gradient and epochs
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

title({'Min gradient for Hybrid Prediction of Trajectory'},'FontSize',15);
 

 %% Epoch Spent
 figure(5)
 plot(bestnumepoch);
  %plot(medfilt1(bestnumepoch,5));
  hold on
  plot(medfilt1(bestnumepoch,20),'r','LineWidth',2);
   xlabel({'Sequence of Data'},'FontSize',15);
ylabel({'Epochs of each sequence'},'FontSize',15);
legend({'Actual Epochs per sequence','Average Epochs  per sequence'},'FontSize',13);

title({'Epochs for Hybrid Prediction of Trajectory'},'FontSize',15);


 %% Save information
    meannmse=mean(nmse)
    meanmingrad=mean(mingrad)
    meanepoch=floor(mean(bestnumepoch))
    totaltimespent=sum(timespent)
    meantimeepoch=mean(timespent)
    netoutput.totaltimespent=totaltimespent;

    netoutput.meannmse=meannmse;
    netoutput.nmse=nmse;
    netoutput.meanepoch=meanepoch;
    netoutput.meanmingrad=meanmingrad;
    netoutput.bestnumepoch=bestnumepoch;
    netoutput.track_gradient=track_gradient;
    netoutput.track_mu=track_mu;
    netoutput.track_tr=track_tr;
    netoutput.networkresults=networkresults;
    youtname='Position Hybrid --';
    timenow=datetime;
    trajfilename=strcat(youtname,datestr(datetime));
    trajfilename=strcat('Outputs/',trajfilename);
    save(trajfilename,'-struct','netoutput');