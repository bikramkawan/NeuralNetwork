function corrtest()
tmpdata= load('vessel_status_old.txt');
datain= tmpdata(11:200,2:11);

[R,P] = corrcoef(datain);

savejson(' ',R(1:2,:),'savdebnn.json');
dat=loadjson(['' filesep 'savdebnn.json'])