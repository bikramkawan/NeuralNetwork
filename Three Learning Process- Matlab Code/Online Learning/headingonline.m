% bikramkawan@gmail.com
% Updated 29-May-2016 13:09:37
%% Data index info
% 2=surge_vel[m/s], 
% 3=sway_vel[m/s],
% 4=yaw_vel[deg/s], 
% 5=roll_vel[deg/s], 
% 6=pitch_vel[deg/s], 
% 9 = yaw angle[deg],
% 10=roll[deg], 
% 11= pitch[deg]

%%
close all, clear all, clc, format compact

% ------- load in the data -------
%data =load('../vessel_status_new.txt');
tmpdata = load('../vessel_status_new.txt');
a=tmpdata; % Required Data Only
index=10; 

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


datanorm=a;
%%

trainingstartindex=1;%3000;%1
trainingendindex=length(a);%6000

raw_alldata=datanorm(trainingstartindex:trainingendindex,2:end);
indexid=index-1;


inputs_data=raw_alldata;


targets_data=inputs_data(:,indexid) ;


%%
networkresults=[];
nmse=[];
inputs = tonndata(inputs_data,false,false);
targets = tonndata(targets_data,false,false);

% Choose a Training Function

trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

% Create a Nonlinear Autoregressive Network with External Input
inputDelays = 1:2;
feedbackDelays = 1:2;
hiddenLayerSize = 10;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open',trainFcn);


% Prepare the Data for Training and Simulation



% Setup Division of Data for Training, Validation, Testing
 net.divideFcn='divideblock';
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;
net.performParam.regularization = 0.5;
net.trainParam.showCommandLine = false;
net.trainParam.showWindow = false;
net.inputs{1}.processFcns{2}='mapstd';
net.outputs{2}.processFcns{2}='mapstd';
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
ypred=medfilt1(ypred,18);
attrname=' Roll Angle';
attrunit='[deg]';
plot(targets_data(:,1),'r','LineWidth',1)
hold on
plot(ypred(:,1),'--','LineWidth',1);
ylabel({strcat(attrname,attrunit)},'FontSize',15);
xlabel({'Sequence of Data'},'FontSize',15)
title({strcat('Online Prediction of', attrname)},'FontSize',15);
legend({strcat('Desired ', attrname),strcat('Predicted',attrname)},'FontSize',12)

%
%% Time spent
figure(2)
%plot(medfilt1(timespent,9));
plot(timespent);
hold on
plot(medfilt1(timespent,20),'r','LineWidth',2);

xlabel({'Sequence of Data'},'FontSize',15);
ylabel({'Time spent in seconds'},'FontSize',15);
legend({'Actual Time per sequence','Average Time per sequence'},'FontSize',13);
title({strcat('Time spent on each Sequence for Online Prediction of ',attrname)},'FontSize',15);

%% MSE
figure(3)

plot(nmse);
%plot(medfilt1(nmse,15));  % 15 =heading, 0=pitch,
%nmse1=medfilt1(nmse,400)
%plot(nmse1);
hold on
%plot(medfilt1(nmse1,50),'r','LineWidth',2);
plot(medfilt1(nmse,20),'r','LineWidth',2); % 80 = heading, 50 =pitch
xlabel({'Sequence of Data'},'FontSize',15);
ylabel({'MSE'},'FontSize',15);
title({strcat('MSE of each Sequence for Online Prediction of',attrname)},'FontSize',15);

%% Minimum gradient and epochs
mingrad=[];
for i=1:length(track_tr)
    mingrad =[mingrad; min(track_tr(i).gradient)];
        
end
 
%% Plot min gradient
figure(4)
  %plot(medfilt1(mingrad,7));  % 7=heading, 0=pitch
  plot(mingrad);
  hold on
  plot(medfilt1(mingrad,20),'r','LineWidth',2); % 20=headin, , 20=pitch
   xlabel({'Sequence of Data'},'FontSize',15);
ylabel({'minimum gradient of each sequence'},'FontSize',15);
legend({'Actual minimum gradient per sequence','Average minimum gradient per sequence'},'FontSize',13);

title({strcat('Minimum gradient of each Sequence for Online Prediction of',attrname)},'FontSize',15);
 

 %% Epoch Spent
 figure(5)
 plot(bestnumepoch);
  %plot(medfilt1(bestnumepoch,11)); %11= heading
  hold on
  plot(medfilt1(bestnumepoch,50),'r','LineWidth',2);  % 50 =heading,pitch
   xlabel({'Sequence of Data'},'FontSize',15);
ylabel({'Epochs of each sequence'},'FontSize',15);
legend({'Actual Epochs per sequence','Average Epochs  per sequence'},'FontSize',13);

title({strcat('Epochs of each Sequence for Online Prediction of',attrname)},'FontSize',15);


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
    youtname=strcat(attrname,'--');
    timenow=datetime;
    trajfilename=strcat(youtname,datestr(datetime));
    trajfilename=strcat('Outputs/',trajfilename);
    save(trajfilename,'-struct','netoutput');