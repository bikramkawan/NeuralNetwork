%clear;
 function  heading(h)
 addpath('../jsonlab');
 
datasetfilename=loadjson(['../datasetfilename.json']);

indata=load(strcat('../',datasetfilename{1,1}));

a = indata;

minmaxdata=a(:,2:11); 
minvalues= min(minmaxdata);
maxvalues= max(minmaxdata);

field1 = 'minvalues';
value1 = {minvalues};
field2 = 'maxvalues';
value2 = {maxvalues};
jsondataminmax = struct(field1,value1,field2,value2);
savejson('minmaxrange',jsondataminmax,'../timeline/minmaxvalues.json');



index=h;  %9= heading
% figure(1)
% plot(indata(:,index));
% 
% xlabel('Time series');
% ylabel('Heading in Degree');
% 
% hold on


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

%%
% {
 figure(2)

plot(indata(:,index));
hold on
plot(a(:,index));

 legend('Before Phase Correction','After Phase Corrected');
 xlabel('Time Series');
  ylabel('Heading in Degrees');


%%hold off
%}

timeseries=[1:1:length(indata)]';
headingjson = [indata(:,index) a(:,index) timeseries];
savejson('heading',headingjson,'heading.json');


