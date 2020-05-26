classdef lorentz < abstract_dynamics
    %LORENTZ Summary of this class goes here
    %   Detailed explanation goes here

    %=== PUBLIC ===%
    methods

        function obj = lorentz(varargin)
            %LORENTZ Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@abstract_dynamics(varargin{:});

            if ~isfield(obj.params_, 'sigma'); obj.params_.space = 10; end
            if ~isfield(obj.params_, 'rho'); obj.params_.space = 28; end
            if ~isfield(obj.params_, 'beta'); obj.params_.space = 8/3; end
        end

    end

    %=== PROTECTED ===%
    properties (Access = protected)

    end

    methods (Access = protected)
        signature(obj)
        f = calc_field(obj, x)
    end

end
