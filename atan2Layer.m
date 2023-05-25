
classdef atan2Layer < nnet.layer.Layer

    methods
        function layer = atan2Layer(name)
            layer.Name = name; 
        end
        function Z = predict(layer, X)
            a = X(:,1,:);
            b = X(:,2,:);

            if (a>0)
              C = atan(b/a);
            elseif (a<0 && b>=0)
              C = atan(b/a)+pi;
            elseif (a<0 && b<0)
              C = atan(b/a)-pi;
            elseif (a==0 && b>0)
              C = 0.5*pi;
            elseif (a==0 && b<0)
              C = -0.5*pi;
            else
             C = (sign(b)*0.5*pi);
            end

            Z = C/(2*pi);
        end
       
    end
end