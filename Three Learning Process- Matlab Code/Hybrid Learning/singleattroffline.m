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


% ------- load in the data -------


%% Heading corrrection.
close all, clear all, clc, format compact
tmpdata = load('../vessel_status_new.txt');
a=tmpdata; % Required Data Only

phi_last_step = 0; 
circle_num = 0; 

[row, col] = size(a);

 index=4; %( 9 = heading[deg],10=roll[deg], 11= pitch[deg])

% for i= 1:row
%    
% 
%  if( a(i,index) - phi_last_step > 300*pi/180)
%         circle_num = circle_num + 1;
%         a(i,index) = a(i,index) -360;
%     elseif ( a(i,index) - phi_last_step < -300*pi/180)
%         circle_num = circle_num - 1;
%         a(i,index) =a(i,index) + 360;
%  end
%  
%  phi_last_step =a(i,index);
%  
% end
% 
% figure(1)
 plot(a(:,index),'r');
% hold on
% plot(tmpdata(:,index),'--');
% hold off
%%

datanorm=a;
datanorm=datanorm(:,2:end);
trainingstartindex=1;%3000;%1
trainingendindex=1100;%6000

raw_alldata=(datanorm(trainingstartindex:trainingendindex,:));

index=index-1;
inputs_data=raw_alldata;
targets_data=inputs_data(:,index);

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


%networkresults=[networkresults ys(:,end)];

%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
%figure, plotresponse(t,y)
%figure, ploterrcorr(e)
%figure, plotinerrcorr(x,e)



ypred=cell2mat(y);
 ypred=ypred';

%%
figure(2)
%plot(raw_alldata(:,index),'r');

plot(raw_alldata(:,index),'b');
hold on

% plot([nan(tr.valInd(end),1);y1(testid1:testidend)],'--','LineWidth',2);
% % legend('Complete Heading','Training ','Testing');
% hold on


plot(ypred(:,1),'--');


legend('Original Heading','Results '); 
save('netheading.mat','net');
%plot(data(from:endof,5),data(from:endof,6));


% plot(raw_alldata(:,index_posx),raw_alldata(:,index_posy),'r',...
%     raw_alldata(trainid1:trainidend,index_posx),raw_alldata(trainid1:trainidend,index_posy),'k',...
%     raw_alldata(testid1:testidend,index_posx),raw_alldata(testid1:testidend,index_posy),'o');


toc