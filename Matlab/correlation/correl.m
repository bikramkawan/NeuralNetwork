
function correl()
addpath('../jsonlab');

datasetfilename=loadjson(['../datasetfilename.json']);

tmpdata=load(strcat('../',datasetfilename{1,1}));


indata=tmpdata(:,2:11);
[R,P] = corrcoef(indata);
%{
R(R==1)=[];
R = reshape(R,9,10);
R=R';

P(P==1)=[];
P = reshape(P,9,10);
P=P';
%}


field1 = 'R';
value1 = {R};
field2 = 'P';
value2 = {P};
corrdatajson = struct(field1,value1,field2,value2);
savejson('corrdata',corrdatajson,'corrdata.json');
