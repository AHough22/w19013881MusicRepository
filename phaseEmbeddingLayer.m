
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
            %frequency bins
            layer.Freqs = (1:(layer.TimeRange-1)/2)'; %real fft bins without DC component
            layer.Freqs = layer.Freqs.*((layer.TimeRange*layer.TimeScale)/layer.Window);
            layer.InputNames = {'in1','in2'};
        end
        function Z = predict(layer,X1,X2)

            %for each minibatch:

                %Calculate one-sided power spectrum
                rfftValues = X2(2:(layer.TimeRange+1)/2,:,:,:); %one-sided real fft values without DC component
                complexValues = rfftValues(:,1,:,:)+rfftValues(:,2,:,:)*1i;
                magnitudes = abs(complexValues);
                powerSpectrum = magnitudes.^2;

                %Frequency
                F = ( sum((layer.Freqs.*powerSpectrum),1)./sum(powerSpectrum,1) ) ...
                ./(layer.TimeScale);
                %Amplitude
                A = 2.*sqrt(sum(powerSpectrum,1)./layer.TimeRange);
                %Offset
                B = X2(1,1,:,:)/layer.TimeRange; %DC component is only real so imaginary data type removed
                %PhaseShift
                S = X1(1,1,:,:);

                phaseEmbedding = (A.*sin(2.*pi.*((F.*layer.Args)+S)))+B;
            %'SCBTU'
            Z = phaseEmbedding;

        end

        %could not get derivative to work.
        %function [dLdX1, dLdX2] = backward(layer, X1, X2, Z, dLdZ, ~) 

            %c = X2(:,1,:,:) + X2(:,2,:,:)*1i;
            
            %dZdX1 = 160*sqrt(30)*pi*sqrt(1/layer.TimeRange).*sum(abs(c)).*cos(2*pi*( ((sum(layer.Args).*sum(layer.Freqs))/layer.TimeScale) + X1(1,1,:,:) ));
            %dZdX2 = 80*sqrt(30)*sqrt(1/layer.TimeRange).*sum(X2).*sin(2*pi*( ((sum(layer.Args).*sum(layer.Freqs))/layer.TimeScale) + X1(1,1,:,:) ))+1/layer.TimeRange;
            %sumdLdZ = sum(dLdZ);
            %dLdX1 = sum(dZdX1.*dLdZ);
            %dLdX2 = dZdX2.*dLdZ;
        %end
    end
end