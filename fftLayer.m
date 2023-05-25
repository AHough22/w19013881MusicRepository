
classdef fftLayer < nnet.layer.Layer
    properties
        TimeRange
        TimeScale
        Window
    end
    methods
        function layer = fftLayer(name, timeRange, timeScale, window)
            layer.Name = name;
            layer.TimeRange = timeRange;
            layer.TimeScale = timeScale;
            layer.Window = window;
        end
        function Z = predict(layer, X)
            
            Y = fft(X);
            Z = cat(2,real(Y),imag(Y));
        end
        function dLdX = backward(layer, X, Z, dLdZ, ~) 

            %The derivative below is the spectral derivative, taken from the reference at the bottom (Brunton S.L., 2019):
            fhat = fft( Z(:,1,:,:)+(Z(:,2,:,:)*1i) );
            kappa = (2*pi/layer.Window)*(-(layer.TimeRange-1)/2:(layer.TimeRange-1)/2);
            kappa = fftshift(kappa);
            dfhat = 1i*kappa*fhat;
            dZdX = ifft(dfhat);
            dLdX = real(dZdX.*(dLdZ(:,1,:,:)+dLdZ(:,2,:,:).*1i));
            
            
            %Brunton, S.L. and Kutz, J.N. (2019) Data-Driven Science and Engineering: Machine Learning, Dynamical Systems, and Control. 
            %Available at: http://dx.doi.org/10.1017/9781108380690 [Accessed at: 2 May 2023].

        end
    end
end