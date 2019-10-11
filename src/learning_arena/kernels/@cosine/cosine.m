classdef cosine < abstract_kernel
    %COSINE Summary of this class goes here
    %   Detailed explanation goes here

%=== PUBLIC ===%
    methods
        function obj = cosine(varargin)
            %COSINE Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@abstract_kernel(varargin{:});

            if ~isfield(obj.h_params_, 'scale'); obj.h_params_.scale = 1; end
            if ~isfield(obj.params_, 'isnan'); obj.params_.isnan = 1; end
        end
    end
  
%=== PROTECTED ===%
    methods (Access = protected)
        function signature(obj)
            obj.type_ = {'scalar_valued'};
            obj.h_params_list_ = ['scale', obj.h_params_list_];
            obj.params_list_ = ['isnan', obj.params_list_];
        end
        
        function d = num_params(obj, name)
            d = length(name);
        end
        
        function counter = set_pvec(obj, name, vec, counter)
            obj.set_params(name, vec(counter+1)); % name = 'scale'
            counter = counter + 1;
        end
        
        function [vec, counter] = pvec(obj, name, vec, counter)
           vec(counter+1) = obj.h_params_.(name); % name = 'scale'
           counter = counter + 1; 
        end

        function k = calc_kernel(obj)
            k = sum(obj.Data_{1}.*obj.Data_{2},2)./vecnorm(obj.Data_{1},2,2)./vecnorm(obj.Data_{2},2,2);
            k(isnan(k)) = obj.params_.isnan;
        end

        function dk = calc_gradient(obj, var)
            switch var
                case 1
                    dk = 0;
                case 2
                    dk = 0;    
                otherwise
                    error("First derivative not present");
            end
        end

        function d2k = calc_hessian(obj, var)
            switch var
                case 1
                    d2k = 0;    
                case 2
                    d2k = 0;
                case 3
                    d2k = 0;
                case 4
                    d2k = 0;
                otherwise
                    error("Second derivative not present");
            end
        end
        
        function dp = calc_pgradient(obj, var)
            switch var
                case 'scale'
                    dp = 0;
            end
        end
    end
end

