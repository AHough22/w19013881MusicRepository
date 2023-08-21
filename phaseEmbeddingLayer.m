classdef phaseEmbeddingLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
        TimeRange
        TimeScale
        Window
        Args
        Freqs
    end
    methods
        function layer = phaseEmbeddingLayer(name, timeRange, timeScale, window)
            layer.Name = name; 
            layer.TimeRange = timeRange;
            layer.TimeScale = timeScale;
            layer.Window = window;
            %args array
            layer.Args = linspace(-layer.Window/2,layer.Window/2,layer.TimeRange)';
            layer.InputNames = {'in1','in2'};
        end
        function Z = predict(layer,X1,X2)
             
            S = X1(1,:,:,:); %Phase Shift
            F = X2(1,:,:,:); %Frequency
            A = X2(2,:,:,:); %Amplitude
            B = X2(3,:,:,:); %Offset    

            phaseEmbedding = (A.*sin(2.*pi.*((F.*layer.Args)+S)))+B;
            %'SCBTU'
            Z = phaseEmbedding.*layer.Args;

        end
    end
end