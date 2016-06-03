% bikramkawan@gmail.com
% Updated 29-May-2016 13:09:37


%% Data set Index 

% 2=surge_vel[m/s], 
% 3=sway_vel[m/s],
% 4=yaw_vel[deg/s], 
% 5=roll_vel[deg/s], 
% 6=pitch_vel[deg/s], 
% 9 = yaw angle[deg],
% 10=roll[deg], 
% 11= pitch[deg]

%%
tic

%% Phase corrrection.
close all, clear all, clc, format compact
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
plot(a(:,index),'r','LineWidth',1.5);
hold on
plot(tmpdata(:,index),'--','LineWidth',1.5);
hold off
xlabel({'Time(s)'},'FontSize',15);
ylabel({'Yaw Angle [deg]'},'FontSize',15);
legend({'Phase Corrected yaw angle','Original yaw angle'},'FontSize',15);

%% Data division

datanorm=a;%zscore(a);
datanorm=datanorm(:,2:end);
trainingstartindex=1;
trainingendindex=1300;


testingstartindex=1301;
testingendindex=length(a);

raw_alldata=(datanorm(trainingstartindex:trainingendindex,:));
index=index-1;
inputs_data=raw_alldata;
targets_data=inputs_data(:,index);

testing_data=datanorm(testingstartindex:testingendindex,:);
testing_target=testing_data(:,index);
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
hiddenLayerSize = 15;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open',trainFcn); % Define NARX Network
net.inputs{1}.processFcns{2}='mapstd'; % Standarization(z-score)  for input data before training
net.outputs{2}.processFcns{2}='mapstd'; % Revert back to original value
% net.trainParam.epochs=1000;
 net.trainParam.mu=1  % initial learning rate 
 net.trainParam.mu_dec=1; % learning rate increamental 
  net.trainParam.mu_max=1; % learning rate decremental 

% Prepare the Data for Training and Simulation

% Setup Division of Data for Training, Validation, Testing
% net.divideFcn='divideblock';
% net.divideParam.trainRatio = 70/100;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;

net.trainParam.showCommandLine = false; 
net.trainParam.showWindow = false; % Hide Window of training
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

%%
y1=cell2mat(y);
y1=y1';
%%
ypred=cell2mat(yout);
ypred=ypred';
%ypred1=medfilt1(ypred,5);
timespent=toc
figure(3)
attrname=' Roll Angle  ';
attrunit='[deg]';
%plot(raw_alldata(:,index),'r');
plot(datanorm(3:end,index),'r','LineWidth',1.5);
hold on
plot(raw_alldata(trainingstartindex:trainingendindex,index),'b','LineWidth',1.5);
hold on
plot([nan(testingstartindex-1,1);ypred(:,1)],'--','LineWidth',1.5);
ylabel({strcat(attrname,attrunit)},'FontSize',15);
xlabel({'Time(s)'},'FontSize',15)
title({strcat('Offline Prediction of', attrname)},'FontSize',15);
legend({strcat('Desired ', attrname),strcat('Training',attrname),strcat(' Testing', attrname)},'FontSize',13)

%%
figure, plotperform(tr);
figure, plottrainstate(tr);
figure, plotregression(t1,yout)

%%  Save Information
netoutput.timespent=timespent;
netoutput.performance=performance;
netoutput.yout=yout;
netoutput.net=net;
netoutput.e=e;
netoutput.tr=tr;
netoutput.t1=t1;

youtname=strcat(attrname,'--');
timenow=datetime;
trajfilename=strcat(youtname,datestr(datetime));
trajfilename=strcat('Outputs/',trajfilename);
save(trajfilename,'-struct','netoutput');
