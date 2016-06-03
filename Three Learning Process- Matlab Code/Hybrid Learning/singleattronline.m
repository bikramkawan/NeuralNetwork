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
%%
close all, clear all, clc, format compact

% ------- load in the data -------
%data =load('../vessel_status_new.txt');
tmpdata = load('../vessel_status_new.txt');
%tmpdata = load('../../vessel_status_new.txt');
a=tmpdata; % Required Data Only
index=11; %( 9 = heading[deg],10=roll[deg], 11= pitch[deg])

phi_last_step = 0;
circle_num = 0;

[row, col] = size(a);


for i= 1:row
    
    
    if( a(i,index) - phi_last_step > 300*pi/180)
        circle_num = circle_num + 1;
        a(i,index) = a(i,index) -360;
    elseif ( a(i,index) - phi_last_step < -300*pi/180)
        circle_num = circle_num - 1;
        a(i,index) =a(i,index) + 360;
    end
    
    phi_last_step =a(i,index);
    
end

figure(1)
plot(a(:,index),'r');
hold on
plot(tmpdata(:,index),'--');
hold off


datanorm=a;%zscore(a);
%%
% index=1;%1
% lengthofdata=1000;%6000
% trainingdatasize=900;%4000
%
% raw_alldata=zscore(data(index:index+lengthofdata-1,2:end));
%
trainingstartindex=1101;%3000;%1
trainingendindex=length(a);%6000

raw_alldata=datanorm(trainingstartindex:trainingendindex,2:end);
indexid=index-1;

%initialinputzeros=zeros(9,21);
inputs_data=raw_alldata;
%inputs_data=[initialinputzeros;inputs_data];

targets_data=inputs_data(:,indexid) ;


%%
networkresults=[];
nmse=[];
inputs = tonndata(inputs_data,false,false);
targets = tonndata(targets_data,false,false);

load('netheading.mat');



% % Choose a Training Function
% 
% trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.
% 
% % Create a Nonlinear Autoregressive Network with External Input
% inputDelays = 1:2;
% feedbackDelays = 1:2;
% hiddenLayerSize = 10;
% net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open',trainFcn);


% Prepare the Data for Training and Simulation



% Setup Division of Data for Training, Validation, Testing
 %net.divideFcn='divideblock';
% net.divideParam.trainRatio = 70/100;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;
%net.performParam.regularization = 0.5;
net.trainParam.showCommandLine = false;
net.trainParam.showWindow = false;
% net.inputs{1}.processFcns{2}='mapstd';
%net.outputs{2}.processFcns{2}='mapstd';
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
for j=startindex:length(inputs)
    tic;
    X=inputs(:,j-pasttime:j);
    T=targets(:,j-pasttime:j);
    train_out=[train_out T];
    [x,xi,ai,t] = preparets(net,X,{},T);
    % Train the Network
    [net,tr] = train(net,x,t,xi,ai);
    net.IW{1};
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
%%
figure(1)
ypred=cell2mat(networkresults);
ypred=ypred';
ypred=medfilt1(ypred,10);
ypred(1)=ypred(2);
 ypred=[nan(1100,1);ypred];

if(indexid==1) 
attrname=' Surge Velocity';
attrunit='[m/s]';
end 
if(indexid==2) 
attrname=' Sway Velocity';
attrunit='[m/s]';
end
if(indexid==3) 
attrname=' Yaw Velocity';
attrunit='[deg/s]';
end
if(indexid==8) 
attrname=' Yaw Angle';
attrunit='[deg]';
end
if(indexid==9) 
attrname=' Roll Angle';
attrunit='[deg]';
end
if(indexid==10) 
attrname=' Pitch Angle';
attrunit='[deg]';
end
%plot(targets_data(:,1),'r','LineWidth',1)
plot(datanorm(1:end,index),'r','LineWidth',1);
  hold on
  offtrainingdata=[datanorm(1:trainingstartindex-1,index);nan(length(datanorm)-trainingstartindex,1)];
  plot(offtrainingdata,'b','LineWidth',1);
  %plot(targets_data(:,1),'r','LineWidth',1)

hold on
plot(ypred(:,1),'--','LineWidth',1);
ylabel({strcat(attrname,attrunit)},'FontSize',15);
xlabel({'Sequence of Data'},'FontSize',15)
title({strcat('Hybrid Prediction of', attrname)},'FontSize',15);
legend({strcat('Desired ', attrname),strcat('Offline Trainined',attrname),strcat('Predicted',attrname)},'FontSize',12)

%
%% Time spent
figure(2)
%plot(medfilt1(timespent,5));
plot(timespent);
hold on
plot(medfilt1(timespent,20),'r','LineWidth',2);

xlabel({'Sequence of Data'},'FontSize',15);
ylabel({'Time spent in seconds'},'FontSize',15);
legend({'Actual Time per sequence','Average Time per sequence'},'FontSize',13);
title({strcat('Time spent on each Sequence for Hybrid Prediction of ',attrname)},'FontSize',15);

%% MSE
figure(3)

plot(nmse);
%plot(medfilt1(nmse,10));
%nmse1=medfilt1(nmse,400)
%plot(nmse1);
hold on
%plot(medfilt1(nmse1,50),'r','LineWidth',2);
plot(medfilt1(nmse,50),'r','LineWidth',2);
xlabel({'Sequence of Data'},'FontSize',15);
ylabel({'MSE'},'FontSize',15);
legend({'Actual MSE per sequence','Average MSE per sequence'},'FontSize',13);
title({strcat('MSE for Hybrid Prediction of',attrname)},'FontSize',15);

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

title({strcat('Min gradient for Hybrid Prediction of',attrname)},'FontSize',15);
 

 %% Epoch Spent
 figure(5)
 plot(bestnumepoch);
  %plot(medfilt1(bestnumepoch,5));
  hold on
  plot(medfilt1(bestnumepoch,20),'r','LineWidth',2);
   xlabel({'Sequence of Data'},'FontSize',15);
ylabel({'Epochs of each sequence'},'FontSize',15);
legend({'Actual Epochs per sequence','Average Epochs  per sequence'},'FontSize',13);

title({strcat('Epochs of each Sequence for Hybrid Prediction of',attrname)},'FontSize',15);


    %% Save information
    meannmse=mean(nmse)
    meanmingrad=mean(mingrad)
    meanepoch=floor(mean(bestnumepoch))
    totaltime=sum(timespent)
        meantimeepoch=mean(timespent)
    netoutput.timespent=timespent;
    netoutput.totaltime=totaltime;
    netoutput.meannmse=meannmse;
    netoutput.nmse=nmse;
    netoutput.meanepoch=meanepoch;
    netoutput.meanmingrad=meanmingrad;
    netoutput.bestnumepoch=bestnumepoch;
    netoutput.track_gradient=track_gradient;
    netoutput.track_mu=track_mu;
    netoutput.track_tr=track_tr;
    netoutput.networkresults=networkresults;
    youtname=strcat(attrname,' Hybrid --');
    timenow=datetime;
    trajfilename=strcat(youtname,datestr(datetime));
    trajfilename=strcat('Outputs/',trajfilename);
    save(trajfilename,'-struct','netoutput');