classdef linear_system < abstract_dynamics
    %LINEAR_SYSTEM Summary of this class goes here
    %   Detailed explanation goes here
 
%=== PUBLIC ===%
    methods
        function obj = linear_system(varargin)
            %LINEAR_SYSTEM Construct an instance of this class
            %   Detailed explanation goes here           
            obj = obj@abstract_dynamics(varargin{:});
            if ~isfield(obj.params_, 'friction'); obj.params_.space = 0; end
        end
    end
    
%=== PROTECTED ===%
    methods (Access = protected)
        signature(obj)
        f = calc_field(obj, x)
    end
end
