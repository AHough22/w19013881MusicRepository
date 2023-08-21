classdef fftLayer < nnet.layer.Layer
    properties
        TimeRange
        TimeScale
        Window
        Freqs
    end
    methods
        function layer = fftLayer(name, timeRange, timeScale, window)
            layer.Name = name;
            layer.TimeRange = timeRange;
            layer.TimeScale = timeScale;
            layer.Window = window;
            %frequency bins
            layer.Freqs = (1:(layer.TimeRange-1)/2)'; %real fft bins without DC component
            layer.Freqs = layer.Freqs.*((layer.TimeRange*layer.TimeScale)/layer.Window);
        end
        function Z = predict(layer, X)
            %Calculate one-sided power spectrum
            %one-sided real fft magnitudes without DC component
            X = real(X);
            xfft = fft(X,layer.TimeRange,1);
            xfft = xfft(2:(layer.TimeRange+1)/2,:,:);
            magnitudes = abs(xfft);
            powerSpectrum = magnitudes.^2; %Removes dc component
            %disp(powerSpectrum);
            %Frequency
            F = ( sum((layer.Freqs.*powerSpectrum),1)./sum(powerSpectrum,1) ) ...
                ./(layer.TimeScale);
            %Amplitude
            A = 2.*sqrt(sum(powerSpectrum,1)./layer.TimeRange);
            %Offset
            B = xfft(1,:,:,:); %DC component
            Z = cat(1,F,A,B);

        end
    end
end