files = dir('V2');

% (timeRange x i x Channel) | Data Import and Preprocessing Step
% pseudoCode, runs model on a single wav file:
songs = 5;
inputSongCell = cell(1,songs);
for i = 1:songs
dataCell = cell(1, inputChannels);
for j = 1:inputChannels
    dataCell{j} = audioread('V2/Allegria_MendelssohnMovement1/Allegria_MendelssohnMovement1_MIX.wav');
    dataCell{j} = buffer(dataCell{j},timeRange,(timeRange-1)/2);
end
inputSongCell{i} = cat(3,dataCell);
end
inputData = cat(2,inputSongCell);
inputCell = cell(1,size(inputData,2));
for i = 1:size(inputData,2)
    inputCell{i} = squeeze(inputData(:,i,:));
end