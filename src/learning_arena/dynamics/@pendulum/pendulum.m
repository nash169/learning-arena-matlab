classdef pendulum < abstract_dynamics
    %PENDULUM Summary of this class goes here
    %   Detailed explanation goes here
    
%=== PUBLIC ===%
    methods
        function obj = pendulum(varargin)
            %PENDULUM Construct an instance of this class
            %   Detailed explanation goes here           
            obj = obj@abstract_dynamics(varargin{:});
            
        end
    end
    
%=== PROTECTED ===%
    properties (Access = protected)
            g_ = 9.81
    end
    
    methods (Access = protected)
        signature(obj)
        f = calc_field(obj, x)
    end
end

