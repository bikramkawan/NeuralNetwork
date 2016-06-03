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
data =load('../vessel_status_new.txt');
%data =load('../vessel_status_old.txt');


datanorm=data;%zscore(data);
trainingstartindex=1;%3000;%1
N=1900;
trainingendindex=N;%6000
horizon=10;




raw_alldata=datanorm(trainingstartindex:trainingendindex,2:end);

index_posx=6;%4
index_posy=7;%5
inputs_data=raw_alldata;
targets_data=[inputs_data(:,index_posx) inputs_data(:,index_posy)];


networkresults=[];
%%
inputs = tonndata(inputs_data,false,false);
targets = tonndata(targets_data,false,false);

% Choose a Training Function

trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.
%trainFcn = 'trainbr';  % Levenberg-Marquardt backpropagation.

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


timespent=toc;

%%


% Step-Ahead Prediction Network

nets = removedelay(net);
nets.name = [net.name ' - Predict One Step Ahead'];
%view(nets)
[xs,xis,ais,ts] = preparets(nets,X,{},T);
ys = nets(xs,xis,ais);
stepAheadPerformance = perform(nets,ts,ys);
%networkresults=[networkresults ys(:,end)];

%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
%figure, plotresponse(t,y)
%figure, ploterrcorr(e)
%figure, plotinerrcorr(x,e)


%% multi
ys1=ys;
inputs_data1=cell2mat(X);
inputs_data1=inputs_data1';
targets_data1=cell2mat(T);
targets_data1=targets_data1';
track_mse=[];
for k=1:horizon 
 ynum=cell2mat(ys1(end));
 ynum=ynum';
inputs_data1=[inputs_data1;inputs_data(end,:)];
inputs_data1(end,index_posx)=ynum(1);
inputs_data1(end,index_posy)=ynum(2);

targets_data1=[targets_data1;ynum];

inputs1 = tonndata(inputs_data1,false,false);
targets1 = tonndata(targets_data1,false,false);

X1=inputs1;
T1=targets1;
[xs1,xis1,ais1,ts1] = preparets(nets,X1,{},T1);
ys1 = nets(xs1,xis1,ais1);
stepAheadPerformance1 = perform(nets,ts1,ys1);
track_mse=[track_mse;stepAheadPerformance1];
    
end
%%
figure(1)
ypred=cell2mat(ys1);
 ypred=ypred';
 
 %ypred=ypred(2:end,:);
ypred=medfilt1(ypred,3);

plot(datanorm(3:N+horizon+2,index_posx+1),datanorm(3:N+horizon+2,index_posy+1),'r','LineWidth',1.5);
hold on
plot(raw_alldata(3:end,index_posx),raw_alldata(3:end,index_posy),'b','LineWidth',1.5);

ymulti=cell2mat(ys1);
ymulti=ymulti';
ymulti = medfilt1(ymulti,15);
offdata=[nan(N,2);ymulti(length(raw_alldata):end,:)];


plot(offdata(:,1),offdata(:,2),'--','LineWidth',1.5);
hold on 

xlabel({'Position East[m]'},'FontSize',15);
ylabel({'Position North[m]'},'FontSize',15);
legend({'Desired Trajectory','1 Step-ahead Offline Prediction',strcat(num2str(horizon),' Step-ahead Prediction')},'FontSize',15); 
title({strcat(num2str(horizon),' steps-ahead Prediction of Trajectory using recursive Feedback')},'FontSize',15);
save('ypred.mat','ypred')
%% Save
attrname='Trajectory';
 meannmse=mean(track_mse)
 netoutput.track_mse=track_mse
 netoutput.N=N


netoutput.ymulti=ymulti
netoutput.ypred=ypred
netoutput.neto=net;
netoutput.netc=nets;
youtname=strcat(attrname,'_',num2str(horizon),'--');
timenow=datetime;
trajfilename=strcat(youtname,datestr(datetime));
trajfilename=strcat('Outputs/',trajfilename);
save(trajfilename,'-struct','netoutput');
save(strcat(attrname,'.mat'),'ypred');
