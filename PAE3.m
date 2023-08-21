
dataPreprocessingScript
%% 
datastoreScript
%%

%Variables
timeRange = 88201;
keyRange = 13;
timeScale = keyRange/timeRange;
window = 2;
inputChannels = 7;
intermediateChannels = 6;
embeddingChannels = 5;

%initialise architecture

inputLayer = sequenceInputLayer([timeRange inputChannels],'Name','inputLayer');

convolutionalEncoder = [
    convolution1dLayer(timeRange,intermediateChannels,'Padding',(timeRange-1)/2,'Name','convolutionalEncoderInput')
    batchNormalizationLayer
    tanhLayer
    convolution1dLayer(timeRange,embeddingChannels,'Padding',(timeRange-1)/2)
    batchNormalizationLayer
    tanhLayer('Name','convolutionalEncoderOutput')
];

phaseChannelCell = cell(1,embeddingChannels);
fullyConnectedCell = cell(1, embeddingChannels);
fftLayerCell = cell(1,embeddingChannels);
phaseEmbeddingLayerCell = cell(1, embeddingChannels);
concatLayerCell = cell(1, embeddingChannels);

for i = 1:embeddingChannels
    phaseChannelCell{i} = [
        functionLayer(@(X) X(:,i,:),'Name',['phaseChannelFilter',num2str(i)])
        ];
    fullyConnectedCell{i} = [
        functionLayer(@(X) dlarray(X((timeRange+1)/2),'SCB'),'Name',['centralFrameSelector',num2str(i)],Formattable=true)
        fullyConnectedLayer(2,'Name',['fullyConnected',num2str(i)])
        batchNormalizationLayer('Name',['fcBatchNorm',num2str(i)])
        atan2Layer(['atan2Layer',num2str(i)])
        ];

    fftLayerCell{i} = [
                      fftLayer(['fftLayer',num2str(i)],timeRange,timeScale,window)
                      ];
    phaseEmbeddingLayerCell{i} = [  phaseEmbeddingLayer(['phaseEmbedding',num2str(i)],timeRange,timeScale,window);  
        ];
end

convolutionalDecoder = [
    concatenationLayer(2,embeddingChannels,'Name','convolutionalDecoderInput')
    convolution1dLayer(timeRange,intermediateChannels,'Padding',(timeRange-1)/2)
    batchNormalizationLayer
    tanhLayer
    convolution1dLayer(timeRange,inputChannels,'Padding',(timeRange-1)/2,'Name','convolutionalDecoderOutput')
];

outputLayer = regressionLayer('Name','outputLayer');



%Add Layers
lgraph = layerGraph;
lgraph = addLayers(lgraph, inputLayer);
lgraph = addLayers(lgraph, convolutionalEncoder);
for i = 1:embeddingChannels
    lgraph = addLayers(lgraph, phaseChannelCell{i});
    lgraph = addLayers(lgraph, fullyConnectedCell{i});
    lgraph = addLayers(lgraph, fftLayerCell{i});
    lgraph = addLayers(lgraph, phaseEmbeddingLayerCell{i});
end
lgraph = addLayers(lgraph, convolutionalDecoder);
lgraph = addLayers(lgraph,outputLayer);



%Connect Layers
lgraph = connectLayers(lgraph,'inputLayer','convolutionalEncoderInput');
for i = 1:embeddingChannels
    lgraph = connectLayers(lgraph, 'convolutionalEncoderOutput',['phaseChannelFilter',num2str(i)]);  
    lgraph = connectLayers(lgraph, ['phaseChannelFilter',num2str(i)],['centralFrameSelector',num2str(i)]);
    lgraph = connectLayers(lgraph, ['phaseChannelFilter',num2str(i)],['fftLayer',num2str(i)]);
    lgraph = connectLayers(lgraph, ['atan2Layer',num2str(i)],['phaseEmbedding',num2str(i),'/in1']);
    lgraph = connectLayers(lgraph, ['fftLayer',num2str(i)],['phaseEmbedding',num2str(i),'/in2']);
    lgraph = connectLayers(lgraph, ['phaseEmbedding',num2str(i)],['convolutionalDecoderInput/in',num2str(i)]);
end
lgraph = connectLayers(lgraph,'convolutionalDecoderOutput','outputLayer');

%train network
options = trainingOptions('adam', ...
                          'InitialLearnRate',1e-4, ...
                          'MaxEpochs',30, ...
                          'MiniBatchSize', 1, ...
                          'L2Regularization',1e-4, ...
                          'Verbose', false, ...
                          'Plots','training-progress', ...
                          'ExecutionEnvironment', 'auto' );
%% 


%Plot model structure
figure
analyzeNetwork(lgraph);
%%

net = trainNetwork(sds, lgraph, options);