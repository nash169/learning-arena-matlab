classdef vanderpol_oscillator < abstract_dynamics
    %LINEAR_SYSTEM Summary of this class goes here
    %   Detailed explanation goes here

    %=== PUBLIC ===%
    methods

        function obj = vanderpol_oscillator(varargin)
            %LINEAR_SYSTEM Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@abstract_dynamics(varargin{:});
            if ~isfield(obj.params_, 'attractor'); obj.params_.attractor = 0; end
        end

        f = calc_field(obj, x)
    end

    %=== PROTECTED ===%
    methods (Access = protected)
        signature(obj)
    end

end
