%% set parameters
clear;clc;
source_dir = 'Extradata_20161009_1307';
dest_dir = 'F:\Augustinus\Documents\MATLAB\cleandata\';
source_files = dir(fullfile(source_dir, '*.xls'));
i=1;
opts = detectImportOptions(fullfile(source_files(i).folder,source_files(i).name));
opts.SelectedVariableNames = {'BOROUGH','NEIGHBORHOOD', ...
    'BUILDINGCLASSCATEGORY', 'ADDRESS' , 'ZIPCODE', 'LANDSQUAREFEET', ...
    'YEARBUILT'	, 'TAXCLASSATTIMEOFSALE' ,	 'BUILDINGCLASSATTIMEOFSALE' ,...
    'SALEPRICE','SALEDATE'};
opts=setvaropts(opts,'SALEPRICE','TreatAsMissing','0');
opts.MissingRule='omitrow';
opts.ImportErrorRule='omitrow';
opts=setvartype(opts,{'BOROUGH', 'ADDRESS' ,...
    'ZIPCODE','YEARBUILT' 	},{'uint8','char','uint16','uint16'});

filter={'01  ONE FAMILY DWELLINGS','02  TWO FAMILY DWELLINGS',...
    '03  THREE FAMILY DWELLINGS','01  ONE FAMILY HOMES','02  TWO FAMILY HOMES',...
    '03  THREE FAMILY HOMES',    '04  TAX CLASS 1 CONDOS','07  RENTALS - WALKUP APARTMENTS',...
    '08  RENTALS - ELEVATOR APARTMENTS', '09  COOPS - WALKUP APARTMENTS', ...
    '10  COOPS - ELEVATOR APARTMENTS',  '11A CONDO-RENTALS',...
    '12  CONDOS - WALKUP APARTMENTS',   '13  CONDOS - ELEVATOR APARTMENTS',...
    '28  COMMERCIAL CONDOS'};
disp('parameters set')
%% clean data1 for data before 2012
data={};ind={};
tic
parfor i = 1:45
    data{i}= readtable(fullfile(source_dir, source_files(i).name),opts);
    %remove 0 sale price, 0 land square feet
    data{i}=rmmissing(...
        standardizeMissing(data{i},0,'DataVariables',{'SALEPRICE','LANDSQUAREFEET'})...
        );
    % keep only 9 types of apartments that we are interested in
    ind{i}=~ismember(data{i}.BUILDINGCLASSCATEGORY,filter);
end
toc
save sales_data_temp
disp('clean data1 finished')
%% clean data for data after 2012
%
opts.VariableNamesRange='A5';
opts.DataRange='A6';
parfor i = 46:length(source_files)
    data{i}= readtable(fullfile(source_dir, source_files(i).name),opts);
    %remove 0 sale price, 0 land square feet
    data{i}=rmmissing(...
        standardizeMissing(data{i},0,'DataVariables',{'SALEPRICE','LANDSQUAREFEET'})...
        );
    % keep only 9 types of apartments that we are interested in
    ind{i}=~ismember(data{i}.BUILDINGCLASSCATEGORY,filter);
    %  keep name consistency
    inconsistentnames=strcat({'01  ONE','02  TWO','03  THREE'},' FAMILY DWELLINGS');
    consistentnames=strcat({'01  ONE','02  TWO','03  THREE'},' FAMILY HOMES');
    [~,Locb] = ismember(...
        data{i}.BUILDINGCLASSCATEGORY,...
        inconsistentnames...
        );
    for hometype=[1,2,3]
        data{i}.BUILDINGCLASSCATEGORY(Locb==hometype)=consistentnames(hometype);
    end
end
toc
save sales_data_temp
disp('clean data2 finished')
%% clear and combine
for i=1:length(source_files)
    data{i}(ind{i},:)=[];
end
cleandata=vertcat(data{:});
cleandata(cleandata.SALEPRICE<1000,:)=[];
save sales_data_temp
toc
disp('cleandata finished')
%% ouput files
cleandata.SALEDATE.Format='defaultdate';
writetable(cleandata,[dest_dir,'cleandata.xlsx'])
disp('cleandata in ouput directory')


