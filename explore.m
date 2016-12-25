%% read data
clear;
inp_dir='D:\OneDrive - Columbia University\2016Fall\5. LINEAR REGRESSION MODELS\HW\Final Exam\';
filename=[inp_dir,'Test.csv'];
opts=detectImportOptions(filename);
test=readtable(filename,opts);
filename2=[inp_dir,'Training.csv'];
train=readtable(filename2,opts);
clear filename filename2 inp_dir
tb=[train;test];
tb.price_per_sqft=tb.price./tb.sqft_living;
%%
%[accumsum,counts,lon,lat]=hist3d(tb.long,tb.lat,tb.price_per_sqft,80);
%lon=lon(:);lat=lat(:);mean_price=accumsum./counts;mean_price=mean_price(:);
%%
tb=tb(:,{'long','lat','price_per_sqft'});
writetable(tb,'apt_price_geo.csv')