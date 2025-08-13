%Get a record a main Hausgerten parameters 
function HGP = HG_GetParams(JobID)
arguments
    JobID = ''
end

%% Data 
%Raw data
HGP.Data.Path2RawData = '..\data\LTER Hausgarten\';
%processed data
HGP.Data.Path2ProcData = '..\data\LTER Hausgarten\proc\';

if ismember(JobID, {'StationsSpeciesJaccard2023', 'StationsGeneraJaccard2023',  'StationsGeneraJaccard2023NoMetazoa'})
    %use new dataset of samples 
    HGP.Data.fnSamplesRaw = '..\data\eDNA\current_version\Analyse_Hausgarten_2009_2023_merged_FastQ_Names.csv';
    HGP.Data.fnSamplesProc = [HGP.Data.Path2ProcData 'HGSamples2023.mat'];
    HGP.Data.fnSamplMetaDataProc = [HGP.Data.Path2ProcData 'SampleDescription2023.xls'];
else
    HGP.Data.fnSamplesRaw = [HGP.Data.Path2RawData 'Version3_Analyse_Hausgarten_2009_2021_working_table.csv'];
    HGP.Data.fnSamplesProc = [HGP.Data.Path2ProcData 'HGSamples.mat'];
    HGP.Data.fnSamplMetaDataProc = [HGP.Data.Path2ProcData 'SampleDescription.xls'];
end
%additional raw data
HGP.Data.Path2AddData = '..\data\LTER Hausgarten\additional_data\';


%calculated and saved for further use
HGP.Data.Path2CalcData = '..\data\LTER Hausgarten\calculated\';
HGP.Data.Path2DMs = '..\data\LTER Hausgarten\calculated\dm\'; %diffusion maps

HGP.Data.fnMetadata = [HGP.Data.Path2RawData 'HG_metadata.xlsx'];
HGP.Data.fnStatCoors = [HGP.Data.Path2ProcData 'Stations_coorsd.xlsx'];

%Pangaea data
HGP.Data.Path2RawPangaea = '..\data\Pangaea\main\';
HGP.Data.Path2RawPangaeaChl = '..\data\Pangaea\main\selected_data_collection\data_selected_Chlorophyll\main_data\';
HGP.Data.Path2RawPangaeaCTD = '..\data\Pangaea\main\selected_data_collection\data_selected_CTD\main_data\';
HGP.Data.Path2RawPangaeaNutr = '..\data\Pangaea\main\selected_data_collection\data_selected_nutrients\main_data\';
HGP.Data.fnPangaeaChl = 'main_Chlorophyll.csv';
HGP.Data.fnPangaeaCTD = 'main_CTD.csv';
HGP.Data.fnPangaeaNutr = 'main_nutrients.csv';

%Environmental data (from Merle and Lennard)
%Ice data 
HGP.Data.Path2IceRaw = '..\data\HG_environmental_parameters\seaice\processed_data\meereisportal\';
HGP.Data.Path2IceAggregated = '..\data\HG_environmental_parameters\seaice\aggregated_data\';
HGP.Data.fnIceMonthlyLotLat = [HGP.Data.Path2IceAggregated 'Ice_Hausgarten_Month_Lat_Lon.csv'];


%set params specific fo JobID
HGP.JobID = JobID;
switch JobID
    case {'StationsSpeciesJaccard', 'StationsSpeciesJaccard2023'}  % dm of stations group by genera and use Jaccard as similarity measure 
        HGP.dm.dataGroupBy = 'dataSpecies';
        HGP.dm.Objects = 'Stations';  %dm if stations or species
        HGP.dm.SimilarityMetric = 'jaccard';
        %group name to the final grouping of the data 
        HGP.topGroupName = 'Species';
    case 'StationsSpeciesJaccardNoMetazoa' %the same as StationsSpeciesJaccard but excluding all Metazoa species StationsSpeciesJaccard'}  % dm of stations group by genera and use Jaccard as similarity measure 
        HGP.dm.dataGroupBy = 'dataSpeciesNoMetazoa';
        HGP.dm.Objects = 'Stations';  %dm if stations or species
        HGP.dm.SimilarityMetric = 'jaccard';
        %group name to the final grouping of the data 
        HGP.topGroupName = 'Species';
    case'StationsSpecies1quote'   %dm of stations group by genera and use euclidean dist between abundance^0.25 as similarity measure 
        HGP.dm.dataGroupBy = 'dataSpecies';
        HGP.dm.Objects = 'Stations';  %dm if stations or species
        HGP.dm.SimilarityMetric = 'euclidean1quote'; %euclidean distance between abudan^0.25
        HGP.topGroupName = 'Species';
    case {'StationsGeneraJaccard', 'StationsGeneraJaccard2023', 'StationsGeneraJaccard2023NoMetazoa'}  % dm of stations group by genera and use Jaccard as similarity measure 
        if strcmp(JobID, 'StationsGeneraJaccard2023NoMetazoa')
            HGP.dm.dataGroupBy = 'dataGeneraNoMetazoa';
        else
            HGP.dm.dataGroupBy = 'dataGenera';
        end
        HGP.dm.Objects = 'Stations';  %dm if stations or species
        HGP.dm.SimilarityMetric = 'jaccard';

        %group name to the final grouping of the data 
        HGP.topGroupName = 'Genus';
        %HGP.topGroupName = 'Family';
        %HGP.topGroupName = 'Order';
        %HGP.topGroupName = 'Class';
        %HGP.topGroupName = 'Phylum';
    case 'StationsGeneraPairwiseComp'
        HGP.dm.dataGroupBy = 'dataGenera';
        HGP.dm.Objects = 'Stations';  %dm if stations or species
        HGP.dm.SimilarityMetric = 'pairwisediff';
        %group name to the final grouping of the data 
        HGP.topGroupName = 'Genus';
   % otherwise
   %     error('JobID %s not found', JobID);

end
