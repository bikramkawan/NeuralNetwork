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

indexi=9; %( 9 = heading[deg],10=roll[deg], 11= pitch[deg])
phi_last_step = 0; 
circle_num = 0; 

[row, col] = size(a);
if (indexi==9 || indexi==10 ||indexi==11)
for index=9:11
    
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
end

figure(1)
plot(a(:,index),'r');
hold on
plot(tmpdata(:,index),'--');
hold off
end
%%

datanorm=a;
datanorm=datanorm(:,2:end);
trainingstartindex=1;%3000;%1
N=1820; %1890;
trainingendindex=N;%6000
horizon=30;

raw_alldata=(datanorm(trainingstartindex:trainingendindex,:));

indexid=indexi-1;
inputs_data=raw_alldata;
targets_data=inputs_data(:,indexid);


%%
inputs = tonndata(inputs_data,false,false);
targets = tonndata(targets_data,false,false);

% Choose a Training Function

trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

% Create a Nonlinear Autoregressive Network with External Input
inputDelays = 1:2;
feedbackDelays = 1:2;
hiddenLayerSize = 10;
rng('default')
neto = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open',trainFcn);


% Prepare the Data for Training and Simulation



% Setup Division of Data for Training, Validation, Testing
% net.divideFcn='divideind';
% [trainInd,valInd,testInd]=divideind(8000,1:5000,5001:6000,6001:8000);
%   net.divideParam.trainInd= trainInd;
%   net.divideParam.valInd= valInd;
%   net.divideParam.testInd=testInd;
neto.divideFcn='divideblock';
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

neto.trainParam.showCommandLine = false;
neto.trainParam.showWindow = false;
X=inputs;
T=targets;


[ Xo,Xoi,Aoi,To ] = preparets(neto,X,{},T);
% Train the Network
[ neto tro Yo Eo Aof Xof ] = train( neto, Xo, To, Xoi, Aoi );
 [ Yo Xof Aof ] = neto( Xo, Xoi, Aoi );
% Test the Network
%networkresults=[networkresults ys(:,end)];

%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
%figure, plotresponse(t,y)
%figure, ploterrcorr(e)
%figure, plotinerrcorr(x,e)

%% Step-Ahead Prediction Network

%nets = removedelay(neto);
nets=closeloop(neto);
nets.name = [neto.name ' - Closed Loop Multi Step Ahead'];
%view(nets)

[xs,xis,ais,ts] = preparets(nets,X,{},T);
ys = nets(xs,xis,ais);
stepAheadPerformance = perform(nets,ts,ys);


ys1=ys; 
inputs_data1=cell2mat(X);
inputs_data1=inputs_data1';
targets_data1=cell2mat(T);
targets_data1=targets_data1';
track_mse=[];
for k=1:horizon  
inputs_data1=[inputs_data1;inputs_data(end,:)];
inputs_data1(end,indexid)=cell2mat(ys1(end));


targets_data1=[targets_data1;cell2mat(ys1(end))];

inputs1 = tonndata(inputs_data1,false,false);
targets1 = tonndata(targets_data1,false,false);

X1=inputs1;
T1=targets1;
[xs1,xis1,ais1,ts1] = preparets(nets,X1,{},T1);
ys1 = nets(xs1,xis1,ais1);
stepAheadPerformance1 = perform(nets,ts1,ys1);
track_mse=[track_mse;stepAheadPerformance1];
   
end

%% plot
meanmse=mean(track_mse)
ypred=cell2mat(Yo);
 ypred=ypred';
 %ypred=medfilt1(ypred,5);
ymulti=cell2mat(ys1);
ymulti=ymulti';
%%
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

% errror 
e_t= datanorm(N:N+horizon-2,indexid);
e_y=ymulti(N:end);
%%
nmse=mse(nets,e_t,e_y)
figure(1)

%%
r=datanorm(3:N+horizon,indexid);
plot(r,'r','LineWidth',1.5);
hold on
b=datanorm(3:length(raw_alldata)+2,indexid);
plot(b,'b','LineWidth',1.5);
hold on

multidata=[nan(size(raw_alldata(:,indexid),1),1);ymulti(size(raw_alldata(:,indexid),1):end-15,1)];
plot(multidata,'--','LineWidth',1.5);
ylabel({strcat(attrname,attrunit)},'FontSize',15);
xlabel({'Time [s]'},'FontSize',15);
legend({strcat('Desired ', attrname),strcat('1 Step-ahead Offline Prediction of',attrname),strcat(num2str(horizon),' Step-ahead Prediction of',attrname)},'FontSize',12)
%sprin=sprintf('%d steps-ahead Prediction of from recursive Feedback of',horizon);
title({strcat(num2str(horizon),' steps-ahead Prediction of',attrname,' using recursive Feedback')},'FontSize',15);

%% Save plot data
plotdata.r=r;
plotdata.b=b;
plotdata.multidata=multidata;
plotdata.attrname=attrname;
plotdata.attrunit=attrunit;
plotdata.horizon=horizon;
youtname=strcat(attrname,'_',num2str(horizon),'--');
timenow=datetime;
trajfilename=strcat(youtname,datestr(datetime));
trajfilename=strcat('results/',trajfilename);
save(trajfilename,'-struct','plotdata');

%% Re plot from saved file


plot(r,'r','LineWidth',1.5);
hold on

plot(b,'b','LineWidth',1.5);
hold on
plot(multidata,'--','LineWidth',1.5);
ylabel({strcat(attrname,attrunit)},'FontSize',15);
xlabel({'Time [s]'},'FontSize',15);
legend({strcat('Desired ', attrname),strcat('1 Step-ahead Offline Prediction of',attrname),strcat(num2str(horizon),' Step-ahead Prediction of',attrname)},'FontSize',12)
%sprin=sprintf('%d steps-ahead Prediction of from recursive Feedback of',horizon);
title({strcat(num2str(horizon),' steps-ahead Prediction of',attrname,' using recursive Feedback')},'FontSize',15);


%%  Save Information
 meannmse=meanmse
 netoutput.track_mse=track_mse
 netoutput.N=N
netoutput.nmse=nmse
netoutput.e_t=e_t
netoutput.e_y=e_y
netoutput.ymulti=ymulti
netoutput.ypred=ypred
netoutput.neto=neto;
netoutput.netc=nets;
youtname=strcat(attrname,'_',num2str(horizon),'--');
timenow=datetime;
trajfilename=strcat(youtname,datestr(datetime));
trajfilename=strcat('Outputs/',trajfilename);
save(trajfilename,'-struct','netoutput');
save(strcat(attrname,'.mat'),'ypred');



toc