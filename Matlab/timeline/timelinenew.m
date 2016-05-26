
function timelinenew()
clear;
addpath('../jsonlab'); %JSON Library
%%Load Data

datasetfilename=loadjson(['../datasetfilename.json']);

data=load(strcat('../',datasetfilename{1,1}));

data=data(:,2:11);          % Complete Shrinked Data

datajson=loadjson(['' filesep 'filtertimelinejson.json']);
filterdatafromuser = [str2num(datajson{1,1}.Surge);...
                      str2num(datajson{1,1}.Sway);...
                      str2num(datajson{1,1}.Yaw);...
                      str2num(datajson{1,1}.Rollvelocity);...
                      str2num(datajson{1,1}.Pitchvelocity);...
                      str2num(datajson{1,1}.Positioneast);...
                      str2num(datajson{1,1}.Positionnorth);...
                      str2num(datajson{1,1}.Heading);...
                      str2num(datajson{1,1}.Roll);...
                      str2num(datajson{1,1}.Pitch)...
                      
];

id= (  data(:,1) >=  filterdatafromuser(1,1) & data(:,1) <= filterdatafromuser(1,2)        & ...
        data(:,2) >= filterdatafromuser(2,1) & data(:,2) <= filterdatafromuser(2,2)        & ...
        data(:,3) >= filterdatafromuser(3,1) & data(:,3) <= filterdatafromuser(3,2)        & ...
        data(:,4) >= filterdatafromuser(4,1) & data(:,4) <= filterdatafromuser(4,2)        & ...
        data(:,5) >= filterdatafromuser(5,1) & data(:,5) <= filterdatafromuser(5,2)        & ...
        data(:,6) >= filterdatafromuser(6,1) & data(:,6) <= filterdatafromuser(6,2)        & ...
        data(:,7) >= filterdatafromuser(7,1) & data(:,7) <= filterdatafromuser(7,2)        & ...
        data(:,8) >= filterdatafromuser(8,1) & data(:,8) <= filterdatafromuser(8,2)        & ...
        data(:,9) >= filterdatafromuser(9,1) & data(:,9) <= filterdatafromuser(9,2)        & ...
        data(:,10)>= filterdatafromuser(10,1) & data(:,10) <= filterdatafromuser(10,2)    ...
      ) ;  


  

index=find(id);


threshold = 1;
id = 1;

result = [];

state = 1;

diff_index = diff(index);

for i= 1:length(diff_index)
    if state == 1
        result(id,1) = index(i);
        state = 2;
    end
    
    if state == 2
        if diff_index(i) > threshold
            result(id,2) = index(i);
            
            state = 1;
            id = id + 1;
        end
        
        
        
    end

    
end

result(id,2) = index(end);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t_start = datetime(2013,11,1,8,0,0);
t_end = datetime(2013,11,5,8,0,0);

t = t_start:seconds(0.5):t_end;
t=t';
t=t(1:length(data));
timeresult=[];
datarangeforneural=[];

if(length(result)> 2)

for j=1:length(result)
    
    timeresult=[timeresult;t(result(j,1)) t(result(j,2))];
    datarangeforneural=[datarangeforneural;data(result(j,1),:) data(result(j,2),:)];
 

end
itemnumber= [1:1:length(result)];
end

if(length(result)<= 2)
    
   timeresult=[t(1) t(end)];
   itemnumber= [1:1:1];
 
end

field1 = 'id';
value1 = {itemnumber};
field2 = 'content';
value2 = {itemnumber};
field3 = 'start';
value3 = {datestr(timeresult(:,1))};
field4 = 'end';
value4 = {datestr(timeresult(:,2))};


jsondata = struct(field1,value1,field2,value2,field3,value3,field4,value4);
savejson('timelinejsondata',jsondata,'timelinejsondata.json');


%Result JSON for Neural Network Data selection

field5 ='indexresult';
value5={result};

resultjson = struct(field5,value5);
savejson('resultjson',resultjson,'../neuralnetmodel/resultjson.json');

