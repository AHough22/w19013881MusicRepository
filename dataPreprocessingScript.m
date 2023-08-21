% (timeRange x i x Channel) | Data Import and Preprocessing Step
% pseudoCode, runs model on a single wav file:
timeRange = 88201;
inputChannels = 7;

dataSet = audioDatastore('MatlabDataset/','FileExtensions','.wav','IncludeSubfolders',true,'LabelSource','foldernames');
labels = unique(dataSet.Labels);
numberOfSongs = length(labels);
instrumentCell = cell(1,inputChannels);
mkdir('preprocessedMatlabDataset');

for i = 1:numberOfSongs    

        songData = dataSet.Files(dataSet.Labels == labels(i));
        songName = string(labels(i)); 
        songInstruments = extractBetween(songData,append(songName,"_"),".wav");

        instrumentList = {'AcousticGuitar','CleanElectricGuitar','Drumset', ...
                             'DistortedElectricGuitar','ElectricBass','Piano','Vocals'};
        newInstrumentData = {};

        Lia = ismember(instrumentList, songInstruments);
        for j = 1:length(instrumentList)
            if Lia(j)==false
                instrumentName = instrumentList{j};
                newInstrument = append(pwd,'/MatlabDataset/',songName,'/',songName,'_',instrumentName,'.wav');
                %pwd,'/MatlabDataset/',songName,'/',songName,'_',instrumentName,'.wav'
                audiowrite(newInstrument,0,44100);
                newInstrumentData = cat(1,newInstrumentData, newInstrument);
            end 
        end
        %disp(newInstrumentData);
        newSongData = cat(1,songData, newInstrumentData);
        sort(newSongData)
        disp(newSongData)
        for k = 1:length(newSongData) % for each instrument read the audio, buffer it, turn into column vector
            instrumentCell{k} = audioread(newSongData{k});
            instrumentCell{k} = buffer(instrumentCell{k},timeRange,(timeRange-1)/2); %96001 * partitions
            instrumentCell{k} = instrumentCell{k}(:);
        end 
        trackLength = max(cellfun(@numel,instrumentCell));
        newInstrumentCell = cellfun(@(x) [x; zeros(trackLength - numel(x),1)], instrumentCell, 'un',0);
        save(append(pwd,'/preprocessedMatlabDataset/', songName, '.mat'),"newInstrumentCell","-v7.3");

        %for l = 1:size(inputData,2)
        %inputCell{l} = squeeze(inputData(:,i,:));
        %end
end