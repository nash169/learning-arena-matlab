classdef velocity_oriented < rbf
    %VELOCITY_ORIENTED Summary of this class goes here
    %   Detailed explanation goes here
    
%=== PUBLIC ===%
    methods
        function obj = velocity_oriented(varargin)
            %VELOCITY_ORIENTED Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@rbf(varargin{:});

            if ~isfield(obj.h_params_, 'weights'); obj.h_params_.weights = [2.5,5]; end
            if ~isfield(obj.h_params_, 'weight_fun'); obj.h_params_.weight_fun = @obj.weighted_norm; end       
        end
        
        set_params(obj, varargin)
    end
    
%=== PROTECTED ===%
    methods (Access = protected)
        signature(obj)
        
        check(obj)
        
        velocity_sigma(obj)
    end
    
    methods (Access = protected, Static = true)
        V = weighted_norm(v, a, b)
    end
end

